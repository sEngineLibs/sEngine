package s2d.objects;

import s2d.math.Vec2;
import s2d.math.Vec3;
import s2d.math.Mat4;

class Object {
	@:isVar public var parent(default, null):Object = null;
	@:isVar public var children(default, null):Array<Object> = [];

	public var location(get, set):Vec3;
	public var scale(get, set):Vec2;
	public var rotation(get, set):Float;

	public var transformation:Mat4 = Mat4.identity();
	public var finalTransformation(get, never):Mat4;

	public inline function new() {}

	inline function get_location():Vec3 {
		return transformation.translation;
	}

	inline function set_location(value:Vec3):Vec3 {
		transformation.translation = value;
		return value;
	}

	inline function get_scale():Vec2 {
		return transformation.scale;
	}

	inline function set_scale(value:Vec2):Vec2 {
		transformation.scale = value;
		return value;
	}

	inline function get_rotation():Float {
		return transformation.rotation;
	}

	inline function set_rotation(value:Float):Float {
		transformation.rotation = value;
		return value;
	}

	public inline function setParent(value:Object):Void {
		if (parent == value)
			return;

		removeParent();

		if (value != null) {
			if (!value.children.contains(this))
				value.addChild(this);
			parent = value;
		}
	}

	public inline function removeParent():Void {
		if (parent != null)
			parent.removeChild(this);
		parent = null;
	}

	public inline function addChild(value:Object):Void {
		if (value == null || value == this)
			return;

		if (!children.contains(value)) {
			children.push(value);
			value.setParent(this);
		}
	}

	public inline function removeChild(value:Object):Void {
		if (value != null && children.remove(value))
			value.removeParent();
	}

	inline function get_finalTransformation():Mat4 {
		return parent == null ? transformation : parent.finalTransformation * transformation;
	}
}
