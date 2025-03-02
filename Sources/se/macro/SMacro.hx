package se.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using tink.MacroApi;

@:dox(hide)
class SMacro {
	#if macro
	static var classPack:Array<String>;
	static var className:String;
	static var classFields:Array<Field>;

	static var signals:Map<Field, Array<Expr>>;

	macro public static function build():Array<Field> {
		var path = Context.getLocalModule().split(".");
		// get name
		className = path[path.length - 1];
		// get pack
		classPack = path.slice(0, path.length - 1);
		// get fields
		classFields = Context.getBuildFields();

		signals = [];
		var constructor = buildConstructor();

		for (field in classFields) {
			for (meta in field.meta ?? []) {
				switch (meta.name) {
					case ":signal":
						if (!signals.exists(field))
							signals[field] = [];
					case ":slot":
						switch (field.kind) {
							case FFun(f):
								for (signal in meta.params) {
									switch (signal.expr) {
										case EConst(c):
											switch (c) {
												case CIdent(s):
													var signalField = findField(s);
													if (signalField != null) {
														if (signals.exists(signalField)) {
															signals[signalField].push(field.name.resolve());
														} else {
															signals[signalField] = [field.name.resolve()];
														}
													}
												default: null;
											}
										default: null;
									}
								}
							default:
								Context.error("slot must be a function", field.pos);
						}
					case ":track":
						buildTrack(field);
				}
			}
		}

		for (signal in signals.keys()) {
			buildSignal(signal);

			// connect slots to the signal
			var signalRef = signal.name.resolve();
			var slots = signals[signal];
			switch (constructor.expr.expr) {
				case EBlock(exprs):
					for (slot in slots)
						exprs.unshift(macro $signalRef.connect($slot));
				default:
					constructor.expr = {
						expr: EBlock([
							for (slot in slots)
								macro $signalRef.connect($slot)
						].concat([constructor.expr])),
						pos: Context.currentPos()
					}
			}
		}

		return classFields;
	}

	static function buildSignal(field:Field):Void {
		switch (field.kind) {
			case FFun(f):
				var signalName = '${className}_${field.name}_Signal';

				var args = [
					for (arg in f.args) {
						var t = TNamed(arg.name, arg.type);
						if (arg.opt) TOptional(t); else t;
					}
				];

				var _t = ComplexType.TFunction(args, f.ret ?? macro :Void);
				var t = macro :Array<$_t>;

				Context.defineType({
					pack: classPack,
					meta: [
						{
							name: ":forward.new",
							pos: Context.currentPos()
						}
					],
					name: signalName,
					isExtern: true,
					kind: TDAbstract(t, [AbFrom(t), AbTo(t)]),
					fields: [
						{
							meta: [
								{
									name: ":op",
									params: [macro a()],
									pos: Context.currentPos()
								}
							],
							name: "emit",
							kind: FFun({
								args: f.args,
								expr: {
									expr: EFor(macro slot in this, {
										expr: ECall(macro slot, [
											for (arg in f.args)
												macro ${arg.name.resolve()}
										]),
										pos: Context.currentPos()
									}),
									pos: Context.currentPos()
								}
							}),
							access: [APublic, AInline],
							pos: Context.currentPos()
						},
						{
							name: "connect",
							kind: FFun({
								args: [{name: "slot"}],
								expr: macro {
									this.push(slot);
								}
							}),
							access: [APublic, AInline],
							pos: Context.currentPos()
						},
						{
							name: "disconnect",
							kind: FFun({
								args: [{name: "slot"}],
								expr: macro {
									this.remove(slot);
								}
							}),
							access: [APublic, AInline],
							pos: Context.currentPos()
						}
					],
					pos: Context.currentPos()
				});

				field.meta = [];
				field.kind = FVar(TPath({
					pack: classPack,
					name: signalName
				}), macro []);

				field.access = field.access.contains(APublic) ? [APublic] : [];

				// add connector
				classFields.push(genSignalConnector(field));
			default:
				Context.error("Signal must be a function, not " + field, field.pos);
		}
	}

	static function buildTrack(field:Field):Void {
		switch (field.kind) {
			case FVar(t, e):
				field.meta.push({name: ":isVar", pos: Context.currentPos()});
				field.kind = FProp("default", "set", t, e);

				// generate signal
				var signal = genSignal('${field.name}Changed', field.access.contains(APublic), [{name: field.name, type: t}]);

				// generate setter
				var fieldRef = field.name.resolve();
				var setter = {
					name: 'set_${field.name}',
					access: [AExtern, APrivate, AInline],
					kind: FFun({
						args: [{name: "value", type: t}],
						expr: macro {
							$fieldRef = value;
							${signal.name.resolve()}($fieldRef);
							return $fieldRef;
						},
					}),
					pos: Context.currentPos()
				}

				classFields.push(signal);
				if (!signals.exists(signal))
					signals[signal] = [];
				classFields.push(setter);

			case FProp(get, set, t, e):
				switch (set) {
					case "never", "dynamic":
						Context.error('Can\'t track a property with no write access.', field.pos);

					case "default":
						field.kind = FProp(get, "set", t, e);

						// generate signal
						var signal = genSignal('${field.name}Changed', field.access.contains(APublic), [{name: field.name, type: t}]);

						// generate setter
						var fieldRef = field.name.resolve();
						var setter = {
							name: 'set_${field.name}',
							access: [APrivate, AInline],
							kind: FFun({
								args: [{name: "value", type: t}],
								expr: macro {
									$fieldRef = value;
									${signal.name.resolve()}($fieldRef);
									return $fieldRef;
								},
							}),
							pos: Context.currentPos()
						}

						classFields.push(signal);
						if (!signals.exists(signal))
							signals[signal] = [];
						classFields.push(setter);

					case "set", "null":
						var setter = findField('set_${field.name}');
						if (setter == null) {
							Context.error("Can't find setter: " + 'set_${field.name}', field.pos);
						} else {
							// generate signal
							var signal:Field = {
								name: '${field.name}Changed',
								access: field.access.contains(APublic) ? [APublic, AInline] : [AInline],
								kind: FFun({
									args: [{name: field.name, type: t}]
								}),
								pos: Context.currentPos()
							}
							switch (setter.kind) {
								case FFun(f):
									f.expr = injectCall(f.expr, signal.name.resolve());
								default: Context.error("Setter must be function", Context.currentPos());
							}

							classFields.push(signal);
							if (!signals.exists(signal))
								signals[signal] = [];
						}
				}

			case FFun(f):
				if (f.ret == null)
					Context.error("Function return must be type-hinted", Context.currentPos());
				else {
					// generate signal
					var signal:Field = {
						name: '${field.name}Called',
						access: field.access.contains(APublic) ? [APublic, AInline] : [AInline],
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

					classFields.push(signal);
					if (!signals.exists(signal))
						signals[signal] = [];
				}
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

	static function genSignal(name, isPublic, args):Field {
		return {
			name: name,
			access: isPublic ? [APublic] : [],
			kind: FFun({
				args: args
			}),
			pos: Context.currentPos()
		}
	}

	static function genSignalConnector(signal:Field):Field {
		var name = signal.name;
		var ref = name.resolve();
		return {
			name: 'on${name.charAt(0).toUpperCase() + name.substr(1)}',
			kind: FFun({
				args: [{name: "slot"}],
				expr: macro $ref.connect(slot)
			}),
			access: signal.access.concat([AExtern, AInline]),
			pos: Context.currentPos()
		};
	}

	static function findField(name:String):Field {
		for (field in classFields)
			if (field.name == name)
				return field;
		return null;
	}

	static function buildConstructor():Function {
		var f = findField("new");
		if (f == null) {
			var constructor;
			// var sup = findSuperConstructor(Context.getLocalClass().get());
			var sup = Context.getLocalClass().get().superClass;
			if (sup != null) {
				Context.error("This class must have a constructor", Context.currentPos());
				// var sargs:Array<FunctionArg>;

				// switch (sup) {
				// 	case TFun(args, ret):
				// 		sargs = [
				// 			for (arg in args) {
				// 				{
				// 					name: arg.name,
				// 					type: arg.t.toComplex(),
				// 					opt: arg.opt,
				// 				}
				// 			}
				// 		];
				// 	default:
				// 		null;
				// }

				// constructor = {
				// 	args: sargs,
				// 	expr: {
				// 		expr: ECall(macro super, [
				// 			for (arg in sargs)
				// 				macro ${arg.name.resolve()}
				// 		]),
				// 		pos: Context.currentPos()
				// 	}
				// }
			} else {
				constructor = {
					args: [],
					expr: macro {}
				}
			}

			classFields.push({
				name: "new",
				kind: FFun(constructor),
				access: [APublic],
				pos: Context.currentPos()
			});
			return constructor;
		} else {
			return switch (f.kind) {
				case FFun(f):
					f;
				default:
					null;
			}
		}
	}

	static function findSuperConstructor(cls:ClassType):Type {
		function findParam(typeParams:Array<TypeParameter>, param:Type) {
			for (i in 0...typeParams.length) {
				var tp = typeParams[i];
				if (tp.t.compare(param) == 0)
					return tp;
			}
			return null;
		}

		if (cls.constructor == null) {
			var sup = cls.superClass;
			if (sup != null) {
				var typeParams:Map<String, Type> = [
					for (i in 0...sup.t.get().params.length)
						sup.t.get().params[i].t.toExactString() => sup.params[i]
				];
				var constructor = sup.t.get().constructor?.get().expr().t;
				if (constructor != null)
					return switch (constructor) {
						case TFun(args, ret):
							TFun([
								for (arg in args)
									{
										name: arg.name,
										t: typeParams.exists(arg.t.toExactString()) ? typeParams.get(arg.t.toExactString()) : arg.t,
										opt: arg.opt
									}
							], ret);
						default:
							constructor;
					}
				else
					return null;
			}
			return null;
		} else
			return cls.constructor.get().expr().t;
	}
	#end
}
