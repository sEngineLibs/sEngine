package s2d.graphics.stage.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_DEFERRED == 1)
import s2d.stage.Stage;
import se.Texture;
import se.graphics.ShaderPass;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;

@:access(s2d.stage.Stage)
@:allow(s2d.graphics.StageRenderer)
class GeometryPass extends StageRenderPass {
	var viewProjectionCL:ConstantLocation;
	#if (S2D_SPRITE_INSTANCING != 1)
	var depthCL:ConstantLocation;
	var modelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end
	var albedoMapTU:TextureUnit;
	var normalMapTU:TextureUnit;
	var emissionMapTU:TextureUnit;
	#if (S2D_LIGHTING_PBR == 1)
	var ormMapTU:TextureUnit;
	#end

	public function new(inputLayout:Array<VertexStructure>) {
		super({
			inputLayout: inputLayout,
			vertexShader: Reflect.field(Shaders, "sprite_vert"),
			fragmentShader: Reflect.field(Shaders, "geometry_frag"),
			depthWrite: true,
			depthMode: Less,
			depthStencilAttachment: DepthOnly
		});
	}

	function setup() {
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		#if (S2D_LIGHTING_PBR == 1)
		ormMapTU = pipeline.getTextureUnit("ormMap");
		#end
	}

	function render(target:Texture, stage:Stage) {
		final viewProjection = stage.viewProjection;
		final ctx = stage.renderBuffer.depthMap.context3D;
		ctx.begin([
			stage.renderBuffer.albedoMap,
			stage.renderBuffer.normalMap,
			stage.renderBuffer.emissionMap,
			stage.renderBuffer.ormMap
		]);
		ctx.clear(Black, 1.0);
		ctx.setPipeline(pipeline);
		ctx.setIndexBuffer(indices);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setVertexBuffer(vertices);
		#end
		ctx.setMat3(viewProjectionCL, viewProjection);
		for (layer in stage.layers) {
			#if (S2D_LIGHTING_SHADOWS == 1)
			@:privateAccess layer.shadowBuffer.updateBuffersData();
			#end
			#if (S2D_SPRITE_INSTANCING == 1)
			for (atlas in layer.spriteAtlases)
				if (atlas.loaded) {
					ctx.setVertexBuffers(atlas.vertices);
					ctx.setTexture(albedoMapTU, atlas.albedoMap);
					ctx.setTexture(normalMapTU, atlas.normalMap);
					ctx.setTexture(emissionMapTU, atlas.emissionMap);
					#if (S2D_LIGHTING_PBR == 1)
					ctx.setTexture(ormMapTU, atlas.ormMap);
					#end
					ctx.drawInstanced(atlas.sprites.length);
				}
			#else
			for (sprite in layer.sprites)
				if (sprite.atlas.loaded) {
					ctx.setFloat(depthCL, sprite.z);
					ctx.setMat3(modelCL, sprite.finalModel);
					ctx.setVec4(cropRectCL, sprite.cropRect);
					ctx.setTexture(albedoMapTU, sprite.atlas.albedoMap);
					ctx.setTexture(normalMapTU, sprite.atlas.normalMap);
					ctx.setTexture(emissionMapTU, sprite.atlas.emissionMap);
					#if (S2D_LIGHTING_PBR == 1)
					ctx.setTexture(ormMapTU, sprite.atlas.ormMap);
					#end
					ctx.draw();
				}
			#end
		}
		ctx.end();
	}
}
#end
