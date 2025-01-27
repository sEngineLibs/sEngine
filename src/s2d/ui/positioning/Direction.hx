package s2d.ui.positioning;

enum abstract Direction(Int) from Int to Int {
	// horizontal
	var LeftToRight:Int = 1 << 0;
	var RightToLeft:Int = 1 << 1;
	// vertical
	var TopToBottom:Int = 1 << 2;
	var BottomToTop:Int = 1 << 3;
}
