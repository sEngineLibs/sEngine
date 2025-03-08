package s2d.stage.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_DEFERRED != 1)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Layer)
@:access(s2d.stage.SpriteAtlas)
@:access(s2d.stage.objects.Sprite)
class LightingForward {
	public static var structures:Array<VertexStructure> = [];
	static var pipeline:PipelineState;
	static var viewProjectionCL:ConstantLocation;
	static var lightPositionCL:ConstantLocation;
	static var lightColorCL:ConstantLocation;
	static var lightAttribCL:ConstantLocation;
	// #if (S2D_LIGHTING_SHADOWS == 1)
	// static var shadowMapTU:TextureUnit;
	// #end
	#if (S2D_LIGHTING_ENVIRONMENT == 1) static var envMapTU:TextureUnit; #end // S2D_LIGHTING_ENVIRONMENT
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	#if (S2D_SPRITE_INSTANCING != 1)
	static var depthCL:ConstantLocation;
	static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	#end // S2D_SPRITE_INSTANCING

	public static function compile() {
		structures.push(new VertexStructure());
		structures[0].add("vertCoord", Float32_2X);

		#if (S2D_SPRITE_INSTANCING == 1)
		structures.push(new VertexStructure());
		structures[1].instanced = true;
		structures[1].add("cropRect", Float32_4X);
		structures.push(new VertexStructure());
		structures[2].instanced = true;
		structures[2].add("model0", Float32_3X);
		structures[2].add("model1", Float32_3X);
		structures[2].add("model2", Float32_3X);
		structures.push(new VertexStructure());
		structures[3].instanced = true;
		structures[3].add("depth", Float32_1X);
		#end // S2D_SPRITE_INSTANCING

		pipeline = new PipelineState();
		pipeline.inputLayout = structures;
		pipeline.vertexShader = Reflect.field(Shaders, "sprite_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "lighting_forward_frag");
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = BlendOne;
		pipeline.blendOperation = Add;
		pipeline.compile();

		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		lightPositionCL = pipeline.getConstantLocation("lightPosition");
		lightColorCL = pipeline.getConstantLocation("lightColor");
		lightAttribCL = pipeline.getConstantLocation("lightAttrib");
		// #if (S2D_LIGHTING_SHADOWS == 1)
		// shadowMapTU = pipeline.getTextureUnit("shadowMap");
		// #end
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");

		#if (S2D_LIGHTING_ENVIRONMENT == 1) envMapTU = pipeline.getTextureUnit("envMap"); #end // S2D_LIGHTING_ENVIRONMENT
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end // S2D_SPRITE_INSTANCING
	}

	@:access(s2d.stage.objects.Light)
	@:access(s2d.stage.graphics.Renderer)
	public static function render():Void {
		final g4 = Renderer.buffer.tgt.g4;
		final viewProjection = Stage.current.viewProjection;

		g4.begin();
		g4.clear(Black);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(@:privateAccess SEngine.indices);
		g4.setMat3(viewProjectionCL, viewProjection);
		#if (S2D_SPRITE_INSTANCING != 1)
		g4.setVertexBuffer(@:privateAccess SEngine.vertices);
		#end
		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		g4.setTexture(envMapTU, Stage.current.environmentMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		for (layer in Stage.current.layers) {
			for (light in layer.lights) {
				// #if (S2D_LIGHTING_SHADOWS == 1)
				// g4.end();
				// ShadowPass.render(light);
				// g4.begin();
				// g4.setPipeline(pipeline);
				// g4.setIndexBuffer(@:privateAccess SEngine.indices);
				// g4.setVertexBuffer(@:privateAccess SEngine.vertices);
				// g4.setTexture(shadowMapTU, Renderer.buffer.shadowMap);
				// #end
				g4.setFloat3(lightPositionCL, light.x, light.y, light.z);
				g4.setFloat3(lightColorCL, light.color.R, light.color.G, light.color.B);
				g4.setFloat2(lightAttribCL, light.power, light.radius);
				#if (S2D_SPRITE_INSTANCING == 1)
				for (atlas in layer.spriteAtlases) {
					g4.setVertexBuffers(atlas.vertices);
					g4.setTexture(albedoMapTU, atlas.albedoMap);
					g4.setTexture(normalMapTU, atlas.normalMap);
					g4.setTexture(ormMapTU, atlas.ormMap);
					g4.setTexture(emissionMapTU, atlas.emissionMap);
					g4.drawInstanced(atlas.sprites.length);
				}
				#else
				var i = 0;
				for (sprite in layer.sprites) {
					g4.setFloat(depthCL, i / layer.sprites.length);
					g4.setMat3(modelCL, sprite.transform);
					g4.setVec4(cropRectCL, sprite.cropRect);
					g4.setTexture(albedoMapTU, sprite.atlas.albedoMap);
					g4.setTexture(normalMapTU, sprite.atlas.normalMap);
					g4.setTexture(ormMapTU, sprite.atlas.ormMap);
					g4.setTexture(emissionMapTU, sprite.atlas.emissionMap);
					g4.draw();
					++i;
				}
				#end
			}
		}
		g4.end();
	}
}
#end
