#version 450

#include "s2d/std/lighting"

in vec2 fragCoord;
out vec4 fragColor;

#if S2D_RP_ENV_LIGHTING == 1
uniform sampler2D envMap;
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
#endif
uniform sampler2D emissionMap;

void main() {
    // output color
    vec3 col;

    // environment lighting
    #if S2D_RP_ENV_LIGHTING == 1
    // fetch gbuffer textures
    vec3 albedo, normal, emission, orm;
    albedo = texture(albedoMap, fragCoord).rgb;
    normal = texture(normalMap, fragCoord).rgb;
    emission = texture(emissionMap, fragCoord).rgb;
    orm = texture(ormMap, fragCoord).rgb;

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    // convert data
    normal = normalize(normal * 2.0 - 1.0);
    normal.z = sqrt(max(0.5, 1.0 - normal.x * normal.x - normal.y * normal.y));

    vec3 env = envLighting(envMap, normal, albedo, roughness, metalness);
    col = emission + occlusion * env;

    // just emission
    #else
    col = texture(emissionMap, fragCoord).rgb;
    #endif

    fragColor = vec4(col, 1.0);
}
