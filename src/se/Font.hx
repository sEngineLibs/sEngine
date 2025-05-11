package se;

import se.Assets;
import kha.Font as KhaFont;

@:forward()
abstract Font(KhaFont) from KhaFont to KhaFont {
	@:from
	public static inline function fromString(value:String):Font {
		return Font.load(value);
	}

	@:from
	public static inline function load(value:String):Font {
		return FontAsset.load(value);
	}
}
