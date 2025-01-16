package s2d.core.formats;

import kha.Blob;
import kha.Image;

class TGA {
    public static inline function parseBlob(blob:Blob):Image {
        if (blob == null) {
            trace('Failed to parse blob');
            return null;
        }

        var bytes = blob.toBytes();

        var offset = 0;
        var idLength = bytes.get(offset++);
        var colorMapType = bytes.get(offset++);
        var imageType = bytes.get(offset++);

        offset += 5;

        var xOrigin = bytes.getUInt16(offset);
        offset += 2;
        var yOrigin = bytes.getUInt16(offset);
        offset += 2;
        var width = bytes.getUInt16(offset);
        offset += 2;
        var height = bytes.getUInt16(offset);
        offset += 2;
        var bitsPerPixel = bytes.get(offset++);
        var imageDescriptor = bytes.get(offset++);

        offset += idLength;

        if (imageType != 2 && imageType != 10) {
            trace('TGA: Only uncompressed 24 or 32 bit image is supported');
            return null;
        }

        if (bitsPerPixel != 24 && bitsPerPixel != 32) {
            trace('TGA: Only 24 or 32 bits is supported');
            return null;
        }

        var bytesPerPixel = Math.floor(bitsPerPixel / 8);

        var image = Image.create(width, height, RGBA32);
        var imageBytes = image.lock();

        for (y in 0...height) {
            for (x in 0...width) {
                var pixelOffset = (x + (height - 1 - y) * width) * 4;

                var b = bytes.get(offset++);
                var g = bytes.get(offset++);
                var r = bytes.get(offset++);

                var a = 255;
                if (bytesPerPixel == 4) {
                    a = bytes.get(offset++);
                }

                imageBytes.set(pixelOffset + 0, r);
                imageBytes.set(pixelOffset + 1, g);
                imageBytes.set(pixelOffset + 2, b);
                imageBytes.set(pixelOffset + 3, a);
            }
        }
        image.unlock();
        return image;
    }
}
