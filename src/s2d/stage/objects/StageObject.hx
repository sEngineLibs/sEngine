package s2d.stage.objects;

class StageObject extends s2d.PhysicalObject2D<StageObject> {
	@alias public var x:Float = this.transform._20;
	@alias public var y:Float = this.transform._21;

	public function new() {
		super("stageObject");
	}
}
