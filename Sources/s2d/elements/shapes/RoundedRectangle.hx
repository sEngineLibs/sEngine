package s2d.elements.shapes;

import se.Texture;
import s2d.effects.Border;
import s2d.graphics.Drawers;

class RoundedRectangle extends UISceneElement {
	public var border:Border = {};
	public var radius:Float;
	@:isVar public var softness(default, set):Float;

	public function new(?radius:Float = 0.0, ?softness:Float = 0.5, ?parent:Element) {
		super(parent);
		
		this.radius = radius;
		this.softness = softness;
	}

	override inline function draw(target:Texture) {
		super.draw(target);

		@:privateAccess Drawers.rectDrawer.render(target, this);
	}

	inline function set_softness(value:Float):Float {
		softness = Math.max(value, 0.0);
		return value;
	}
}
