package s2d.elements.positioners;

import s2d.Direction;

abstract class Positioner<T:{}> extends Element {
	var slots:Map<Element, T> = [];

	public var spacing:Float = 0.0;
	public var direction:Direction = TopToBottom | LeftToRight;

	public function new(?parent:Element) {
		super(parent);
	}

	@:slot(childAdded)
	function __childAdded(child:Element) {
		position(child, children[children.length - 2]);
		slots.set(child, addToPositioning(child));
	}

	@:slot(childRemoved)
	function __childRemoved(child:Element) {
		removeFromPositioning(child);
		slots.remove(child);
	}

	abstract function addToPositioning(child:Element):T;

	abstract function removeFromPositioning(child:Element):Void;

	abstract function position(el:Element, prev:Element):Void;

	function adjustYPositioning(dir:Direction, d:Float) {
		if (direction & dir != 0)
			for (c in children)
				c.y += d;
	}

	function adjustXPositioning(dir:Direction, d:Float) {
		if (direction & dir != 0)
			for (c in children)
				c.x += d;
	}

	function adjustElementXPositioning(e:Element, dir:Alignment, d:Float) {
		if (direction & dir != 0)
			for (c in children.slice(e.index + 1))
				c.x += d;
		else
			for (c in children.slice(e.index))
				c.x -= d;
	}

	function adjustElementYPositioning(e:Element, dir:Alignment, d:Float) {
		if (direction & dir != 0)
			for (c in children.slice(e.index + 1))
				c.y += d;
		else
			for (c in children.slice(e.index))
				c.y -= d;
	}
}
