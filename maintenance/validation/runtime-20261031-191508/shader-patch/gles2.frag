#version 100
precision highp float;
vec4 texture(sampler2D s, vec2 c) { return texture2D(s,c); }
uniform sampler2D texUnit;
uniform float offset;
uniform vec2 halfpixel;

varying vec2 uv;

#define fragColor gl_FragColor

void main(void)
{
    vec4 sum = texture(texUnit, uv) * 4.0;
    sum += texture(texUnit, uv - halfpixel.xy * offset);
    sum += texture(texUnit, uv + halfpixel.xy * offset);
    sum += texture(texUnit, uv + vec2(halfpixel.x, -halfpixel.y) * offset);
    sum += texture(texUnit, uv - vec2(halfpixel.x, -halfpixel.y) * offset);

    fragColor = sum / 8.0;
}
