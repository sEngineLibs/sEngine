package s2d.controls;

import se.Texture;
import s2d.Element;

class Control<B:Element, C:Element> extends Element {
	public var background(default, set):B;
	public var content(default, set):C;

	@alias public var topInset:Float = background.top.margin;
	@alias public var leftInset:Float = background.left.margin;
	@alias public var bottomInset:Float = background.bottom.margin;
	@alias public var rightInset:Float = background.right.margin;
	@writeonly @alias public var inset:Float = background.anchors.margins;

	@alias public var topOffset:Float = content.top.margin;
	@alias public var leftOffset:Float = content.left.margin;
	@alias public var bottomOffset:Float = content.bottom.margin;
	@alias public var rightOffset:Float = content.right.margin;
	@writeonly @alias public var offset:Float = content.anchors.margins;

	public function new(name:String = "control") {
		super(name);
		enabled = true;
	}

	override function render(target:Texture) {
		final ctx = target.context2D;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;

		background?.render(target);
		content?.render(target);
		for (c in children)
			if (c.visible)
				c.render(target);

		ctx.style.popOpacity();
	}

	function set_background(value:B):B {
		background = value;
		if (background != null)
			background.anchors.fill(this);
		return background;
	}

	function set_content(value:C):C {
		content = value;
		if (content != null)
			content.anchors.fill(this);
		return content;
	}
}
