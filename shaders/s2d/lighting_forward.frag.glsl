#version 450

#include "s2d/std/pbr"

#define MAX_LIGHTS 16
#define LIGHT_STRUCT_SIZE 8

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
uniform sampler2D emissionMap;
uniform mat3 invVP;
uniform float lightsData[1 + MAX_LIGHTS * LIGHT_STRUCT_SIZE];

in vec2 fragCoord;
out vec4 fragColor;

struct Light {
    vec3 position;
    vec3 color;
    float power;
    float radius;
};

Light getLight(int index) {
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

    return (diffuseLight + specularLight) * light.color * lightAttenuation;
}

void main() {
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
    vec3 position = vec3(fragCoord, normal.z);
    position = invVP * vec3(position * 2.0 - 1.0);

    normal = normalize(normal * 2.0 - 1.0);
    normal.z = sqrt(max(0.5, 1.0 - normal.x * normal.x - normal.y * normal.y));

    // lighting
    vec3 c = vec3(0.0);
    int lightCount = int(lightsData[0]);
    for (int i = 0; i < lightCount; ++i)
        c += lighting(getLight(i), position, normal, albedo, roughness, metalness);

    fragColor = vec4(occlusion * c, 1.0);
}