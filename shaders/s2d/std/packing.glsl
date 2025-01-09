const ivec4 _bitShift = ivec4(0, 8, 16, 24);
    
float pack(vec4 v) {
    ivec4 iv = ivec4(clamp(v, 0.0, 1.0) * 255.0) << _bitShift;
    return iv.r | iv.g | iv.b | iv.a;
}

vec4 unpack(float p) {
    vec4 v = vec4((ivec4(p) >> _bitShift) & 0xFF);
    return v / 255.0;
}

