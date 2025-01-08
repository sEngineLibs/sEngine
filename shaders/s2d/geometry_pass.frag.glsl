#version 450

#include "s2d/std/gbuffer"

uniform mat4 model;

uniform sampler2D colorMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
uniform sampler2D glowMap;

uniform float Params[2];
#define depthScale Params[0]
#define glowStrength Params[1]

in vec3 fragPos;
in vec2 fragUV;
out vec4 fragColor;

void main() {
    float rot = atan(model[1][0], model[0][0]);
    float rotSin = sin(rot);
    float rotCos = cos(rot);

    // fetch material textures
    vec4 color = texture(colorMap, fragUV);
    vec3 normal = texture(normalMap, fragUV).rgb;
    vec3 glow = texture(glowMap, fragUV).rgb * glowStrength;
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

    fragColor = packGBuffer(color.rgb, normal, glow, orm, color.a);
}
