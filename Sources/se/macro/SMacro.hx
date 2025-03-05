package se.macro;

import haxe.macro.ComplexTypeTools;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import se.macro.Builder;

using haxe.macro.ExprTools;
using se.extensions.StringExt;

@:dox(hide)
class SMacro extends Builder {
	macro public static function build():Array<Field> {
		return new SMacro().export();
	}

	function run() {
		function extractMask(meta:MetadataEntry) {
			return [
				for (param in meta.params ?? [])
					switch (param.expr) {
						case EConst(c):
							switch c {
								case CIdent(s): s;
								default:
									err("Identifier expected", param.pos);
									continue;
							}
						default:
							err("Identifier expected", param.pos);
							continue;
					}
			];
		}

		for (field in fields)
			for (meta in field.meta ?? []) {
				if (meta.name.startsWith(":signal")) {
					var isPublic = true;
					var ms = meta.name.split(".");
					if (ms.length == 2) {
						switch ms[1] {
							case "private":
								isPublic = false;
							case "public":
								isPublic = true;
							default:
								warn('Unknown `${ms[1]}` access kind', meta.pos);
						}
					}

					buildSignal(field, isPublic, extractMask(meta));
				}

				if (meta.name.startsWith(":track")) {
					var isPublic = false;
					var ms = meta.name.split(".");
					if (ms.length == 2)
						isPublic = ms[1] == "public";

					buildTrack(field, isPublic);
				}
			}
	}

	function buildSignal(field:Field, isPublic:Bool, mask:Array<String>):Void {
		switch (field.kind) {
			case FFun(f):
				if (f.expr != null)
					warn("Signal is not a real function and its body will be removed", f.expr.pos);

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
				var typeName = '${cls.name}_${field.name}_Signal';

				Context.defineType(tdAbstract(cls.pack, typeName, macro :Array<$_t>, [
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
					[AbFrom(macro :Array<$_t>), AbTo(macro :Array<$_t>)], [meta(":forward.new"), meta(":dox", [macro hide])], cls.params.map(p -> {
						name: p.name,
						defaultType: p.defaultType != null ? toComplex(p.defaultType) : null,
						constraints: null,
						params: null,
						meta: null
					}), true));

				// docs
				var paramDoc = "";
				var callDoc = "";
				for (arg in f.args) {
					paramDoc += '${arg.name}:${switch arg.type {
						case TPath(p): p.sub ?? p.name;
						default: 'Void';
					}}, ';
					callDoc += '${arg.name}, ';
				}
				paramDoc = '`${paramDoc.substring(0, paramDoc.length - 2)}`' + (f.args.length == 1 ? " parameter" : " parameters");
				callDoc = '${callDoc.substring(0, callDoc.length - 2)}';

				field.doc = '
				This signal executes its slots ${f.args.length > 0 ? 'with $paramDoc' : ""} when emitted.
				
				Call `${field.name}($callDoc)` or `${field.name}.emit($callDoc)` to emit the signal
				';

				field.access = isPublic ? [APublic] : [APrivate];
				field.kind = FVar(TPath({
					pack: cls.pack,
					name: typeName,
					params: [
						for (param in cls.params)
							TPType(toComplex(param.t))
					]
				}), macro []);

				// add connector
				var connector = method('on${field.name.capitalize()}', fun([arg("slot", _t)], macro $i{field.name}.connect(slot)), [APublic, AInline]);
				connector.doc = '
				This function is a shortcut for `${field.name}` signal\'s function `connect` which connects slots to it.
				@param slot a callback to execute when `${field.name}` is emitted
				';
				add(connector);

			default:
				err("Signal must be declared as a function. Use the `:track` meta to track this field\'s value", field.pos);
		}
	}

	function buildTrack(field:Field, isPublic:Bool):Void {
		switch (field.kind) {
			case FVar(t, e):
				field.meta = [
					{
						name: ":isVar",
						pos: Context.currentPos()
					}
				];
				field.kind = FProp("default", "default", t, e);
				buildTrack(field, isPublic);

			case FProp(get, set, t, e):
				switch (set) {
					case "never", "dynamic":
						err("Can\'t track a property with no write access", field.pos);

					case "default":
						field.kind = FProp(get, "set", t, e);
						buildTrack(field, isPublic);

					case "set", "null":
						var _setter = find('set_${field.name}');
						if (_setter != null) {
							switch (_setter.kind) {
								case FFun(f):
									// generate signal
									var signal = method('${field.name}Changed', fun([arg(field.name, t)]));
									add(signal);
									buildSignal(signal, isPublic, []);
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

							field.doc = '_Note: this property is **tracked**. The corresponding connector is_ `on${field.name.capitalize()}Changed`\n\n'
								+ (field.doc ?? "");
							buildTrack(field, isPublic);
						}
				}

			case FFun(f):
				f.ret = f.ret ?? expected();
				// generate signal
				var signal = method('${field.name}Called', fun(switch (f.ret) {
					case TPath(p):
						p.name == "Void" ? [] : [arg("result", f.ret)];
					default: [arg("result", f.ret)];
				}));
				add(signal);
				buildSignal(signal, isPublic, []);
				// inject
				f.expr = injectCall(f.expr, macro $i{signal.name});
				field.doc = '_Note: this function is **tracked**. The corresponding connector is_ `on${field.name.capitalize()}Called`\n\n'
					+ (field.doc ?? "");
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
