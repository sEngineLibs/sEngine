#version 450

#define gamma vec3(5.2)
#define invGamma (1.0 / gamma)

#ifdef S2D_PP_DOF_QUALITY
#if S2D_PP_DOF_QUALITY == 0
#define quality 4.0
#elif S2D_PP_DOF_QUALITY == 1
#define quality 8.0
#else
#define quality 16.0
#endif
#else
#define quality 4.0
#endif

#if S2D_RP_PACK_GBUFFER == 1
#include "s2d/std/gbuffer"
uniform sampler2D gBuffer;
#else
uniform sampler2D normalMap;
#endif
uniform sampler2D textureMap;
uniform vec2 resolution;
uniform mat4 invVP;
uniform vec3 cameraPos;
uniform float focusDistance;
uniform float blurSize;

in vec2 fragCoord;
out vec4 fragColor;

vec3 blur(sampler2D tex, vec2 uv, float size, float ratio) {
    vec3 col = vec3(0.0);
    float W = 0.0;

    for (float y = -1.0; y <= 1.0; y += 1.0 / quality) {
        for (float x = -1.0; x <= 1.0; x += 1.0 / quality) {
            vec2 p = vec2(x, y);
            vec2 offset = p * size * vec2(1.0, ratio);

            float w = 1.0 - smoothstep(0.0, 1.0, length(p));
            col += pow(texture(tex, uv + offset).rgb, gamma) * w;
            W += w;
        }
    }

    return pow(col / W, invGamma);
}

void main() {
    vec3 normal;
    #if S2D_RP_PACK_GBUFFER == 1
    unpackGBufferNormal(gBuffer, fragCoord, normal);
    #else
    normal = texture(normalMap, fragCoord).rgb;
    #endif

    vec3 position = vec3(fragCoord, normal.z);
    vec4 worldPos = invVP * vec4(position * 2.0 - 1.0, 1.0);
    position = worldPos.xyz / worldPos.w;
    float cameraDist = abs(-position.z - cameraPos.z - focusDistance);

    vec3 color = blur(textureMap, fragCoord, cameraDist * blurSize, resolution.x / resolution.y);

    fragColor = vec4(color, 1.0);
}
