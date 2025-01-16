#version 450

#include "s2d/std/pbr"

in vec2 fragCoord;
out vec4 fragColor;

#if S2D_RP_ENV_LIGHTING == 1
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
#endif
uniform sampler2D emissionMap;

#if S2D_RP_ENV_LIGHTING == 1
uniform sampler2D envMap;

vec3 envLighting(vec3 normal, vec3 color, float roughness, float metalness) {
    vec3 V = normalize(viewDir);

    // radiance
    vec3 reflection = normalize(reflect(V, normal));
    float mipLevel = roughness * 10.0;
    vec3 radiance = textureLod(envMap, reflection.xy * 0.5 + 0.5, mipLevel).rgb;

    // Fresnel
    vec3 F0 = mix(vec3(0.04), color, metalness);
    vec3 F = fresnelSchlick(max(dot(normal, V), 0.0), F0);

    vec3 specular = radiance * F;

    // irradiance
    vec3 diffuseIrradiance = textureLod(envMap, normal.xy * 0.5 + 0.5, 10.0).rgb;
    vec3 kD = (1.0 - F) * (1.0 - metalness);
    vec3 diffuse = kD * color * diffuseIrradiance;

    return diffuse + specular;
}
#endif

void main() {
    // fetch gbuffer textures
    vec3 emission;
    #if S2D_RP_ENV_LIGHTING == 1
    vec3 albedo, normal, orm;
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

    vec3 env = envLighting(normal, albedo, roughness, metalness);
    emission += occlusion * env;
    #else
    emission = texture(emissionMap, fragCoord).rgb;
    #endif

    fragColor = vec4(emission, 1.0);
}
