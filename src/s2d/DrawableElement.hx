package s2d;

import se.Color;
import se.Texture;

abstract class DrawableElement extends InteractiveElement {
	public var color:Color = White;

	override function render(target:Texture) {
		final ctx = target.ctx2D;

		ctx.style.color = color;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;

		draw(target);
		for (c in children)
			if (c.visible)
				c.render(target);

		ctx.style.popOpacity();
	}

	abstract function draw(target:Texture):Void;
}
