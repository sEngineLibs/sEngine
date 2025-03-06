package se;

import kha.Color as KhaColor;
import se.math.Vec3;
import se.math.Vec4;
import se.math.VectorMath;

@:forward.new
extern enum abstract Color(KhaColor) from KhaColor to KhaColor {
	inline final Black = 0xff000000;
	inline final White = 0xffffffff;
	inline final Red = 0xffff0000;
	inline final Blue = 0xff0000ff;
	inline final Green = 0xff00ff00;
	inline final Magenta = 0xffff00ff;
	inline final Yellow = 0xffffff00;
	inline final Cyan = 0xff00ffff;
	inline final Purple = 0xff800080;
	inline final Pink = 0xffffc0cb;
	inline final Orange = 0xffffa500;
	inline final Transparent = 0x00000000;

	public var r(get, set):Float;
	public var g(get, set):Float;
	public var b(get, set):Float;
	public var a(get, set):Float;
	public var h(get, set):Float;
	public var s(get, set):Float;
	public var v(get, set):Float;
	public var RGB(get, set):Vec3;
	public var RGBA(get, set):Vec4;
	public var HSV(get, set):Vec3;
	public var HSVA(get, set):Vec4;
	public var HSL(get, set):Vec3;
	public var HSLA(get, set):Vec4;

	public static inline function rgb(r:Float, g:Float, b:Float):Color {
		return kha.Color.fromFloats(r, g, b);
	}

	public static inline function rgba(r:Float, g:Float, b:Float, a:Float = 1.0):Color {
		return kha.Color.fromFloats(r, g, b, a);
	}

	public static inline function hsv(h:Float, s:Float, v:Float):Color {
		return rgb2hsv(rgb(h, s, v));
	}

	public static inline function hsva(h:Float, s:Float, v:Float, a:Float = 1.0):Color {
		return rgb2hsv(rgba(h, s, v, a));
	}

	public static inline function hsl(h:Float, s:Float, l:Float):Color {
		return rgb2hsl(rgb(h, s, l));
	}

	public static inline function hsla(h:Float, s:Float, l:Float, a:Float = 1.0):Color {
		return rgb2hsl(rgba(h, s, l, a));
	}

	public static inline function hue2rgb(hue:Float):Color {
		var rgb = abs(hue * 6.0 - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
		return clamp(rgb, 0.0, 1.0);
	}

	public static inline function rgb2hcv(color:Color):Color {
		var rgb:Vec3 = color;
		var p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1.0, 2.0 / 3.0) : vec4(rgb.gb, 0.0, -1.0 / 3.0);
		var q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
		var c = q.x - min(q.w, q.y);
		var h = abs((q.w - q.y) / (6.0 * c + 1e-10) + q.z);
		return vec3(h, c, q.x);
	}

	public static inline function hsv2rgb(color:Color):Color {
		var hsv:Vec3 = color;
		var rgb:Vec3 = hue2rgb(hsv.x);
		return ((rgb - 1.0) * hsv.y + 1.0) * hsv.z;
	}

	public static inline function hsl2rgb(color:Color):Color {
		var hsl:Vec3 = color;
		var rgb:Vec3 = hue2rgb(hsl.x);
		var c = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
		return (rgb - 0.5) * c + hsl.z;
	}

	public static inline function rgb2hsv(color:Color):Color {
		var hcv:Vec3 = rgb2hcv(color);
		var s = hcv.y / (hcv.z + 1e-10);
		return vec3(hcv.x, s, hcv.z);
	}

	public static inline function rgb2hsl(rgb:Color):Color {
		var hcv:Vec3 = rgb2hcv(rgb);
		var z = hcv.z - hcv.y * 0.5;
		var s = hcv.y / (1.0 - abs(z * 2.0 - 1.0) + 1e-10);
		return vec3(hcv.x, s, z);
	}

	public static inline function srgb2rgb(srgb:Color):Color {
		return pow(srgb, vec3(2.1632601288));
	}

	public static inline function rgb2srgb(rgb:Color):Color {
		return pow(rgb, vec3(0.46226525728));
	}

	@:from
	public static inline function fromString(value:String):Color {
		return switch (value.toLowerCase()) {
			case "black":
				Color.Black;
			case "white":
				Color.White;
			case "red":
				Color.Red;
			case "blue":
				Color.Blue;
			case "green":
				Color.Green;
			case "magenta":
				Color.Magenta;
			case "yellow":
				Color.Yellow;
			case "cyan":
				Color.Cyan;
			case "purple":
				Color.Purple;
			case "pink":
				Color.Pink;
			case "orange":
				Color.Orange;
			case "transparent":
				Color.Transparent;
			default:
				kha.Color.fromString(value);
		}
	}

	@:to
	public inline function toString():String {
		return '#${StringTools.hex(this, 8)}';
	}

	@:from
	public static inline function fromVec3(value:Vec3):Color {
		return rgb(value.r, value.g, value.b);
	}

	@:from
	public static inline function fromVec4(value:Vec4):Color {
		return rgba(value.r, value.g, value.b, value.a);
	}

	@:to
	public inline function toVec3():Vec3 {
		return vec3(r, g, b);
	}

	@:to
	public inline function toVec4():Vec4 {
		return vec4(r, g, b, a);
	}

	inline function get_r():Float {
		return this.R;
	}

	inline function set_r(value:Float):Float {
		this.R = value;
		return value;
	}

	inline function get_g():Float {
		return this.G;
	}

	inline function set_g(value:Float):Float {
		this.G = value;
		return value;
	}

	inline function get_b():Float {
		return this.B;
	}

	inline function set_b(value:Float):Float {
		this.B = value;
		return value;
	}

	inline function get_a():Float {
		return this.A;
	}

	inline function set_a(value:Float):Float {
		this.A = value;
		return value;
	}

	inline function get_h():Float {
		return Color.rgb2hsv(this).r;
	}

	inline function set_h(value:Float):Float {
		var c = Color.hsv2rgb(vec3(value, s, v));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	inline function get_s():Float {
		return Color.rgb2hsv(this).g;
	}

	inline function set_s(value:Float):Float {
		var c = Color.hsv2rgb(vec3(h, value, v));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	inline function get_v():Float {
		return Color.rgb2hsv(this).b;
	}

	inline function set_v(value:Float):Float {
		var c = Color.hsv2rgb(vec3(h, s, value));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	inline function get_RGB():Vec3 {
		return toVec3();
	}

	inline function set_RGB(value:Vec3):Vec3 {
		fromVec3(value);
		return value;
	}

	inline function get_RGBA():Vec4 {
		return toVec4();
	}

	inline function set_RGBA(value:Vec4):Vec4 {
		fromVec4(value);
		return value;
	}

	inline function get_HSV():Vec3 {
		return rgb2hsv(toVec3());
	}

	inline function set_HSV(value:Vec3):Vec3 {
		fromVec3(hsv2rgb(value));
		return value;
	}

	inline function get_HSVA():Vec4 {
		return rgb2hsv(toVec3());
	}

	inline function set_HSVA(value:Vec4):Vec4 {
		fromVec4(hsv2rgb(value));
		return value;
	}

	inline function get_HSL():Vec3 {
		return rgb2hsv(toVec3());
	}

	inline function set_HSL(value:Vec3):Vec3 {
		fromVec3(hsl2rgb(value));
		return value;
	}

	inline function get_HSLA():Vec4 {
		return rgb2hsl(toVec3());
	}

	inline function set_HSLA(value:Vec4):Vec4 {
		fromVec4(hsl2rgb(value));
		return value;
	}
}
