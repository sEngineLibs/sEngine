package se;

#if !macro
@:build(se.macro.SMacro.build())
@:autoBuild(se.macro.SMacro.build())
#end
abstract class SObject<This:SObject<This>> {
	@:signal function parentChanged(previous:This):Void;

	@:signal function childAdded(child:This):Void;

	@:signal function childRemoved(child:This):Void;

	@:isVar public var parent(default, set):This;
	public var index(get, set):Int;
	public var children:Array<This> = [];
	public var siblings(get, never):Array<This>;

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

	inline function set_parent(value:This):This {
		if (value != parent) {
			var prev = parent;
			parent = value;
			if (prev != null && prev.children.remove(cast this))
				prev.childRemoved(cast this);
			if (parent != null && !parent.children.contains(cast this)) {
				parent.children.push(cast this);
				parent.childAdded(cast this);
			}
			parentChanged(prev);
		}
		return value;
	}

	inline function get_index():Int {
		return parent?.children.indexOf(cast this);
	}

	inline function set_index(value:Int):Int {
		if (parent != null) {
			parent.children.remove(cast this);
			parent.children.insert(value, cast this);
		}
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
