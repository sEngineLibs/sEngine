package s2d.stage.graphics.lighting;

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
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "lighting_deferred_frag");
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
		envPipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		envPipeline.fragmentShader = Reflect.field(Shaders, "env_lighting_deferred_frag");
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

	@:access(s2d.stage.objects.Light)
	@:access(s2d.stage.graphics.Renderer)
	public static function render():Void {
		final ctx = Renderer.buffer.tgt.context3D;

		// emission + (environment)
		ctx.begin();
		ctx.clear(Black);
		ctx.setPipeline(envPipeline);
		ctx.setIndexBuffer(@:privateAccess se.SEngine.indices);
		ctx.setVertexBuffer(@:privateAccess se.SEngine.vertices);
		ctx.setTexture(envEmissionMapTU, Renderer.buffer.emissionMap);
		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		ctx.setTexture(envMapTU, Stage.current.environmentMap);
		ctx.setTexture(envAlbedoMapTU, Renderer.buffer.albedoMap);
		ctx.setTexture(envNormalMapTU, Renderer.buffer.normalMap);
		ctx.setTexture(envORMMapTU, Renderer.buffer.ormMap);
		ctx.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		ctx.drawIndexedVertices();

		// stage lights
		ctx.setPipeline(pipeline);
		ctx.setMatrix3(viewProjectionCL, Stage.current.viewProjection);
		ctx.setTexture(albedoMapTU, Renderer.buffer.albedoMap);
		ctx.setTexture(normalMapTU, Renderer.buffer.normalMap);
		ctx.setTexture(ormMapTU, Renderer.buffer.ormMap);
		for (layer in Stage.current.layers) {
			for (light in layer.lights) {
				#if (S2D_LIGHTING_SHADOWS == 1)
				ctx.end();
				ShadowPass.render(light);
				ctx.begin();
				ctx.setPipeline(pipeline);
				ctx.setIndexBuffer(@:privateAccess se.SEngine.indices);
				ctx.setVertexBuffer(@:privateAccess se.SEngine.vertices);
				ctx.setTexture(shadowMapTU, Renderer.buffer.shadowMap);
				#end
				ctx.setFloat3(lightPositionCL, light._transform._20, light._transform._21, light.z);
				ctx.setVector3(lightColorCL, light.color.RGB);
				ctx.setFloat2(lightAttribCL, light.power, light.radius);
				ctx.drawIndexedVertices();
			}
		}
		ctx.end();
	}
}
#end
