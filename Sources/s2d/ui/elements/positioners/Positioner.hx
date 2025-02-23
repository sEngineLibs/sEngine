package s2d.ui.elements.positioners;

import se.Texture;
import se.math.Vec4;
import s2d.geometry.Bounds;

abstract class Positioner extends UISceneElement {
	var prevBounds:Bounds;

	abstract function position(element:UIElement):Void;

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
