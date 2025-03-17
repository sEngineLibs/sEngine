package s2d.stage.objects;

import kha.FastFloat;
import s2d.Object2D;

class LayerObject extends StageObject {
	var layer:Layer;

	public inline function new(layer:Layer) {
		super();

		this.layer = layer;
	}
}
