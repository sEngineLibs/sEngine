package s2d.core;

import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastMatrix3;

using s2d.core.extensions.FastMatrix3Ext;

abstract class S2DObject<This:S2DObject<This>> {
	var _parent:This = null;

	public var parent(get, set):This;
	public var children:Array<This> = [];

	var finalZ:FastFloat;
	var finalModel:FastMatrix3;

	@:isVar public var z(default, set):FastFloat = 0.0;
	@:isVar public var model(default, set):FastMatrix3 = FastMatrix3.identity();

	public var origin:FastVector2 = {};
	public var translationX(get, set):FastFloat;
	public var translationY(get, set):FastFloat;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var rotation(get, set):FastFloat;

	public function new() {
		finalZ = 0.0;
		finalModel = model;
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
		finalModel = FastMatrix3.translation(origin.x, origin.y).multmat(model).multmat(FastMatrix3.translation(-origin.x, -origin.y));
		if (parent != null)
			finalModel = parent.finalModel.multmat(finalModel);
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

	public function retranslateChild(value:This):Void {
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

	public function retranslateParent():Void {
		if (_parent != null) {
			_parent.retranslateChild(cast this);
		}
	}

	function transform(f:Void->Void) {
		f();
		invalidateTransformation();
	}

	overload extern public inline function translateG(value:FastVector2) {
		transform(() -> {
			model.pushTranslation(value);
		});
	}

	overload extern public inline function translateToG(value:FastVector2) {
		transform(() -> {
			model.setTranslation(value);
		});
	}

	overload extern public inline function scaleG(value:FastVector2) {
		transform(() -> {
			model.pushScale(value);
		});
	}

	overload extern public inline function scaleToG(value:FastVector2) {
		transform(() -> {
			model.setScale(value);
		});
	}

	public function rotateG(value:FastFloat) {
		transform(() -> {
			model.pushRotation(value);
		});
	}

	public function rotateToG(value:FastFloat) {
		transform(() -> {
			model.setRotation(value);
		});
	}

	overload extern public inline function translateL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.translation(x, y));
		});
	}

	overload extern public inline function translateToL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.translation(x - this.translationX, y - this.translationY));
		});
	}

	overload extern public inline function scaleL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.scale(x, y));
		});
	}

	overload extern public inline function scaleToL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.scale(x / scaleX, y / scaleY));
		});
	}

	public function rotateL(value:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.rotation(value));
		});
	}

	public function rotateToL(value:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.rotation(value - rotation));
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

	overload extern public inline function translateL(value:FastVector2) {
		translateL(value.x, value.y);
	}

	overload extern public inline function translateL(value:FastFloat) {
		translateL(value, value);
	}

	overload extern public inline function translateToL(value:FastVector2) {
		translateToL(value.x, value.y);
	}

	overload extern public inline function translateToL(value:FastFloat) {
		translateToL(value, value);
	}

	overload extern public inline function scaleL(value:FastVector2) {
		scaleL(value.x, value.y);
	}

	overload extern public inline function scaleL(value:FastFloat) {
		scaleL(value, value);
	}

	overload extern public inline function scaleToL(value:FastVector2) {
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

	function set_model(value:FastMatrix3):FastMatrix3 {
		transform(() -> {
			model = value;
		});
		return value;
	}

	function get_translationX():FastFloat {
		return model.getTranslationX();
	}

	function set_translationX(value:FastFloat):FastFloat {
		transform(() -> {
			model.setTranslationX(value);
		});
		return value;
	}

	function get_translationY():FastFloat {
		return model.getTranslationY();
	}

	function set_translationY(value:FastFloat):FastFloat {
		transform(() -> {
			model.setTranslationY(value);
		});
		return value;
	}

	function get_scaleX():FastFloat {
		return model.getScaleX();
	}

	function set_scaleX(value:FastFloat):FastFloat {
		transform(() -> {
			model.setScaleX(value);
		});
		return value;
	}

	function get_scaleY():FastFloat {
		return model.getScaleY();
	}

	function set_scaleY(value:FastFloat):FastFloat {
		transform(() -> {
			model.setScaleY(value);
		});
		return value;
	}

	function get_rotation():FastFloat {
		return model.getRotation();
	}

	function set_rotation(value:FastFloat):FastFloat {
		transform(() -> {
			model.setRotation(value);
		});
		return value;
	}
}
