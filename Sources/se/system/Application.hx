package se.system;

import kha.Assets;
import kha.System;
import kha.Window;
import se.system.Time;
import se.system.input.Mouse;
import se.system.input.Keyboard;
import se.events.Dispatcher;

class Application {
	static var updateListeners:Array<Void->Void> = [];

	public static var window:Window;
	public static var input:{
		var mouse:Mouse;
		var keyboard:Keyboard;
	};

	public static function start(options:SystemOptions, setup:Void->Void) {
		System.start(options, function(window) {
			Application.window = window;
			Application.input = {
				mouse: new Mouse(),
				keyboard: new Keyboard()
			}

			System.loadUrl("https://doc.qt.io/qt-6/qml-qtquick-shadereffect.html");
			Time.init();
			Dispatcher.init();
			SEngine.start(window);
			Assets.loadEverything(function() {
				setup();
				System.notifyOnFrames(function(frames) {
					update();
					SEngine.render(frames[0]);
				});
			});
		});
	}

	public static function notifyOnUpdate(f:Void->Void) {
		updateListeners.push(f);
		return {
			f: f,
			remove: () -> updateListeners.remove(f)
		}
	}

	public static function stop() {
		if (!System.stop())
			trace("This application can't be stopped!");
	}

	static function update() @:privateAccess {
		for (listener in updateListeners)
			listener();
	}
}
