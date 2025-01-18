#version 450

uniform vec2 spriteParams;
#define spriteRotation spriteParams[0]
#define spriteZ spriteParams[1]

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
uniform sampler2D emissionMap;

uniform float matParams[2];
#define depthScale matParams[0]
#define emissionStrength matParams[1]

in vec2 fragUV;

layout(location = 0) out vec4 albedoColor;
layout(location = 1) out vec4 normalColor;
layout(location = 2) out vec4 emissionColor;
layout(location = 3) out vec4 ormColor;
layout(location = 4) out vec4 depthColor;

void main() {
    // fetch material textures
    vec4 albedo = texture(albedoMap, fragUV);
    vec3 normal = texture(normalMap, fragUV).rgb;
    vec3 emission = texture(emissionMap, fragUV).rgb * emissionStrength;
    vec3 orm = texture(ormMap, fragUV).rgb;

    // tangent space -> world space
    normal = normalize(vec3(normal.xy * 2.0 - 1.0, normal.z));
    vec2 n = normal.xy;
    float rotSin = sin(-spriteRotation);
    float rotCos = cos(-spriteRotation);
    normal.x = rotCos * n.x - rotSin * n.y;
    normal.y = rotSin * n.x + rotCos * n.y;
    normal.z = sqrt(1 - normal.x * normal.x - normal.y * normal.y);

    albedoColor = albedo;
    normalColor = vec4(normal, albedo.a);
    emissionColor = vec4(emission, albedo.a);
    ormColor = vec4(orm, albedo.a);
    depthColor = vec4(vec3(spriteZ + (1.0 - normal.z) * depthScale), albedo.a);
}
