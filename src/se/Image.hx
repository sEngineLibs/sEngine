package se;

import se.Assets;
import kha.Image as KhaImage;

@:forward(width, height, format, unload, at, fromImage, fromCanvas, fromVideo, fromBytes, fromBytes3D, fromEncodedBytes)
extern abstract Image(KhaImage) from KhaImage to KhaImage {
	@:from
	public static inline function fromString(value:String):Image {
		return ImageAsset.load(value);
	}
}
