package s2d.stage.objects;

import s2d.geometry.Position;

class StageObject extends s2d.PhysicalObject2D<StageObject> {
	@alias public var x:Float = this.translationX;
	@alias public var y:Float = this.translationY;
	@alias public var position:Position = this.translation;

	public function new(name:String = "stageObject") {
		super(name);
	}
}
