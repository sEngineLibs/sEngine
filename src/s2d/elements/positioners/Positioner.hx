package s2d.elements.positioners;

abstract class Positioner<T> extends Element {
	var slots:Map<Element, T> = [];

	public function new(?parent:Element) {
		super(parent);
	}

	override function __childAdded__(child:Element) {
		super.__childAdded__(child);
		position(child, children[child.index - 1]);
		slots.set(child, addToPositioning(child));
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		removeFromPositioning(child);
		slots.remove(child);
	}

	abstract function addToPositioning(child:Element):T;

	abstract function removeFromPositioning(child:Element):Void;

	abstract function position(el:Element, prev:Element):Void;
}
