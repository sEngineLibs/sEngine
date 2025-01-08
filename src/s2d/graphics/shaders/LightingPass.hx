package s2d.graphics.shaders;

import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Stage)
@:allow(s2d.graphics.Renderer)
@:access(s2d.graphics.Renderer)
class LightingPass {
	static var pipeline:PipelineState;
	static var envPipeline:PipelineState;

	static var gBufferTU:TextureUnit;
	static var envGBufferTU:TextureUnit;
	static var invVPCL:ConstantLocation;
	static var lightsDataCL:ConstantLocation;
	#if S2D_RP_ENV_LIGHTING
	static var envMapTU:TextureUnit;
	#end

	static inline function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.lighting_pass_frag;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = BlendOne;
		pipeline.blendOperation = Add;
		pipeline.compile();

		gBufferTU = pipeline.getTextureUnit("gBuffer");
		invVPCL = pipeline.getConstantLocation("invVP");
		lightsDataCL = pipeline.getConstantLocation("lightsData");

		envPipeline = new PipelineState();
		envPipeline.inputLayout = [structure];
		envPipeline.vertexShader = Shaders.s2d_2d_vert;
		envPipeline.fragmentShader = Shaders.env_lighting_pass_frag;
		envPipeline.blendSource = BlendOne;
		envPipeline.blendDestination = BlendOne;
		envPipeline.blendOperation = Add;
		envPipeline.compile();

		envGBufferTU = envPipeline.getTextureUnit("gBuffer");
		#if S2D_RP_ENV_LIGHTING
		envMapTU = envPipeline.getTextureUnit("envMap");
		#end
	}

	static inline function render():Void {
		final g2 = Renderer.ppBuffer.tgt.g2;
		final g4 = Renderer.ppBuffer.tgt.g4;
		final invVP = S2D.stage.VP.inverse();

		g2.begin();
		// glow + environment
		g4.setPipeline(envPipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(envGBufferTU, Renderer.gBuffer);
		#if S2D_RP_ENV_LIGHTING
		g4.setTexture(envMapTU, S2D.stage.environmentMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.drawIndexedVertices();
		// stage lights
		g4.setPipeline(pipeline);
		g4.setTexture(gBufferTU, Renderer.gBuffer);
		g4.setMatrix(invVPCL, invVP);
		g4.setFloats(lightsDataCL, S2D.stage.lightsData);
		g4.drawIndexedVertices();
		g2.end();
	}
}
