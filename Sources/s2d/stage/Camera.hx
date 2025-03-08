package s2d.stage;

import se.math.Mat3;
import se.math.VectorMath;
import s2d.stage.objects.StageObject;

@:allow(s2d.stage.Stage)
class Camera extends StageObject {
	var view:Mat3 = Mat3.lookAt({x: 0.0, y: 0.0}, {x: 0.0, y: -1.0}, {x: 0.0, y: 1.0});

	public function new() {
		super();
	}
}
