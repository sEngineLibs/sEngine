#version 450

#define FXAA_SPAN_MAX 8.0
#define FXAA_REDUCE_MUL   (0.25 / FXAA_SPAN_MAX)
#define FXAA_REDUCE_MIN   (1.0 / 32.0)
#define FXAA_SUBPIX_SHIFT 0.75

uniform sampler2D textureMap;
uniform vec2 resolution;

uniform float params[7];
#define posterizeGamma params[0]
#define posterizeSteps params[1]
#define vignetteStrength params[2]
#define vignetteColor vec4(params[3], params[4], params[5], params[6])

in vec2 fragCoord;
out vec4 fragColor;

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

vec3 AA(sampler2D T, vec2 p) {
    const float AA_STAGES = 8.0;
    const float AA_TOTAL_PASSES = AA_STAGES * AA_STAGES * 4 + 1.0;
    const float AA_JITTER = 0.5;

    vec2 uv = p / textureSize(textureMap, 0);
    vec3 color = texture(textureMap, uv).rgb;
    for (float x = -AA_STAGES; x < AA_STAGES; x++) {
        for (float y = -AA_STAGES; y < AA_STAGES; y++) {
            vec2 offset = AA_JITTER * (2.0 * hash22(vec2(x, y)) - 1.0);
            color += texture(T, (p + offset) / textureSize(T, 0)).rgb;
        }
    }
    return color / AA_TOTAL_PASSES;
}

vec3 posterize(vec3 col, float gamma, float steps) {
    col = pow(col, vec3(gamma));
    col = floor(col * steps) / steps;
    col = pow(col, vec3(1.0 / gamma));
    return col;
}

float vignette(vec2 coord) {
    coord *= 1.0 - coord.yx;
    return pow(coord.x * coord.y * 15.5, vignetteStrength);
}

void main() {
    // aa
    vec3 color = AA(textureMap, gl_FragCoord.xy);

    // posterize
    color = posterize(color, posterizeGamma, posterizeSteps);

    // vignette
    float vignetteFactor = vignette(fragCoord);
    color = mix(vignetteColor.rgb, color, vignetteFactor * vignetteColor.a);

    fragColor = vec4(color, 1.0);
}
