package sengine;

import kha.Image;
import kha.Scheduler;
import kha.Canvas;
// sengine
import score.SApp;
import sui.Scene;
import s2d.S2D;

@:build(score.macro.SMacro.build())
class SEngine {
	#if SENGINE_DEBUG_FPS
	static var fst:FastFloat = 0;
	static var fpsCounter:Int = 0;
	static var fps:Int = 0;

	static inline function showFPS(g2:Graphics) {
		++fpsCounter;
		var t = System.time;
		if (t - fst >= 1) {
			fps = fpsCounter;
			fpsCounter = 0;
			fst = t;
		}
		g2.font = Assets.fonts.get("Roboto_Regular");
		g2.fontSize = 14;
		g2.color = Color.Black;
		g2.drawString('FPS: ${fps}', 6, 6);
		g2.color = Color.White;
		g2.drawString('FPS: ${fps}', 5, 5);
	}
	#end

	@readonly public static var app = SApp;
	public static var stage:S2D;
	public static var ui:Scene;

	public static inline function start(?title:String = "SApp", ?width:Int = 800, ?height:Int = 600, ?vsync:Bool = true, ?samplesPerPixel:Int = 1,
			setup:Void->Void) {
		app.start(title, width, height, vsync, samplesPerPixel, setup);
		app.notifyOnRender(draw);
		app.notifyOnUpdate(update);
	}

	public static inline function stop() {
		app.stop();
	}

	public static inline function update() {
		stage.update();
		ui.update();
	}

	static var backbuffer:Image;

	public static inline function draw(target:Canvas) {
		target.g2.begin(true);
		stage.draw(target);
		ui.draw(target);
		target.g2.end();
	}
}
