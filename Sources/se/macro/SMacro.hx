package se.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using tink.MacroApi;

class SMacro {
	static var fields:Array<Field>;

	static var funcField:String;
	static var fieldName:String;
	static var fieldRef:Dynamic;
	static var listRef:Dynamic;

	macro public static function build():Array<Field> {
		fields = Context.getBuildFields();
		for (field in fields) {
			fieldName = field.name;
			fieldRef = fieldName.resolve();
			for (meta in field.meta ?? []) {
				switch (meta.name) {
					case "bind":
						buildBind(field);
				}
			}
		}
		return fields;
	}

	static function buildBind(field:Field) {
		switch (field.kind) {
			// gen property
			case FVar(t, e):
				field.meta.push({name: ":isVar", pos: Context.currentPos()});
				field.kind = FProp("default", "set", t, e);
				genBind(fieldName, t);

			// edit property
			case FProp(get, set, t, e):
				switch (set) {
					case "never", "dynamic":
						Context.error('can\'t bind "$set" with no access.', field.pos);

					case "default":
						field.kind = FProp(get, "set", t, e);
						genBind(fieldName, t);

					case "set", "null":
						// find setter
						var methodName = "set_" + fieldName;
						var setter = null;
						for (f in fields)
							if (f.name == methodName) {
								setter = f;
								break;
							}

						if (setter == null)
							Context.error("can't find setter: " + methodName, field.pos);

						switch (setter.kind) {
							case FFun(f):
								genBindListeners(fieldName, t);
								genVarBindListenerPusher(fieldName, t);

								funcField = f.args[0].name;

								// store the current field value at the beggining of the setter
								switch (f.expr.expr) {
									case EBlock(exprs):
										exprs.unshift(macro var __from__ = $fieldRef);
									case _:
								}

								// recursivelly add a bind call before return statements.
								f.expr = f.expr.map(addBindCall);

							case _: Context.error("setter must be function", setter.pos);
						}
				}

			// edit function
			case FFun(f):
				genBindListeners(fieldName, f.ret);
				genFuncBindListenerPusher(fieldName, f.ret);
				funcField = f.args[0].name;

				var returnType = f.ret.match(TPath(_)) ? f.ret : null;
				var hasReturn = returnType != null && returnType.toString() != "Void";

				switch (f.expr.expr) {
					case EBlock(exprs):
						if (hasReturn)
							exprs = [
								macro {
									__result__ = {
										$b{exprs}
									};
									for (l in $listRef)
										l(__result__);
									return __result__;
								}
							];
						else
							exprs.push(macro {
								for (l in $listRef)
									l();
							});

						exprs = [];
						f.expr = {expr: EBlock(exprs), pos: f.expr.pos};

					case _: null;
				}
		}
	}

	static function genBind(name:String, t:ComplexType) {
		genBindListeners(name, t);
		genVarBindListenerPusher(name, t);
		genBindSetter(name, t);
	}

	static function genBindListeners(name:String, t:ComplexType) {
		name = name.charAt(0).toUpperCase() + name.substr(1);
		var listName = '__${name}Listeners';
		listRef = listName.resolve();
		fields.push({
			pos: Context.currentPos(),
			name: listName,
			access: [APrivate],
			kind: FVar(macro :Array<$t->Void>, macro [])
		});
	}

	static inline function genVarBindListenerPusher(name:String, t:ComplexType) {
		fields.push({
			pos: Context.currentPos(),
			name: 'on${name.charAt(0).toUpperCase() + name.substr(1)}Changed',
			doc: 'Adds a listener that is triggered when the value of the property `$name` changes.
       			@param listener `($name:${t.getParameters()[0].name}) -> Void` A callback that receives the new value of the property.
       			@return An object with a `remove` function that removes the listener from the active list.',
			kind: FFun({
				ret: macro :{
					remove:Void->Void
				},
				args: [
					{
						name: 'listener',
						type: macro :($name:$t) -> Void
					}
				],
				expr: macro {
					var listener = $i{'listener'};
					$listRef.push(listener);
					return {
						remove: () -> $listRef.remove(listener)
					};
				}
			}),
			access: [APublic, AInline]
		});
	}

	static function genFuncBindListenerPusher(name:String, t:ComplexType) {
		fields.push({
			pos: Context.currentPos(),
			name: 'on${name.charAt(0).toUpperCase() + name.substr(1)}Called',
			doc: 'Adds a listener that is triggered when `$name` is called.
       			@param listener `${t.getParameters()[0].name} -> Void` A callback that receives the returned value from the function.
       			@return An object with a `remove` function that removes the listener from the active list.',
			kind: FFun({
				ret: macro :{
					remove:Void->Void
				},
				args: [
					{
						name: 'listener',
						type: macro :$t->Void
					}
				],
				expr: macro {
					var listener = $i{'listener'};
					$listRef.push(listener);
					return {
						remove: () -> $listRef.remove(listener)
					};
				}
			}),
			access: [APublic, AInline]
		});
	}

	static function genBindSetter(name:String, t:ComplexType) {
		fields.push({
			pos: Context.currentPos(),
			name: "set_" + name,
			access: [AInline, APrivate],
			meta: [],
			kind: FFun({
				ret: t,
				expr: macro {
					var __from__ = $fieldRef;
					$fieldRef = v;
					for (l in $listRef)
						l(v);
					return $fieldRef;
				},
				args: [
					{
						name: "value",
						type: t
					}
				]
			})
		});
	}

	static function addBindCall(expr:Expr):Expr {
		return switch (expr.expr) {
			case EReturn(e):
				if (e == null)
					Context.error("setter must return value", expr.pos);
				switch (e.expr) {
					case EConst(c):
						macro {
							for (l in $listRef)
								l($fieldRef);
							return $e;
						}
					case _:
						macro {
							${e.map(addBindCall)};
							for (l in $listRef)
								l($fieldRef);
							return $i{funcField};
						}
				}
			case _: expr.map(addBindCall);
		}
		return null;
	}
}
