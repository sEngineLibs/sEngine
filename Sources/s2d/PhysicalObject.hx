package s2d;

import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

abstract class PhysicalObject<This:PhysicalObject<This>> extends se.VirtualObject<This> {
	@:track public var z:Float = 0.0;
	@:track @:isVar public var transform(default, set):Mat3 = Mat3.identity();

	@readonly @alias public var global:Global<This> = this;
	@readonly @alias public var local:Local<This> = this;

	public function new(?parent:This) {
		super(parent);
	}

	@:slot(zChanged) function _zChanged(z:Float) {
		for (s in siblings)
			if (s.z <= z) {
				index = s.index - 1;
				break;
			}
	}

	private inline function set_transform(value:Mat3):Mat3 {
		final d = inverse(transform) * value;
		transform = value;
		for (c in children)
			c.transform = c.transform * d;
		return value;
	}
}

extern abstract Global<This:PhysicalObject<This>>(PhysicalObject<This>) from PhysicalObject<This> {
	overload extern public inline function translate(x:Float, y:Float) {
		this.transform = this.transform * Mat3.translation(x, y);
	}

	overload extern public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload extern public inline function translate(value:Float) {
		translate(value, value);
	}

	overload extern public inline function scale(x:Float, y:Float) {
		this.transform = this.transform * Mat3.scale(x, y);
	}

	overload extern public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload extern public inline function scale(value:Float) {
		scale(value, value);
	}

	extern public inline function rotate(value:Float) {
		this.transform = this.transform * Mat3.rotation(value);
	}
}

extern abstract Local<This:PhysicalObject<This>>(PhysicalObject<This>) from PhysicalObject<This> {
	overload extern public inline function translate(x:Float, y:Float) {
		this.transform = Mat3.translation(x, y) * this.transform;
	}

	overload extern public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload extern public inline function translate(value:Float) {
		translate(value, value);
	}

	overload extern public inline function scale(x:Float, y:Float) {
		this.transform = Mat3.scale(x, y) * this.transform;
	}

	overload extern public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload extern public inline function scale(value:Float) {
		scale(value, value);
	}

	extern public inline function rotate(value:Float) {
		this.transform = Mat3.rotation(value) * this.transform;
	}
}
