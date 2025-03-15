package se;

#if !macro
@:autoBuild(se.macro.SMacro.build())
#end
abstract class SObject<This:SObject<This>> {
	@:isVar public var parent(default, set):This;
	public var index(get, set):Int;
	public var children:Set<This> = [];
	public var siblings(get, never):Set<This>;

	public function new(?parent:This) {
		parent?.addChild(cast this);
	}

	public function setParent(value:This):Void {
		parent = value;
	}

	public function removeParent():Void {
		parent = null;
	}

	public function addChild(value:This):Void {
		value.parent = cast this;
	}

	public function removeChild(value:This):Void {
		if (children.contains(value))
			value.parent = null;
	}

	public function toString():String {
		return Type.getClassName(Type.getClass(this));
	}

	abstract function parentChanged(previous:This):Void;

	abstract function childRemoved(child:This):Void;

	abstract function childAdded(child:This):Void;

	inline function set_parent(value:This):This {
		if (value != parent) {
			if (parent != null && parent.children.contains(cast this)) {
				parent.children.remove(cast this);
				parent.childRemoved(cast this);
			}
			if (value != null && !value.children.contains(cast this)) {
				value.children.push(cast this);
				value.childAdded(cast this);
			}
			var prev = parent;
			parent = value;
			parentChanged(prev);
		}
		return value;
	}

	inline function get_index():Int {
		return parent.children.indexOf(cast this);
	}

	inline function set_index(value:Int):Int {
		parent.children.remove(cast this);
		parent.children.insert(value, cast this);
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
