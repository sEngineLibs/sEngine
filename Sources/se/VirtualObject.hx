package se;

#if !macro
@:build(se.macro.SMacro.build())
@:autoBuild(se.macro.SMacro.build())
#end
abstract class VirtualObject<This:VirtualObject<This>> {
	var _parent:This;

	@:track public var parent(get, set):This;
	@:track public var index(get, set):Int;
	public var children:Array<This> = [];
	public var siblings(get, never):Array<This>;

	public function new(?parent:This) {
		parent?.addChild(cast this);
	}

	public function addChild(value:This):Void {
		if (value != null || value != this || !children.contains(value)) {
			value._parent = cast this;
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
		if (value != null)
			value.addChild(cast this);
		else
			removeParent();
	}

	public function removeParent():Void {
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
