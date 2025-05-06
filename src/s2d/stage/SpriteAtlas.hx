package s2d.stage;

import haxe.ds.Vector;
#if (S2D_SPRITE_INSTANCING == 1)
import kha.graphics4.VertexBuffer;
#end
import se.Image;
import s2d.stage.objects.Sprite;
#if (S2D_LIGHTING == 1)
#if (S2D_LIGHTING_DEFERRED == 1)
import s2d.graphics.StageDrawer;
#else
import s2d.graphics.StageDrawer;
#end
#end
@:access(s2d.stage.objects.Sprite)
class SpriteAtlas {
	@:isVar public var layer(default, set):StageLayer;
	public var sprites:Vector<Sprite> = new Vector(0);

	#if (S2D_LIGHTING == 1)
	public var albedoMap:Image;
	public var normalMap:Image;
	public var emissionMap:Image;
	#if (S2D_LIGHTING_PBR == 1)
	public var ormMap:Image;
	#end
	#else
	public var textureMap:Image;
	#end

	public function new(layer:StageLayer) {
		this.layer = layer;
		#if (S2D_SPRITE_INSTANCING == 1)
		init();
		#end
		#if (S2D_LIGHTING == 1)
		albedoMap = "default_color";
		normalMap = "default_normal";
		emissionMap = "default_emission";
		#if (S2D_LIGHTING_PBR == 1)
		ormMap = "default_orm";
		#end
		#else
		textureMap = "default_color";
		#end
	}

	function set_layer(value:StageLayer) {
		value.addSpriteAtlas(this);
		layer = value;
		return value;
	}

	#if (S2D_SPRITE_INSTANCING == 1)
	var vertices:Array<VertexBuffer>;

	function init() {
		vertices = [
			for (i in 0...4)
				new VertexBuffer(0, StageDrawer.structures[i], StaticUsage, 1)
		];
	}

	public function addSprite(sprite:Sprite) {
		final tmp = sprites;
		sprites = new Vector(tmp.length + 1);

		for (i in 0...tmp.length)
			sprites[i] = tmp[i];
		sprites[tmp.length] = sprite;

		vertices[1].delete();
		vertices[2].delete();

		#if (S2D_LIGHTING == 1)
		vertices[1] = new VertexBuffer(sprites.length, StageDrawer.structures[1], StaticUsage, 1);
		vertices[2] = new VertexBuffer(sprites.length, StageDrawer.structures[2], StaticUsage, 1);
		vertices[3] = new VertexBuffer(sprites.length, StageDrawer.structures[3], StaticUsage, 1);
		#end
	}

	function update() {
		#if (S2D_LIGHTING == 1)
		final cStructSize = StageDrawer.structures[1].byteSize() >> 2;
		final mStructSize = StageDrawer.structures[2].byteSize() >> 2;
		final dStructSize = StageDrawer.structures[3].byteSize() >> 2;
		#end
		final cData = vertices[1].lock();
		final mData = vertices[2].lock();
		final dData = vertices[3].lock();
		var i = 0;
		for (sprite in sprites) {
			final c = sprite.cropRect;
			final m = sprite.transform;
			// crop rect
			final ci = i * cStructSize;
			cData[ci + 0] = c.x;
			cData[ci + 1] = c.y;
			cData[ci + 2] = c.z;
			cData[ci + 3] = c.w;
			// model
			final mi = i * mStructSize;
			mData[mi + 0] = m._00;
			mData[mi + 1] = m._01;
			mData[mi + 2] = m._02;
			mData[mi + 3] = m._10;
			mData[mi + 4] = m._11;
			mData[mi + 5] = m._12;
			mData[mi + 6] = m._20;
			mData[mi + 7] = m._21;
			mData[mi + 8] = m._22;
			// depth
			final di = i * dStructSize;
			dData[di] = sprite.z;
			++i;
		}
		vertices[1].unlock();
		vertices[2].unlock();
		vertices[3].unlock();
	}
	#end
}
