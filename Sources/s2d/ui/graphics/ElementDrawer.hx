package s2d.ui.graphics;

import se.Texture;
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

	function render(target:Texture, element:T) {
		final ctx = target.context2D, ctx3d = target.context3D;

		ctx.pipeline = pipeline;
		ctx3d.setPipeline(pipeline);
		ctx3d.setMatrix3(modelCL, ctx.transform);
		draw(target, element);
		ctx.pipeline = null;
	}

	abstract function initStructure():Void;

	abstract function setShaders():Void;

	abstract function getUniforms():Void;

	abstract function draw(target:Texture, element:T):Void;
}
