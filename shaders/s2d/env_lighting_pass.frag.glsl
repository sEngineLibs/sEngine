#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D gMap;
uniform sampler2D envMap;

in vec2 fragCoord;
out vec4 fragColor;

import s2d.std.packing
import s2d.std.pbr

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

void main() {
    // fetch gbuffer textures
    vec4 packed = texture(gMap, fragCoord);
    vec4 upR = unpack(packed.r);
    vec4 upG = unpack(packed.g);
    vec4 upB = unpack(packed.b);

    vec3 color = vec3(upR.r, upG.r, upB.r);
    vec3 normal = vec3(upR.g, upG.g, upB.g);
    vec3 glow = vec3(upR.b, upG.b, upB.b);
    vec3 orm = vec3(upR.a, upG.a, upB.a);

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    // convert data
    normal.z = sqrt(max(0.5, 1.0 - normal.x * normal.x - normal.y * normal.y));
    normal = normalize(normal * 2.0 - 1.0);

    vec3 e = envLighting(normal, color, roughness, metalness);
    fragColor = vec4(glow + occlusion * e, 1.0);
}
