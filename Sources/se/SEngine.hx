package se;

import kha.Window;
import kha.Assets;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import se.Application;
import se.system.Time;
import se.math.Mat3;
import se.math.VectorMath;
import se.graphics.Context2D;
import se.animation.Action;
import s2d.stage.Stage;
import s2d.stage.graphics.Renderer;
import s2d.ui.UIScene;
import s2d.ui.graphics.Drawers;

@:allow(se.Application)
class SEngine {
	static var indices:IndexBuffer;
	static var vertices:VertexBuffer;
	public static var projection:Mat3 = Mat3.identity();

	public static var width:Int;
	public static var height:Int;

	@:isVar public static var scale(default, set):Float = 1.0;
	@:isVar public static var aspectRatio(default, set):Float = 1.0;

	@:access(s2d.ui.graphics.Drawers)
	@:access(s2d.stage.graphics.Renderer)
	public static function start(window:Window) {
		Stage.current = new Stage();
		UIScene.current = new UIScene(window);

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

		Application.notifyOnUpdate(update);

		resize(window.width, window.height);
		window.notifyOnResize(resize);
	}

	@:access(s2d.stage.SpriteAtlas)
	static function update() {
		Action.update(Time.time);
		Stage.current.updateViewProjection();
		#if (S2D_SPRITE_INSTANCING == 1)
		for (layer in Stage.current.layers)
			for (atlas in layer.spriteAtlases)
				atlas.update();
		#end
	}

	@:access(s2d.stage.graphics.Renderer)
	public static function resize(w:Int, h:Int) {
		width = w;
		height = h;
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

	static function updateProjection() {
		if (aspectRatio >= 1)
			projection = Mat3.orthogonalProjection(-scale * aspectRatio, scale * aspectRatio, -scale, scale);
		else
			projection = Mat3.orthogonalProjection(-scale, scale, -scale / aspectRatio, scale / aspectRatio);
		Stage.current.updateViewProjection();
	}

	@:access(s2d.stage.graphics.Renderer)
	public static inline function render():Texture {
		var frame = Renderer.render();
		UIScene.current.render(frame);
		#if S2D_DEBUG_FPS
		showFPS(frame.context2D);
		#end
		return frame;
	}

	#if S2D_DEBUG_FPS
	static function showFPS(ctx:Context2D) {
		final fps = Std.int(1.0 / Time.delta);

		ctx.begin();
		ctx.style.font = Assets.fonts.Roboto_Regular;
		ctx.style.fontSize = 14;
		ctx.style.color = black;
		ctx.drawString('FPS: ${fps}', 6, 6);
		ctx.style.color = white;
		ctx.drawString('FPS: ${fps}', 5, 5);
		ctx.end();
	}
	#end
}
