package s2d.elements.shapes;

import se.Texture;
import s2d.graphics.Drawers;

class RoundedRectangle extends InteractiveElement {
	public var radius:Float;
	public var softness:Float;

	public function new(?radius:Float = 0.0, ?softness:Float = 0.5, ?parent:Element) {
		super(parent);

		this.radius = radius;
		this.softness = softness;
	}

	override inline function draw(target:Texture) {
		super.draw(target);

		@:privateAccess Drawers.rectDrawer.render(target, this);
	}
}
