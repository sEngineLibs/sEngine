package se.graphics;

import se.graphics.ShaderPipeline;

abstract class ShaderPass {
	public var pipeline:ShaderPipeline;

	public function new(pipeline:ShaderPipelineState) {
		this.pipeline = pipeline;
		setup();
	}

	abstract function setup():Void;
}
