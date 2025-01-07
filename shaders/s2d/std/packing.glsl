float pack(vec4 cram) {
    const uvec4 shift = uvec4(24, 16, 8, 0);

    uvec4 crd = uvec4(clamp(cram, 0.0, 1.0) * 255.0) << shift;
    uint haz = crd.x | crd.y | crd.z | crd.w;
    uint cond = haz << 1 >> 24; // exponent - for nan & unnorm cond (IEEE 754)
    haz = cond != 255u ? cond == 0u ? haz | 0x1000000u : haz : haz ^ 0x1000000u;

    return uintBitsToFloat(haz);
}

vec4 unpack(float cram) {
    const uvec4 shift = uvec4(24, 16, 8, 0);

    uvec4 haz = uvec4(floatBitsToUint(cram));
    haz = haz >> shift & 0xFFu;

    return vec4(haz) / 255.0;
}
