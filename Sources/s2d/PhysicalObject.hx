package s2d;

import se.math.Vec2;
import se.math.Mat3;

abstract class PhysicalObject<This:PhysicalObject<This>> extends se.VirtualObject<This> {
	var _transform:Transform = Mat3.identity();

	@:track public var z:Float = 0.0;
	public var transform:Transform = Mat3.identity();
	public var transformOrigin:Vec2 = new Vec2(0.0, 0.0);

	public function new(?parent) {
		super(parent);
		onZChanged(z -> {
			for (s in siblings) {
				if (s.z <= z) {
					index = s.index - 1;
					break;
				}
			}
		});
	}

	inline function syncTransform():Void {
		var t = Mat3.translation(transformOrigin.x, transformOrigin.y) * transform * Mat3.translation(-transformOrigin.x, -transformOrigin.y);
		_transform = parent == null ? t : parent._transform * t;
	}
}
