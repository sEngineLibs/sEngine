package s2d.stage.objects;

import s2d.Object2D;

class StageObject extends Object2D<StageObject> {
	@alias public var x:Float = this.transform._20;
	@alias public var y:Float = this.transform._21;

	public function new() {
		super();
	}
}
