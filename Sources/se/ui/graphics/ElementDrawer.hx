package se.ui.graphics;

import kha.Canvas;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

abstract class ElementDrawer<T> {
	public var pipeline:PipelineState;

	var structure:VertexStructure;
	var modelCL:ConstantLocation;

	public function new() {}

	public function compile() {
		initStructure();
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		setShaders();
		pipeline.compile();
		modelCL = pipeline.getConstantLocation("model");
		getUniforms();
	}

	function render(target:Canvas, element:T) {
		final g2 = target.g2, g4 = target.g4;

		g2.pipeline = pipeline;
		g4.setPipeline(pipeline);
		g4.setMatrix3(modelCL, g2.transformation);
		draw(target, element);
		g2.pipeline = null;
	}

	abstract function initStructure():Void;

	abstract function setShaders():Void;

	abstract function getUniforms():Void;

	abstract function draw(target:Canvas, element:T):Void;
}
