package se.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import se.macro.Builder;

using se.macro.Builder;
using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;
using se.extensions.StringExt;

@:dox(hide)
class SMacro extends Builder {
	var signalsOG:Array<Field> = [];

	macro public static function build():Array<Field> {
		return new SMacro().export();
	}

	function run() {
		function extractMetaParams(meta:MetadataEntry):Map<String, Position> {
			var params:Map<String, Position> = [];
			for (param in meta.params ?? [])
				switch (param.expr) {
					case EConst(c):
						switch c {
							case CIdent(s):
								params.set(s, param.pos);
							default:
								err("Identifier expected", param.pos);
								continue;
						}
					default:
						err("Identifier expected", param.pos);
						continue;
				}
			return params;
		}

		for (field in fields) {
			for (meta in field.meta ?? []) {
				switch meta.name {
					case "alias":
						buildAlias(field);
					case "readonly":
						buildAlias(field);
					case "writeonly":
						buildAlias(field);
					case ":inject":
						var injections:Map<String, Function> = [];
						for (slotIdent in extractMetaParams(meta).keyValueIterator()) {
							var slot = find(slotIdent.key);
							if (slot != null) {
								switch slot.kind {
									case FFun(f):
										injections.set(slot.name, f);
									default:
										err('Slot ${slotIdent.key} must be function', slotIdent.value);
								}
							} else {
								err('Can\'t find slot ${slotIdent.key}', slotIdent.value);
							}
						}
						buildInjection(field, injections);

					default:
						if (meta.name.startsWith(":track")) {
							var isPublic = false;
							var ms = meta.name.split(".");
							if (ms.length == 2)
								isPublic = ms[1] == "public";

							buildTrack(field, isPublic);
						} else if (meta.name.startsWith(":signal")) {
							var isPublic = true;
							var ms = meta.name.split(".");
							if (ms.length == 2)
								isPublic = ms[1] != "private";

							var mask = [];
							for (param in extractMetaParams(meta).keys())
								mask.push(param);

							buildSignal(field, isPublic, mask);
						}
				}
			}
		}

		var slotsSignals:Map<String, Map<String, Position>> = [];

		for (field in fields) {
			for (meta in field.meta ?? []) {
				if (meta.name == ":slot")
					switch field.kind {
						case FFun(f):
							for (signalIdent in extractMetaParams(meta).keyValueIterator()) {
								// find signal
								var signal;
								for (s in signalsOG)
									if (s.name == signalIdent.key) {
										signal = s;
										break;
									}

								if (signal != null) {
									var isSignal = false;
									for (m in signal.meta)
										if (m.name == ":signal") {
											var argsMatch = true;
											switch signal.kind {
												case FFun(sf):
													if (sf.args.length == f.args.length) {
														for (i in 0...f.args.length) {
															var t = resolve(f.args[i].type).toString();
															var st = resolve(sf.args[i].type).toString();
															if (t != st) {
																argsMatch = false;
																err('Arguments mismatch with ${signalIdent.key}', signalIdent.value);
															}
														}
													} else {
														err('Arguments mismatch with ${signalIdent.key}', signalIdent.value);
													}
												default:
													err('Can\'t find signal ${signalIdent.key}', signalIdent.value);
											}

											if (argsMatch)
												slotsSignals.set(field.name, extractMetaParams(meta));

											isSignal = true;
											break;
										}
									if (!isSignal)
										err('${signalIdent.key} is not signal', signalIdent.value);
								} else {
									err('Can\'t find signal ${signalIdent.key}', signalIdent.value);
								}
							}

						default:
							err("Slot must be function", field.pos);
					}
			}
		}

		getConstructor();
		var cf = switch find("new").kind {
			case FFun(f): f;
			default: null;
		}

		for (slot in slotsSignals.keyValueIterator()) {
			var conns = [
				for (signal in slot.value.keys())
					macro $i{signal}.connect($i{slot.key})
			];
			cf.expr = switch cf.expr.expr {
				case EBlock(exprs): {
						expr: EBlock(exprs.concat(conns)),
						pos: Context.currentPos()
					}
				default:
					{
						expr: EBlock([macro ${cf.expr}].concat(conns)),
						pos: Context.currentPos()
					}
			}
		}
	}

	function buildAlias(field:Field) {
		switch field.kind {
			case FVar(t, e):
				field.kind = FProp("get", "set", t);
				add(getter(field, fun([], t, macro {
					return $e;
				})));
				add(setter(field, fun([arg("value", t)], t, macro {
					$e = value;
					return value;
				})));
			default:
				err("Alias must be a variable", field.pos);
		}
	}

	function buildAccessor(field:Field, readable:Bool, writeable:Bool) {
		switch field.kind {
			case FVar(t, e):
				field.meta.push(meta(":isVar"));
				field.kind = FProp(readable ? "get" : "null", writeable ? "set" : "null", t);
				add(getter(field, fun([], t, macro {
					return $i{field.name};
				})));
				add(setter(field, fun([arg("value", t)], t, macro {
					$i{field.name} = value;
					return value;
				})));
			case FProp(get, set, t, e):
				field.kind = FProp(readable ? "get" : "null", writeable ? "set" : "null", t, e);
			case FFun(f):
				warn("Functions can\'t have accessors");
		}
	}

	function buildInjection(field:Field, injections:Map<String, Function>) {
		function injectCalls(f:Function, injections:Map<String, Function>) {
			var injected = false;

			if ((f.ret ?? expected()).toString() == "Void") {
				var block = [];
				for (func in injections.keyValueIterator()) {
					if (func.value.args.length == 0)
						block.push(macro $i{func.key}());
					else
						err('Invalid number of arguments. Expected 0, got ${func.value.args.length}', find(func.key).pos);
				}

				f.expr = macro {
					${f.expr};
					$b{block}
				}
			} else {
				var block = [];
				for (func in injections.keyValueIterator()) {
					var args = func.value.args;
					if (args.length == 0)
						block.push(macro $i{func.key}());
					else if (args.length == 1)
						block.push(macro $i{func.key}(res));
					else
						err('Invalid number of arguments. Expected 1, got ${args.length}', find(func.key).pos);
				}
				
				f.expr = f.expr.map(expr -> switch expr.expr {
					case EReturn(e):
						macro {
							var res = $e;
							$b{block};
							return res;
						}
					default: expr;
				});
			}
		}

		switch field.kind {
			case FVar(t, e):
				field.meta.push(meta(":isVar"));
				field.kind = FProp("default", "set", t, e);
				buildInjection(field, injections);

			case FProp(get, set, t, e):
				switch (set) {
					case "set", "null":
						var _setter = find('set_${field.name}');
						if (_setter == null) {
							// generate setter
							_setter = add(setter(field, fun([arg("value", t)], macro {
								$i{field.name} = value;
								return $i{field.name};
							}), [APrivate, AInline]));
						}
						buildInjection(_setter, injections);

					default:
						field.kind = FProp(get, "set", t, e);
						buildInjection(field, injections);
				}

			case FFun(f):
				injectCalls(f, injections);
		}
	}

	function buildSignal(field:Field, isPublic:Bool, mask:Array<String>):Void {
		var fieldOG = copy(field);

		switch (field.kind) {
			case FFun(f):
				if (f.expr != null)
					warn("Signals are not real functions and its body will never be used.", f.expr.pos);

				for (arg in f.args)
					arg.type = resolve(arg.type ?? expected());
				var maskedArgs = [];
				var maskKeys = [];
				for (arg in f.args)
					if (!mask.contains(arg.name))
						maskedArgs.push(arg);
					else
						maskKeys.push(arg);
				// define underlying type
				var _t = ComplexType.TFunction([
					for (arg in maskedArgs) {
						var t = TNamed(arg.name, arg.type);
						if (arg.opt) TOptional(t) else t;
					}
				], macro :Void);
				var typeName = '${cls.name}_${field.name}_Signal';
				var stypepath = {
					pack: cls.pack,
					name: typeName,
					params: [
						for (param in cls.params)
							TPType(toComplex(param.t))
					]
				};
				if (maskKeys.length == 0) {
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
						method("clear", fun([], macro :Void, macro this = new $stypepath()), [APublic, AInline])
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
					This signal invokes its slots ${f.args.length > 0 ? 'with $paramDoc' : ""} when emitted.
					Call `${field.name}($callDoc)` or `${field.name}.emit($callDoc)` to emit the signal
					';
					field.kind = FVar(TPath(stypepath), macro new $stypepath());
					field.access = isPublic ? [APublic] : [APrivate];
					// add connector
					var connector = method('on${field.name.capitalize()}', fun([arg("slot", _t)], macro {
						$i{field.name}.connect(slot);
					}), [APublic, AInline]);
					connector.doc = '
					Shortcut for `${field.name}` signal\'s function `connect` which connects slots to it.
					@param slot a callback to invoke when `${field.name}` is emitted
					';
					add(connector);
				}
				// masked signal
				else {
					var _m = anon(maskKeys.map(k -> variable(k.name, k.type)));
					var underlying = macro :Map<$_m, Array<$_t>>;
					var sidents = maskKeys.map(k -> k.name);
					var sidentsExpr = idents(sidents);
					var cond = eqChain(idents([
						for (k in sidents)
							'p.key.$k'
					]), sidentsExpr);
					var stypepath = {
						pack: cls.pack,
						name: typeName,
						params: [
							for (param in cls.params)
								TPType(toComplex(param.t))
						]
					};
					Context.defineType(tdAbstract(cls.pack, typeName, underlying, [
						method("emit", fun(f.args, macro :Void, macro {
							for (p in this.keyValueIterator()) {
								if ($cond) {
									for (slot in p.value) {
										slot(${
											for (arg in maskedArgs)
												macro $i{arg.name}
										});
										break;
									}
								}
							}
						}), [APublic, AInline],
							[meta(":op", [macro a()])]),
						method("connect", fun(args(maskKeys).concat([arg("slot", _t)]), macro :Void, macro {
							var flag = false;
							for (p in this.keyValueIterator())
								if ($cond) {
									p.value.push(slot);
									flag = true;
									break;
								}
							if (!flag)
								this.set(${
									obj([
										for (k in maskKeys)
											objField(k.name, macro $i{k.name})
									])
								}, [slot]);
						}), [APublic, AInline]),
						method("disconnect", fun([arg("slot", _t)], macro :Void,
							macro {
								for (slotList in this)
									if (slotList.contains(slot)) {
										slotList.remove(slot);
										break;
									}
							}),
							[APublic, AInline]),
						method("clear", fun([], macro :Void, macro this = new $stypepath()), [APublic, AInline])
					], [AbFrom(underlying), AbTo(underlying)],
						[meta(":forward.new"), meta(":dox", [macro hide])], cls.params.map(p -> {
							name: p.name,
							defaultType: p.defaultType != null ? toComplex(p.defaultType) : null,
							constraints: null,
							params: null,
							meta: null
						}), true));
					// docs
					var maskValuesDoc = "";
					for (key in maskKeys)
						maskValuesDoc += '`${key.name}:${key.type.toString()}`';
					var callDoc = "";
					for (arg in f.args)
						callDoc += '${arg.name}, ';
					callDoc = '${callDoc.substring(0, callDoc.length - 2)}';
					field.doc = '
					When this signal is emitted, only the slots with the exact parameter mask
					($maskValuesDoc) values are invoked.
					Call `${field.name}($callDoc)` or `${field.name}.emit($callDoc)` to emit the signal
					';
					field.access = isPublic ? [APublic] : [APrivate];
					field.kind = FVar(TPath(stypepath), macro new $stypepath());
					// add connector
					var cargs = sidentsExpr.concat([macro slot]);
					var connector = method('on${field.name.capitalize()}', fun(args(maskKeys).concat([arg("slot", _t)]), macro {
						$i{field.name}.connect($a{cargs});
					}), [APublic, AInline]);
					var maskDoc = "";
					for (key in maskKeys)
						maskDoc += '\n@param ${key.name} Mask parameter of the slot';
					connector.doc = '
					Shortcut for `${field.name}` signal\'s function `connect` which connects slots to it.
					$maskDoc
					@param slot a callback to invoke when `${field.name}` is emitted
					';
					add(connector);
				}

				// add disconnector
				var disconnector = method('off${field.name.capitalize()}', fun([arg("slot", _t)], macro {
					$i{field.name}.disconnect(slot);
				}), [APublic, AInline]);
				disconnector.doc = '
					Shortcut for `${field.name}` signal\'s function `disconnect` which disconnects slots from it.
					@param slot a callback to remove from `${field.name}`\'s list
					';
				add(disconnector);

				signalsOG.push(fieldOG);
			default:
				err("Signal must be declared as a function. Use `:track` meta to track this field", field.pos);
		}
	}

	function buildTrack(field:Field, isPublic:Bool):Void {
		// generate signal
		var signalName;
		var signalFun;

		switch (field.kind) {
			case FVar(t, e):
				signalName = '${field.name}Changed';
				signalFun = fun([arg(field.name, t)]);
			case FProp(get, set, t, e):
				signalName = '${field.name}Changed';
				signalFun = fun([arg(field.name, t)]);
			case FFun(f):
				f.ret = f.ret ?? expected();
				signalName = '${field.name}Called';
				signalFun = fun(switch (f.ret) {
					case TPath(p):
						p.name == "Void" ? [] : [arg("value", f.ret)];
					default: [arg("value", f.ret)];
				});
		}

		buildSignal(add(method(signalName, signalFun, [meta(":signal")])), isPublic, []);
		buildInjection(field, [signalName => signalFun]);
		field.doc = '_Note: this field is **tracked**. The corresponding connector is_ `on${signalName.capitalize()}`\n\n' + (field.doc ?? "");
	}
}
#end
