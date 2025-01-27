#version 450

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D emissionMap;
uniform sampler2D ormMap;

#if (S2D_SPRITE_INSTANCING != 1)
uniform mat3 model;
#else
in mat3 model;
#endif

in vec2 fragUV;

layout(location = 0) out float depthColor;
layout(location = 1) out vec3 albedoColor;
layout(location = 2) out vec3 normalColor;
layout(location = 3) out vec3 emissionColor;
layout(location = 4) out vec3 ormColor;

void main() {
    vec4 albedo = texture(albedoMap, fragUV);
    if (albedo.a < 0.5)
        discard;

    vec3 normal = texture(normalMap, fragUV).rgb * 2.0 - 1.0;
    vec3 emission = texture(emissionMap, fragUV).rgb;
    vec3 orm = texture(ormMap, fragUV).rgb;

    // local space -> world space
    normal.xy = mat2(model) * normal.xy;
    normal = normalize(vec3(normal.xy, normal.z));
    normal = normal * 0.5 + 0.5;

    depthColor = 1.0 - gl_FragCoord.z;
    albedoColor = albedo.rgb / albedo.a;
    normalColor = normal;
    emissionColor = emission;
    ormColor = orm;
}
