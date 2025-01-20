#version 450

#include "s2d/std/lighting"

// stage uniforms
uniform mat3 viewProjection;
uniform float lightsData[1 + MAX_LIGHTS * LIGHT_STRUCT_SIZE];
#if S2D_RP_ENV_LIGHTING == 1
uniform sampler2D envMap;
#endif

// material uniforms
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D emissionMap;
uniform sampler2D ormMap;

#if (S2D_SPRITE_INSTANCING != 1)
uniform mat3 model;
#else
in mat3 model;
#endif

in vec2 fragCoord;
in vec2 fragUV;
out vec4 fragColor;

void main() {
    // fetch material textures
    vec4 albedo = texture(albedoMap, fragUV);
    albedo.rgb /= albedo.a;
    vec3 emission = texture(emissionMap, fragUV).rgb;
    vec3 orm = texture(ormMap, fragUV).rgb;

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    vec3 normal = texture(normalMap, fragUV).rgb * 2.0 - 1.0;
    normal.xy = inverse(mat2(model)) * normal.xy;
    normal = normalize(vec3(normal.xy, normal.z));

    vec3 position = inverse(viewProjection) * vec3(fragCoord, 0.0);

    // output color
    vec3 col = vec3(0.0);

    // environment lighting
    #if S2D_RP_ENV_LIGHTING == 1
    col += envLighting(envMap, normal, albedo.rgb, roughness, metalness);
    #endif

    // lighting
    int lightCount = int(lightsData[0]);
    for (int i = 0; i < lightCount; ++i)
        col += lighting(getLight(lightsData, i), position, normal, albedo.rgb, roughness, metalness);

    fragColor = vec4(emission + occlusion * col, albedo.a);
}
