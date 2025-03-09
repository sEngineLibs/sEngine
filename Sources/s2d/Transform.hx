package s2d;

import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

extern abstract GlobalTransform(Mat3) from Mat3 {
	overload public inline function translate(x:Float, y:Float) {
		this *= Mat3.translation(x, y);
	}

	overload public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload public inline function translate(value:Float) {
		translate(value, value);
	}

	overload public inline function scale(x:Float, y:Float) {
		this *= Mat3.scale(x, y);
	}

	overload public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload public inline function scale(value:Float) {
		scale(value, value);
	}

	public inline function rotate(value:Float) {
		this *= Mat3.rotation(value);
	}
}

extern abstract LocalTransform(Mat3) from Mat3 {
	overload public inline function translate(x:Float, y:Float) {
		this.copyFrom(Mat3.translation(x, y) * this);
	}

	overload public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload public inline function translate(value:Float) {
		translate(value, value);
	}

	overload public inline function scale(x:Float, y:Float) {
		this.copyFrom(Mat3.scale(x, y) * this);
	}

	overload public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload public inline function scale(value:Float) {
		scale(value, value);
	}

	public inline function rotate(value:Float) {
		this.copyFrom(Mat3.rotation(value) * this);
	}
}
