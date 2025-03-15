package s2d;

enum abstract Alignment(Int) from Int to Int {
	var AlignLeft:Int = 1 << 0;
	var AlignRight:Int = 1 << 1;
	var AlignHCenter:Int = 1 << 2;
	var AlignTop:Int = 1 << 3;
	var AlignBottom:Int = 1 << 4;
	var AlignVCenter:Int = 1 << 5;
	var AlignCenter:Int = AlignHCenter | AlignVCenter;
}
