package s2d;

import kha.Window;
import kha.Assets;
import kha.Canvas;
import kha.math.FastVector2;
import kha.math.FastMatrix3;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
// s2d
import s2d.Stage;
import s2d.core.Time;
import s2d.ui.UIScene;
import s2d.events.Dispatcher;
import s2d.graphics.Renderer;
import s2d.ui.graphics.Drawers;
import s2d.animation.Action;

using s2d.core.extensions.FastMatrix3Ext;

class S2D {
	public static var indices:IndexBuffer;
	public static var vertices:VertexBuffer;
	public static var projection:FastMatrix3;

	public static var width:Int;
	public static var height:Int;
	public static var realWidth(get, set):Int;
	public static var realHeight(get, set):Int;
	@:isVar public static var resolutionScale(default, set):Float = 1.0;

	@:isVar public static var scale(default, set):Float = 1.0;
	@:isVar public static var aspectRatio(default, set):Float = 1.0;

	public static var stage:Stage = new Stage();
	public static var ui:UIScene = new UIScene();

	static function get_realWidth():Int {
		return Std.int(width / resolutionScale);
	}

	static function set_realWidth(value:Int):Int {
		width = Std.int(value * resolutionScale);
		return value;
	}

	static function get_realHeight():Int {
		return Std.int(height / resolutionScale);
	}

	static function set_realHeight(value:Int):Int {
		height = Std.int(value * resolutionScale);
		return value;
	}

	static function set_resolutionScale(value:Float):Float {
		width = Std.int(width * resolutionScale / value);
		height = Std.int(height * resolutionScale / value);
		resolutionScale = value;

		return value;
	}

	@:access(s2d.graphics.Renderer)
	@:access(s2d.ui.graphics.Drawers)
	public static function start(window:Window) {
		realWidth = window.width;
		realHeight = window.height;
		aspectRatio = width / height;
		window.notifyOnResize(resize);

		Renderer.compile(width, height);
		Drawers.compile();

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

	@:access(s2d.SpriteAtlas)
	static function update() {
		Dispatcher.update();
		Action.update(Time.time);
		S2D.stage.updateViewProjection();
		#if (S2D_SPRITE_INSTANCING == 1)
		for (layer in S2D.stage.layers)
			for (atlas in layer.spriteAtlases)
				atlas.update();
		#end
	}

	@:access(s2d.graphics.Renderer)
	public static function resize(w:Int, h:Int) {
		realWidth = w;
		realHeight = h;
		aspectRatio = width / height;
		Renderer.resize(width, height);
	}

	static function set_scale(value:Float):Float {
		scale = value;
		updateProjection();
		return value;
	}

	static function set_aspectRatio(value:Float):Float {
		aspectRatio = value;
		updateProjection();
		return value;
	}

	static function updateProjection() {
		if (aspectRatio >= 1)
			projection = FastMatrix3Ext.orthogonalProjection(-scale * aspectRatio, scale * aspectRatio, -scale, scale);
		else
			projection = FastMatrix3Ext.orthogonalProjection(-scale, scale, -scale / aspectRatio, scale / aspectRatio);
		stage.updateViewProjection();
	}

	public static function local2WorldSpace(point:FastVector2):FastVector2 {
		return stage.viewProjection.inverse().multvec(point);
	}

	public static function world2LocalSpace(point:FastVector2):FastVector2 {
		return stage.viewProjection.multvec(point);
	}

	public static function screen2LocalSpace(point:FastVector2):FastVector2 {
		return {
			x: point.x / realWidth * 2.0 - 1.0,
			y: point.y / realHeight * 2.0 - 1.0
		};
	}

	public static function local2ScreenSpace(point:FastVector2):FastVector2 {
		return {
			x: point.x * realWidth * 0.5 - 0.5,
			y: point.y * realHeight * 0.5 - 0.5
		};
	}

	public static function screen2WorldSpace(point:FastVector2):FastVector2 {
		return local2WorldSpace(screen2LocalSpace(point));
	}

	public static function world2ScreenSpace(point:FastVector2):FastVector2 {
		return local2ScreenSpace(world2LocalSpace(point));
	}

	@:access(s2d.graphics.Renderer)
	public static function render(target:Canvas):Void {
		update();

		var frame = Renderer.render();
		var g2 = target.g2;
		g2.begin();
		g2.drawScaledImage(frame, 0, 0, target.width, target.height);
		ui.render(target);
		#if S2D_DEBUG_FPS
		showFPS(g2);
		#end
		g2.end();
	}

	#if S2D_DEBUG_FPS
	static function showFPS(g:kha.graphics2.Graphics) {
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
