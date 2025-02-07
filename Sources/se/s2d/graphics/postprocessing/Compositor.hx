package se.s2d.graphics.postprocessing;

import se.Color;
import kha.Canvas;
import kha.Shaders;
import kha.arrays.Float32Array;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;

class Compositor extends PPEffect {
	var textureMapTU:TextureUnit;
	var paramsCL:ConstantLocation;

	var params:Float32Array;

	public var letterBoxHeight:Int = 0;
	public var letterBoxColor:Color = "black";
	public var vignetteStrength(get, set):Float;
	public var vignetteColor(get, set):Color;
	public var posterizeGamma(get, set):Float;
	public var posterizeSteps(get, set):Float;

	public function new() {
		super();

		params = new Float32Array(7);
		posterizeGamma = 1.0;
		posterizeSteps = 255.0;
		vignetteStrength = 0.0;
		vignetteColor = "black";
	}

	function setPipeline() {
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "compositor_frag");
	}

	function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		paramsCL = pipeline.getConstantLocation("params");
	}

	@:access(se.s2d.graphics.Renderer)
	function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		g2.begin();
		g4.scissor(0, letterBoxHeight, SEngine.width, SEngine.height - letterBoxHeight * 2);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(SEngine.indices);
		g4.setVertexBuffer(SEngine.vertices);
		g4.setTexture(textureMapTU, Renderer.buffer.src);
		g4.setFloats(paramsCL, params);
		g4.drawIndexedVertices();
		g4.disableScissor();
		g2.end();
	}

	function get_posterizeGamma():Float {
		return params[0];
	}

	function set_posterizeGamma(value:Float):Float {
		params[0] = value;
		return value;
	}

	function get_posterizeSteps():Float {
		return params[1];
	}

	function set_posterizeSteps(value:Float):Float {
		params[1] = value;
		return value;
	}

	function get_vignetteStrength():Float {
		return params[2];
	}

	function set_vignetteStrength(value:Float):Float {
		params[2] = value;
		return value;
	}

	function get_vignetteColor():Color {
		return Color.rgba(params[3], params[4], params[5], params[6]);
	}

	function set_vignetteColor(value:Color):Color {
		params[3] = value.r;
		params[4] = value.g;
		params[5] = value.b;
		params[6] = value.a;
		return value;
	}
}
