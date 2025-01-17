package s2d.graphics.lighting;

#if (S2D_RP_LIGHTING_DEFFERED == 1)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Stage)
@:allow(s2d.graphics.Renderer)
@:access(s2d.graphics.Renderer)
class LightingDeferred {
	static var envPipeline:PipelineState;
	static var pipeline:PipelineState;

	static var envEmissionMapTU:TextureUnit;
	#if (S2D_RP_ENV_LIGHTING == 1)
	static var envMapTU:TextureUnit;
	static var envAlbedoMapTU:TextureUnit;
	static var envNormalMapTU:TextureUnit;
	static var envORMMapTU:TextureUnit;
	#end
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	static var invVPCL:ConstantLocation;
	static var lightsDataCL:ConstantLocation;

	static inline function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

		envPipeline = new PipelineState();
		envPipeline.inputLayout = [structure];
		envPipeline.vertexShader = Shaders.s2d_2d_vert;
		envPipeline.fragmentShader = Shaders.env_lighting_deferred_frag;
		envPipeline.blendSource = BlendOne;
		envPipeline.blendDestination = BlendOne;
		envPipeline.blendOperation = Add;
		envPipeline.compile();

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.lighting_deferred_frag;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = BlendOne;
		pipeline.blendOperation = Add;
		pipeline.compile();

		#if (S2D_RP_ENV_LIGHTING == 1)
		envMapTU = envPipeline.getTextureUnit("envMap");
		envAlbedoMapTU = envPipeline.getTextureUnit("albedoMap");
		envNormalMapTU = envPipeline.getTextureUnit("normalMap");
		envORMMapTU = envPipeline.getTextureUnit("ormMap");
		#end
		envEmissionMapTU = envPipeline.getTextureUnit("emissionMap");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");

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
		g4.setTexture(envEmissionMapTU, Renderer.gBuffer.emissionMap);
		#if (S2D_RP_ENV_LIGHTING == 1)
		g4.setTexture(envMapTU, S2D.stage.environmentMap);
		g4.setTexture(envAlbedoMapTU, Renderer.gBuffer.albedoMap);
		g4.setTexture(envNormalMapTU, Renderer.gBuffer.normalMap);
		g4.setTexture(envORMMapTU, Renderer.gBuffer.ormMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.drawIndexedVertices();
		// stage lights
		g4.setPipeline(pipeline);
		g4.setTexture(albedoMapTU, Renderer.gBuffer.albedoMap);
		g4.setTexture(normalMapTU, Renderer.gBuffer.normalMap);
		g4.setTexture(emissionMapTU, Renderer.gBuffer.emissionMap);
		g4.setTexture(ormMapTU, Renderer.gBuffer.ormMap);
		g4.setMatrix3(invVPCL, invVP);
		g4.setFloats(lightsDataCL, S2D.stage.lightsData);
		g4.drawIndexedVertices();
		g2.end();
	}
}
#end
