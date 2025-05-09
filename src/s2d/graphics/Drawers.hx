package s2d.graphics;

import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

@:allow(se.App)
class Drawers {
	public static var indices:IndexBuffer;
	public static var vertices:VertexBuffer;

	public static var rectDrawer:RectDrawer;
	public static var stageRenderer:StageRenderer;

	static function compile() {
		rectDrawer = new RectDrawer();
		stageRenderer = new StageRenderer();

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
	}
}
