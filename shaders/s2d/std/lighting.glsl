#include "s2d/std/pbr"

#ifndef MAX_LIGHTS
#define MAX_LIGHTS 16
#endif

struct Light {
    vec3 position;
    vec3 color;
    float power;
    float radius;
    float volume;
};
#define LIGHT_STRUCT_SIZE 9

Light getLight(float lightsData[1 + MAX_LIGHTS * LIGHT_STRUCT_SIZE], int index) {
    int i = 1 + index * LIGHT_STRUCT_SIZE;

    Light light;
    light.position = vec3(lightsData[i + 0],
            lightsData[i + 1],
            lightsData[i + 2]);
    light.color = vec3(lightsData[i + 3],
            lightsData[i + 4],
            lightsData[i + 5]);
    light.power = lightsData[i + 6];
    light.radius = lightsData[i + 7];
    light.volume = lightsData[i + 8];

    return light;
}

vec3 lighting(Light light, vec3 position, vec3 normal, vec3 albedo, float roughness, float metalness) {
    vec3 l = light.position - position;
    float distSq = dot(l, l);
    float dist = sqrt(distSq);
    vec3 dir = l / dist;

    float lightAttenuation = light.power / (4.0 * PI * distSq + light.radius * light.radius);

    vec3 V = normalize(viewDir);
    vec3 H = normalize(dir + V);

    // Fresnel
    vec3 F0 = mix(vec3(0.04), albedo, metalness);
    vec3 F = fresnelSchlick(dot(H, V), F0);

    // BRDF components
    float roughnessE2 = roughness * roughness;
    float NDF = distributionGGX(normal, H, roughnessE2);
    float G = geometrySmith(normal, V, dir, roughnessE2);
    vec3 specularLight = (NDF * G * F) / 4.0 * dot(normal, V) * dot(normal, dir);

    // diffuse
    vec3 kD = (1.0 - F) * (1.0 - metalness);
    vec3 diffuseLight = kD * albedo * max(dot(normal, dir), 0.0) / PI;

    return (diffuseLight + specularLight + light.volume) * light.color * lightAttenuation;
}

#if S2D_RP_ENV_LIGHTING == 1
vec3 envLighting(sampler2D envMap, vec3 normal, vec3 color, float roughness, float metalness) {
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
