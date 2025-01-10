#include "s2d/std/packing"

vec4 packGBuffer(vec4 albedo, vec3 normal, vec3 emission, vec3 orm) {
    return vec4(
        pack(vec4(albedo.r, normal.r, emission.r, orm.r)),
        pack(vec4(albedo.g, normal.g, emission.g, orm.g)),
        pack(vec4(albedo.b, normal.b, emission.b, orm.b)),
        albedo.a
    );
}

void unpackRGB(sampler2D tex, vec2 uv, out vec4 upR, out vec4 upG, out vec4 upB) {
    vec4 packed = texture(tex, uv);
    upR = unpack(packed.r);
    upG = unpack(packed.g);
    upB = unpack(packed.b);
}

void unpackGBuffer(sampler2D tex, vec2 uv, out vec3 albedo, out vec3 normal, out vec3 emission, out vec3 orm) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    albedo = vec3(upR.r, upG.r, upB.r);
    normal = vec3(upR.g, upG.g, upB.g);
    emission = vec3(upR.b, upG.b, upB.b);
    orm = vec3(upR.a, upG.a, upB.a);
}

void unpackGBufferAlbedo(sampler2D tex, vec2 uv, out vec3 albedo) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    albedo = vec3(upR.r, upG.r, upB.r);
}

void unpackGBufferNormal(sampler2D tex, vec2 uv, out vec3 normal) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    normal = vec3(upR.g, upG.g, upB.g);
}

void unpackGBufferEmission(sampler2D tex, vec2 uv, out vec3 emission) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    emission = vec3(upR.b, upG.b, upB.b);
}

void unpackGBufferORM(sampler2D tex, vec2 uv, out vec3 orm) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    orm = vec3(upR.a, upG.a, upB.a);
}
