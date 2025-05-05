package s2d.elements;

import kha.Font;
import kha.Assets;
import se.Texture;
import s2d.Alignment;

using se.extensions.StringExt;

class Label extends DrawableElement {
	@:inject(updateTextWidth) @track public var text:String;
	@:inject(updateTextSize) public var font:Font;
	@:inject(updateTextSize) @track @:isVar public var fontSize(default, set):Int = 32;

	public var alignment:Alignment = AlignLeft | AlignTop;
	public var textWidth(default, null):Float;
	public var textHeight(default, null):Float;

	public function new(text:String = "Text", name:String = "label") {
		super(name);
		this.font = Assets.fonts.get("Roboto_Regular");
		this.text = text;
	}

	function draw(target:Texture) {
		final ctx = target.context2D;

		var drawX = absX;
		if ((alignment & AlignHCenter) != 0)
			drawX += (width - textWidth) / 2.0;
		else if ((alignment & AlignRight) != 0)
			drawX += width - textWidth;

		var drawY = absY;
		if ((alignment & AlignVCenter) != 0)
			drawY += (height - textHeight) / 2.0;
		else if ((alignment & AlignBottom) != 0)
			drawY += height - textHeight;

		ctx.style.font = font;
		ctx.style.fontSize = fontSize;
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
