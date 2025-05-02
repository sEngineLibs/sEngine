package s2d.elements;

import kha.Assets;
import se.Image;
import se.Texture;

class ImageElement extends DrawableElement {
	var image:Image;

	public var source(default, set):String;
	public var fillMode:ImageFillMode = Stretch;

	public function new(source:String = "", name:String = "image", ?scene:WindowScene) {
		super(name, scene);
		this.source = source;
	}

	function draw(target:Texture) {
		if (image != null) {
			switch fillMode {
				case Pad:
					target.ctx2D.drawSubImage(image, absX, absY, 0.0, 0.0, width, height);
				case Stretch:
					target.ctx2D.drawScaledImage(image, absX, absY, width, height);
				case Cover:
					var scale = Math.max(width / image.width, height / image.height);
					var scaledWidth = image.width * scale;
					var scaledHeight = image.height * scale;
					var offsetX = (scaledWidth - width) / 2;
					var offsetY = (scaledHeight - height) / 2;
					target.ctx2D.drawScaledSubImage(image, offsetX / scale, offsetY / scale, width / scale, height / scale, absX, absY, width, height);
				case Contain:
					var scale = Math.min(width / image.width, height / image.height);
					var scaledWidth = image.width * scale;
					var scaledHeight = image.height * scale;
					var offsetX = (width - scaledWidth) / 2;
					var offsetY = (height - scaledHeight) / 2;
					target.ctx2D.drawScaledImage(image, absX + offsetX, absY + offsetY, scaledWidth, scaledHeight);
				case Tile:
					throw new haxe.exceptions.NotImplementedException("Tile fill mode is not yet implemented");
				case TileVertically:
					throw new haxe.exceptions.NotImplementedException("TileVertically fill mode is not yet implemented");
				case TileHorizontally:
					throw new haxe.exceptions.NotImplementedException("TileHorizontally fill mode is not yet implemented");
			}
		}
	}

	function set_source(value:String):String {
		source = value;
		image = source != "" ? Assets.images.get(source) : null;
		return source;
	}
}

enum ImageFillMode {
	/**
	 * The image is not transformed
	 */
	Pad;

	/**
	 * The image is scaled to fit
	 */
	Stretch;

	/**
	 * The image is scaled uniformly to fill, cropping if necessary
	 */
	Cover;

	/**
	 * The image is scaled uniformly to fit without cropping
	 */
	Contain;

	/**
	 * The image is duplicated horizontally and vertically
	 */
	Tile;

	/**
	 * The image is stretched horizontally and tiled vertically
	 */
	TileVertically;

	/**
	 * The image is stretched vertically and tiled horizontally
	 */
	TileHorizontally;
}
