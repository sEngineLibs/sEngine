package s2d.elements;

import s2d.elements.shapes.Rectangle;


class TextInput extends Label {
	public var cursor:Rectangle;
	public var selection:Rectangle;

	public function new(?parent:Element) {
		super(parent);

		cursor = new Rectangle(this);
		cursor.color = Black;
		cursor.visible = false;
		cursor.enabled = false;
		cursor.width = fontSize / 10;
		cursor.height = textHeight * 2;

		onFocusedChanged(f -> cursor.visible = f);
		onFontSizeChanged(s -> {
			cursor.width = s / 5;
			cursor.height = textHeight * 2;
		});

		onKeyboardPressed(c -> editText(() -> text += c));
		onKeyboardKeyDown(Backspace, () -> editText(() -> text = text.sub(0, text.length - 1)));
	}

	inline function editText(f:Void->Void) {
		f();
		setCursorPosition(text.length);
	}

	inline function setCursorPosition(pos:Int) {
		cursor.x = x + font.widthOfCharacters(fontSize, text, 0, pos);
	}
}
