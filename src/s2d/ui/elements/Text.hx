package s2d.ui.elements;

import kha.Font;
import kha.Canvas;
import kha.Assets;

class Text extends UIElement {
	public var text:String;
	public var font:Font;
	public var fontSize:Int = 14;

	public function new(text:String, scene:UIScene) {
		super(scene);
		this.text = text;
		this.font = Assets.fonts.Roboto_Regular;
	}

	function draw(target:Canvas) {
		final g2 = target.g2;

		g2.font = font;
		g2.fontSize = fontSize;
		g2.drawString(text, x, y);
	}
}
