package s2d.graphics.postprocessing;

import kha.Color;
import kha.Canvas;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.math.SMath;

class Mist extends PPEffect {
	var textureMapTU:TextureUnit;
	var normalMapTU:TextureUnit;
	var cameraPosCL:ConstantLocation;
	var mistScaleCL:ConstantLocation;
	var mistColorCL:ConstantLocation;

	public var near:Float = 0.0;
	public var far:Float = 1.0;
	public var color:Color = White;

	inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.mist_frag;
	}

	inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		cameraPosCL = pipeline.getConstantLocation("cameraPos");
		mistScaleCL = pipeline.getConstantLocation("mistScale");
		mistColorCL = pipeline.getConstantLocation("mistColor");
	}

	inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		final c = S2D.stage.camera;
		final camPos = vec3(c.x, c.y, c.z);

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(textureMapTU, Renderer.ppBuffer.src);
		g4.setTexture(normalMapTU, Renderer.gBuffer.normalMap);
		g4.setVector3(cameraPosCL, camPos);
		g4.setFloat2(mistScaleCL, near, far);
		g4.setFloat4(mistColorCL, color.R, color.G, color.B, color.A);
		g4.drawIndexedVertices();
		g2.end();
	}
}
