package se;

import kha.FastFloat;
import se.math.Vec2;
import se.math.Mat3;

abstract class SObject<This:SObject<This>> {
	var _parent:This = null;

	public var parent(get, set):This;
	public var children:Array<This> = [];

	var finalZ:FastFloat;
	var finalModel:Mat3;

	@:isVar public var z(default, set):FastFloat = 0.0;
	@:isVar public var model(default, set):Mat3 = Mat3.identity();

	public var origin:Vec2;
	public var translationX(get, set):FastFloat;
	public var translationY(get, set):FastFloat;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var rotation(get, set):FastFloat;

	public function new() {
		this.origin = new Vec2(0.0, 0.0);
		this.finalModel = this.model;
		this.finalZ = this.z;
	}

	public function toString():String {
		return Type.getClassName(Type.getClass(this));
	}

	abstract function onParentChanged():Void;

	abstract function onZChanged():Void;

	abstract function onTransformationChanged():Void;

	function invalidateZ():Void {
		finalZ = parent == null ? z : parent.finalZ + z;
		onZChanged();
		for (c in children)
			c.invalidateZ();
	}

	function invalidateTransformation():Void {
		finalModel = Mat3.translationMatrix(origin.x, origin.y);
		finalModel *= model;
		finalModel *= Mat3.translationMatrix(-origin.x, -origin.y);

		if (parent != null)
			finalModel = parent.finalModel * finalModel;
		onTransformationChanged();
		for (c in children)
			c.invalidateTransformation();
	}

	public function addChild(value:This):Void {
		if (value != null || value != this || !children.contains(value)) {
			value._parent = cast this;
			value.onParentChanged();
			children.push(value);
		}
	}

	public function removeChild(value:This):Void {
		if (value != null || value != this || children.contains(value)) {
			value._parent = null;
			children.remove(value);
		}
	}

	public function setParent(value:This):Void {
		if (value != null) {
			value.addChild(cast this);
		}
	}

	public function removeParent():Void {
		if (_parent != null) {
			_parent.removeChild(cast this);
		}
	}

	function transform(f:Void->Void) {
		f();
		invalidateTransformation();
	}

	overload extern public inline function translateG(value:Vec2) {
		transform(() -> {
			model.pushTranslation(value);
		});
	}

	overload extern public inline function translateToG(value:Vec2) {
		transform(() -> {
			model.translation = value;
		});
	}

	overload extern public inline function scaleG(value:Vec2) {
		transform(() -> {
			model.pushScale(value);
		});
	}

	overload extern public inline function scaleToG(value:Vec2) {
		transform(() -> {
			model.scale = value;
		});
	}

	public function rotateG(value:FastFloat) {
		transform(() -> {
			model.pushRotation(value);
		});
	}

	public function rotateToG(value:FastFloat) {
		transform(() -> {
			model.rotation = value;
		});
	}

	overload extern public inline function translateL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model *= Mat3.translationMatrix(x, y);
		});
	}

	overload extern public inline function translateToL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = Mat3.translationMatrix(x - this.translationX, y - this.translationY);
		});
	}

	overload extern public inline function scaleL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model *= Mat3.scaleMatrix(x, y);
		});
	}

	overload extern public inline function scaleToL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model *= Mat3.scaleMatrix(x / scaleX, y / scaleY);
		});
	}

	public function rotateL(value:FastFloat) {
		transform(() -> {
			model *= Mat3.rotationMatrix(value);
		});
	}

	public function rotateToL(value:FastFloat) {
		transform(() -> {
			model *= Mat3.rotationMatrix(value - rotation);
		});
	}

	overload extern public inline function translateG(x:FastFloat, y:FastFloat) {
		translateG({x: x, y: y});
	}

	overload extern public inline function translateG(value:FastFloat) {
		translateG(value, value);
	}

	overload extern public inline function translateToG(x:FastFloat, y:FastFloat) {
		translateToG({x: x, y: y});
	}

	overload extern public inline function translateToG(value:FastFloat) {
		translateToG(value, value);
	}

	overload extern public inline function scaleG(x:FastFloat, y:FastFloat) {
		scaleG({x: x, y: y});
	}

	overload extern public inline function scaleG(value:FastFloat) {
		scaleG(value, value);
	}

	overload extern public inline function scaleToG(x:FastFloat, y:FastFloat) {
		scaleToG({x: x, y: y});
	}

	overload extern public inline function scaleToG(value:FastFloat) {
		scaleToG(value, value);
	}

	overload extern public inline function translateL(value:Vec2) {
		translateL(value.x, value.y);
	}

	overload extern public inline function translateL(value:FastFloat) {
		translateL(value, value);
	}

	overload extern public inline function translateToL(value:Vec2) {
		translateToL(value.x, value.y);
	}

	overload extern public inline function translateToL(value:FastFloat) {
		translateToL(value, value);
	}

	overload extern public inline function scaleL(value:Vec2) {
		scaleL(value.x, value.y);
	}

	overload extern public inline function scaleL(value:FastFloat) {
		scaleL(value, value);
	}

	overload extern public inline function scaleToL(value:Vec2) {
		scaleToL(value.x, value.y);
	}

	overload extern public inline function scaleToL(value:FastFloat) {
		scaleToL(value, value);
	}

	function get_parent():This {
		return _parent;
	}

	function set_parent(value:This):This {
		setParent(value);
		return value;
	}

	function set_z(value:FastFloat):FastFloat {
		z = value;
		invalidateZ();
		return value;
	}

	function set_model(value:Mat3):Mat3 {
		transform(() -> {
			model = value;
		});
		return value;
	}

	function get_translationX():FastFloat {
		return model.translationX;
	}

	function set_translationX(value:FastFloat):FastFloat {
		transform(() -> {
			model.translationX = value;
		});
		return value;
	}

	function get_translationY():FastFloat {
		return model.translationY;
	}

	function set_translationY(value:FastFloat):FastFloat {
		transform(() -> {
			model.translationY = value;
		});
		return value;
	}

	function get_scaleX():FastFloat {
		return model.scaleX;
	}

	function set_scaleX(value:FastFloat):FastFloat {
		transform(() -> {
			model.scaleX = value;
		});
		return value;
	}

	function get_scaleY():FastFloat {
		return model.scaleY;
	}

	function set_scaleY(value:FastFloat):FastFloat {
		transform(() -> {
			model.scaleY = value;
		});
		return value;
	}

	function get_rotation():FastFloat {
		return model.rotation;
	}

	function set_rotation(value:FastFloat):FastFloat {
		transform(() -> {
			model.rotation = value;
		});
		return value;
	}
}
