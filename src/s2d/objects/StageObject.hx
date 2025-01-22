package s2d.objects;

import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastMatrix3;
// s2d
import s2d.core.utils.MathUtils;

@:autoBuild(s2d.core.macro.SMacro.build())
abstract class StageObject {
	@readonly public var layer:Layer;
	@readonly public var children:Array<StageObject> = [];
	@readonly public var targets:Array<StageObject> = [];
	@readonly public var model:FastMatrix3 = FastMatrix3.identity();

	var _parent:StageObject = null;
	var _source:StageObject = null;

	public var parent(get, set):StageObject;
	public var source(get, set):StageObject;

	@:isVar public var z(default, set):FastFloat;
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var rotation(get, set):FastFloat;

	var finalModel:FastMatrix3;
	var finalZ:FastFloat;

	public inline function new(layer:Layer) {
		this.layer = layer;
	}

	abstract function reset():Void;

	inline function invalidate():Void {
		reset();
		for (c in children)
			c.invalidate();
		for (t in targets)
			t.invalidate();
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

	public inline function addTarget(value:StageObject):Void {
		if (value == null || value == this || targets.contains(value))
			return;
		value._source = this;
		targets.push(value);
	}

	public inline function removeTarget(value:StageObject):Void {
		if (value == null || value == this || !targets.contains(value))
			return;
		value._source = null;
		targets.remove(value);
	}

	public inline function setSource(value:StageObject):Void {
		if (value != null)
			value.addTarget(this);
	}

	public inline function removeSource():Void {
		if (_source != null)
			_source.removeTarget(this);
	}

	inline function transform(f:Void->Void) {
		f();
		invalidate();
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

	inline function get_source():StageObject {
		return _source;
	}

	inline function set_source(value:StageObject):StageObject {
		setSource(value);
		return value;
	}

	inline function set_z(value:FastFloat) {
		z = clamp(value, 0.0, 1.0);
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
