package s2d.graphics.postprocessing;

import kha.Color;
import kha.Canvas;
import kha.Shaders;
import kha.FastFloat;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;

class Mist extends PPEffect {
	var textureMapTU:TextureUnit;
	var gBufferTU:TextureUnit;
	var invVPCL:ConstantLocation;
	var cameraPosCL:ConstantLocation;
	var mistScaleCL:ConstantLocation;
	var mistColorCL:ConstantLocation;

	public var near:FastFloat = 0.0;
	public var far:FastFloat = 1.0;
	public var color = Color.fromFloats(0.0, 0.0, 0.0, 0.0);

	inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.mist_pass_frag;
	}

	inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		gBufferTU = pipeline.getTextureUnit("gBuffer");
		invVPCL = pipeline.getConstantLocation("invVP");
		cameraPosCL = pipeline.getConstantLocation("cameraPos");
		mistScaleCL = pipeline.getConstantLocation("mistScale");
		mistColorCL = pipeline.getConstantLocation("mistColor");
	}

	inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		final invVP = S2D.stage.VP.inverse();
		final camPos = S2D.stage.camera.transformation.getTranslation();

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(textureMapTU, Renderer.ppBuffer.src);
		g4.setTexture(gBufferTU, Renderer.gBuffer);
		g4.setMatrix(invVPCL, invVP);
		g4.setVector3(cameraPosCL, camPos);
		g4.setFloat2(mistScaleCL, near, far);
		g4.setFloat4(mistColorCL, color.R, color.G, color.B, color.A);
		g4.drawIndexedVertices();
		g2.end();
	}
}
