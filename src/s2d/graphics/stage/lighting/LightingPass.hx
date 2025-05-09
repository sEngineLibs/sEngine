package s2d.graphics.stage.lighting;

#if (S2D_LIGHTING)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexStructure;
import se.Texture;
import se.graphics.ShaderPass;
import se.graphics.ShaderPipeline;
import s2d.stage.Stage;

@:access(s2d.stage.Stage)
@:allow(s2d.graphics.StageRenderer)
class LightingPass extends StageRenderPass {
	var viewProjectionCL:ConstantLocation;
	var lightPositionCL:ConstantLocation;
	var lightColorCL:ConstantLocation;
	var lightAttribCL:ConstantLocation;
	var albedoMapTU:TextureUnit;
	var normalMapTU:TextureUnit;
	var emissionMapTU:TextureUnit;
	#if (S2D_LIGHTING_PBR == 1)
	var ormMapTU:TextureUnit;
	#end
	#if (S2D_LIGHTING_DEFERRED != 1 && S2D_SPRITE_INSTANCING != 1)
	var depthCL:ConstantLocation;
	var modelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end

	public function new(inputLayout:Array<VertexStructure>) {
		super({
			#if (S2D_LIGHTING_DEFERRED == 1)
			inputLayout: [inputLayout[0]], vertexShader: Reflect.field(Shaders, "sprite_vert"), fragmentShader: Reflect.field(Shaders, "geometry_frag"),
			depthWrite: true, depthMode: Less, depthStencilAttachment: DepthOnly
			#else
			inputLayout: inputLayout, vertexShader: Reflect.field(Shaders, "sprite_vert"), fragmentShader: Reflect.field(Shaders, "lighting_forward_frag"),
			alphaBlendSource: SourceAlpha
			#end
		});
	}

	function setup() {
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		lightPositionCL = pipeline.getConstantLocation("lightPosition");
		lightColorCL = pipeline.getConstantLocation("lightColor");
		lightAttribCL = pipeline.getConstantLocation("lightAttrib");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		#if (S2D_LIGHTING_PBR == 1)
		ormMapTU = lightPipeline.getTextureUnit("ormMap");
		#end
		#if (S2D_LIGHTING_DEFERRED != 1 && S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
	}

	function render(target:Texture, stage:Stage) {
		final buffer = stage.renderBuffer;
		final ctx = buffer.tgt.context3D;

		ctx.begin();
		ctx.clear(Black);
		ctx.setMat3(viewProjectionCL, stage.viewProjection);
		ctx.setIndexBuffer(Drawers.indices);
		#if (S2D_LIGHTING_DEFERRED == 1)
		ctx.setVertexBuffer(Drawers.vertices);
		ctx.setPipeline(pipeline);
		ctx.setTexture(albedoMapTU, buffer.albedoMap);
		ctx.setTexture(normalMapTU, buffer.normalMap);
		ctx.setTexture(ormMapTU, buffer.ormMap);
		for (layer in stage.layers) {
			for (light in layer.lights) {
				#if (S2D_LIGHTING_SHADOWS == 1)
				ctx.end();
				ShadowPass.render(light);
				ctx.begin();
				ctx.setPipeline(pipeline);
				ctx.setIndexBuffer(Drawers.indices);
				ctx.setVertexBuffer(Drawers.vertices);
				ctx.setTexture(shadowMapTU, buffer.shadowMap);
				#end
				ctx.setFloat3(lightPositionCL, light.x, light.y, light.z);
				ctx.setVec3(lightColorCL, light.color.RGB);
				ctx.setFloat2(lightAttribCL, light.power, light.radius);
				ctx.draw();
			}
		}
		#else
		ctx.setPipeline(pipeline);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setVertexBuffer(Drawers.vertices);
		#end
		#if (S2D_LIGHTING_ENVIRONMENT == 1)
		ctx.setTexture(envMapTU, stage.environmentMap);
		ctx.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		for (layer in stage.layers) {
			for (light in layer.lights) {
				ctx.setFloat3(lightPositionCL, light.x, light.y, light.z);
				ctx.setFloat3(lightColorCL, light.color.r, light.color.g, light.color.b);
				ctx.setFloat2(lightAttribCL, light.power, light.radius);
				#if (S2D_SPRITE_INSTANCING == 1)
				for (atlas in layer.spriteAtlases)
					if (atlas.loaded) {
						ctx.setVertexBuffers(atlas.vertices);
						ctx.setTexture(albedoMapTU, atlas.albedoMap);
						ctx.setTexture(normalMapTU, atlas.normalMap);
						ctx.setTexture(ormMapTU, atlas.ormMap);
						ctx.setTexture(emissionMapTU, atlas.emissionMap);
						ctx.drawInstanced(atlas.sprites.length);
					}
				#else
				var i = 0;
				for (sprite in layer.sprites)
					if (sprite.atlas.loaded) {
						ctx.setFloat(depthCL, i / layer.sprites.length);
						ctx.setMat3(modelCL, sprite.transform);
						ctx.setVec4(cropRectCL, sprite.cropRect);
						ctx.setTexture(albedoMapTU, sprite.atlas.albedoMap);
						ctx.setTexture(normalMapTU, sprite.atlas.normalMap);
						#if (S2D_LIGHTING_PBR == 1)
						ctx.setTexture(ormMapTU, sprite.atlas.ormMap);
						#end
						ctx.setTexture(emissionMapTU, sprite.atlas.emissionMap);
						ctx.draw();
						++i;
					}
				#end
			}
		}
		#end
	}
}
#end
