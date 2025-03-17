package s2d.elements.positioners;

import s2d.Direction;

abstract class Positioner<T> extends Element {
	var slots:Map<Element, T> = [];

	@:isVar public var spacing(default, set):Float = 0.0;
	@:isVar public var direction(default, set):Direction = TopToBottom | LeftToRight;

	public function new(?parent:Element) {
		super(parent);
	}

	@:slot(childAdded)
	function __childAdded(child:Element) {
		slots.set(child, addToPositioning(child));
		position(child, children[child.index - 1]);
	}

	@:slot(childRemoved)
	function __childRemoved(child:Element) {
		slots.remove(child);
		removeFromPositioning(child);
	}

	abstract function addToPositioning(child:Element):T;

	abstract function removeFromPositioning(child:Element):Void;

	abstract function rebuild():Void;

	abstract function adjustSpacing(d:Float):Void;

	abstract function adjust(dir:Direction, d:Float):Void;

	abstract function position(el:Element, prev:Element):Void;

	abstract function adjustElement(el:Element, dir:Alignment, d:Float):Void;

	function set_spacing(value:Float):Float {
		adjustSpacing(value - spacing);
		spacing = value;
		return spacing;
	}

	function set_direction(value:Direction):Direction {
		direction = value;
		if (children.length > 0)
			rebuild();
		return direction;
	}
}
