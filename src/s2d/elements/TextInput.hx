package s2d.elements;

import s2d.shapes.Rectangle;

using se.extensions.StringExt;

class TextInput extends Label {
	public var cursor:Rectangle;
	public var selection:Rectangle;

	public function new(?scene:WindowScene) {
		super(scene);
		
		cursor = new Rectangle();
		cursor.color = Black;
		cursor.visible = false;
		cursor.enabled = false;
		cursor.width = fontSize / 10;
		cursor.height = textHeight * 2;
		addChild(cursor);

		onFocusedChanged(f -> cursor.visible = f);
		onFontSizeChanged(s -> {
			cursor.width = s / 5;
			cursor.height = textHeight * 2;
		});

		onKeyboardPressed(c -> editText(() -> text += c));
		onKeyboardKeyDown(Backspace, () -> editText(() -> text = text.substring(0, text.length - 1)));
	}

	function editText(f:Void->Void) {
		f();
		setCursorPosition(text.length);
	}

	function setCursorPosition(pos:Int) {
		cursor.x = x + font.widthOfCharacters(fontSize, text.toCharArray(), 0, pos);
	}
}
