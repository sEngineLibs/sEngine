package se;

#if !macro
@:build(se.macro.SMacro.build())
@:autoBuild(se.macro.SMacro.build())
#end
abstract class VirtualObject<This:VirtualObject<This>> {
	@:track @:isVar public var parent(default, set):This;
	@:track public var index(get, set):Int;
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
		value.setParent(cast this);
	}

	public function removeChild(value:This):Void {
		if (children.contains(value))
			value.removeParent();
	}

	public function toString():String {
		return Type.getClassName(Type.getClass(this));
	}

	private inline function set_parent(value:This):This {
		if (parent != null)
			parent.children.remove(cast this);

		if (value != null) {
			if (value.children.push(cast this) != -1)
				parent = value;
		} else
			parent = value;

		return value;
	}

	private inline function get_index():Int {
		return parent.children.indexOf(cast this);
	}

	private inline function set_index(value:Int):Int {
		parent.children.remove(cast this);
		parent.children.insert(value, cast this);
		return value;
	}

	private inline function get_siblings() {
		if (parent != null) {
			var s = parent.children.copy();
			s.remove(cast this);
			return s;
		}
		return [];
	}
}
