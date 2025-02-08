package se.ui.elements;

import kha.Font;
import kha.Canvas;
import kha.Assets;
import se.ui.Alignment;

using kha.StringExtensions;

class TextElement extends UIElement {
	var textWidth:Float;
	var textHeight:Float;

	@:isVar public var text(default, set):String;
	@:isVar public var font(default, set):Font;
	@:isVar public var fontSize(default, set):Int = 14;
	public var alignment:Alignment = Alignment.Left | Alignment.Top;

	public function new(?text:String = "Text", ?scene:UIScene) {
		super(scene);
		this.font = Assets.fonts.get("Roboto_Regular");
		this.text = text;
	}

	override function draw(target:Canvas) {
		final g2 = target.g2;

		g2.font = font;
		g2.fontSize = fontSize;

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

		g2.drawString(text, drawX, drawY);
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

	function set_text(value:String) {
		text = value;
		updateTextWidth();
		return value;
	}

	function set_font(value:Font) {
		font = value;
		updateTextSize();
		return value;
	}

	function set_fontSize(value:Int) {
		fontSize = value < 0 ? 0 : value;
		updateTextSize();
		return value;
	}
}
