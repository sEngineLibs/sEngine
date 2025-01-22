package s2d.objects;

import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastMatrix3;
// s2d
import s2d.core.utils.MathUtils;

@:autoBuild(s2d.core.macro.SMacro.build())
abstract class StageObject {
	@readonly public var layer:Layer;
	@readonly public var model:FastMatrix3 = FastMatrix3.identity();

	var _parent:StageObject = null;
	var _transformationSource:StageObject = null;

	public var parent(get, set):StageObject;
	public var transformationSource(get, set):StageObject;
	@readonly public var children:Array<StageObject> = [];
	@readonly public var transformationTargets:Array<StageObject> = [];

	var finalModel:FastMatrix3;
	var finalZ:FastFloat;

	@:isVar public var z(default, set):FastFloat = 0.0;
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var rotation(get, set):FastFloat;

	public inline function new(layer:Layer) {
		this.layer = layer;
	}

	abstract function onZChanged():Void;

	abstract function onTransformationChanged():Void;

	inline function invalidateZ():Void {
		if (parent != null)
			finalZ = clamp(parent.finalZ + z, 0.0, 1.0);
		else
			finalZ = clamp(z, 0.0, 1.0);
		onZChanged();
		for (c in children)
			c.invalidateZ();
	}

	inline function invalidateTransformation():Void {
		finalModel = model;
		if (parent != null)
			finalModel = parent.finalModel.multmat(finalModel);
		if (transformationSource != null)
			finalModel = finalModel.multmat(transformationSource.finalModel);
		onTransformationChanged();
		for (c in children)
			c.invalidateTransformation();
		for (t in transformationTargets)
			t.invalidateTransformation();
	}

	public inline function addChild(value:StageObject):Void {
		if (value == null || value == this || children.contains(value))
			return;
		value._parent = this;
		children.push(value);
	}

	public inline function removeChild(value:StageObject):Void {
		if (value == null || value == this || !children.contains(value))
			return;
		value._parent = null;
		children.remove(value);
	}

	public inline function setParent(value:StageObject):Void {
		if (value != null)
			value.addChild(this);
	}

	public inline function removeParent():Void {
		if (_parent != null)
			_parent.removeChild(this);
	}

	public inline function addTransformationTarget(value:StageObject):Void {
		if (value == null || value == this || transformationTargets.contains(value))
			return;
		value._transformationSource = this;
		transformationTargets.push(value);
	}

	public inline function removeTransformationTarget(value:StageObject):Void {
		if (value == null || value == this || !transformationTargets.contains(value))
			return;
		value._transformationSource = null;
		transformationTargets.remove(value);
	}

	public inline function setTransformationSource(value:StageObject):Void {
		if (value != null)
			value.addTransformationTarget(this);
	}

	public inline function removeTransformationSource():Void {
		if (_transformationSource != null)
			_transformationSource.removeTransformationTarget(this);
	}

	inline function transform(f:Void->Void) {
		f();
		invalidateTransformation();
	}

	overload extern public inline function moveG(x:FastFloat, y:FastFloat) {
		transform(() -> {
			this.x += x;
			this.y += y;
		});
	}

	overload extern public inline function moveG(value:FastFloat) {
		moveG(value, value);
	}

	overload extern public inline function moveG(value:FastVector2) {
		moveG(value.x, value.y);
	}

	overload extern public inline function moveToG(x:FastFloat, y:FastFloat) {
		transform(() -> {
			this.x = x;
			this.y = y;
		});
	}

	overload extern public inline function moveToG(value:FastVector2) {
		moveToG(value.x, value.y);
	}

	overload extern public inline function moveToG(value:FastFloat) {
		moveToG(value, value);
	}

	overload extern public inline function scaleG(x:FastFloat, y:FastFloat) {
		transform(() -> {
			this.scaleX *= x;
			this.scaleY *= y;
		});
	}

	overload extern public inline function scaleG(value:FastVector2) {
		scaleG(value.x, value.y);
	}

	overload extern public inline function scaleG(value:FastFloat) {
		scaleG(value, value);
	}

	overload extern public inline function scaleToG(x:FastFloat, y:FastFloat) {
		transform(() -> {
			this.scaleX = x;
			this.scaleY = y;
		});
	}

	overload extern public inline function scaleToG(value:FastVector2) {
		scaleToG(value.x, value.y);
	}

	overload extern public inline function scaleToG(value:FastFloat) {
		scaleToG(value, value);
	}

	public inline function rotateG(angle:FastFloat) {
		transform(() -> {
			this.rotation += angle;
		});
	}

	public inline function rotateToG(angle:FastFloat) {
		transform(() -> {
			this.rotation = angle;
		});
	}

	overload extern public inline function moveL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.translation(x, y));
		});
	}

	overload extern public inline function moveL(value:FastFloat) {
		moveL(value, value);
	}

	overload extern public inline function moveL(value:FastVector2) {
		moveL(value.x, value.y);
	}

	overload extern public inline function moveToL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.translation(x - this.x, y - this.y));
		});
	}

	overload extern public inline function moveToL(value:FastVector2) {
		moveToL(value.x, value.y);
	}

	overload extern public inline function moveToL(value:FastFloat) {
		moveToL(value, value);
	}

	overload extern public inline function scaleL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.scale(x, y));
		});
	}

	overload extern public inline function scaleL(value:FastVector2) {
		scaleL(value.x, value.y);
	}

	overload extern public inline function scaleL(value:FastFloat) {
		scaleL(value, value);
	}

	overload extern public inline function scaleToL(x:FastFloat, y:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.scale(x / scaleX, y / scaleY));
		});
	}

	overload extern public inline function scaleToL(value:FastVector2) {
		scaleToL(value.x, value.y);
	}

	overload extern public inline function scaleToL(value:FastFloat) {
		scaleToL(value, value);
	}

	public inline function rotateL(angle:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.rotation(angle));
		});
	}

	public inline function rotateToL(angle:FastFloat) {
		transform(() -> {
			model = model.multmat(FastMatrix3.rotation(angle - rotation));
		});
	}

	inline function get_parent():StageObject {
		return _parent;
	}

	inline function set_parent(value:StageObject):StageObject {
		setParent(value);
		return value;
	}

	inline function get_transformationSource():StageObject {
		return _transformationSource;
	}

	inline function set_transformationSource(value:StageObject):StageObject {
		setTransformationSource(value);
		return value;
	}

	inline function set_z(value:FastFloat) {
		z = value;
		invalidateZ();
		return z;
	}

	inline function get_x():FastFloat {
		return model._20;
	}

	inline function set_x(value:FastFloat):FastFloat {
		transform(() -> {
			model._20 = value;
		});
		return value;
	}

	inline function get_y():FastFloat {
		return model._21;
	}

	inline function set_y(value:FastFloat):FastFloat {
		transform(() -> {
			model._21 = value;
		});
		return value;
	}

	inline function get_scaleX():FastFloat {
		return Math.sqrt(model._00 * model._00 + model._10 * model._10);
	}

	inline function set_scaleX(value:FastFloat):FastFloat {
		transform(() -> {
			var xt = new FastVector2(model._00, model._10).normalized();
			model._00 = xt.x * value;
			model._10 = xt.y * value;
		});
		return value;
	}

	inline function get_scaleY():FastFloat {
		return Math.sqrt(model._01 * model._01 + model._11 * model._11);
	}

	inline function set_scaleY(value:FastFloat):FastFloat {
		transform(() -> {
			var yt = new FastVector2(model._01, model._11).normalized();
			model._01 = yt.x * value;
			model._11 = yt.y * value;
		});
		return value;
	}

	inline function get_rotation():FastFloat {
		return Math.atan2(model._10, model._00);
	}

	inline function set_rotation(value:FastFloat):FastFloat {
		transform(() -> {
			var sx = scaleX;
			var sy = scaleY;
			var c = Math.cos(value);
			var s = Math.sin(value);
			model._00 = c * sx;
			model._10 = s * sx;
			model._01 = -s * sy;
			model._11 = c * sy;
		});
		return value;
	}
}
