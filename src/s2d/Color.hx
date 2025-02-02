package s2d;

import kha.FastFloat;
// s2d
import s2d.math.Vec3;
import s2d.math.Vec4;
import s2d.math.VectorMath;

@:forward.new
enum abstract Color(kha.Color) from kha.Color to kha.Color {
	var black = 0xff000000;
	var white = 0xffffffff;
	var red = 0xffff0000;
	var blue = 0xff0000ff;
	var green = 0xff00ff00;
	var magenta = 0xffff00ff;
	var yellow = 0xffffff00;
	var cyan = 0xff00ffff;
	var purple = 0xff800080;
	var pink = 0xffffc0cb;
	var orange = 0xffffa500;
	var transparent = 0x00000000;

	public var r(get, set):FastFloat;
	public var g(get, set):FastFloat;
	public var b(get, set):FastFloat;
	public var a(get, set):FastFloat;
	public var h(get, set):FastFloat;
	public var s(get, set):FastFloat;
	public var v(get, set):FastFloat;

	public static inline function hue2rgb(hue:FastFloat):Color {
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
		var rgb = hue2rgb(hsv.x);
		return ((rgb - vec3(1.0)) * vec3(hsv.y) + vec3(1.0)) * hsv.z;
	}

	public static inline function hsl2rgb(color:Color):Color {
		var hsl:Vec3 = color;
		var rgb = hue2rgb(hsl.x);
		var c = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
		return (rgb - vec3(0.5)) * vec3(c) + vec3(hsl.z);
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
	static inline function fromString(value:String):Color {
		return kha.Color.fromString(value);
	}

	@:to
	inline function toString():String {
		return '#${StringTools.hex(this, 8)}';
	}

	@:from
	static inline function fromVec3(value:Vec3):Color {
		return kha.Color.fromFloats(value.r, value.g, value.b);
	}

	@:from
	static inline function fromVec4(value:Vec4):Color {
		return kha.Color.fromFloats(value.r, value.g, value.b, value.a);
	}

	@:to
	inline function toVec3():Vec3 {
		return vec3(r, g, b);
	}

	@:to
	inline function toVec4():Vec4 {
		return vec4(r, g, b, a);
	}

	inline function get_r():FastFloat {
		return this.R;
	}

	inline function set_r(value:FastFloat):FastFloat {
		this.R = value;
		return value;
	}

	inline function get_g():FastFloat {
		return this.G;
	}

	inline function set_g(value:FastFloat):FastFloat {
		this.G = value;
		return value;
	}

	inline function get_b():FastFloat {
		return this.B;
	}

	inline function set_b(value:FastFloat):FastFloat {
		this.B = value;
		return value;
	}

	inline function get_a():FastFloat {
		return this.A;
	}

	inline function set_a(value:FastFloat):FastFloat {
		this.A = value;
		return value;
	}

	inline function get_h():FastFloat {
		return Color.rgb2hsv(this).r;
	}

	inline function set_h(value:FastFloat):FastFloat {
		var c = Color.hsv2rgb(vec3(value, s, v));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	inline function get_s():FastFloat {
		return Color.rgb2hsv(this).g;
	}

	inline function set_s(value:FastFloat):FastFloat {
		var c = Color.hsv2rgb(vec3(h, value, v));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}

	inline function get_v():FastFloat {
		return Color.rgb2hsv(this).b;
	}

	inline function set_v(value:FastFloat):FastFloat {
		var c = Color.hsv2rgb(vec3(h, s, value));
		r = c.r;
		g = c.g;
		b = c.b;
		return value;
	}
}
