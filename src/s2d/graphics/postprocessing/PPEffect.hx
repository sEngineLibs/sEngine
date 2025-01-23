package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;

@:access(s2d.graphics.Renderer)
abstract class PPEffect {
	var pipeline:PipelineState;
	var index:Int;

	public var enabled(get, set):Bool;

	public function new() {}

	function get_enabled():Bool {
		return Renderer.commands.contains(command);
	}

	function set_enabled(value:Bool):Bool {
		if (!enabled)
			Renderer.commands.insert(index, command);
		return value;
	}

	public function enable() {
		enabled = true;
	}

	public function disable() {
		enabled = false;
	}

	abstract function setPipeline():Void;

	abstract function getUniforms():Void;

	public function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		setPipeline();
		pipeline.compile();
		getUniforms();
	}

	abstract public function render(target:Canvas):Void;

	public function command():Void {
		Renderer.buffer.swap();
		render(Renderer.buffer.tgt);
	}
}
