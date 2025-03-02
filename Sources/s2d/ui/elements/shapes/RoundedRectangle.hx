package s2d.ui.elements.shapes;

import se.Texture;
import s2d.ui.effects.Border;
import s2d.ui.graphics.Drawers;

class RoundedRectangle extends UISceneElement {
	public var border:Border = {};
	public var radius:Float;
	@:isVar public var softness(default, set):Float;

	public function new(?radius:Float = 0.0, ?softness:Float = 0.5, ?parent:UIElement) {
		super(parent);
		this.radius = radius;
		this.softness = softness;
	}

	override inline function draw(target:Texture) {
		@:privateAccess Drawers.rectDrawer.render(target, this);
	}

	inline function set_softness(value:Float):Float {
		softness = Math.max(value, 0.0);
		return value;
	}
}
