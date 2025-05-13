package se;

import se.Resource;

@:forward()
@:forward.new
extern abstract BlobAsset(BlobAssetData) {
	@:from
	public static inline function get(source:String):BlobAsset {
		return new BlobAsset(source);
	}

	@:to
	public inline function toAsset():Blob {
		return this.asset;
	}
}

@:forward()
@:forward.new
extern abstract FontAsset(FontAssetData) {
	@:from
	public static inline function get(source:String):FontAsset {
		return new FontAsset(source);
	}

	@:to
	public inline function toAsset():Font {
		return this.asset;
	}
}

@:forward()
@:forward.new
extern abstract ImageAsset(ImageAssetData) {
	@:from
	public static inline function get(source:String):ImageAsset {
		return new ImageAsset(source);
	}

	@:to
	public inline function toAsset():Image {
		return this.asset;
	}
}

@:forward()
@:forward.new
extern abstract SoundAsset(SoundAssetData) {
	@:from
	public static inline function get(source:String):SoundAsset {
		return new SoundAsset(source);
	}

	@:to
	public inline function toAsset():Sound {
		return this.asset;
	}
}

@:forward()
@:forward.new
extern abstract VideoAsset(VideoAssetData) {
	@:from
	public static inline function get(source:String):VideoAsset {
		return new VideoAsset(source);
	}

	@:to
	public inline function toAsset():Video {
		return this.asset;
	}
}

private class BlobAssetData extends AssetData<Blob> {
	function _get(?done:Blob->Void, ?failed:ResourceError->Void):Void {
		Resource.getBlob(source, done, failed);
	}

	function _reload(?done:Blob->Void, ?failed:ResourceError->Void):Void {
		Resource.reloadBlob(source, done, failed);
	}
}

private class FontAssetData extends AssetData<Font> {
	function _get(?done:Font->Void, ?failed:ResourceError->Void):Void {
		Resource.getFont(source, done, failed);
	}

	function _reload(?done:Font->Void, ?failed:ResourceError->Void):Void {
		Resource.reloadFont(source, done, failed);
	}
}

private class ImageAssetData extends AssetData<Image> {
	function _get(?done:Image->Void, ?failed:ResourceError->Void):Void {
		Resource.getImage(source, done, failed);
	}

	function _reload(?done:Image->Void, ?failed:ResourceError->Void):Void {
		Resource.reloadImage(source, done, failed);
	}
}

private class SoundAssetData extends AssetData<Sound> {
	function _get(?done:Sound->Void, ?failed:ResourceError->Void):Void {
		Resource.getSound(source, done, failed);
	}

	function _reload(?done:Sound->Void, ?failed:ResourceError->Void):Void {
		Resource.reloadSound(source, done, failed);
	}
}

private class VideoAssetData extends AssetData<Video> {
	function _get(?done:Video->Void, ?failed:ResourceError->Void):Void {
		Resource.getVideo(source, done, failed);
	}

	function _reload(?done:Video->Void, ?failed:ResourceError->Void):Void {
		Resource.reloadVideo(source, done, failed);
	}
}

#if !macro
@:build(se.macro.SMacro.build())
#end
abstract class AssetData<T:kha.Resource> {
	@:isVar public var asset(default, null):T = null;
	@:isVar public var source(default, set):String = "";

	public var isLoaded(get, never):Bool;

	@:signal function assetLoaded(asset:T):Void;

	public inline function new(?source:String) {
		this.source = source;
	}

	abstract function _get(?done:T->Void, ?failed:ResourceError->Void):Void;

	abstract function _reload(?done:T->Void, ?failed:ResourceError->Void):Void;

	public inline function reload(?done:T->Void, ?failed:ResourceError->Void) {
		_reload(a -> {
			this.asset = a;
			this.assetLoaded(asset);
		});
	}

	inline function set_source(value:String):String {
		value = value ?? "";
		if (value != source) {
			source = value;
			if (source != "")
				_get(a -> {
					asset = a;
					assetLoaded(this.asset);
				});
			else
				asset = null;
		}
		return source;
	}

	inline function get_isLoaded():Bool {
		return this.asset != null;
	}
}
