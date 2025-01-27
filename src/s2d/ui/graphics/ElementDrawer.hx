package s2d.ui.graphics;

import kha.Canvas;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;

abstract class ElementDrawer<T> {
	public var pipeline:PipelineState;

	var structure:VertexStructure;

	public function new() {}

	public function ready() {
		initStructure();

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
	}

	abstract function initStructure():Void;

	public function set() {
		setShaders();
		pipeline.compile();
		getUniforms();
	}

	abstract function setShaders():Void;

	abstract function getUniforms():Void;

	function render(target:Canvas, element:T) {
		final g2 = target.g2, g4 = target.g4;

		g2.pipeline = pipeline;
		g4.setPipeline(pipeline);
		draw(target, element);
		g2.pipeline = null;
	}

	abstract function draw(target:Canvas, element:T):Void;
}
