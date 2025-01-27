package s2d.objects;

import s2d.core.S2DObject;

@:autoBuild(s2d.core.macro.SMacro.build())
abstract class StageObject extends S2DObject<StageObject> {
	var layer:Layer;

	public function new(layer:Layer) {
		super();
		this.layer = layer;
	}

	function onParentChanged() {}
}
