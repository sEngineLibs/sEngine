package s2d.elements;

import kha.Font;
import kha.Assets;
import se.Texture;
import s2d.Alignment;

using se.extensions.StringExt;

class Label extends DrawableElement {
	var textWidth:Float;
	var textHeight:Float;

	@:inject(updateTextWidth)
	@track public var text:String;
	@:inject(updateTextSize)
	public var font:Font;
	@:inject(updateTextSize)
	@track @:isVar public var fontSize(default, set):Int = 14;

	public var alignment:Alignment = AlignLeft | AlignTop;

	public function new(?text:String = "Text",) {
		super();
		this.font = Assets.fonts.get("Roboto_Regular");
		this.text = text;
	}

	function draw(target:Texture) {
		final ctx = target.ctx2D;

		ctx.style.font = font;
		ctx.style.fontSize = fontSize;

		var drawX = x;
		if ((alignment & AlignHCenter) != 0)
			drawX += (width - textWidth) / 2.0;
		else if ((alignment & AlignRight) != 0)
			drawX += width - textWidth;

		var drawY = y;
		if ((alignment & AlignVCenter) != 0)
			drawY += (height - textHeight) / 2.0;
		else if ((alignment & AlignBottom) != 0)
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

	private function set_fontSize(value:Int) {
		fontSize = value < 0 ? 0 : value;
		return value;
	}
}
