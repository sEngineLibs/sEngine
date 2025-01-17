#version 450

#include "s2d/std/lighting"

// stage uniforms
#if S2D_RP_ENV_LIGHTING == 1
uniform sampler2D envMap;
#endif
uniform mat3 invVP;
uniform float lightsData[1 + MAX_LIGHTS * LIGHT_STRUCT_SIZE];

// sprite uniforms
uniform vec2 spriteParams;
#define spriteRotation spriteParams[0]
#define spriteZ spriteParams[1]

// material uniforms
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
uniform sampler2D emissionMap;
uniform float matParams[2];
#define depthScale matParams[0]
#define emissionStrength matParams[1]

in vec2 fragUV;

layout(location = 0) out vec4 depthColor;
layout(location = 1) out vec4 fragColor;

void main() {
    // fetch material textures
    vec4 albedo = texture(albedoMap, fragUV);
    vec4 normal = texture(normalMap, fragUV);
    vec3 emission = texture(emissionMap, fragUV).rgb * emissionStrength;
    vec3 orm = texture(ormMap, fragUV).rgb;
    float depth = spriteZ + (1.0 - normal.a) * depthScale;
    depthColor = vec4(vec3(depth), albedo.a);

    // tangent space -> world space
    vec3 n = normal.xyz * 2.0 - 1.0;
    float rotSin = sin(-spriteRotation);
    float rotCos = cos(-spriteRotation);
    normal.x = rotCos * n.x - rotSin * n.y;
    normal.y = rotSin * n.x + rotCos * n.y;
    n = normalize(vec3(normal.xy, n.z));

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    // convert data
    vec3 position = vec3(fragUV, depth);
    position = invVP * vec3(position * 2.0 - 1.0);

    // output color
    vec3 col = vec3(0.0);

    // environment lighting
    #if S2D_RP_ENV_LIGHTING == 1
    col += envLighting(envMap, n, albedo.rgb, roughness, metalness);
    #endif

    // lighting
    int lightCount = int(lightsData[0]);
    for (int i = 0; i < lightCount; ++i)
        col += lighting(getLight(lightsData, i), position, n, albedo.rgb, roughness, metalness);

    fragColor = vec4((emission + occlusion * col) / albedo.a, albedo.a);
}
