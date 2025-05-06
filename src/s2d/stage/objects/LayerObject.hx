package s2d.stage.objects;

class LayerObject extends StageObject {
	var layer:StageLayer;

	public function new(layer:StageLayer) {
		super();
		this.layer = layer;
	}
}
