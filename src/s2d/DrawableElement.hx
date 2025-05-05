package s2d;

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
		ctx.style.color = color;
		ctx.transform = globalTransform;
		draw(target);
		for (el in vChildren)
			el.render(target);
		ctx.style.popOpacity();
	}
}
