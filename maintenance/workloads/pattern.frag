#version 450
layout(push_constant) uniform Params { uint frame; } params;
layout(location = 0) out vec4 color;
void main() {
    uvec2 p = uvec2(gl_FragCoord.xy);
    uint tile = ((p.x / 16u) + 3u * (p.y / 16u) + params.frame) % 4u;
    vec3 colors[4] = vec3[](vec3(1,0,0), vec3(0,1,0),
                           vec3(0,0,1), vec3(1,1,1));
    color = vec4(colors[tile], 1);
}
