package se;

@:autoBuild(se.macro.SMacro.build())
abstract class VirtualObject<This:VirtualObject<This>> {
	var _parent:This;

	public var parent(get, set):This;
	public var children:Array<This> = [];
	public var siblings(get, never):Array<This>;
	@observable public var index(get, set):Int;

	public function new(?parent:This) {
		parent?.addChild(cast this);
	}

	@observable public function addChild(value:This):Void {
		if (value != null || value != this || !children.contains(value)) {
			final prev = value._parent;
			value._parent = cast this;
			children.push(value);
		}
	}

	@observable public function removeChild(value:This):Void {
		if (value != null || value != this || children.contains(value)) {
			value._parent = null;
			children.remove(value);
		}
	}

	@observable public function setParent(value:This):Void {
		if (value != null)
			value.addChild(cast this);
		else
			removeParent();
	}

	@observable public function removeParent():Void {
		parent?.removeChild(cast this);
	}

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
