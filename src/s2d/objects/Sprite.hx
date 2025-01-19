package s2d.objects;

import kha.Image;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
// s2d
import s2d.math.Vec4;
import s2d.graphics.Lighting;

@:access(s2d.graphics.Lighting)
class Sprite extends Object {
	var indices:IndexBuffer;
	var vertices:VertexBuffer;

	public var cropRect:Vec4 = new Vec4(0.0, 0.0, 1.0, 1.0);
	public var albedoMap:Image;
	public var normalMap:Image;
	public var ormMap:Image;
	public var emissionMap:Image;

	public inline function new(layer:Layer) {
		super(layer);
		init();
	}

	inline function init() {
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

		// init vertices
		vertices = new VertexBuffer(4, Lighting.structures[0], StaticUsage);
		var vert = vertices.lock();
		for (i in 0...4) {
			vert[i * 2 + 0] = i == 0 || i == 1 ? -1.0 : 1.0;
			vert[i * 2 + 1] = i == 0 || i == 3 ? -1.0 : 1.0;
		}
		vertices.unlock();
	}
}
