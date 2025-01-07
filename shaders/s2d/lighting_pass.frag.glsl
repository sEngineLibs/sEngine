#version 450

#ifdef GL_ES
precision mediump float;
#endif

#define MAX_LIGHTS 16
#define LIGHT_STRUCT_SIZE 8

uniform sampler2D gMap;
uniform mat4 invVP;
uniform float lightsData[1 + MAX_LIGHTS * LIGHT_STRUCT_SIZE];

in vec2 fragCoord;
out vec4 fragColor;

const vec3 viewDir = vec3(0.0, 0.0, 1.0); // 2D
const float PI = 3.14159;

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

import s2d.std.packing
import s2d.std.pbr

vec3 lighting(Light light, vec3 position, vec3 normal, vec3 color, float roughness, float metalness) {
    vec3 l = light.position - position;
    float distSq = dot(l, l);
    float dist = sqrt(distSq);
    vec3 dir = l / dist;

    float lightAttenuation = light.power / (4.0 * PI * distSq + light.radius * light.radius);

    vec3 V = normalize(viewDir);
    vec3 H = normalize(dir + V);

    // Fresnel
    vec3 F0 = mix(vec3(0.04), color, metalness);
    vec3 F = fresnelSchlick(dot(H, V), F0);

    // BRDF components
    float roughnessE2 = roughness * roughness;
    float NDF = distributionGGX(normal, H, roughnessE2);
    float G = geometrySmith(normal, V, dir, roughnessE2);
    vec3 specularLight = (NDF * G * F) / 4.0 * dot(normal, V) * dot(normal, dir);

    // diffuse
    vec3 kD = (1.0 - F) * (1.0 - metalness);
    vec3 diffuseLight = kD * color * max(dot(normal, dir), 0.0) / PI;

    return (diffuseLight + specularLight) * light.color * lightAttenuation;
}

void main() {
    // fetch gbuffer textures
    vec4 packed = texture(gMap, fragCoord);
    vec4 upR = unpack(packed.r);
    vec4 upG = unpack(packed.g);
    vec4 upB = unpack(packed.b);

    vec3 color = vec3(upR.r, upG.r, upB.r);
    vec3 normal = vec3(upR.g, upG.g, upB.g);
    vec3 orm = vec3(upR.a, upG.a, upB.a);

    float occlusion = orm.r;
    float roughness = clamp(orm.g, 0.05, 1.0);
    float metalness = orm.b;

    // convert data
    vec3 position = vec3(fragCoord, normal.z);
    vec4 worldPos = invVP * vec4(position * 2.0 - 1.0, 1.0);
    position = worldPos.xyz / worldPos.w;

    normal.z = sqrt(max(0.5, 1.0 - normal.x * normal.x - normal.y * normal.y));
    normal = normalize(normal * 2.0 - 1.0);

    // lighting
    vec3 c = vec3(0.0);
    int lightCount = min(int(lightsData[0]), MAX_LIGHTS);
    for (int i = 0; i < lightCount; ++i)
        c += lighting(getLight(i), position, normal, color, roughness, metalness);

    fragColor = vec4(occlusion * c, 1.0);
}
