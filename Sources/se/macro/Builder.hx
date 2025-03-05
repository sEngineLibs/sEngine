package se.macro;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type.Ref;
import haxe.macro.TypeTools;
import haxe.macro.ExprTools;
import haxe.macro.ComplexTypeTools;

abstract class Builder {
	var cls:haxe.macro.Type.ClassType;
	var fields:Array<Field>;

	function new() {
		cls = Context.getLocalClass().get();
		fields = Context.getBuildFields();
	}

	function export() {
		run();
		return fields;
	}

	abstract function run():Void;

	function add(field:Field) {
		fields.push(field);
	}

	function find(name:String) {
		for (field in fields)
			if (field.name == name)
				return field;
		return null;
	}
}

// SHORTCUTS

function warn(msg:String, ?pos:Position) {
	Context.warning(msg, pos ?? Context.currentPos());
}

function err(msg:String, ?pos:Position) {
	Context.error(msg, pos ?? Context.currentPos());
}

function fatal(msg:String, ?pos:Position) {
	Context.fatalError(msg, pos ?? Context.currentPos());
}

function fun(args:Array<FunctionArg>, ?ret:ComplexType, ?expr:Expr, ?params:Array<TypeParamDecl>):Function {
	return {
		args: args,
		ret: ret,
		expr: expr,
		params: params
	}
}

function arg(name:String, ?type:ComplexType):FunctionArg {
	return {
		name: name,
		type: type
	}
}

function def(t:TypeDefinition, ?moduleDependency:String):Void {
	Context.defineType(t, moduleDependency);
}

function tdef(pack:Array<String>, name:String, kind:TypeDefKind, fields:Array<Field>, ?pos:Position, ?doc:String, ?meta:Metadata,
		?params:Array<TypeParamDecl>, ?isExtern:Bool):TypeDefinition {
	return {
		pack: pack,
		name: name,
		kind: kind,
		fields: fields,
		pos: pos ?? Context.currentPos(),
		doc: doc,
		meta: meta,
		params: params,
		isExtern: isExtern
	}
}

function tdEnum(pack:Array<String>, name:String, fields:Array<Field>, ?pos:Position, ?doc:String, ?meta:Metadata, ?params:Array<TypeParamDecl>,
		?isExtern:Bool):TypeDefinition {
	return tdef(pack, name, TDEnum, fields, pos, doc, meta, params);
}

function tdStruct(pack:Array<String>, name:String, fields:Array<Field>, ?pos:Position, ?doc:String, ?meta:Metadata, ?params:Array<TypeParamDecl>,
		?isExtern:Bool):TypeDefinition {
	return tdef(pack, name, TDStructure, fields, pos, doc, meta, params);
}

function tdClass(pack:Array<String>, name:String, fields:Array<Field>, ?superClass:TypePath, ?interfaces:Array<TypePath>, ?isInterface:Bool, ?isFinal:Bool,
		?isAbstract:Bool, ?pos:Position, ?doc:String, ?meta:Metadata, ?params:Array<TypeParamDecl>, ?isExtern:Bool):TypeDefinition {
	return tdef(pack, name, TDClass(superClass, interfaces, isInterface, isFinal, isAbstract), fields, pos, doc, meta, params);
}

function tdAlias(pack:Array<String>, name:String, type:ComplexType, fields:Array<Field>, ?pos:Position, ?doc:String, ?meta:Metadata,
		?params:Array<TypeParamDecl>, ?isExtern:Bool):TypeDefinition {
	return tdef(pack, name, TDAlias(type), fields, pos, doc, meta, params);
}

function tdAbstract(pack:Array<String>, name:String, tthis:Null<ComplexType>, fields:Array<Field>, ?flags:Array<AbstractFlag>, ?from:Array<ComplexType>,
		?to:Array<ComplexType>, ?pos:Position, ?doc:String, ?meta:Metadata, ?params:Array<TypeParamDecl>, ?isExtern:Bool):TypeDefinition {
	return tdef(pack, name, TDAbstract(tthis, flags, from, to), fields, pos, doc, meta, params);
}

function tdField(pack:Array<String>, name:String, kind:FieldType, fields:Array<Field>, ?access:Array<Access>, ?pos:Position, ?doc:String, ?meta:Metadata,
		?params:Array<TypeParamDecl>, ?isExtern:Bool):TypeDefinition {
	return tdef(pack, name, TDField(kind, access), fields, pos, doc, meta, params);
}

function obj(fields:Array<ObjectField>, ?pos:Position):Expr {
	return {
		expr: EObjectDecl(fields),
		pos: pos ?? Context.currentPos()
	}
}

function objField(name:String, ?expr:Expr):ObjectField {
	return {
		field: name,
		expr: expr
	}
}

function meta(name:String, ?params:Array<Expr>, ?pos:Position):MetadataEntry {
	return {
		name: name,
		params: params,
		pos: pos ?? Context.currentPos()
	}
}

function field(name:String, kind:FieldType, ?doc:String, ?access:Array<Access>, ?meta:Metadata, ?pos:Position) {
	return {
		name: name,
		kind: kind,
		doc: doc,
		access: access,
		meta: meta,
		pos: pos ?? Context.currentPos()
	};
}

function variable(name:String, type:ComplexType, ?expr:Expr, ?doc:String, ?access:Array<Access>, ?meta:Metadata, ?pos:Position):Field {
	return field(name, FVar(type, expr), doc, access, meta, pos);
}

function method(name:String, f:Function, ?doc:String, ?access:Array<Access>, ?meta:Metadata, ?pos:Position):Field {
	return field(name, FFun(f), doc, access, meta, pos);
}

function getter(variable:Field, f:Function, ?doc:String, ?access:Array<Access>, ?meta:Metadata, ?pos:Position):Field {
	return switch variable.kind {
		case FProp(get, set, t, e):
			switch get {
				case "get", "null":
					method('get_${variable.name}', f, doc, access, meta, pos);
				default:
					throw 'Can\t add $get getter';
			}
		default: throw 'Can\t add getter to ${variable.kind}';
	}
}

function setter(variable:Field, f:Function, ?doc:String, ?access:Array<Access>, ?meta:Metadata, ?pos:Position):Field {
	return switch variable.kind {
		case FProp(get, set, t, e):
			switch set {
				case "set", "null":
					method('set_${variable.name}', f, doc, access, meta, pos);
				default:
					throw 'Can\t add $set setter';
			}
		default: throw 'Can\t add setter to ${variable.kind}';
	}
}

function toType(type:ComplexType) {
	return ComplexTypeTools.toType(type);
}

function toComplex(type:haxe.macro.Type) {
	return TypeTools.toComplexType(type);
}

function expected():ComplexType {
	return toComplex(Context.getExpectedType() ?? toType(macro :Void));
}

function withLocalImports(code:Void->Void) {
	Context.withImports(resolve(Context.getLocalImports()), resolve(Context.getLocalUsing()), () -> {
		code();
	});
}

overload extern inline function resolve(type:ComplexType, ?pos:Position):ComplexType {
	return toComplex(Context.resolveType(type, pos ?? Context.currentPos()));
}

overload extern inline function resolve(imports:Array<ImportExpr>):Array<String> {
	return imports.map(i -> {
		var path = '${i.path.map(p -> p.name).join(".")}';
		switch i.mode {
			case INormal: path;
			case IAsName(alias): '$path as $alias';
			case IAll: '$path.*';
		}
	});
}

overload extern inline function resolve(usings:Array<Ref<haxe.macro.Type.ClassType>>):Array<String> {
	return usings.map(u -> {
		var c = u.get();
		return '${c.pack.join(".")}${c.name}';
	});
}

function opt(e:Null<Expr>, f:Expr->Expr):Expr {
	return e == null ? null : f(e);
}

function map(e:Expr, f:Expr->Expr):Expr {
	return {
		pos: e.pos,
		expr: switch (e.expr) {
			case EConst(_): e.expr;
			case EArray(e1, e2): EArray(f(e1), f(e2));
			case EBinop(op, e1, e2): EBinop(op, f(e1), f(e2));
			case EField(e, field, kind): EField(f(e), field, kind);
			case EParenthesis(e): EParenthesis(f(e));
			case EObjectDecl(fields):
				var ret = [];
				for (field in fields)
					ret.push({field: field.field, expr: f(field.expr), quotes: field.quotes});
				EObjectDecl(ret);
			case EArrayDecl(el): EArrayDecl(el.map(e -> map(e, f)));
			case ECall(e, params): ECall(f(e), params.map(e -> map(e, f)));
			case ENew(tp, params): ENew(tp, params.map(e -> map(e, f)));
			case EUnop(op, postFix, e): EUnop(op, postFix, f(e));
			case EVars(vars):
				var ret = [];
				for (v in vars) {
					var v2:Var = {name: v.name, type: v.type, expr: opt(v.expr, f)};
					if (v.isFinal != null)
						v2.isFinal = v.isFinal;
					ret.push(v2);
				}
				EVars(ret);
			case EBlock(el): EBlock(el.map(e -> map(e, f)));
			case EFor(it, expr): EFor(f(it), f(expr));
			case EIf(econd, eif, eelse): EIf(f(econd), f(eif), opt(eelse, f));
			case EWhile(econd, e, normalWhile): EWhile(f(econd), f(e), normalWhile);
			case EReturn(e): EReturn(opt(e, f));
			case EUntyped(e): EUntyped(f(e));
			case EThrow(e): EThrow(f(e));
			case ECast(e, t): ECast(f(e), t);
			case EIs(e, t): EIs(f(e), t);
			case EDisplay(e, dk): EDisplay(f(e), dk);
			case ETernary(econd, eif, eelse): ETernary(f(econd), f(eif), f(eelse));
			case ECheckType(e, t): ECheckType(f(e), t);
			case EContinue, EBreak:
				e.expr;
			case ETry(e, catches):
				var ret = [];
				for (c in catches)
					ret.push({name: c.name, type: c.type, expr: f(c.expr)});
				ETry(f(e), ret);
			case ESwitch(e, cases, edef):
				var ret = [];
				for (c in cases)
					ret.push({expr: opt(c.expr, f), guard: opt(c.guard, f), values: c.values.map(e -> map(e, f))});
				ESwitch(f(e), ret, edef == null || edef.expr == null ? edef : f(edef));
			case EFunction(kind, func):
				var ret = [];
				for (arg in func.args)
					ret.push({
						name: arg.name,
						opt: arg.opt,
						type: arg.type,
						value: opt(arg.value, f)
					});
				EFunction(kind, {
					args: ret,
					ret: func.ret,
					params: func.params,
					expr: f(func.expr)
				});
			case EMeta(m, e): EMeta(m, f(e));
		}
	};
}

function has(e:Expr, condition:Expr->Bool, ?options:{?enterFunctions:Bool}) {
	var skipFunctions = options == null || options.enterFunctions != true;
	function seek(e:Expr)
		switch e {
			case {expr: EFunction(_)} if (skipFunctions):
			case _ if (condition(e)):
				throw "Error";
			default:
				ExprTools.iter(e, seek);
		}

	return try {
		ExprTools.iter(e, seek);
		false;
	} catch (e) {
		true;
	}
}
#end
