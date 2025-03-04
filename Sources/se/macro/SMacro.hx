package se.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using se.extensions.StringExt;

@:dox(hide)
class SMacro extends Builder {
	macro public static function build():Array<Field> {
		return new SMacro().export();
	}

	function run() {
		for (field in fields)
			for (meta in field.meta ?? [])
				switch (meta.name) {
					case ":signal":
						buildSignal(field);
					case ":track":
						buildTrack(field);
				}
	}

	function buildSignal(field:Field):Void {
		switch (field.kind) {
			case FFun(f):
				for (arg in f.args)
					arg.type = resolve(arg.type ?? expected());
				f.ret = resolve(f.ret ?? expected());

				// define underlying type
				var _t = ComplexType.TFunction([
					for (arg in f.args) {
						var t = TNamed(arg.name, arg.type);
						if (arg.opt) TOptional(t) else t;
					}
				], f.ret ?? macro :Void);
				var t = macro :Array<$_t>;
				var typeName = '${cls.name}_${field.name}_Signal';

				Context.defineType({
					params: cls.params.map(p -> {
						name: p.name,
						defaultType: p.defaultType != null ? toComplex(p.defaultType) : null,
						constraints: null,
						params: null,
						meta: null
					}),
					pack: cls.pack,
					meta: [meta(":forward.new"), meta(":dox", [macro hide])],
					name: typeName,
					isExtern: true,
					kind: TDAbstract(t, [AbFrom(t), AbTo(t)]),
					fields: [
						method("emit", fun(f.args, macro :Void,
							macro {
								for (slot in this)
									slot(${
										for (arg in f.args)
											macro $i{arg.name}
									});
							}),
							[APublic, AInline], [meta(":op", [macro a()])]),
						method("connect", fun([arg("slot", _t)], macro :Void, macro this.push(slot)), [APublic, AInline]),
						method("disconnect", fun([arg("slot", _t)], macro :Void, macro this.remove(slot)), [APublic, AInline]),
					],
					pos: Context.currentPos()
				});

				field.kind = FVar(TPath({
					pack: cls.pack,
					name: typeName,
					params: [
						for (param in cls.params)
							TPType(toComplex(param.t))
					]
				}), macro []);

				// add connector
				add(method('on${field.name.capitalize()}', fun([arg("slot", _t)], macro $i{field.name}.connect(slot)), [APublic, AInline]));

			default:
				err("Signal must be function", field.pos);
		}
	}

	function buildTrack(field:Field):Void {
		switch (field.kind) {
			case FVar(t, e):
				field.meta = [
					{
						name: ":isVar",
						pos: Context.currentPos()
					}
				];
				field.kind = FProp("default", "default", t, e);
				buildTrack(field);

			case FProp(get, set, t, e):
				switch (set) {
					case "never", "dynamic":
						err("Can\'t track a property with no write access", field.pos);

					case "default":
						field.kind = FProp(get, "set", t, e);
						buildTrack(field);

					case "set", "null":
						var _setter = find('set_${field.name}');
						if (_setter != null) {
							switch (_setter.kind) {
								case FFun(f):
									// generate signal
									var signal = method('${field.name}Changed', fun([arg(field.name, t)], macro {}));
									add(signal);
									buildSignal(signal);
									// inject
									f.expr = injectCall(f.expr, macro $i{signal.name});
								default:
									err("Setter must be function", _setter.pos);
							}
						} else {
							// generate setter
							add(setter(field, fun([arg("value", t)], macro {
								$i{field.name} = value;
								return $i{field.name};
							}), [APrivate, AInline]));
							buildTrack(field);
						}
				}

			case FFun(f):
				f.ret = f.ret ?? expected();
				// generate signal
				var signal = method('${field.name}Called', fun(switch (f.ret) {
					case TPath(p):
						p.name == "Void" ? [] : [arg("result", f.ret)];
					default: [arg("result", f.ret)];
				}, macro {}));
				add(signal);
				buildSignal(signal);
				// inject
				f.expr = injectCall(f.expr, macro $i{signal.name});
		}
	}

	function injectCall(f:Expr, call:Expr):Expr {
		function inject(f:Expr, call:Expr):Expr {
			function replace(e:Expr):Expr {
				if (e != null)
					return switch (e.expr) {
						case EReturn(eValue):
							if (eValue != null) macro {
								final result = $eValue;
								$call(result);
								return result;
							} else macro {
								$call();
								return;
							}
						case EIf(econd, ethen, eelse):
							macro {
								if ($econd)
									${replace(ethen)};
								else
									${replace(eelse)};
							}
						default:
							map(e, replace);
					}
				else
					return e;
			}
			return replace(f);
		}
		if (has(f, (e) -> switch (e.expr) {
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
