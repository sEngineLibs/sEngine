package s2d;

import se.math.Mat3;
import s2d.Transform.LocalTransform;
import s2d.Transform.GlobalTransform;

abstract class PhysicalObject<This:PhysicalObject<This>> extends se.VirtualObject<This> {
	@:track public var z:Float = 0.0;

	public var transform:Mat3 = Mat3.identity();
	
	@readonly @alias public var global:GlobalTransform = transform;
	@readonly @alias public var local:LocalTransform = transform;

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
}
