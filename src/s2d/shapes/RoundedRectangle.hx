package s2d.shapes;

import se.Texture;
import s2d.graphics.Drawers;

class RoundedRectangle extends DrawableElement {
	public var radius:Float;
	public var softness:Float;

	public function new(?radius:Float = 10.0, ?softness:Float = 0.5, ?scene:WindowScene) {
		super(scene);
		this.radius = radius;
		this.softness = softness;
	}

	function draw(target:Texture) {
		@:privateAccess Drawers.rectDrawer.render(target, this);
	}
}
