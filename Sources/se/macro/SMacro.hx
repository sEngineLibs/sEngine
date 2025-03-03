package se.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;

@:dox(hide)
class SMacro {
	static var cls:ClassBuilder;
	static var signals:Map<Member, Array<Expr>>;

	macro public static function build():Array<Field> {
		return ClassBuilder.run([buildClass]);
	}

	static public function buildClass(cls:ClassBuilder) {
		SMacro.cls = cls;
		signals = [];

		for (member in cls.iterator()) {
			switch member.extractMeta(":signal") {
				case Success(meta):
					if (!signals.exists(member))
						signals[member] = [];
				default:
					null;
			}

			switch member.extractMeta(":slot") {
				case Success(meta):
					if (meta.params.length == 0)
						Context.warning('Slot must have signal list', meta.pos);

					for (param in meta.params) {
						switch param.getIdent() {
							case Success(data):
								switch cls.memberByName(data) {
									case Success(signal):
										if (signals.exists(signal)) {
											signals[signal].push(member.name.resolve());
										} else if (signal.hasMeta(":signal")) {
											signals[signal] = [member.name.resolve()];
										} else {
											Context.warning('$data is not a signal', param.pos);
										}
									case Failure(failure):
										Context.warning('Can\'t find signal $data', param.pos);
								}
							case Failure(failure):
								Context.warning(failure.message, param.pos);
						}
					}
				default:
					null;
			}

			switch member.extractMeta(":track") {
				case Success(meta):
					buildTrack(member);
				default:
					null;
			}
		}

		var constructor = cls.getConstructor();

		for (signal in signals.keys()) {
			buildSignal(signal);

			// connect slots to the signal
			var signalRef = signal.name.resolve();
			for (slot in signals[signal] ?? [])
				constructor.addStatement(macro $signalRef.connect($slot));
		}
	}

	static function buildSignal(member:Member):Void {
		switch (member.kind) {
			case FFun(f):
				// define abstract methods
				var emit = Member.method("emit", {
					args: f.args,
					ret: macro :Void,
					expr: macro {
						for (slot in this)
							slot(${
								for (arg in f.args)
									macro $i{arg.name}
							});
					}
				}).addMeta(":op", [macro a()]);
				emit.isBound = true;

				var connect = Member.method("connect", {
					args: [{name: "slot"}],
					ret: macro :Void,
					expr: macro this.push(slot)
				});
				connect.isBound = true;

				var disconnect = Member.method("disconnect", {
					args: [{name: "slot"}],
					ret: macro :Void,
					expr: macro this.remove(slot)
				});
				disconnect.isBound = true;

				// define underlying type
				var _t = ComplexType.TFunction([
					for (arg in f.args) {
						var t = TNamed(arg.name, arg.type);
						if (arg.opt) TOptional(t); else t;
					}
				], f.ret ?? macro :Void);
				var t = macro :Array<$_t>;

				// define abstract
				var signalName = '${cls.target.name}_${member.name}_Signal';
				var params = [
					for (param in cls.target.params)
						{
							name: param.name,
							defaultType: param.defaultType?.toComplex()
						}
				];
				Context.defineType({
					params: [
						for (param in cls.target.params)
							{
								name: param.name,
								defaultType: param.defaultType?.toComplex()
							}
					],
					pack: cls.target.pack,
					meta: [
						{
							name: ":forward.new",
							pos: Context.currentPos()
						}
					],
					name: signalName,
					isExtern: true,
					kind: TDAbstract(t, [AbFrom(t), AbTo(t)]),
					fields: [emit, connect, disconnect],
					pos: Context.currentPos()
				});

				member.meta = [];
				member.kind = FVar(TPath({
					pack: cls.target.pack,
					name: signalName,
					params: [
						for (param in cls.target.params)
							TPType(param.t.toComplex())
					]
				}), macro []);

				// add connector
				var connector = Member.method('on${member.name.charAt(0).toUpperCase() + member.name.substr(1)}', {
					args: [{name: "slot"}],
					expr: macro $i{member.name}.connect(slot)
				});
				connector.isBound = true;
				cls.addMember(connector);
			default:
				Context.error("Signal must be a function, not " + member, member.pos);
		}
	}

	static function buildTrack(member:Member):Void {
		switch (member.kind) {
			case FVar(t, e):
				member.meta = [
					{
						name: ":isVar",
						pos: Context.currentPos()
					}
				];
				member.kind = FProp('default', 'set', t, e);

				// generate signal
				var signal = Member.method('${member.name}Changed', Context.currentPos(), member.isPublic, {
					args: [{name: member.name, type: t}],
					expr: macro {}
				});
				cls.addMember(signal);

				if (!signals.exists(signal))
					signals[signal] = [];

				// generate setter
				var fieldRef = member.name.resolve();
				var setter = Member.method('set_${member.name}', false, {
					args: [{name: "value", type: t}],
					expr: macro {
						$fieldRef = value;
						${signal.name.resolve()}($fieldRef);
						trace($fieldRef);
						return $fieldRef;
					}
				});
				setter.asField().access = [AExtern, APrivate, AInline];
				cls.addMember(setter);
			case FProp(get, set, t, e):
				switch (set) {
					case "never", "dynamic":
						Context.error('Can\'t track a property with no write access.', member.pos);

					case "default":
						member.kind = FProp(get, "set", t, e);

						// generate signal
						var signal = Member.method('${member.name}Changed', member.isPublic, {
							args: [{name: member.name, type: t}]
						});
						cls.addMember(signal);

						if (!signals.exists(signal))
							signals[signal] = [];

						// generate setter
						var fieldRef = member.name.resolve();
						var setter = Member.method('set_${member.name}', false, {
							args: [{name: "value", type: t}],
							expr: macro {
								$fieldRef = value;
								${signal.name.resolve()}($fieldRef);
								return $fieldRef;
							},
						});
						setter.asField().access = [AExtern, APrivate, AInline];
						cls.addMember(setter);

					case "set", "null":
						switch cls.memberByName('set_${member.name}') {
							case Success(setter):
								// generate signal
								var signal:Field = {
									name: '${member.name}Changed',
									access: member.isPublic ? [APublic, AInline] : [AInline],
									kind: FFun({
										args: [{name: member.name, type: t}]
									}),
									pos: Context.currentPos()
								}
								switch (setter.kind) {
									case FFun(f):
										f.expr = injectCall(f.expr, signal.name.resolve());
									default: Context.error("Setter must be function", setter.pos);
								}

								cls.addMember(signal);
								if (!signals.exists(signal)) {
									signals[signal] = [];
								}

							case Failure(failure):
								Context.error("Can't find setter: " + 'set_${member.name}', member.pos);
						}
				}
			case FFun(f):
				if (f.ret == null)
					Context.error("Function return must be type-hinted", member.pos);
				else {
					// generate signal
					var signal:Field = {
						name: '${member.name}Called',
						access: member.isPublic ? [APublic, AInline] : [AInline],
						kind: FFun({
							args: switch (f.ret) {
								case TPath(p):
									p.name == "Void" ? [] : [{name: "result", type: f.ret}];
								default: [{name: "result", type: f.ret}];
							}
						}),
						pos: Context.currentPos()
					}
					f.expr = injectCall(f.expr, signal.name.resolve());

					cls.addMember(signal);
					if (!signals.exists(signal))
						signals[signal] = [];
				}
			default:
				null;
		}
	}

	static function injectCall(f:Expr, call:Expr):Expr {
		function inject(f:Expr, call:Expr):Expr {
			function replace(e:Expr):Expr {
				if (e != null)
					return switch (e.expr) {
						case EReturn(eValue):
							if (eValue != null) {
								macro {
									final result = $eValue;
									$call(result);
									return result;
								}
							} else {
								macro {
									$call();
									return;
								}
							}
						case EIf(econd, ethen, eelse):
							macro {
								if ($econd)
									${replace(ethen)};
								else
									${replace(eelse)};
							}
						default:
							e.map(replace);
					}
				else
					return e;
			}

			return replace(f);
		}

		if (f.has((e) -> switch (e.expr) {
			case EReturn(e): true;
			default: false;
		}))
			return inject(f, call);

		return macro {
			$f;
			$call();
		};
	}
}
#end
