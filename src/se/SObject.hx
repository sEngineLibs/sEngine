package se;

#if !macro
@:build(se.macro.SMacro.build())
@:autoBuild(se.macro.SMacro.build())
#end
abstract class SObject<This:SObject<This>> {
	@:signal function parentChanged(previous:This):Void;

	@:signal function childAdded(child:This):Void;

	@:signal function childRemoved(child:This):Void;

	@:signal function childMoved(child:This):Void;

	@:isVar public var parent(default, set):This;
	public var index(get, set):Int;
	public var children:Array<This> = [];
	public var siblings(get, never):Array<This>;

	public function new(?parent:This) {
		this.parent = parent;
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

	function set_parent(value:This):This {
		if (value != parent) {
			if (parent != null && parent.children.remove(cast this))
				parent.childRemoved(cast this);
			parent = value;
			parentChanged(parent);
			if (parent != null && !parent.children.contains(cast this)) {
				parent.children.push(cast this);
				parent.childAdded(cast this);
			}
		}
		return value;
	}

	function get_index():Int {
		return parent?.children.indexOf(cast this);
	}

	function set_index(value:Int):Int {
		if (parent != null) {
			parent.children.remove(cast this);
			parent.children.insert(value, cast this);
			parent.childMoved(cast this);
		}
		return value;
	}

	function get_siblings() {
		if (parent != null) {
			var s = parent.children.copy();
			s.remove(cast this);
			return s;
		}
		return [];
	}
}
