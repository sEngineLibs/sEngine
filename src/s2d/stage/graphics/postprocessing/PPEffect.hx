package s2d.stage.graphics.postprocessing;

import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import se.Texture;

@:access(s2d.stage.graphics.Renderer)
abstract class PPEffect {
	var pipeline:PipelineState;
	var index:Int;

	public var enabled(get, set):Bool;

	public function new() {}

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

	abstract public function render(target:Texture):Void;

	public function command():Void {
		Renderer.buffer.swap();
		render(Renderer.buffer.tgt);
	}

	function get_enabled():Bool {
		return Renderer.commands.contains(command);
	}

	function set_enabled(value:Bool):Bool {
		if (!enabled && value)
			Renderer.commands.insert(index, command);
		return enabled;
	}
}
