package s2d.elements.positioners;

import se.Texture;
import se.math.Vec4;
import s2d.geometry.Bounds;

abstract class Positioner extends Element {
	var prevBounds:Bounds;

	public var spacing:Float = 0.0;

	abstract function position(element:Element):Void;

	override function renderTree(target:Texture) {
		prevBounds = new Vec4(0.0, 0.0, left.padding, top.padding);
		for (child in children) {
			if (child.visible) {
				position(child);
				prevBounds = child.bounds;
				child.render(target);
			}
		}
	}
}
