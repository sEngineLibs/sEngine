package se;

@:autoBuild(se.macro.SMacro.build())
abstract class VirtualObject<This:VirtualObject<This>> {
	var _parent:This;

	public var children:Array<This> = [];
	public var parent(get, set):This;
	public var index(get, set):Int;

	public var siblings(get, never):Array<This>;

	public function new(?parent:This) {
		parent?.addChild(cast this);
	}

	public function addChild(value:This):Void {
		if (value != null || value != this || !children.contains(value)) {
			final prev = value._parent;
			value._parent = cast this;
			children.push(value);
			value.onParentChanged(prev);
		}
	}

	public function removeChild(value:This):Void {
		if (value != null || value != this || children.contains(value)) {
			value._parent = null;
			children.remove(value);
			value.onParentChanged(cast this);
		}
	}

	public function setParent(value:This):Void {
		if (value != null)
			value.addChild(cast this);
		else
			removeParent();
	}

	public function removeParent():Void {
		parent?.removeChild(cast this);
	}

	abstract function onParentChanged(previous:This):Void;

	public function toString():String {
		return Type.getClassName(Type.getClass(this));
	}

	inline function get_parent() {
		return _parent;
	}

	inline function set_parent(value:This):This {
		setParent(value);
		return value;
	}

	inline function get_index():Int {
		return _parent.children.indexOf(cast this);
	}

	inline function set_index(value:Int):Int {
		_parent.children.remove(cast this);
		_parent.children.insert(value, cast this);
		return value;
	}

	inline function get_siblings() {
		if (parent != null) {
			var s = parent.children.copy();
			s.remove(cast this);
			return s;
		}
		return [];
	}
}
