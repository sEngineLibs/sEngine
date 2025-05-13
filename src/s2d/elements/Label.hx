package s2d.elements;

import se.Font;
import se.Assets;
import se.Texture;
import s2d.Alignment;

using se.extensions.StringExt;

class Label extends DrawableElement {
	var asset:FontAsset = new FontAsset();
	@readonly @alias var kravur:Font = asset.asset;

	@alias public var font:String = asset.source;
	@readonly @alias public var isLoaded:Bool = asset.isLoaded;

	@:inject(syncTextWidth)
	@track public var text:String;

	@:inject(syncTextSize)
	@track @:isVar public var fontSize(default, set):Int = 32;

	public var alignment:Alignment = AlignLeft | AlignTop;
	public var textWidth(default, null):Float = 0.0;
	public var textHeight(default, null):Float = 0.0;

	public function new(text:String = "Text", name:String = "label") {
		super(name);
		this.text = text;
		font = "font_default";
		asset.onAssetLoaded(_ -> syncTextSize());
	}

	function draw(target:Texture) {
		if (asset.isLoaded) {
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
	}

	function syncTextSize() {
		syncTextWidth();
		syncTextHeight();
	}

	function syncTextWidth() {
		if (asset.isLoaded && text != null)
			textWidth = kravur.widthOfCharacters(fontSize, text.toCharArray(), 0, text.length);
	}

	function syncTextHeight() {
		if (asset.isLoaded)
			textHeight = kravur.height(fontSize);
	}

	function set_fontSize(value:Int) {
		fontSize = value < 0 ? 0 : value;
		return value;
	}
}
