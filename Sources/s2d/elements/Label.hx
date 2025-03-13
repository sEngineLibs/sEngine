package s2d.elements;

import kha.Font;
import kha.Assets;
import se.Texture;
import s2d.Alignment;

using kha.StringExtensions;

class Label extends InteractiveElement {
	var textWidth:Float;
	var textHeight:Float;

	@:inject(updateTextWidth) public var text:String;
	@:inject(updateTextSize) public var font:Font;
	@:inject(updateTextSize) @:isVar public var fontSize(default, set):Int = 14;
	public var alignment:Alignment = Alignment.Left | Alignment.Top;

	public function new(?text:String = "Text", ?parent:Element) {
		super(parent);
		this.font = Assets.fonts.get("Roboto_Regular");
		this.text = text;
	}

	override inline function draw(target:Texture) {
		super.draw(target);

		final ctx = target.ctx2D;

		ctx.style.font = font;
		ctx.style.fontSize = fontSize;

		var drawX = x;
		if ((alignment & Alignment.HCenter) != 0)
			drawX += (width - textWidth) / 2.0;
		else if ((alignment & Alignment.Right) != 0)
			drawX += width - textWidth;

		var drawY = y;
		if ((alignment & Alignment.VCenter) != 0)
			drawY += (height - textHeight) / 2.0;
		else if ((alignment & Alignment.Bottom) != 0)
			drawY += height - textHeight;

		ctx.drawString(text, drawX, drawY);
	}

	function updateTextWidth() {
		if (font != null && text != null)
			textWidth = font.widthOfCharacters(fontSize, text.toCharArray(), 0, text.length);
	}

	function updateTextHeight() {
		if (font != null)
			textHeight = font.height(fontSize);
	}

	function updateTextSize() {
		updateTextWidth();
		updateTextHeight();
	}

	private inline function set_fontSize(value:Int) {
		fontSize = value < 0 ? 0 : value;
		return value;
	}
}
