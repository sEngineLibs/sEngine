package s2d.graphics;

import s2d.graphics.stage.SpritePass;
#if (S2D_LIGHTING != 1)
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
#else
#if (S2D_LIGHTING_DEFERRED == 1)
import s2d.graphics.stage.lighting.GeometryPass;
#end
import s2d.graphics.stage.lighting.LightingPass;
#end
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import se.Texture;
import s2d.stage.Stage;

@:allow(s2d.stage.Stage)
@:access(s2d.stage.Stage)
class StageRenderer {
	#if (S2D_LIGHTING == 1)
	#if (S2D_LIGHTING_DEFERRED == 1)
	var geometryPass:GeometryPass;
	#end
	var lightingPass:LightingPass;
	#else
	var spritePass:SpritePass;
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

		#if (S2D_LIGHTING == 1)
		#if (S2D_LIGHTING_DEFERRED == 1)
		geometryPass = new GeometryPass(structures);
		#end
		lightingPass = new LightingPass(structures);
		#else
		spritePass = new SpritePass(structures);
		#end
	}

	@:access(s2d.stage.objects.Sprite)
	function render(target:Texture, stage:Stage) {
		#if (S2D_LIGHTING == 1)
		#if (S2D_LIGHTING_DEFERRED == 1)
		geometryPass.render(target, stage);
		#end
		lightingPass.render(target, stage);
		#else
		spritePass.render(target, stage);
		#end
	}
}
