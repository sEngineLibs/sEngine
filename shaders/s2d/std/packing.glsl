float pack(vec4 cram) {
    int crd = (int(cram.r * 255.0) << 24) | (int(cram.g * 255.0) << 16) | (int(cram.b * 255.0) << 8) | int(cram.a * 255.0);
    int cond = (crd >> 24) & 0xFF;
    crd = (cond != 255) ? ((cond == 0) ? (crd | 0x1000000) : crd) : (crd ^ 0x1000000);
    return intBitsToFloat(crd);
}

vec4 unpack(float cram) {
    int haz = floatBitsToInt(cram);
    return vec4(
        float((haz >> 24) & 0xFF) / 255.0,
        float((haz >> 16) & 0xFF) / 255.0,
        float((haz >> 8) & 0xFF) / 255.0,
        float(haz & 0xFF) / 255.0
    );
}
