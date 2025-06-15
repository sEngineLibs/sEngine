package s2d.elements;

import se.Color;
import se.Texture;

abstract class DrawableElement extends Element {
	public var color:Color = White;

	public function new(name:String = "drawable") {
		super(name);
	}

	abstract function draw(target:Texture):Void;

	override function render(target:Texture) {
		final ctx = target.context2D;
		ctx.style.pushOpacity(opacity);
		var order = zsorted();
		for (c in order.below)
			if (c.visible)
				c.render(target);
		ctx.transform = globalTransform;
		ctx.style.color = color;
		draw(target);
		for (c in order.above)
			if (c.visible)
				c.render(target);
		ctx.style.popOpacity();
	}
}
