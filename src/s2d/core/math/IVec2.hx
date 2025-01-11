package s2d.core.math;

@:structInit
class IVec2 {
	public var x:Int = 0;
	public var y:Int = 0;

	public inline function add(value:IVec2):IVec2 {
		return {x: x + value.x, y: y + value.y};
	}

	public inline function addValue(value:Int):IVec2 {
		return {x: x + value, y: y + value};
	}

	public inline function sub(value:IVec2):IVec2 {
		return {x: x - value.x, y: y - value.y};
	}

	public inline function subValue(value:Int):IVec2 {
		return {x: x - value, y: y - value};
	}

	public inline function mult(value:IVec2):IVec2 {
		return {x: x * value.x, y: y * value.y};
	}

	public inline function multValue(value:Int):IVec2 {
		return {x: x * value, y: y * value};
	}

	public inline function div(value:IVec2):IVec2 {
		return {x: Std.int(x / value.x), y: Std.int(y / value.y)};
	}

	public inline function divValue(value:Int):IVec2 {
		return {x: Std.int(x / value), y: Std.int(y / value)};
	}

	public inline function mod(value:IVec2):IVec2 {
		return {x: x % value.x, y: y % value.y};
	}

	public inline function modValue(value:Int):IVec2 {
		return {x: x % value, y: y % value};
	}
}
