package s2d.stage.objects;

import s2d.PhysicalObject2D;

class StageObject extends PhysicalObject2D<StageObject> {
	@alias public var x:Float = this.transform._20;
	@alias public var y:Float = this.transform._21;

	public function new() {
		super();
	}
}
