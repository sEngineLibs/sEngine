package se;

import kha.Framebuffer;
import kha.Assets;
import kha.System;
import se.Time;
import se.input.Mouse;
import se.input.Keyboard;
import se.animation.Action;
import se.graphics.Context2D;
import s2d.WindowScene;
import s2d.graphics.Drawers;

@:build(se.macro.SMacro.build())
class App {
	@:signal static function update();

	public static var input(default, null):{
		var mouse:Mouse;
		var keyboard:Keyboard;
	};
	public static var scenes(default, null):Array<WindowScene>;

	public static function start(options:SystemOptions, setup:Void->Void) {
		onUpdate(() -> @:privateAccess {
			Time.update();
			Action.update(Time.time);
		});
		System.start(options, window -> {
			Drawers.compile();

			App.input = {
				mouse: new Mouse(),
				keyboard: new Keyboard()
			}
			scenes = [new WindowScene(window)];

			Assets.loadEverything(() -> {
				setup();
				System.notifyOnFrames(frames -> {
					update();
					render(frames);
				});
			}, a -> a.type == "font");
		});
	}

	public static function stop() {
		if (!System.stop())
			Log.error("This application can't be stopped!");
	}

	static inline function render(frames:Array<Framebuffer>) @:privateAccess {
		for (i in 0...frames.length) {
			final scene = scenes[i];
			final frame = frames[i];

			scene.render(scene.backbuffer);

			final ctx:Context2D = frame.g2;
			ctx.render(true, Transparent, ctx -> {
				ctx.drawScaledImage(scene.backbuffer, 0, 0, frame.width, frame.height);
				#if S2D_DEBUG_FPS
				final fps = Std.int(1.0 / Time.delta);
				ctx.style.font = "Roboto_Regular";
				ctx.style.fontSize = 14;
				ctx.style.color = Black;
				ctx.drawString('FPS: ${fps}', 6, 6);
				ctx.style.color = White;
				ctx.drawString('FPS: ${fps}', 5, 5);
				#end
			});
		}
	}
}
