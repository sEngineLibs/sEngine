package sengine;

import kha.System;
import kha.Scaler;
import kha.Image;
import kha.Canvas;
import kha.Shaders;
import kha.Assets;
import kha.FastFloat;
// sengine
import score.SApp;
import sui.SUI;
import s2d.S2D;
import s2d.graphics.shaders.S2DShaders;

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
	public static var stage:S2D = new S2D();
	public static var ui:SUI = new SUI();

	public static inline function start(?title:String = "SApp", ?width:Int = 800, ?height:Int = 600, ?vsync:Bool = true, ?samplesPerPixel:Int = 1,
			setup:Void->Void) {
		app.start(title, width, height, vsync, samplesPerPixel, function() {
			setup();
			S2DShaders.pbr.compile(Shaders.s2d_sprite_vert, Shaders.s2d_pbr_frag);
		});
		app.notifyOnRender(render);
		app.notifyOnUpdate(update);
		app.window.notifyOnResize(function(w, h) {
			stage.projection.setAspectRatio(w / h);
			backbuffer = Image.createRenderTarget(w, h, RGBA32, DepthOnly);
		});
		app.window.resize(width, height);
	}

	public static inline function stop() {
		app.stop();
	}

	public static inline function update() {
		stage.update();
		ui.update();
	}

	static var backbuffer:Image;

	public static inline function render(target:Canvas) {
		backbuffer.g2.begin(true);
		stage.render(backbuffer);
		// ui.render(backbuffer);
		backbuffer.g2.end();

		target.g2.begin(true);
		Scaler.scale(backbuffer, target, System.screenRotation);
		#if SENGINE_DEBUG_FPS
		showFPS(target);
		#end
		target.g2.end();
	}
}
