package se;

import se.math.Vec2;
import se.math.Mat3;

using se.extensions.Mat3Ext;

abstract class PhysicalObject<This:PhysicalObject<This>> extends VirtualObject<This> {
	var _transform:Transform = Mat3.identity();

	public var z:Float = 0.0;
	public var transform:Transform = Mat3.identity();
	public var transformOrigin:Vec2 = new Vec2(0.0, 0.0);

	inline function updateTransform():Void {
		var t = Mat3.identity();
		t.translateG(transformOrigin);
		t *= transform;
		t.translateG(-transformOrigin);
		_transform = parent == null ? t : parent._transform * t;
	}
}
