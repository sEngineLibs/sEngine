package s2d.graphics;

import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

@:allow(se.App)
@:dox(hide)
class Drawers {
	public static var indices2D:IndexBuffer;
	public static var vertices2D:VertexBuffer;

	public static var rectDrawer:RectDrawer;
	public static var stageRenderer:StageRenderer;

	static function compile() {
		// init vertices
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);
		vertices2D = new VertexBuffer(4, structure, StaticUsage);
		var vert = vertices2D.lock();
		for (i in 0...4) {
			vert[i * 2 + 0] = i == 0 || i == 1 ? -1.0 : 1.0;
			vert[i * 2 + 1] = i == 0 || i == 3 ? -1.0 : 1.0;
		}
		vertices2D.unlock();

		// init indices
		indices2D = new IndexBuffer(6, StaticUsage);
		var ind = indices2D.lock();
		ind[0] = 0;
		ind[1] = 1;
		ind[2] = 2;
		ind[3] = 3;
		ind[4] = 2;
		ind[5] = 0;
		indices2D.unlock();
		
		rectDrawer = new RectDrawer();
		stageRenderer = new StageRenderer();
	}
}
