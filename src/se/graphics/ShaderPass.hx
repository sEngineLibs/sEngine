package se.graphics;

import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import se.Texture;
import se.graphics.ShaderPipeline;

abstract class ShaderPass {
	public var pipeline:ShaderPipeline;

	public function new(pipeline:ShaderPipelineState) {
		this.pipeline = pipeline;
		setup();
	}

	abstract function setup():Void;
}
