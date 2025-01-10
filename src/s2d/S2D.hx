package s2d;

import s2d.animation.Motion;
import kha.Scheduler;
import kha.Assets;
import kha.System;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastVector3;
import kha.math.FastMatrix4;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
// s2d
import s2d.Stage;
import s2d.core.Time;
import s2d.objects.Sprite;
import s2d.graphics.Renderer;

using s2d.core.utils.extensions.FastMatrix4Ext;

class S2D {
	public static var indices:IndexBuffer;
	public static var vertices:VertexBuffer;
	public static var projection:FastMatrix4;

	public static var width:Int;
	public static var height:Int;
	public static var realWidth(get, set):Int;
	public static var realHeight(get, set):Int;
	@:isVar public static var resolutionScale(default, set):FastFloat = 1.0;

	@:isVar public static var scale(default, set):FastFloat = 1.0;
	@:isVar public static var aspectRatio(default, set):FastFloat = 1.0;

	public static var stage:Stage = new Stage();

	static inline function get_realWidth():Int {
		return Std.int(width / resolutionScale);
	}

	static inline function set_realWidth(value:Int):Int {
		width = Std.int(value * resolutionScale);
		return value;
	}

	static inline function get_realHeight():Int {
		return Std.int(height / resolutionScale);
	}

	static inline function set_realHeight(value:Int):Int {
		height = Std.int(value * resolutionScale);
		return value;
	}

	static inline function set_resolutionScale(value:FastFloat):FastFloat {
		width = Std.int(width * resolutionScale / value);
		height = Std.int(height * resolutionScale / value);
		resolutionScale = value;

		return value;
	}

	public static inline function init(w:Int, h:Int) {
		realWidth = w;
		realHeight = h;
		aspectRatio = width / height;
		Renderer.init(width, height);
		Sprite.init();

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

		// init structure
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);
		var structSize = structure.byteSize() >> 2;

		// init vertices
		vertices = new VertexBuffer(4, structure, StaticUsage);
		var vert = vertices.lock();
		for (i in 0...4) {
			vert[i * structSize + 0] = i == 0 || i == 1 ? -1.0 : 1.0;
			vert[i * structSize + 1] = i == 0 || i == 3 ? -1.0 : 1.0;
		}
		vertices.unlock();
	}

	static inline function update() {
		Time.update();
		Motion.update();
	}

	public static inline function compile() {
		Renderer.compile();
	}

	public static inline function resize(w:Int, h:Int) {
		realWidth = w;
		realHeight = h;
		aspectRatio = width / height;
		Renderer.resize(width, height);
	}

	static inline function set_scale(value:FastFloat):FastFloat {
		scale = value;
		updateProjection();
		return value;
	}

	static inline function set_aspectRatio(value:FastFloat):FastFloat {
		aspectRatio = value;
		updateProjection();
		return value;
	}

	static inline function updateProjection() {
		if (aspectRatio >= 1)
			projection = FastMatrix4.orthogonalProjection(-scale * aspectRatio, scale * aspectRatio, -scale, scale, 0.0, scale);
		else
			projection = FastMatrix4.orthogonalProjection(-scale, scale, -scale / aspectRatio, scale / aspectRatio, 0.0, scale);

		projection = projection.multmat(FastMatrix4.lookAt({x: 0.0, y: 0.0, z: 0.0}, {x: 0.0, y: 0.0, z: -1.0}, {x: 0.0, y: 1.0, z: 0.0}));
	}

	public static inline function local2WorldSpace(point:FastVector3):FastVector3 {
		var wsp = stage.VP.inverse().multvec({
			x: point.x * 2.0 - 1.0,
			y: point.y * 2.0 - 1.0,
			z: point.z * 2.0 - 1.0,
			w: 1.0
		});

		return {
			x: wsp.x,
			y: wsp.y,
			z: wsp.z
		};
	}

	public static inline function world2LocalSpace(point:FastVector3):FastVector3 {
		var ncp = stage.VP.multvec({
			x: point.x,
			y: point.y,
			z: point.z,
			w: 1.0
		});

		return {
			x: ncp.x * 0.5 + 0.5,
			y: ncp.y * 0.5 + 0.5,
			z: ncp.z * 0.5 + 0.5
		};
	}

	public static inline function screen2LocalSpace(point:FastVector3):FastVector3 {
		return {
			x: point.x / realWidth,
			y: point.y / realHeight
		};
	}

	public static inline function local2ScreenSpace(point:FastVector3):FastVector3 {
		return {
			x: point.x * realWidth,
			y: point.y * realHeight
		};
	}

	public static inline function screen2WorldSpace(point:FastVector3):FastVector3 {
		return local2WorldSpace(screen2LocalSpace(point));
	}

	public static inline function world2ScreenSpace(point:FastVector3):FastVector3 {
		return local2ScreenSpace(world2LocalSpace(point));
	}

	public static inline function render(target:Canvas):Void {
		update();
		
		var frame = Renderer.render();
		var g2 = target.g2;
		g2.begin();
		g2.drawScaledImage(frame, 0, 0, target.width, target.height);
		#if S2D_DEBUG_FPS
		showFPS(g2);
		#end
		g2.end();
	}

	#if S2D_DEBUG_FPS
	static inline function showFPS(g:kha.graphics2.Graphics) {
		final fps = Std.int(1.0 / Time.delta);

		g.font = Assets.fonts.Roboto_Regular;
		g.fontSize = 14;
		g.color = Black;
		g.drawString('FPS: ${fps}', 6, 6);
		g.color = White;
		g.drawString('FPS: ${fps}', 5, 5);
	}
	#end
}
