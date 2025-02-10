package se;

import se.math.Vec3;
import se.math.Mat4;

using se.extensions.Mat4Ext;

abstract class PhysicalObject3D<This:PhysicalObject3D<This>> extends VirtualObject<This> {
	var _transform:Transform3D = Mat4.identity();

	public var transform:Transform3D = Mat4.identity();
	public var transformOrigin:Vec3 = new Vec3(0.0, 0.0, 0.0);

	inline function updateTransform():Void {
		var t = Mat4.identity();
		t.translateG(transformOrigin);
		t *= transform;
		t.translateG(-transformOrigin);
		_transform = parent == null ? t : parent._transform * t;
	}
}
