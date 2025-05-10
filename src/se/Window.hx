package se;

import kha.WindowMode;
import kha.WindowOptions;
import kha.Window as KhaWindow;
import kha.Framebuffer;
import se.input.Mouse;
import se.events.MouseEvents;
import s2d.Element;
import s2d.WindowScene;
import s2d.FocusPolicy;

#if !macro
@:build(se.macro.SMacro.build())
#end
final class Window {
	public static function create():Window {
		return new Window(KhaWindow.create());
	}

	var window:KhaWindow;
	var backbuffer:Texture;

	var pending:Array<Element> = [];
	var activeElements:Array<Element> = [];
	@:isVar var focusedElement(default, set):Element;

	public var scene:WindowScene;

	@alias public var title:String = window.title;
	@alias public var mode:WindowMode = window.mode;
	@alias public var x:Int = window.x;
	@alias public var y:Int = window.y;
	@alias public var width:Int = window.width;
	@alias public var height:Int = window.height;

	@:inject(syncFeatures) public var resizable:Bool = true;
	@:inject(syncFeatures) public var minimizable:Bool = true;
	@:inject(syncFeatures) public var maximizable:Bool = true;
	@:inject(syncFeatures) public var borderless:Bool = false;
	@:inject(syncFeatures) public var onTop:Bool = false;

	@:inject(syncFramebuffer) public var frequency:Int = 60;
	@:inject(syncFramebuffer) public var verticalSync:Bool = true;
	@:inject(syncFramebuffer) public var colorBufferBits:Int = 32;
	@:inject(syncFramebuffer) public var depthBufferBits:Int = 16;
	@:inject(syncFramebuffer) public var stencilBufferBits:Int = 8;
	@:inject(syncFramebuffer) public var samplesPerPixel:Int = 1;

	@:signal function resized(width:Int, height:Int);

	public function new(window:KhaWindow) {
		this.window = window;

		scene = createScene();
		backbuffer = new Texture(window.width, window.height);

		window.notifyOnResize((w, h) -> {
			backbuffer = new Texture(w, h);
			resized(w, h);
		});

		// handle mouse events
		var m = App.input.mouse;
		m.onMoved(processMouseMoved);
		m.onScrolled(d -> {
			processMouseScrolled(d, m.x, m.y);
			adjustWheelFocus(d);
		});
		m.onPressed(processMouseDown);
		m.onReleased(processMouseUp);
		m.onHold(processMouseHold);
		m.onClicked(processMouseClicked);
		m.onDoubleClicked(processMouseDoubleClicked);

		// handle keyboard events
		var k = App.input.keyboard;
		k.onKeyDown(Tab, adjustTabFocus);
		k.onDown(key -> focusedElement?.keyboardDown(key));
		k.onUp(key -> focusedElement?.keyboardUp(key));
		k.onHold(key -> focusedElement?.keyboardHold(key));
		k.onPressed(char -> focusedElement?.keyboardPressed(char));
	}

	public function resize(width:Int, height:Int) {
		window.resize(width, height);
	}

	public function destroy() {
		KhaWindow.destroy(window);
	}

	public function createScene() {
		return new WindowScene(this);
	}

	function render(frame:Framebuffer) @:privateAccess {
		scene.render(backbuffer);

		final g2 = frame.g2;
		g2.begin(true);
		g2.drawImage(backbuffer, 0, 0);
		g2.end();
	}

	function syncFramebuffer() {
		window.changeFramebuffer({
			frequency: frequency,
			verticalSync: verticalSync,
			colorBufferBits: colorBufferBits,
			depthBufferBits: depthBufferBits,
			stencilBufferBits: stencilBufferBits,
			samplesPerPixel: samplesPerPixel
		});
	}

	function syncFeatures() {
		var res = resizable ? FeatureResizable : None;
		var min = minimizable ? FeatureMinimizable : None;
		var max = maximizable ? FeatureMaximizable : None;
		var bor = borderless ? FeatureBorderless : None;
		var top = onTop ? FeatureOnTop : None;
		window.changeWindowFeatures(res | min | max | bor | top);
	}

	function adjustTabFocus() {
		final i = scene.children.indexOf(focusedElement);
		for (j in 1...scene.children.length) {
			var e = scene.children[(i + j) % scene.children.length];
			if (e.enabled && (e.focusPolicy & TabFocus != 0)) {
				focusedElement = e;
				return;
			}
		}
	}

	function adjustWheelFocus(d:Int) {
		final i = scene.children.length + scene.children.indexOf(focusedElement);
		for (j in 1...scene.children.length) {
			var e = scene.children[(i + (d > 0 ? j : -j)) % scene.children.length];
			if (e.enabled && (e.focusPolicy & WheelFocus != 0)) {
				focusedElement = e;
				return;
			}
		}
	}

	function processMouseMoved(x:Int, y:Int, dx:Int, dy:Int):Void {
		final moved = {
			accepted: false,
			x: x,
			y: y,
			dx: dx,
			dy: dy
		}
		function f(el) {
			for (i in 1...(el.vChildren.length + 1))
				f(el.vChildren[el.vChildren.length - i]);
			if (el.enabled) {
				if (el.contains(App.input.mouse.x, App.input.mouse.y)) {
					if (!moved.accepted) {
						if (!activeElements.contains(el)) {
							activeElements.push(el);
							el.containsMouse = true;
							el.mouseEntered(x, y);
						}
						moved.accepted = true;
						el.mouseMoved(moved);
					} else if (activeElements.remove(el)) {
						el.containsMouse = false;
						el.mouseExited(x, y);
					}
				} else if (activeElements.remove(el)) {
					el.containsMouse = false;
					el.mouseExited(x, y);
				}
			}
		};
		for (i in 1...(scene.children.length + 1)) {
			final el = scene.children[scene.children.length - i];
			if (el.visible)
				f(el);
		}
	}

	function processMouseEvent<T:MouseEvent>(event:T, f:(Element, T) -> Void) {
		for (el in activeElements) {
			f(el, event);
			if (event.accepted)
				break;
		}
	}

	function processMouseScrolled(d:Int, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			delta: d,
			x: x,
			y: y
		}, (c, m) -> c.mouseScrolled(m));
	}

	function processMouseDown(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> {
			pending.push(c);
			c.mousePressed(m);
		});
	}

	function processMouseUp(b:MouseButton, x:Int, y:Int):Void {
		final m = {
			accepted: true,
			button: b,
			x: x,
			y: y
		}
		for (el in pending)
			el.mouseReleased(m);
	}

	function processMouseHold(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseHold(m));
	}

	function processMouseClicked(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> {
			c.mouseClicked(m);
			if (!c.focused && (c.focusPolicy & ClickFocus != 0))
				focusedElement = c;
		});
	}

	function processMouseDoubleClicked(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseDoubleClicked(m));
	}

	function set_focusedElement(value:Element):Element {
		if (focusedElement != value) {
			if (focusedElement != null)
				focusedElement.focused = false;
			value.focused = true;
			focusedElement = value;
		}
		return focusedElement;
	}
}
