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
	static var envPipeline:PipelineState;
	static var pipeline:PipelineState;

	#if (S2D_RP_PACK_GBUFFER == 1)
	static var envGBufferTU:TextureUnit;
	static var gBufferTU:TextureUnit;
	#else
	static var envAlbedoMapTU:TextureUnit;
	static var envNormalMapTU:TextureUnit;
	static var envEmissionMapTU:TextureUnit;
	static var envORMMapTU:TextureUnit;
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	#end
	#if S2D_RP_ENV_LIGHTING
	static var envMapTU:TextureUnit;
	#end
	static var invVPCL:ConstantLocation;
	static var lightsDataCL:ConstantLocation;

	static inline function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

		envPipeline = new PipelineState();
		envPipeline.inputLayout = [structure];
		envPipeline.vertexShader = Shaders.s2d_2d_vert;
		envPipeline.fragmentShader = Shaders.env_lighting_pass_frag;
		envPipeline.blendSource = BlendOne;
		envPipeline.blendDestination = BlendOne;
		envPipeline.blendOperation = Add;
		envPipeline.compile();

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.lighting_pass_frag;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = BlendOne;
		pipeline.blendOperation = Add;
		pipeline.compile();

		#if (S2D_RP_PACK_GBUFFER == 1)
		envGBufferTU = envPipeline.getTextureUnit("gBuffer");
		gBufferTU = pipeline.getTextureUnit("gBuffer");
		#else
		envAlbedoMapTU = envPipeline.getTextureUnit("albedoMap");
		envNormalMapTU = envPipeline.getTextureUnit("normalMap");
		envEmissionMapTU = envPipeline.getTextureUnit("emissionMap");
		envORMMapTU = envPipeline.getTextureUnit("ormMap");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
		#end
		#if S2D_RP_ENV_LIGHTING
		envMapTU = envPipeline.getTextureUnit("envMap");
		#end

		invVPCL = pipeline.getConstantLocation("invVP");
		lightsDataCL = pipeline.getConstantLocation("lightsData");
	}

	static inline function render():Void {
		final g2 = Renderer.ppBuffer.tgt.g2;
		final g4 = Renderer.ppBuffer.tgt.g4;
		final invVP = S2D.stage.VP.inverse();

		g2.begin();
		// emission + environment
		g4.setPipeline(envPipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		#if (S2D_RP_PACK_GBUFFER == 1)
		g4.setTexture(envGBufferTU, Renderer.gBuffer);
		#else
		g4.setTexture(envAlbedoMapTU, Renderer.gBuffer[0]);
		g4.setTexture(envNormalMapTU, Renderer.gBuffer[1]);
		g4.setTexture(envEmissionMapTU, Renderer.gBuffer[2]);
		g4.setTexture(envORMMapTU, Renderer.gBuffer[3]);
		#end
		#if S2D_RP_ENV_LIGHTING
		g4.setTexture(envMapTU, S2D.stage.environmentMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.drawIndexedVertices();
		// stage lights
		g4.setPipeline(pipeline);
		#if (S2D_RP_PACK_GBUFFER == 1)
		g4.setTexture(gBufferTU, Renderer.gBuffer);
		#else
		g4.setTexture(albedoMapTU, Renderer.gBuffer[0]);
		g4.setTexture(normalMapTU, Renderer.gBuffer[1]);
		g4.setTexture(emissionMapTU, Renderer.gBuffer[2]);
		g4.setTexture(ormMapTU, Renderer.gBuffer[3]);
		#end
		g4.setMatrix(invVPCL, invVP);
		g4.setFloats(lightsDataCL, S2D.stage.lightsData);
		g4.drawIndexedVertices();
		g2.end();
	}
}
