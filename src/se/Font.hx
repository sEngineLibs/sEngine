package se;

import kha.Assets;
import kha.AssetError;
import kha.Font as KhaFont;
import se.Asset;

@:forward()
@:forward.new
abstract Font(KhaFont) from KhaFont to KhaFont {
	@:from
	public static inline function fromString(value:String):Font {
		var font:Font = null;
		if (value.indexOf("/") + value.indexOf("\\") + value.indexOf(".") > -3)
			font = Font.fromPath(value);
		else
			font = Font.fromName(value);
		return font;
	}

	public static inline function fromPath(path:String, asynchronous:Bool = false, ?callback:Font->Void):Font {
		var font:Font = null;
		if (asynchronous)
			asyncLoadFromPath(path, callback);
		else
			font = syncLoadFromPath(path);
		return font;
	}

	public static inline function fromName(name:String, asynchronous:Bool = false, ?callback:Font->Void):Font {
		var font:Font = Assets.fonts.get(name);
		if (font == null) {
			if (asynchronous)
				asyncLoadFromName(name, callback);
			else
				font = syncLoadFromName(name);
		}
		return font;
	}

	public static inline function syncLoadFromPath(path:String):Font {
		return Asset.syncLoad(path, asyncLoadFromPath);
	}

	public static inline function syncLoadFromName(name:String):Font {
		return Asset.syncLoad(name, asyncLoadFromName);
	}

	public static inline function asyncLoadFromPath(path:String, callback:Font->Void, ?errorCallback:AssetError->Void):Void {
		Assets.loadFontFromPath(path, callback, error -> {
			Log.error('Failed to load font from name: $error');
			if (errorCallback != null)
				errorCallback(error);
		});
	}

	public static inline function asyncLoadFromName(name:String, ?callback:Font->Void, ?errorCallback:AssetError->Void):Void {
		Assets.loadFont(name, ft -> {
			if (callback != null)
				callback(ft);
		}, error -> {
			Log.error('Failed to load font from name: $error');
			if (errorCallback != null)
				errorCallback(error);
		});
	}
}
