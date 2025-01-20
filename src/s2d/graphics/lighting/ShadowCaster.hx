package s2d.graphics.lighting;

#if (S2D_LIGHTING_SHADOWS == 1)
import kha.Canvas;
import kha.Shaders;
import kha.math.FastVector2;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.core.Buffer;
import s2d.objects.Light;
import s2d.objects.Sprite;
import s2d.core.utils.MathUtils;

@:access(s2d.SpriteAtlas)
@:access(s2d.objects.Sprite)
class ShadowCaster {
	static var pipeline:PipelineState;
	static var mvpCL:ConstantLocation;
	static var textureMapTU:TextureUnit;

	public static inline function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.shadow_vert;
		pipeline.fragmentShader = Shaders.shadow_frag;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		mvpCL = pipeline.getConstantLocation("MVP");
		textureMapTU = pipeline.getTextureUnit("textureMap");
	}

	public static inline function castShadows(target:Canvas, light:Light, sprites:Buffer<Sprite>):Void {
		final g2 = target.g2;
		final pos = new FastVector2(light.x, light.y);

		g2.begin(true, White);
		g2.color = Black;
		for (sprite in sprites) {
			final model = sprite._model;
			for (i in 0...sprite.shadowVertices.length) {
				var nextIndex = (i + 1) % sprite.shadowVertices.length;

				var p1 = model.multvec(sprite.shadowVertices[i]);
				var d1 = p1.sub(pos).normalized();
				var e1 = p1.add(d1.mult(light.radius * light.power));

				var p2 = model.multvec(sprite.shadowVertices[nextIndex]);
				var d2 = p2.sub(pos).normalized();
				var e2 = p2.add(d2.mult(light.radius * light.power));

				p1 = S2D.world2ScreenSpace(p1);
				p2 = S2D.world2ScreenSpace(p2);
				e1 = S2D.world2ScreenSpace(e1);
				e2 = S2D.world2ScreenSpace(e2);

				g2.fillTriangle(p1.x, p1.y, e1.x, e1.y, p2.x, p2.y);
				g2.fillTriangle(e1.x, e1.y, e2.x, e2.y, p2.x, p2.y);
			}
			g2.end();
			drawEmitter(target, sprite);
			g2.begin(false);
		}
		g2.end();
	}

	static inline function drawEmitter(target:Canvas, sprite:Sprite):Void {
		final g4 = target.g4;
		g4.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setMatrix3(mvpCL, S2D.stage.viewProjection.multmat(sprite._model));
		g4.setTexture(textureMapTU, sprite.atlas.albedoMap);
		g4.drawIndexedVertices();
		g4.end();
	}
}
#end
