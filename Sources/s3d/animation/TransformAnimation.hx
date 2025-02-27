package s3d.animation;

import se.animation.Animation;
import se.math.VectorMath.mix;

class TransformAnimation extends Animation<Transform> {
	inline function update(t:Float) {
		return new Transform(mix(from._00, to._00, t), mix(from._01, to._01, t), mix(from._02, to._02, t), mix(from._03, to._03, t), mix(from._10, to._10, t),
			mix(from._11, to._11, t), mix(from._12, to._12, t), mix(from._13, to._13, t), mix(from._20, to._20, t), mix(from._21, to._21, t),
			mix(from._22, to._22, t), mix(from._23, to._23, t), mix(from._30, to._30, t), mix(from._31, to._31, t), mix(from._32, to._32, t),
			mix(from._33, to._33, t),);
	}
}
