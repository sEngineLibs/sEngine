package s2d.graphics.postprocessing;

import kha.Color;
import kha.Canvas;
import kha.Shaders;
import kha.FastFloat;
import kha.arrays.Float32Array;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;

class Compositor extends PPEffect {
	var textureMapTU:TextureUnit;
	var resolutionCL:ConstantLocation;
	var paramsCL:ConstantLocation;

	var params:Float32Array;

	public var letterBoxHeight:Int = 0;
	public var letterBoxColor:Color = Black;
	public var vignetteStrength(get, set):FastFloat;
	public var vignetteColor(get, set):Color;
	public var posterizeGamma(get, set):FastFloat;
	public var posterizeSteps(get, set):FastFloat;

	public inline function new() {
		params = new Float32Array(7);

		posterizeGamma = 1.0;
		posterizeSteps = 255.0;
		vignetteStrength = 0.0;
		vignetteColor = Black;
	}

	override inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.compositor_pass_frag;
	}

	override inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		resolutionCL = pipeline.getConstantLocation("resolution");
		paramsCL = pipeline.getConstantLocation("Params");
	}

	override inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		g2.begin();
		g4.scissor(0, letterBoxHeight, S2D.width, S2D.height - letterBoxHeight * 2);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(textureMapTU, Renderer.ppBuffer.src);
		g4.setFloat2(resolutionCL, S2D.width, S2D.height);
		g4.setFloats(paramsCL, params);
		g4.drawIndexedVertices();
		g4.disableScissor();
		g2.end();
	}

	inline function get_posterizeGamma():FastFloat {
		return params[0];
	}

	inline function set_posterizeGamma(value:FastFloat):FastFloat {
		params[0] = value;
		return value;
	}

	inline function get_posterizeSteps():FastFloat {
		return params[1];
	}

	inline function set_posterizeSteps(value:FastFloat):FastFloat {
		params[1] = value;
		return value;
	}

	inline function get_vignetteStrength():FastFloat {
		return params[2];
	}

	inline function set_vignetteStrength(value:FastFloat):FastFloat {
		params[2] = value;
		return value;
	}

	inline function get_vignetteColor():Color {
		return Color.fromFloats(params[3], params[4], params[5], params[6]);
	}

	inline function set_vignetteColor(value:Color):Color {
		params[3] = value.R;
		params[4] = value.G;
		params[5] = value.B;
		params[6] = value.A;
		return value;
	}
}
