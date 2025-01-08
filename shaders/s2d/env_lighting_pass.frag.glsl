#version 450

#include "s2d/std/gbuffer"
#include "s2d/std/pbr"

in vec2 fragCoord;
out vec4 fragColor;

uniform sampler2D gBuffer;

#ifdef S2D_RP_ENV_LIGHTING
uniform sampler2D envMap;

vec3 envLighting(vec3 normal, vec3 color, float roughness, float metalness) {
    vec3 V = normalize(viewDir);

    // radiance
    vec3 reflection = normalize(reflect(-V, normal));
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
    #ifdef S2D_RP_ENV_LIGHTING
    // fetch gbuffer textures
    vec3 color, normal, glow, orm;
    unpackGBuffer(gBuffer, fragCoord, color, normal, glow, orm);

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    // convert data
    normal.z = sqrt(max(0.5, 1.0 - normal.x * normal.x - normal.y * normal.y));
    normal = normalize(normal * 2.0 - 1.0);

    vec3 env = envLighting(normal, color, roughness, metalness);
    glow += occlusion * env;
    #else
    vec3 glow = unpackGBufferGlow(gBuffer, fragCoord);
    #endif

    fragColor = vec4(glow, 1.0);
}
