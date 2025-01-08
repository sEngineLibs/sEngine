package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;

@:access(s2d.graphics.Renderer)
class PPEffect {
	var pipeline:PipelineState;

	var index:Int;

	public var enabled(get, set):Bool;

	inline function get_enabled():Bool {
		return Renderer.commands.contains(command);
	}

	inline function set_enabled(value:Bool):Bool {
		if (!enabled)
			Renderer.commands.insert(index, command);
		return value;
	}

	public inline function enable() {
		enabled = true;
	}

	public inline function disable() {
		enabled = false;
	}

	function setPipeline() {}

	function getUniforms() {}

	public function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		setPipeline();
		pipeline.compile();
		getUniforms();
	}

	public function render(target:Canvas) {}

	public function command():Void {
		Renderer.ppBuffer.swap();
		render(Renderer.ppBuffer.tgt);
	}
}
