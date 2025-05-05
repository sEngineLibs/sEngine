package s2d.elements;

import se.Image;
import se.Texture;
import s2d.geometry.Rect;

class ImageElement extends DrawableElement {
	public var image(default, set):Image;
	public var sourceClip:Rect = new Rect(0.0, 0.0, 0.0, 0.0);
	public var fillMode:ImageFillMode = Stretch;

	public function new(?image:Image, name:String = "image") {
		super(name);
		this.image = image;
	}

	function draw(target:Texture) {
		if (image != null) {
			switch fillMode {
				case Pad:
					target.context2D.drawSubImage(image, absX, absY, sourceClip.x, sourceClip.y, sourceClip.width, sourceClip.height);
				case Stretch:
					target.context2D.drawScaledSubImage(image, sourceClip.x, sourceClip.y, sourceClip.width, sourceClip.height, absX, absY, width, height);
				case Cover:
					var scale = Math.max(width / sourceClip.width, height / sourceClip.height);
					var scaledWidth = sourceClip.width * scale;
					var scaledHeight = sourceClip.height * scale;
					var offsetX = (scaledWidth - width) / 2;
					var offsetY = (scaledHeight - height) / 2;
					target.context2D.drawScaledSubImage(image, sourceClip.x + offsetX / scale, sourceClip.y + offsetY / scale, width / scale, height / scale,
						absX, absY, width, height);
				case Contain:
					var scale = Math.min(width / sourceClip.width, height / sourceClip.height);
					var scaledWidth = sourceClip.width * scale;
					var scaledHeight = sourceClip.height * scale;
					var offsetX = (width - scaledWidth) / 2;
					var offsetY = (height - scaledHeight) / 2;
					target.context2D.drawScaledSubImage(image, sourceClip.x, sourceClip.y, sourceClip.width, sourceClip.height, absX + offsetX,
						absY + offsetY, scaledWidth, scaledHeight);
				case Tile:
					throw new haxe.exceptions.NotImplementedException("Tile fill mode is not yet implemented");
				case TileVertically:
					throw new haxe.exceptions.NotImplementedException("TileVertically fill mode is not yet implemented");
				case TileHorizontally:
					throw new haxe.exceptions.NotImplementedException("TileHorizontally fill mode is not yet implemented");
			}
		}
	}

	function set_image(value:Image):Image {
		image = value;
		if (image != null)
			sourceClip = new Rect(0.0, 0.0, image.width, image.height);
		return image;
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
