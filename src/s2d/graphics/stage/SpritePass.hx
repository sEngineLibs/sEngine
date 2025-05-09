package s2d.graphics.stage;

import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import se.Texture;
import s2d.stage.Stage;

@:access(s2d.stage.Stage)
@:allow(s2d.graphics.StageRenderer)
class SpritePass extends StageRenderPass {
	var viewProjectionCL:ConstantLocation;
	var textureMapTU:TextureUnit;
	#if (S2D_SPRITE_INSTANCING != 1)
	var depthCL:ConstantLocation;
	var modelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end

	public function new(inputLayout:Array<VertexStructure>) {
		super({
			inputLayout: inputLayout,
			vertexShader: Reflect.field(Shaders, "sprite_vert"),
			fragmentShader: Reflect.field(Shaders, "sprite_frag"),
			alphaBlendSource: SourceAlpha
		});
	}

	function setup() {
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		textureMapTU = pipeline.getTextureUnit("textureMap");
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
	}

	function render(target:Texture, stage:Stage) {
		final ctx = stage.renderBuffer.tgt.context3D;
		ctx.begin();
		ctx.clear(Black);
		ctx.setPipeline(pipeline);
		ctx.setIndexBuffer(Drawers.indices);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setVertexBuffer(Drawers.vertices);
		#end
		ctx.setMat3(viewProjectionCL, stage.viewProjection);
		for (layer in stage.layers) {
			#if (S2D_SPRITE_INSTANCING == 1)
			for (atlas in layer.spriteAtlases)
				if (atlas.loaded) {
					ctx.setVertexBuffers(atlas.vertices);
					ctx.setTexture(textureMapTU, atlas.textureMap);
					ctx.drawInstanced(atlas.sprites.length);
				}
			#else
			for (sprite in layer.sprites)
				if (sprite.atlas.loaded) {
					ctx.setMat3(modelCL, sprite.transform);
					ctx.setVec4(cropRectCL, sprite.cropRect);
					ctx.setTexture(textureMapTU, sprite.atlas.textureMap);
					ctx.draw();
				}
			#end
		}
		ctx.end();
	}
}
