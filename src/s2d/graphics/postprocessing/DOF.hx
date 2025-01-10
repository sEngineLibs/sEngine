package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.FastFloat;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;

class DOF extends PPEffect {
	var textureMapTU:TextureUnit;
	var resolutionCL:ConstantLocation;
	var gBufferTU:TextureUnit;
	var invVPCL:ConstantLocation;
	var cameraPosCL:ConstantLocation;
	var focusDistanceCL:ConstantLocation;
	var blurSizeCL:ConstantLocation;

	public var focusDistance:FastFloat = 0.5;
	public var blurSize:FastFloat = 0.0;

	public inline function new() {}

	override inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.dof_pass_frag;
	}

	override inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		resolutionCL = pipeline.getConstantLocation("resolution");
		gBufferTU = pipeline.getTextureUnit("gBuffer");
		invVPCL = pipeline.getConstantLocation("invVP");
		cameraPosCL = pipeline.getConstantLocation("cameraPos");
		focusDistanceCL = pipeline.getConstantLocation("focusDistance");
		blurSizeCL = pipeline.getConstantLocation("blurSize");
	}

	override inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		final invVP = S2D.stage.VP.inverse();
		final camPos = S2D.stage.camera.transformation.getTranslation();

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(gBufferTU, Renderer.gBuffer);
		g4.setTexture(textureMapTU, Renderer.ppBuffer.src);
		g4.setFloat2(resolutionCL, S2D.width, S2D.height);
		g4.setMatrix(invVPCL, invVP);
		g4.setVector3(cameraPosCL, camPos);
		g4.setFloat(focusDistanceCL, focusDistance);
		g4.setFloat(blurSizeCL, blurSize);
		g4.drawIndexedVertices();
		g2.end();
	}
}
