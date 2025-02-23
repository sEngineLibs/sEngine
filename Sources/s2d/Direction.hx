package s2d;

enum abstract Direction(Int) from Int to Int {
	// horizontal
	var LeftToRight:Int = 0;
	var RightToLeft:Int = 1;
	// vertical
	var TopToBottom:Int = 2;
	var BottomToTop:Int = 4;
}
