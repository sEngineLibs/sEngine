#version 450

uniform mat3 viewProjection;
#if (S2D_SPRITE_INSTANCING != 1)
uniform mat3 model;
uniform vec4 cropRect;
#else
in vec4 cropRect;
in vec3 model0;
in vec3 model1;
in vec3 model2;
out mat3 model;
#endif

in vec2 vertCoord;
out vec2 fragCoord;
out vec2 fragUV;

void main() {
    #if (S2D_SPRITE_INSTANCING == 1)
    model = mat3(model0, model1, model2);
    #endif
    gl_Position = vec4(viewProjection * model * vec3(vertCoord, 1.0), 1.0);

    fragCoord = gl_Position.xy;
    fragUV = cropRect.xy + (vertCoord.xy * 0.5 + 0.5) * cropRect.zw;
}
