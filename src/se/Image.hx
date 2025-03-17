package se;

import kha.Image as KhaImage;

@:forward(width, height, format, unload, at, fromImage, fromCanvas, fromVideo, fromBytes, fromBytes3D, fromEncodedBytes, setDepthStencilFrom, generateMipmaps)
extern abstract Image(KhaImage) from KhaImage to KhaImage {}
