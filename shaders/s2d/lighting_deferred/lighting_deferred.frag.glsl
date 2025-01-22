#version 450

#include "s2d/std/lighting"

uniform mat3 viewProjection;
#if S2D_LIGHTING_SHADOWS == 1
uniform sampler2D shadowMap;
#endif

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

    vec3 l = lighting(light, position, normal, albedo.rgb, orm);
    #if S2D_LIGHTING_SHADOWS == 1
    float shadow = texture(shadowMap, fragCoord).r;
    fragColor = vec4(l * shadow, 1.0);
    #else
    fragColor = vec4(l, 1.0);
    #endif
}
