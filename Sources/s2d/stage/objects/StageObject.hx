package s2d.stage.objects;

import s2d.PhysicalObject;

class StageObject extends PhysicalObject<StageObject> {
	@alias public var x:Float = this.transform._20;
	@alias public var y:Float = this.transform._21;

	public function new() {
		super(null);
	}

	function childRemoved(child:StageObject):Void {}

	function childAdded(child:StageObject):Void {}
}
