package s2d.stage.objects;

import kha.FastFloat;
import s2d.PhysicalObject2D;

class LayerObject extends StageObject {
	var layer:StageLayer;

	public function new(layer:StageLayer) {
		super();
		this.layer = layer;
	}
}
