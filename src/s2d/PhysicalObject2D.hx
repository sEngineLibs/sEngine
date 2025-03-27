package s2d;

import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

abstract class PhysicalObject2D<This:PhysicalObject2D<This>> extends se.VirtualObject<This> {
	@track public var visible:Bool = true;
	public var vChildren:Array<This> = [];
	public var index(get, never):Int;
	@:isVar public var z(default, set):Float = 0.0;

	@:signal function vChildAdded(child:This):Void;

	@:signal function vChildMoved(child:This):Void;

	@:signal function vChildRemoved(child:This):Void;

	var globalTransform:Mat3 = Mat3.identity();

	public var origin:Vec2 = vec2(0.0, 0.0);
	public var transform:Mat3 = Mat3.identity();

	public var translationX(get, set):Float;
	public var translationY(get, set):Float;
	public var translation(get, set):Vec2;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var scale(get, set):Vec2;
	public var rotation(get, set):Float;

	public function new() {
		onParentChanged(_ -> syncTransform());
	}

	function insertVChild(el:This) {
		for (i in 0...vChildren.length)
			if (vChildren[i].z > el.z) {
				vChildren.insert(i, el);
				return;
			}
		vChildren.push(el);
	}

	function removeVChild(el:This) {
		vChildren.remove(el);
	}

	@:slot(childAdded)
	function __childAdded__(child:This) {
		if (child.visible) {
			insertVChild(child);
			vChildAdded(child);
		}
		var slot = v -> {
			if (!v && child.visible) {
				insertVChild(child);
				vChildAdded(child);
			} else if (v && !child.visible) {
				removeVChild(child);
				vChildRemoved(child);
			}
		};
		child.onVisibleChanged(slot);
		child.onParentChanged(_ -> child.offVisibleChanged(slot));
	}

	@:slot(childRemoved)
	function __childRemoved__(child:This) {
		if (child.visible)
			removeVChild(child);
	}

	function get_index():Int {
		return parent?.vChildren.indexOf(cast this);
	}

	function set_z(value:Float):Float {
		z = value;
		if (visible && parent != null) {
			parent.removeVChild(cast this);
			parent.insertVChild(cast this);
			parent.vChildMoved(cast this);
		}
		return z;
	}

	extern overload public inline function translate(x:Float, y:Float) {
		transform *= Mat3.translation(x, y);
		syncTransform();
	}

	extern overload public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	extern overload public inline function translate(value:Float) {
		translate(value, value);
	}

	extern overload public inline function upscale(x:Float, y:Float) {
		transform *= Mat3.scale(x, y);
		syncTransform();
	}

	extern overload public inline function upscale(value:Vec2) {
		upscale(value.x, value.y);
	}

	extern overload public inline function upscale(value:Float) {
		upscale(value, value);
	}

	public function rotate(value:Float) {
		transform *= Mat3.rotation(value);
		syncTransform();
	}

	function syncTransform():Void {
		globalTransform = Mat3.translation(-origin.x, -origin.y);
		globalTransform *= parent != null ? transform * parent.globalTransform : transform;
		globalTransform *= Mat3.translation(origin.x, origin.y);
		for (c in children)
			c.syncTransform();
	}

	function get_translationX():Float {
		return transform._20;
	}

	function set_translationX(value:Float) {
		transform._20 = value;
		syncTransform();
		return value;
	}

	function get_translationY():Float {
		return transform._21;
	}

	function set_translationY(value:Float) {
		transform._21 = value;
		syncTransform();
		return value;
	}

	function get_translation():Vec2 {
		return vec2(translationX, translationY);
	}

	function set_translation(value:Vec2) {
		transform._20 = value.x;
		transform._21 = value.y;
		syncTransform();
		return value;
	}

	function get_scaleX():Float {
		return Math.sqrt(transform._00 * transform._00 + transform._10 * transform._10);
	}

	function set_scaleX(value:Float) {
		var s = scaleX;
		if (s != 0) {
			var d = value / s;
			transform._00 *= d;
			transform._10 *= d;
		} else {
			transform._00 = value;
			transform._10 = value;
		}
		syncTransform();
		return value;
	}

	function get_scaleY():Float {
		return Math.sqrt(transform._01 * transform._01 + transform._11 * transform._11);
	}

	function set_scaleY(value:Float) {
		var s = scaleY;
		if (s != 0) {
			var d = value / s;
			transform._01 *= d;
			transform._11 *= d;
		} else {
			transform._01 = value;
			transform._11 = value;
		}
		syncTransform();
		return value;
	}

	function get_scale():Vec2 {
		return vec2(scaleX, scaleY);
	}

	function set_scale(value:Vec2) {
		var sx = scaleX;
		var sy = scaleY;
		if (sx != 0) {
			var d = value.x / sx;
			transform._00 *= d;
			transform._10 *= d;
		} else {
			transform._00 = value.x;
			transform._10 = value.x;
		}
		if (sy != 0) {
			var d = value.y / sy;
			transform._01 *= d;
			transform._11 *= d;
		} else {
			transform._01 = value.y;
			transform._11 = value.y;
		}
		syncTransform();
		return value;
	}

	function get_rotation():Float {
		return Math.atan2(transform._10, transform._00);
	}

	function set_rotation(value:Float) {
		var c = Math.cos(value);
		var s = Math.sin(value);
		var sx = scaleX;
		var sy = scaleY;

		transform._00 = c * sx;
		transform._10 = s * sx;
		transform._01 = -s * sy;
		transform._11 = c * sy;

		syncTransform();
		return value;
	}
}
