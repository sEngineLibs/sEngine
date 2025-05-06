package se;

import kha.Assets;
import kha.AssetError;
import kha.Image as KhaImage;
import se.Asset;

@:forward(width, height, format, unload, at, fromImage, fromCanvas, fromVideo, fromBytes, fromBytes3D, fromEncodedBytes)
extern abstract Image(KhaImage) from KhaImage to KhaImage {
	@:from
	public static inline function fromString(value:String):Null<Image> {
		var image:Image = null;
		if (value.indexOf("/") + value.indexOf("\\") + value.indexOf(".") > -3)
			image = Image.fromPath(value);
		else
			image = Image.fromName(value);
		return image;
	}

	public static inline function fromPath(path:String, asynchronous:Bool = false, ?callback:Image->Void):Null<Image> {
		var image:Image = null;
		if (asynchronous)
			asyncLoadFromPath(path, callback);
		else
			image = syncLoadFromPath(path);
		return image;
	}

	public static inline function fromName(name:String, asynchronous:Bool = false, ?callback:Image->Void):Null<Image> {
		var image:Image = Assets.images.get(name);
		if (image == null) {
			if (!asynchronous)
				image = syncLoadFromName(name);
			else
				asyncLoadFromName(name, callback);
		}
		return image;
	}

	public static inline function syncLoadFromPath(path:String):Null<Image> {
		return Asset.syncLoad(path, asyncLoadFromPath);
	}

	public static inline function syncLoadFromName(name:String):Null<Image> {
		return Asset.syncLoad(name, asyncLoadFromName);
	}

	public static inline function asyncLoadFromPath(path:String, callback:Image->Void, ?errorCallback:AssetError->Void):Void {
		Assets.loadImageFromPath(path, false, callback, error -> {
			Log.error('Failed to load image from name: $error');
			if (errorCallback != null)
				errorCallback(error);
		});
	}

	public static inline function asyncLoadFromName(name:String, ?callback:Image->Void, ?errorCallback:AssetError->Void):Void {
		Assets.loadImage(name, img -> if (callback != null) callback(img), error -> {
			Log.error('Failed to load image from name: $error');
			if (errorCallback != null)
				errorCallback(error);
		});
	}
}
