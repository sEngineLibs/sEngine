package se.ui.positioning;

enum abstract Alignment(Int) from Int to Int {
	// horizontal
	var Left:Int = 0;
	var Right:Int = 1;
	var HCenter:Int = 2;
	// vertical
	var Top:Int = 4;
	var Bottom:Int = 8;
	var VCenter:Int = 16;

	var Center:Int = HCenter | VCenter;
}
