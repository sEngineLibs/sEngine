package s2d.graphics;

import kha.graphics4.ConstantLocation;
import se.Texture;
import se.graphics.ShaderPipeline;
import se.graphics.ShaderPass;

@:allow(s2d.Element)
abstract class ElementDrawer<T> extends ShaderPass {
	var modelCL:ConstantLocation;

	public function new(state:ShaderPipelineState) {
		super(state);
	}

	function setup() {
		modelCL = pipeline.getConstantLocation("model");
	}

	function render(target:Texture, element:T) {
		final ctx = target.context2D, ctx3d = target.context3D;

		ctx.pipeline = pipeline;
		ctx3d.setPipeline(pipeline);
		ctx3d.setMat3(modelCL, ctx.transform);
		draw(target, element);
		ctx.pipeline = null;
	}

	abstract function draw(target:Texture, element:T):Void;
}
