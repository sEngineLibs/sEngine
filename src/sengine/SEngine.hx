package sengine;

import kha.System;
import kha.Image;
import kha.Canvas;
import kha.Assets;
import kha.FastFloat;
// sengine
import sui.SUI;
import s2d.S2D;
import score.SApp;

@:build(score.macro.SMacro.build())
class SEngine {
	#if SENGINE_DEBUG_FPS
	static var fst:FastFloat = 0;
	static var fpsCounter:Int = 0;
	static var fps:Int = 0;

	static inline function showFPS(target:Canvas) {
		++fpsCounter;
		var t = System.time;
		if (t - fst >= 1) {
			fps = fpsCounter;
			fpsCounter = 0;
			fst = t;
		}
		var g2 = target.g2;
		g2.font = Assets.fonts.get("Roboto_Regular");
		g2.fontSize = 14;
		g2.color = Black;
		g2.drawString('FPS: ${fps}', 6, 6);
		g2.color = White;
		g2.drawString('FPS: ${fps}', 5, 5);
	}
	#end

	@readonly public static var app = SApp;
	public static var ui:SUI = new SUI();

	public static inline function start(?title:String = "SApp", ?width:Int = 800, ?height:Int = 600, setup:Void->Void) {
		app.start(title, width, height, true, 1, function() {
			app.notifyOnRender(render);
			app.notifyOnUpdate(update);
			app.window.notifyOnResize(function(w, h) {
				ui.resize(w, h);
				S2D.resize(w, h);
				backbuffer = Image.createRenderTarget(w, h, RGBA32);
			});
			app.window.resize(width, height);

			S2D.init(app.window.width, app.window.height);

			setup();
		});
	}

	public static inline function stop() {
		app.stop();
	}

	public static inline function update() {
		S2D.update();
		ui.update();
	}

	static var backbuffer:Image;

	public static inline function render(target:Canvas) {
		S2D.render(backbuffer);
		ui.render(backbuffer);

		var g2 = target.g2;

		g2.begin();
		g2.drawScaledImage(backbuffer, 0, 0, target.width, target.height);
		#if SENGINE_DEBUG_FPS
		showFPS(target);
		#end
		g2.end();
	}
}
