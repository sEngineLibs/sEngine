package s2d.stage;

import se.math.Mat3;
import se.math.VectorMath;
import s2d.stage.objects.StageObject;

@:allow(s2d.stage.Stage)
class Camera extends StageObject {
	var view:Mat3 = Mat3.lookAt(vec2(0.0, 0.0), vec2(0.0, -1.0), vec2(0.0, 1.0));

	public function new() {
		super();
	}
}
