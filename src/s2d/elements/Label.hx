package s2d.elements;

import kha.Kravur;
import se.Texture;
import se.Assets.FontAsset;
import s2d.Alignment;

using se.extensions.StringExt;

class Label extends DrawableElement {
	var asset:FontAsset = new FontAsset();
	@readonly @alias var kravur:Kravur = asset.asset;

	@alias public var font:String = asset.source;

	@:inject(updateTextWidth) @track public var text:String;
	@:inject(updateTextSize) @track @:isVar public var fontSize(default, set):Int = 32;

	public var alignment:Alignment = AlignLeft | AlignTop;
	public var textWidth(default, null):Float = 0.0;
	public var textHeight(default, null):Float = 0.0;

	public function new(text:String = "Text", name:String = "label") {
		super(name);
		this.text = text;
		asset.onAssetLoaded(updateTextSize);
		font = "font_default";
	}

	function draw(target:Texture) {
		if (kravur != null) {
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

			ctx.style.font = kravur;
			ctx.style.fontSize = fontSize;
			ctx.drawString(text, drawX, drawY);
		}
	}

	function updateTextWidth() {
		if (kravur != null && text != null)
			textWidth = kravur.widthOfCharacters(fontSize, text.toCharArray(), 0, text.length);
	}

	function updateTextHeight() {
		if (kravur != null)
			textHeight = kravur.height(fontSize);
	}

	function updateTextSize() {
		updateTextWidth();
		updateTextHeight();
	}

	private function setkravurSize(value:Int) {
		fontSize = value < 0 ? 0 : value;
		return value;
	}
}
