#version 450

#include "s2d/std/lighting"

uniform mat3 viewProjection;

// light uniforms
uniform vec3 lightPosition;
uniform vec3 lightColor;
uniform vec3 lightAttrib;
#define lightPower lightAttrib.x
#define lightRadius lightAttrib.y
#define lightVolume lightAttrib.z

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;

in vec2 fragCoord;
out vec4 fragColor;

void main() {
    vec3 albedo, normal, orm;
    albedo = texture(albedoMap, fragCoord).rgb;
    normal = texture(normalMap, fragCoord).rgb;
    orm = texture(ormMap, fragCoord).rgb;

    normal = normalize(normal * 2.0 - 1.0);

    vec3 position = inverse(viewProjection) * vec3(fragCoord * 2.0 - 1.0, 0.0);

    Light light;
    light.position = lightPosition;
    light.color = lightColor;
    light.power = lightPower;
    light.radius = lightRadius;
    light.volume = lightVolume;

    fragColor = vec4(lighting(light, position, normal, albedo.rgb, orm), 1.0);
}
