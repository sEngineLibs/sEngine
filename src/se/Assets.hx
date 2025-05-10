package se;

import kha.Sound;
import kha.Assets;
import kha.AssetError;

@:forward()
@:forward.new
abstract FontAsset(FontAssetData) {
	@:from
	public static function fromString(value:String) {
		return FontAsset.load(value);
	}

	public static function load(source:String) {
		return new FontAsset(source);
	}

	@:to
	public function toFont():Font {
		return this.asset;
	}
}

@:forward()
@:forward.new
abstract ImageAsset(ImageAssetData) {
	@:from
	public static function fromString(value:String) {
		return ImageAsset.load(value);
	}

	public static function load(source:String, readable:Bool = false) {
		return new ImageAsset(source, readable);
	}

	@:to
	public function toImage():Image {
		return this.asset;
	}
}

@:forward()
@:forward.new
abstract AudioAsset(AudioAssetData) {
	@:from
	public static function fromString(value:String) {
		return AudioAsset.load(value);
	}

	public static function load(source:String, uncompress:Bool = true) {
		return new AudioAsset(source, uncompress);
	}

	@:to
	public function toAudio():Audio {
		return this.asset;
	}
}

private class FontAssetData extends AssetData<Font> {
	override function load(?callback:Font->Void) {
		static final assets:Map<String, Font> = [];

		if (assets.exists(source))
			asset = assets.get(source);
		else
			super.load(a -> assets.set(source, a));
	}

	function loadFromName(callback:Font->Void, errorCallback:AssetError->Void) {
		Assets.loadFont(source, callback, errorCallback);
	}

	function loadFromPath(callback:Font->Void, errorCallback:AssetError->Void) {
		Assets.loadFontFromPath(source, callback, errorCallback);
	}
}

private class ImageAssetData extends AssetData<Image> {
	@:isVar public var readable(default, set):Bool;

	public function new(?source:String, readable:Bool = false) {
		super(source);
		this.readable = readable;
	}

	override function load(?callback:Image->Void) {
		static final assets:Map<String, Image> = [];

		if (assets.exists(source))
			asset = assets.get(source);
		else
			super.load(a -> assets.set(source, a));
	}

	function loadFromName(callback:Image->Void, errorCallback:AssetError->Void) {
		Assets.loadImage(source, callback, errorCallback);
	}

	function loadFromPath(callback:Image->Void, errorCallback:AssetError->Void) {
		Assets.loadImageFromPath(source, readable, callback, errorCallback);
	}

	function set_readable(value:Bool):Bool {
		if (readable != value) {
			readable = value;
			reload();
		}
		return readable;
	}
}

private class AudioAssetData extends AssetData<Audio> {
	var uncompressed:Bool;

	public function new(?source:String, uncompressed:Bool = true) {
		super(source);
		this.uncompressed = uncompressed;
	}

	override function load(?callback:Audio->Void) {
		static final assets:Map<String, Audio> = [];

		if (assets.exists(source))
			asset = assets.get(source);
		else
			super.load(a -> assets.set(source, a));
	}

	function loadFromName(callback:Audio->Void, errorCallback:AssetError->Void) {
		Assets.loadSound(source, audio -> processSound(audio, callback), errorCallback);
	}

	function loadFromPath(callback:Audio->Void, errorCallback:AssetError->Void) {
		Assets.loadSoundFromPath(source, audio -> processSound(audio, callback), errorCallback);
	}

	function processSound(sound:Sound, callback:Audio->Void) {
		if (uncompressed)
			sound.uncompress(() -> callback(sound));
		else // Krom only uses uncompressedData
			#if !kha_krom
			if (sound.compressedData != null)
			#end
		{
			callback(sound);
		}
	}
}

private abstract class AssetData<T:AssetType> {
	var assetLoaded:T->Void;

	@:isVar public var asset(default, set):T;
	@:isVar public var source(default, set):String;

	public var loaded(get, never):Bool;

	public function new(?source:String) {
		this.source = source;
	}

	public function onAssetLoaded(cb:T->Void) {
		assetLoaded = cb;
	}

	public function unload() {
		if (loaded) {
			asset.unload();
			asset = null;
		}
	}

	public function reload() {
		unload();
		load();
	}

	public function load(?callback:T->Void) {
		if (source != "") {
			if (source.indexOf("/") + source.indexOf("\\") + source.indexOf(".") > -3)
				loadFromPath(a -> {
					asset = a;
					if (callback != null)
						callback(asset);
				}, err -> {
					Log.error('Failed to load asset ${err.url}: ${err.error ?? "Unknown Error"}');
				});
			else
				loadFromName(a -> {
					asset = a;
					if (callback != null)
						callback(asset);
				}, err -> {
					Log.error('Failed to load asset ${err.url}: ${err.error ?? "Unknown Error"}');
				});
		}
	}

	abstract function loadFromName(callback:T->Void, errorCallback:AssetError->Void):Void;

	abstract function loadFromPath(callback:T->Void, errorCallback:AssetError->Void):Void;

	function set_source(value:String):String {
		value = value ?? "";
		if (source != value) {
			source = value;
			if (source != "")
				load();
			else
				unload();
		}
		return source;
	}

	function set_asset(value:T):T {
		asset = value;
		if (assetLoaded != null)
			assetLoaded(asset);
		return asset;
	}

	function get_loaded():Bool {
		return asset != null;
	}
}

private typedef AssetType = {
	function unload():Void;
}
