package se.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using se.extensions.MacroExt;

@:dox(hide)
class SMacro {
	#if macro
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
					case "observable":
						buildObservable(field);
				}
			}
		}
		return fields;
	}

	static function buildObservable(field:Field) {
		switch (field.kind) {
			// gen property
			case FVar(t, e):
				genObservable(fieldName, t);
				field.meta.push({name: ":isVar", pos: Context.currentPos()});
				field.kind = FProp("default", "set", t, e);
				var docstring = '_This variable is **observable**._\n';
				field.doc = field.doc == null ? docstring : docstring + field.doc;
				field.doc += '\n@see `on${fieldName.charAt(0).toUpperCase() + fieldName.substr(1)}Changed`';

			// edit property
			case FProp(get, set, t, e):
				var docstring = '_This property is **observable**._\n';
				switch (set) {
					case "never", "dynamic":
						Context.error('Can\'t observable a property with no access.', field.pos);

					case "default":
						genObservable(fieldName, t);
						field.kind = FProp(get, "set", t, e);
						field.doc = field.doc == null ? docstring : docstring + field.doc;
						field.doc += '\n@see `on${fieldName.charAt(0).toUpperCase() + fieldName.substr(1)}Changed`';

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
							Context.error("Can't find setter: " + methodName, field.pos);

						switch (setter.kind) {
							case FFun(f):
								genObservableListeners(fieldName, t);
								genVarObservableListenerPusher(fieldName, t);

								funcField = f.args[0].name;
								// store the current field value at the beggining of the setter
								switch (f.expr.expr) {
									case EBlock(exprs):
										exprs.unshift(macro var __from__ = $fieldRef);
									case _:
								}
								// recursivelly add a observable call before return statements.
								f.expr = addObservableCall(f.expr);

								field.doc = field.doc == null ? docstring : docstring + field.doc;
								field.doc += '\n@see `on${fieldName.charAt(0).toUpperCase() + fieldName.substr(1)}Changed`';

							case _: Context.error("setter must be function", setter.pos);
						}
				}

			// edit function
			case FFun(f):
				var docstring = '_This function is **observable**._\n';
				field.doc = field.doc == null ? docstring : docstring + field.doc;
				field.doc += '\n@see `on${fieldName.charAt(0).toUpperCase() + fieldName.substr(1)}Called`';

				genObservableListeners(fieldName, f.ret);
				genFuncObservableListenerPusher(fieldName, f.ret);
				funcField = fieldName;

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
						f.expr = {expr: EBlock(exprs), pos: f.expr.pos};

					case _: null;
				}
		}
	}

	static function genObservable(name:String, t:ComplexType) {
		genObservableListeners(name, t);
		genVarObservableListenerPusher(name, t);
		genObservableSetter(name, t);
	}

	static function genObservableListeners(name:String, t:ComplexType) {
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

	static inline function genVarObservableListenerPusher(name:String, t:ComplexType) {
		fields.push({
			pos: Context.currentPos(),
			name: 'on${name.charAt(0).toUpperCase() + name.substr(1)}Changed',
			doc: 'Adds a listener that is triggered when `$name` changes. 
       			@param listener A callback that receives the new value of the property.
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

	static function genFuncObservableListenerPusher(name:String, t:ComplexType) {
		fields.push({
			pos: Context.currentPos(),
			name: 'on${name.charAt(0).toUpperCase() + name.substr(1)}Called',
			doc: 'Adds a listener that is triggered when `$name` is called.
       			@param listener A callback that receives the returned value from the function.
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

	static function genObservableSetter(name:String, t:ComplexType) {
		fields.push({
			pos: Context.currentPos(),
			name: "set_" + name,
			access: [AInline, APrivate],
			meta: [],
			kind: FFun({
				ret: t,
				args: [
					{
						name: "value",
						type: t
					}
				],
				expr: macro {
					var __from__ = $fieldRef;
					$fieldRef = value;
					for (l in $listRef)
						l(value);
					return $fieldRef;
				}
			})
		});
	}

	static function addObservableCall(expr:Expr):Expr {
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
							${addObservableCall(e)};
							for (l in $listRef)
								l($fieldRef);
							return $i{funcField};
						}
				}
			case _: expr;
		}
		return null;
	}
	#end
}
