package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;

class Bloom extends PPEffect {
	var textureMapTU:TextureUnit;
	var paramsCL:ConstantLocation;

	public var radius:Float = 8.0;
	public var threshold:Float = 0.25;
	public var intensity:Float = 0.75;

	inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.bloom_frag;
	}

	inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		paramsCL = pipeline.getConstantLocation("params");
	}

	inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		Renderer.ppBuffer.src.generateMipmaps(4);

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(textureMapTU, Renderer.ppBuffer.src);
		g4.setTextureParameters(textureMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		g4.setFloat3(paramsCL, radius, threshold, intensity);
		g4.drawIndexedVertices();
		g2.end();
	}
}
