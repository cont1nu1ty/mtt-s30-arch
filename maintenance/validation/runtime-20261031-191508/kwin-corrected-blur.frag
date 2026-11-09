#version 300 es
#extension GL_OES_EGL_image_external : require
precision highp float;
precision highp sampler2D;
precision highp sampler3D;
#define TRAIT_MAP_TEXTURE 1
#define TRAIT_UNIFORM_COLOR 0
#define TRAIT_MODULATE 0
#define TRAIT_ADJUST_SATURATION 0
#define TRAIT_TRANSFORM_COLORSPACE 0
#define TRAIT_MAP_EXTERNAL_TEXTURE 0
#define TRAIT_MAP_MULTI_PLANE_TEXTURE 0
#define TRAIT_ROUNDED_CORNERS 0
#define TRAIT_BORDER 0

uniform sampler2D texUnit;
uniform float offset;
uniform vec2 halfpixel;

in vec2 uv;

out vec4 fragColor;

void main(void)
{
    vec4 sum = texture(texUnit, uv) * 4.0;
    sum += texture(texUnit, uv - halfpixel.xy * offset);
    sum += texture(texUnit, uv + halfpixel.xy * offset);
    sum += texture(texUnit, uv + vec2(halfpixel.x, -halfpixel.y) * offset);
    sum += texture(texUnit, uv - vec2(halfpixel.x, -halfpixel.y) * offset);

    fragColor = sum / 8.0;
}


