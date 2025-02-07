package se;

import kha.Window;
import kha.Assets;
import kha.Canvas;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import se.s2d.Stage;
import se.system.Time;
import se.math.Mat3;
import se.animation.Action;
import se.ui.UIScene;
import se.ui.graphics.Drawers;
import se.s2d.graphics.Renderer;

@:allow(se.system.App)
class SEngine {
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

	@:access(se.ui.graphics.Drawers)
	@:access(se.s2d.graphics.Renderer)
	public static function start(window:Window) {
		Stage.current = new Stage();
		UIScene.current = new UIScene();

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

	@:access(se.s2d.SpriteAtlas)
	static function update() {
		Action.update(Time.time);
		Stage.current.updateViewProjection();
		#if (S2D_SPRITE_INSTANCING == 1)
		for (layer in Stage.current.layers)
			for (atlas in layer.spriteAtlases)
				atlas.update();
		#end
	}

	@:access(se.s2d.graphics.Renderer)
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
			projection = Mat3.orthogonalProjection(-scale * aspectRatio, scale * aspectRatio, -scale, scale);
		else
			projection = Mat3.orthogonalProjection(-scale, scale, -scale / aspectRatio, scale / aspectRatio);
		Stage.current.updateViewProjection();
	}

	@:access(se.s2d.graphics.Renderer)
	public static function render(target:Canvas):Void {
		var frame = Renderer.render();
		UIScene.current.render(frame);

		var g2 = target.g2;
		g2.begin();
		g2.drawScaledImage(frame, 0, 0, target.width, target.height);
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
