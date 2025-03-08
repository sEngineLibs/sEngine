package s2d;

import se.math.Vec2;
import se.math.Mat3;

abstract class PhysicalObject<This:PhysicalObject<This>> extends se.VirtualObject<This> {
	public var _transform:Mat3;

	@:track public var z:Float = 0.0;
	@:track public var transform:Mat3 = Mat3.identity();

	public function new(?parent:This) {
		super(parent);
	}

	overload extern public inline function translate(x:Float, y:Float) {
		transform *= Mat3.translation(x, y);
	}

	overload extern public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload extern public inline function translate(value:Float) {
		translate(value, value);
	}

	overload extern public inline function scale(x:Float, y:Float) {
		transform *= Mat3.scale(x, y);
	}

	overload extern public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload extern public inline function scale(value:Float) {
		scale(value, value);
	}

	extern public inline function rotate(value:Float) {
		transform *= Mat3.rotation(value);
	}

	@:slot(zChanged) function _zChanged(z:Float) {
		for (s in siblings)
			if (s.z <= z) {
				index = s.index - 1;
				break;
			}
	}

	@:slot(transformChanged) function _transformChanged(transform:Mat3) {
		traverse(c -> c.transform = transform * c.transform);
	}
}
