package s2d.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_DEFERRED == 1)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Layer)
class LightingDeferred {
	// LIGHTING PASS
	static var pipeline:PipelineState;
	static var viewProjectionCL:ConstantLocation;
	#if (S2D_LIGHTING_SHADOWS == 1)
	static var shadowMapTU:TextureUnit;
	#end
	static var lightPositionCL:ConstantLocation;
	static var lightColorCL:ConstantLocation;
	static var lightAttribCL:ConstantLocation;
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	// ENVIRONMENT PASS
	static var envPipeline:PipelineState;
	#if (S2D_LIGHTING_ENVIRONMENT == 1)
	static var envMapTU:TextureUnit;
	static var envAlbedoMapTU:TextureUnit;
	static var envNormalMapTU:TextureUnit;
	static var envORMMapTU:TextureUnit;
	#end // S2D_LIGHTING_ENVIRONMENT
	static var envEmissionMapTU:TextureUnit;

	public static function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

		// LIGHTING PASS
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.lighting_deferred_frag;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = BlendOne;
		pipeline.blendOperation = Add;
		pipeline.compile();

		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		#if (S2D_LIGHTING_SHADOWS == 1)
		shadowMapTU = pipeline.getTextureUnit("shadowMap");
		#end
		lightPositionCL = pipeline.getConstantLocation("lightPosition");
		lightColorCL = pipeline.getConstantLocation("lightColor");
		lightAttribCL = pipeline.getConstantLocation("lightAttrib");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");

		// ENVIRONMENT PASS
		envPipeline = new PipelineState();
		envPipeline.inputLayout = [structure];
		envPipeline.vertexShader = Shaders.s2d_2d_vert;
		envPipeline.fragmentShader = Shaders.env_lighting_deferred_frag;
		envPipeline.blendSource = BlendOne;
		envPipeline.blendDestination = BlendOne;
		envPipeline.blendOperation = Add;
		envPipeline.compile();

		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		envMapTU = envPipeline.getTextureUnit("envMap");
		envAlbedoMapTU = envPipeline.getTextureUnit("albedoMap");
		envNormalMapTU = envPipeline.getTextureUnit("normalMap");
		envORMMapTU = envPipeline.getTextureUnit("ormMap");
		#end // S2D_LIGHTING_ENVIRONMENT
		envEmissionMapTU = envPipeline.getTextureUnit("emissionMap");
	}

	@:access(s2d.objects.Light)
	@:access(s2d.graphics.Renderer)
	public static function render():Void {
		final g4 = Renderer.buffer.tgt.g4;

		// emission + (environment)
		g4.begin();
		g4.clear(Black);
		g4.setPipeline(envPipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(envEmissionMapTU, Renderer.buffer.emissionMap);
		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		g4.setTexture(envMapTU, Stage.current.environmentMap);
		g4.setTexture(envAlbedoMapTU, Renderer.buffer.albedoMap);
		g4.setTexture(envNormalMapTU, Renderer.buffer.normalMap);
		g4.setTexture(envORMMapTU, Renderer.buffer.ormMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.drawIndexedVertices();

		// stage lights
		g4.setPipeline(pipeline);
		g4.setMatrix3(viewProjectionCL, Stage.current.viewProjection);
		g4.setTexture(albedoMapTU, Renderer.buffer.albedoMap);
		g4.setTexture(normalMapTU, Renderer.buffer.normalMap);
		g4.setTexture(ormMapTU, Renderer.buffer.ormMap);
		for (layer in Stage.current.layers) {
			for (light in layer.lights) {
				#if (S2D_LIGHTING_SHADOWS == 1)
				g4.end();
				ShadowPass.render(light);
				g4.begin();
				g4.setPipeline(pipeline);
				g4.setIndexBuffer(S2D.indices);
				g4.setVertexBuffer(S2D.vertices);
				g4.setTexture(shadowMapTU, Renderer.buffer.shadowMap);
				#end
				g4.setFloat3(lightPositionCL, light.finalModel._20, light.finalModel._21, light.z);
				g4.setVector3(lightColorCL, light.color.RGB);
				g4.setFloat2(lightAttribCL, light.power, light.radius);
				g4.drawIndexedVertices();
			}
		}
		g4.end();
	}
}
#end
