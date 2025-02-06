package s2d.math;

#if macro
import haxe.macro.Expr.ExprOf;
#end

@:nullSafety
abstract Vec4I(Vec4IData) from Vec4IData to Vec4IData {
	#if !macro
	public var x(get, set):Int;

	inline function get_x()
		return this.x;

	inline function set_x(v:Int)
		return this.x = v;

	public var y(get, set):Int;

	inline function get_y()
		return this.y;

	inline function set_y(v:Int)
		return this.y = v;

	public var z(get, set):Int;

	inline function get_z()
		return this.z;

	inline function set_z(v:Int)
		return this.z = v;

	public var w(get, set):Int;

	inline function get_w()
		return this.w;

	inline function set_w(v:Int)
		return this.w = v;

	public inline function new(x:Int, y:Int, z:Int, w:Int) {
		this = new Vec4IData(x, y, z, w);
	}

	@:from
	public static inline function fromVec4(value:Vec4):Vec4I {
		return new Vec4I(Std.int(value.x), Std.int(value.y), Std.int(value.z), Std.int(value.w));
	}

	public inline function set(x:Int, y:Int, z:Int, w:Int) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public inline function clone() {
		return new Vec4I(x, y, z, w);
	}

	public inline function toString() {
		return 'vec4(${x}, ${y}, ${z}, ${w})';
	}

	@:op([])
	inline function arrayRead(i:Int)
		return switch i {
			case 0: x;
			case 1: y;
			case 2: z;
			case 3: w;
			default: null;
		}

	@:op([])
	inline function arrayWrite(i:Int, v:Int)
		return switch i {
			case 0: x = v;
			case 1: y = v;
			case 2: z = v;
			case 3: w = v;
			default: null;
		}

	@:op(-a)
	static inline function neg(a:Vec4I)
		return new Vec4I(-a.x, -a.y, -a.z, -a.w);

	@:op(++a)
	static inline function prefixIncrement(a:Vec4I) {
		++a.x;
		++a.y;
		++a.z;
		++a.w;
		return a.clone();
	}

	@:op(--a)
	static inline function prefixDecrement(a:Vec4I) {
		--a.x;
		--a.y;
		--a.z;
		--a.w;
		return a.clone();
	}

	@:op(a++)
	static inline function postfixIncrement(a:Vec4I) {
		var ret = a.clone();
		++a.x;
		++a.y;
		++a.z;
		++a.w;
		return ret;
	}

	@:op(a--)
	static inline function postfixDecrement(a:Vec4I) {
		var ret = a.clone();
		--a.x;
		--a.y;
		--a.z;
		--a.w;
		return ret;
	}

	@:op(a * b)
	static inline function mul(a:Vec4I, b:Vec4I):Vec4I
		return new Vec4I(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w);

	@:op(a * b) @:commutative
	static inline function mulScalar(a:Vec4I, b:Int):Vec4I
		return new Vec4I(a.x * b, a.y * b, a.z * b, a.w * b);

	@:op(a / b)
	static inline function div(a:Vec4I, b:Vec4I):Vec4I
		return new Vec4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w);

	@:op(a / b)
	static inline function divScalar(a:Vec4I, b:Int):Vec4I
		return new Vec4(a.x / b, a.y / b, a.z / b, a.w / b);

	@:op(a / b)
	static inline function divScalarInv(a:Int, b:Vec4I):Vec4I
		return new Vec4(a / b.x, a / b.y, a / b.z, a / b.w);

	@:op(a + b)
	static inline function add(a:Vec4I, b:Vec4I):Vec4I
		return new Vec4I(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);

	@:op(a + b) @:commutative
	static inline function addScalar(a:Vec4I, b:Int):Vec4I
		return new Vec4I(a.x + b, a.y + b, a.z + b, a.w + b);

	@:op(a - b)
	static inline function sub(a:Vec4I, b:Vec4I):Vec4I
		return new Vec4I(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);

	@:op(a - b)
	static inline function subScalar(a:Vec4I, b:Int):Vec4I
		return new Vec4I(a.x - b, a.y - b, a.z - b, a.w - b);

	@:op(b - a)
	static inline function subScalarInv(a:Int, b:Vec4I):Vec4I
		return new Vec4I(a - b.x, a - b.y, a - b.z, a - b.w);

	@:op(a == b)
	static inline function equal(a:Vec4I, b:Vec4I):Bool
		return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;

	@:op(a != b)
	static inline function notEqual(a:Vec4I, b:Vec4I):Bool
		return !equal(a, b);
	#end // !macro

	// macros

	/**
	 * Copy from any object with .x .y .z .w fields
	 */
	@:overload(function(source:{
		x:Int,
		y:Int,
		z:Int,
		w:Int
	}):Vec4I {})
	public macro function copyFrom(self:ExprOf<Vec4I>, source:ExprOf<{
		x:Int,
		y:Int,
		z:Int,
		w:Int
	}>):ExprOf<Vec4I> {
		return macro {
			var self = $self;
			var source = $source;
			self.x = source.x;
			self.y = source.y;
			self.z = source.z;
			self.w = source.w;
			self;
		}
	}

	/**
	 * Copy into any object with .x .y .z .w fields
	 */
	@:overload(function(target:{
		x:Int,
		y:Int,
		z:Int,
		w:Int
	}):{
		x:Int,
		y:Int,
		z:Int,
		w:Int
	} {})
	public macro function copyInto(self:ExprOf<Vec4I>, target:ExprOf<{x:Int, y:Int, z:Int}>):ExprOf<{x:Int, y:Int, z:Int}> {
		return macro {
			var self = $self;
			var target = $target;
			target.x = self.x;
			target.y = self.y;
			target.z = self.z;
			target.w = self.w;
			target;
		}
	}

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyIntoArray(self:ExprOf<Vec4I>, array:ExprOf<ArrayAccess<Int>>, index:ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			array[0 + i] = self.x;
			array[1 + i] = self.y;
			array[2 + i] = self.z;
			array[3 + i] = self.w;
			array;
		}
	}

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyFromArray(self:ExprOf<Vec4I>, array:ExprOf<ArrayAccess<Int>>, index:ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self.x = array[0 + i];
			self.y = array[1 + i];
			self.z = array[2 + i];
			self.w = array[3 + i];
			self;
		}
	}

	// static macros

	/**
	 * Create from any object with .x .y .z .w fields
	 */
	@:overload(function(source:{
		x:Int,
		y:Int,
		z:Int,
		w:Int
	}):Vec4I {})
	public static macro function from(xyzw:ExprOf<{
		x:Int,
		y:Int,
		z:Int,
		w:Int
	}>):ExprOf<Vec4I> {
		return macro {
			var source = $xyzw;
			new Vec4I(source.x, source.y, source.z, source.w);
		}
	}

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public static macro function fromArray(array:ExprOf<ArrayAccess<Int>>, index:ExprOf<Int>):ExprOf<Vec4I> {
		return macro {
			var array = $array;
			var i:Int = $index;
			new Vec4I(array[0 + i], array[1 + i], array[2 + i], array[3 + i]);
		}
	}
}

private class Vec4IData {
	public var x:Int;
	public var y:Int;
	public var z:Int;
	public var w:Int;

	public inline function new(x:Int = 0, y:Int = 0, z:Int = 0, w:Int = 0):Void {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
}
