package s2d.ui.positioning;

enum abstract Alignment(Int) from Int to Int {
	// horizontal
	var Left:Int = 1 << 0;
	var Right:Int = 1 << 1;
	var HCenter:Int = 1 << 2;
	// vertical
	var Top:Int = 1 << 3;
	var Bottom:Int = 1 << 4;
	var VCenter:Int = 1 << 5;

	var Center:Int = HCenter | VCenter;
}
