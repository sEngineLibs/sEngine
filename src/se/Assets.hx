package se;

import kha.Assets;
import kha.AssetError;

@:forward()
@:forward.new
abstract FontAsset(FontAssetData) {
	public static function load(source:String) {
		return new FontAsset(source);
	}

	@:from
	public static function fromString(value:String) {
		return FontAsset.load(value);
	}

	@:to
	public function toFont():Font {
		return this.asset;
	}
}

@:forward()
@:forward.new
abstract ImageAsset(ImageAssetData) {
	public static function load(source:String) {
		return new ImageAsset(source);
	}

	@:from
	public static function fromString(value:String) {
		return ImageAsset.load(value);
	}

	@:to
	public function toImage():Image {
		return this.asset;
	}
}

private abstract class AssetData<T> {
	var assetChanged:Void->Void;

	@:isVar public var asset(default, set):T;
	@:isVar public var source(default, set):String;

	public var loaded(get, never):Bool;

	public function new(?source:String) {
		this.source = source;
	}

	public function onAssetChanged(cb:Void->Void) {
		assetChanged = cb;
	}

	public function load() {
		if (source != "")
			if (source.indexOf("/") + source.indexOf("\\") + source.indexOf(".") > -3)
				loadFromPath(a -> asset = a, err -> Log.error('Failed to load asset ${err.url}: ${err.error}'));
			else
				loadFromName(a -> asset = a, err -> Log.error('Failed to load asset ${err.url}: ${err.error}'));
	}

	public function reload() {
		if (source != "")
			if (source.indexOf("/") + source.indexOf("\\") + source.indexOf(".") > -3)
				reloadFromPath(a -> asset = a, err -> Log.error('Failed to reload asset ${err.url}: ${err.error}'));
			else
				reloadFromName(a -> asset = a, err -> Log.error('Failed to reload asset ${err.url}: ${err.error}'));
	}

	abstract function loadFromName(callback:T->Void, errorCallback:AssetError->Void):Void;

	abstract function loadFromPath(callback:T->Void, errorCallback:AssetError->Void):Void;

	abstract function reloadFromName(callback:T->Void, errorCallback:AssetError->Void):Void;

	abstract function reloadFromPath(callback:T->Void, errorCallback:AssetError->Void):Void;

	function set_source(value:String):String {
		source = value ?? "";
		if (source != "")
			reload();
		return source;
	}

	function set_asset(value:T):T {
		final old = asset;
		asset = value;
		if (old != asset && assetChanged != null)
			assetChanged();
		return asset;
	}

	function get_loaded():Bool {
		return asset != null;
	}
}

private class FontAssetData extends AssetData<Font> {
	static var fonts:Map<String, Font> = [];

	function loadFromName(callback:Font->Void, errorCallback:AssetError->Void) {
		Assets.loadFont(source, font -> {
			fonts.set(source, font);
			callback(font);
		}, errorCallback);
	}

	function loadFromPath(callback:Font->Void, errorCallback:AssetError->Void) {
		Assets.loadFontFromPath(source, font -> {
			fonts.set(source, font);
			callback(font);
		}, errorCallback);
	}

	function reloadFromName(callback:Font->Void, errorCallback:AssetError->Void) {
		if (fonts.exists(source))
			callback(fonts.get(source));
		else
			loadFromName(callback, errorCallback);
	}

	function reloadFromPath(callback:Font->Void, errorCallback:AssetError->Void) {
		if (fonts.exists(source))
			callback(fonts.get(source));
		else
			loadFromPath(callback, errorCallback);
	}
}

private class ImageAssetData extends AssetData<Image> {
	static var images:Map<String, Image> = [];

	function loadFromName(callback:Image->Void, errorCallback:AssetError->Void) {
		Assets.loadImage(source, image -> {
			images.set(source, image);
			callback(image);
		}, errorCallback);
	}

	function loadFromPath(callback:Image->Void, errorCallback:AssetError->Void) {
		Assets.loadImageFromPath(source, false, image -> {
			images.set(source, image);
			callback(image);
		}, errorCallback);
	}

	function reloadFromName(callback:Image->Void, errorCallback:AssetError->Void) {
		if (images.exists(source))
			callback(images.get(source));
		else
			loadFromName(callback, errorCallback);
	}

	function reloadFromPath(callback:Image->Void, errorCallback:AssetError->Void) {
		if (images.exists(source))
			callback(images.get(source));
		else
			loadFromPath(callback, errorCallback);
	}
}
