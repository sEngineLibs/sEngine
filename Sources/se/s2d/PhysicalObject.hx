package se.s2d;

import se.math.Vec2;
import se.math.Mat3;

using se.extensions.Mat3Ext;

abstract class PhysicalObject<This:PhysicalObject<This>> extends VirtualObject<This> {
	var _transform:Transform = Mat3.identity();

	@:isVar public var z(default, set):Float = 0.0;
	public var transform:Transform = Mat3.identity();
	public var transformOrigin:Vec2 = new Vec2(0.0, 0.0);

	inline function updateTransform():Void {
		var t = Mat3.identity();
		t.translateG(transformOrigin);
		t *= transform;
		t.translateG(-transformOrigin);
		_transform = parent == null ? t : parent._transform * t;
	}

	inline function set_z(value:Float):Float {
		z = value;
		for (s in siblings) {
			if (s.z <= z) {
				index = s.index - 1;
				break;
			}
		}
		return value;
	}
}
