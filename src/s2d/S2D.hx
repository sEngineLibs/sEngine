package s2d;

import s2d.events.Dispatcher;
import kha.Assets;
import kha.Canvas;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
// s2d
import s2d.Stage;
import s2d.core.Time;
import s2d.math.SMath;
import s2d.math.Vec2;
import s2d.math.Mat3;
import s2d.graphics.Renderer;
import s2d.animation.Action;

class S2D {
	public static var indices:IndexBuffer;
	public static var vertices:VertexBuffer;
	public static var projection:Mat3;

	public static var width:Int;
	public static var height:Int;
	public static var realWidth(get, set):Int;
	public static var realHeight(get, set):Int;
	@:isVar public static var resolutionScale(default, set):Float = 1.0;

	@:isVar public static var scale(default, set):Float = 1.0;
	@:isVar public static var aspectRatio(default, set):Float = 1.0;

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

	static inline function set_resolutionScale(value:Float):Float {
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

		// init vertices
		vertices = new VertexBuffer(4, structure, StaticUsage);
		var vert = vertices.lock();
		for (i in 0...4) {
			vert[i * 2 + 0] = i == 0 || i == 1 ? -1.0 : 1.0;
			vert[i * 2 + 1] = i == 0 || i == 3 ? -1.0 : 1.0;
		}
		vertices.unlock();
	}

	static inline function update() {
		Time.update();
		Dispatcher.update();
		Action.update(Time.time);
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

	static inline function set_scale(value:Float):Float {
		scale = value;
		updateProjection();
		return value;
	}

	static inline function set_aspectRatio(value:Float):Float {
		aspectRatio = value;
		updateProjection();
		return value;
	}

	static inline function updateProjection() {
		if (aspectRatio >= 1)
			projection = Mat3.orthogonalProjection(-scale * aspectRatio, scale * aspectRatio, -scale, scale);
		else
			projection = Mat3.orthogonalProjection(-scale, scale, -scale / aspectRatio, scale / aspectRatio);
	}

	public static inline function local2WorldSpace(point:Vec2):Vec2 {
		var wsp = inverse(stage.viewProjection) * vec3(point * 2.0 - 1.0, 1.0);
		return wsp.xy;
	}

	public static inline function world2LocalSpace(point:Vec2):Vec2 {
		var ncp = stage.viewProjection * vec3(point, 1.0);
		return ncp.xy * 0.5 + 0.5;
	}

	public static inline function screen2LocalSpace(point:Vec2):Vec2 {
		return point / vec2(realWidth, realHeight);
	}

	public static inline function local2ScreenSpace(point:Vec2):Vec2 {
		return point * vec2(realWidth, realHeight);
	}

	public static inline function screen2WorldSpace(point:Vec2):Vec2 {
		return local2WorldSpace(screen2LocalSpace(point));
	}

	public static inline function world2ScreenSpace(point:Vec2):Vec2 {
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
