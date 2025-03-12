package s2d;

import se.math.Mat3;
import s2d.Transform.LocalTransform;
import s2d.Transform.GlobalTransform;

abstract class PhysicalObject<This:PhysicalObject<This>> extends se.VirtualObject<This> {
	var _transform:Mat3 = Mat3.identity();

	public var transform:Mat3 = Mat3.identity();
	@readonly @alias public var global:GlobalTransform = transform;
	@readonly @alias public var local:LocalTransform = transform;

	@:isVar public var z(default, set):Float = 0.0;

	public function new(?parent:This) {
		super(parent);
	}

	inline function set_z(value:Float):Float {
		final d = value - z;
		for (c in children)
			c.z += d;
		for (s in siblings)
			if (s.z <= z) {
				index = s.index - 1;
				break;
			}
		return z;
	}
}
