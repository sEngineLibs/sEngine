package s2d;

import se.Color;
import se.Texture;

abstract class DrawableElement extends Element {
	public var color:Color = White;

	public function new(name:String = "drawable", ?scene:WindowScene) {
		super(name, scene);
	}

	abstract function draw(target:Texture):Void;

	override function render(target:Texture) {
		final ctx = target.ctx2D;
		ctx.style.pushOpacity(opacity);
		ctx.style.color = color;
		ctx.transform = globalTransform;
		draw(target);
		for (el in vChildren)
			el.render(target);
		ctx.style.popOpacity();
	}

	static function insert(a:Array<Element>, el:Element) {
		for (i in 0...a.length)
			if (a[i].z > el.z) {
				a.insert(i, el);
				return;
			}
		a.push(el);
	}
}
