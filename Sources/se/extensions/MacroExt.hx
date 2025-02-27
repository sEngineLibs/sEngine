package se.extensions;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Printer;

using se.extensions.MacroExt;

@:dox(hide)
class MacroExt {
	#if macro
	static public inline function resolve(s:String, ?pos)
		return drill(s.split('.'), pos);

	static public function drill(parts:Array<String>, ?pos:Position, ?target:Expr) {
		if (target == null)
			target = at(EConst(CIdent(parts.shift())), pos);
		for (part in parts)
			target = field(target, part, pos);
		return target;
	}

	static public inline function at(e:ExprDef, ?pos:Position)
		return {
			expr: e,
			pos: pos.sanitize()
		};

	static public inline function sanitize(pos:Position)
		return if (pos == null) Context.currentPos(); else pos;

	static public inline function field(e:Expr, field, ?pos)
		return EField(e, field).at(pos);

	static public function toString(t:ComplexType)
		return new Printer().printComplexType(t);
	#end
}
