#version 450

#include "s2d/std/lighting"

uniform mat3 viewProjection;
uniform float lightsData[1 + MAX_LIGHTS * LIGHT_STRUCT_SIZE];

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;

in vec2 fragCoord;
out vec4 fragColor;

void main() {
    // fetch gbuffer textures
    vec3 albedo, normal, orm;
    albedo = texture(albedoMap, fragCoord).rgb;
    normal = texture(normalMap, fragCoord).rgb;
    orm = texture(ormMap, fragCoord).rgb;

    normal = normalize(normal * 2.0 - 1.0);

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    // convert data
    vec3 position = inverse(viewProjection) * vec3(fragCoord * 2.0 - 1.0, 0.0);

    // lighting
    vec3 c = vec3(0.0);
    int lightCount = int(lightsData[0]);
    for (int i = 0; i < lightCount; ++i)
        c += lighting(getLight(lightsData, i), position, normal, albedo, roughness, metalness);

    fragColor = vec4(occlusion * c, 1.0);
}
