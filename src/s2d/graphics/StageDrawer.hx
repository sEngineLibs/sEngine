package s2d.graphics;

#if (S2D_LIGHTING != 1)
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
#else
#if (S2D_LIGHTING_DEFERRED == 1)
import s2d.graphics.stage.lighting.GeometryPass;
#end
import s2d.graphics.stage.lighting.LightingPass;
#end
import kha.Shaders;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import se.Texture;
import s2d.stage.Stage;

@:access(s2d.stage.Stage)
class StageDrawer extends ElementDrawer<Stage> {
	public static var indices:IndexBuffer;
	public static var vertices:VertexBuffer;

	#if (S2D_LIGHTING == 1)
	#if (S2D_LIGHTING_DEFERRED == 1)
	var geometryPass:GeometryPass;
	#end
	var lightingPass:LightingPass;
	#else
	var viewProjectionCL:ConstantLocation;
	var textureMapTU:TextureUnit;
	#if (S2D_SPRITE_INSTANCING != 1)
	var spriteModelCL:ConstantLocation;
	var cropRectCL:ConstantLocation;
	#end
	#end
	public function new() {
		var structures = [];
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
		#end

		super({
			inputLayout: structures,
			vertexShader: Reflect.field(Shaders, "sprite_vert"),
			fragmentShader: Reflect.field(Shaders, "sprite_frag"),
			alphaBlendSource: SourceAlpha
		});

		#if (S2D_LIGHTING == 1)
		#if (S2D_LIGHTING_DEFERRED == 1)
		geometryPass = new GeometryPass(structures);
		#end
		lightingPass = new LightingPass(structures);
		#end
	}

	override function setup() {
		super.setup();

		// init vertices
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);
		vertices = new VertexBuffer(4, structure, StaticUsage);
		var vert = vertices.lock();
		for (i in 0...4) {
			vert[i * 2 + 0] = i == 0 || i == 1 ? -1.0 : 1.0;
			vert[i * 2 + 1] = i == 0 || i == 3 ? -1.0 : 1.0;
		}
		vertices.unlock();
		// init indices
		indices = new IndexBuffer(6, StaticUsage);
		var ind = indices.lock();
		ind[0] = 0;
		ind[1] = 1;
		ind[2] = 2;
		ind[3] = 3;
		ind[4] = 2;
		ind[5] = 0;
		indices.unlock();

		#if (S2D_LIGHTING != 1)
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		textureMapTU = pipeline.getTextureUnit("textureMap");
		#if (S2D_SPRITE_INSTANCING != 1)
		spriteModelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end
		#end
	}

	@:access(s2d.stage.objects.Sprite)
	function draw(target:Texture, stage:Stage) {
		final tgtCtx = target.context2D;
		tgtCtx.end();
		#if (S2D_LIGHTING == 1)
		#if (S2D_LIGHTING_DEFERRED == 1)
		geometryPass.render(target, stage);
		#end
		lightingPass.render(target, stage);
		#else
		final ctx = stage.renderBuffer.tgt.context3D;
		ctx.begin();
		ctx.clear(Black);
		ctx.setPipeline(pipeline);
		ctx.setIndexBuffer(indices);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setVertexBuffer(vertices);
		#end
		ctx.setMat3(viewProjectionCL, stage.viewProjection);
		for (layer in stage.layers) {
			#if (S2D_SPRITE_INSTANCING == 1)
			for (atlas in layer.spriteAtlases) {
				ctx.setVertexBuffers(atlas.vertices);
				ctx.setTexture(textureMapTU, atlas.textureMap);
				ctx.drawInstanced(atlas.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				ctx.setMat3(spriteModelCL, sprite.transform);
				ctx.setVec4(cropRectCL, sprite.cropRect);
				ctx.setTexture(textureMapTU, sprite.atlas.textureMap);
				ctx.draw();
			}
			#end
		}
		ctx.end();
		#end
		tgtCtx.begin();
		tgtCtx.drawImage(stage.renderBuffer.tgt, stage.absX, stage.absY);
	}
}
