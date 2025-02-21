package se;

import kha.graphics4.TextureFormat;

@:forward.new
@:forward(at, fromImage, fromCanvas, fromVideo, fromBytes, fromBytes3D, fromEncodedBytes)
abstract Image(kha.Image) from kha.Image to kha.Image {
	public var width(get, never):Int;
	public var height(get, never):Int;
	public var format(get, never):TextureFormat;

	function get_width():Int {
		return this.width;
	}

	inline function get_height():Int {
		return this.height;
	}

	inline function get_format():TextureFormat {
		return this.format;
	}
}
