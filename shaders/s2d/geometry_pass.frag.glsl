#version 450

#ifdef GL_ES
precision highp float;
#endif

uniform mat4 model;

uniform sampler2D colorMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
uniform sampler2D glowMap;

// 1 - depth scale
uniform float Params[1];

in vec3 fragPos;
in vec2 fragUV;
out vec4 fragColor;

float pack(vec4 cram) {
    const uvec4 shift = uvec4(24, 16, 8, 0);

    uvec4 crd = uvec4(clamp(cram, 0.0, 1.0) * 255.0) << shift;
    uint haz = crd.x | crd.y | crd.z | crd.w;
    uint cond = haz << 1 >> 24; // exponent - for nan & unnorm cond (IEEE 754)
    haz = cond != 255u ? cond == 0u ? haz | 0x1000000u : haz : haz ^ 0x1000000u;

    return uintBitsToFloat(haz);
}

void main() {
    // fetch material parameters
    float depthScale = Params[0];

    float rot = atan(model[1][0], model[0][0]);
    float rotSin = sin(rot);
    float rotCos = cos(rot);

    // fetch material textures
    vec4 color = texture(colorMap, fragUV);
    vec3 normal = texture(normalMap, fragUV).rgb;
    vec3 glow = texture(glowMap, fragUV).rgb;
    vec3 orm = texture(ormMap, fragUV).rgb;

    // tangent space -> world space
    vec2 n = normal.xy * 2.0 - 1.0;
    normal.x = rotCos * n.x + rotSin * n.y;
    normal.y = -rotSin * n.x + rotCos * n.y;
    normal.xy = normal.xy * 0.5 + 0.5;
    normal.z = fragPos.z + (normal.z * 2.0 - 1.0) * depthScale;

    color.a = step(0.5, color.a);

    // premultiply alpha
    normal.rgb *= color.a;
    glow.rgb *= color.a;
    orm.rgb *= color.a;

    fragColor = vec4(
            pack(vec4(color.r, normal.r, glow.r, orm.r)),
            pack(vec4(color.g, normal.g, glow.g, orm.g)),
            pack(vec4(color.b, normal.b, glow.b, orm.b)),
            color.a
        );
}
