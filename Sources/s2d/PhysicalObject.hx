package s2d;

import se.math.Vec2;
import se.math.Mat3;

abstract class PhysicalObject<This:PhysicalObject<This>> extends se.VirtualObject<This> {
	var _transform:Transform = Mat3.identity();

	@:isVar public var z(default, set):Float = 0.0;
	public var transform:Transform = Mat3.identity();
	public var transformOrigin:Vec2 = new Vec2(0.0, 0.0);

	inline function syncTransform():Void {
		var t = Mat3.translation(transformOrigin.x, transformOrigin.y) * transform * Mat3.translation(-transformOrigin.x, -transformOrigin.y);
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
