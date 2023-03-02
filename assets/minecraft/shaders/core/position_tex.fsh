#version 150
#extension GL_NV_shader_buffer_load : enable

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;
uniform float GameTime;

in vec2 texCoord0;
in float isMojang;

out vec4 fragColor;

//绘制时的坐标直接用屏幕上的像素点为单位表示
//两倍超采样
//可以用AABB先判断在不在需要绘制的空间内

#define FULLCOLOR vec4(1.0, 1.0, 1.0, 1.0)
#define NULLCOLOR vec4(-1.0, 0.0, 0.0, 0.0)
#define SAMPLERTIME 3

float samplerStep = 1.0 / (SAMPLERTIME + 1);

float product(vec2 p1,vec2 p2, vec2 p3) {
    return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);
}

bool IsInTriangle(in vec2 area[3], vec2 dot)
{
	if(product(area[0], area[1], area[2]) < 0) {
        if(product(area[0], area[2], dot) >= 0 && product(area[2], area[1], dot) >= 0 && product(area[1], area[0], dot) >= 0) return true;
        return false;
    }
    if(product(area[0], area[1], dot) >= 0 && product(area[1], area[2], dot) >= 0 && product(area[2], area[0], dot) >= 0) return true;
    return false;
}

bool AABB(in vec2 area[2], vec2 dot) {
    if(abs(area[0].x - dot.x) + abs(area[1].x - dot.x) == abs(area[0].x - area[1].x) &&
       abs(area[0].y - dot.y) + abs(area[1].y - dot.y) == abs(area[0].y - area[1].y)) return true;
    
    return false;
}

void DrawRoughTriangle(in vec2 area[3], vec4 color, out vec4 outputColor) {
    vec2 aabbArea[2];
    aabbArea[0].x = min(area[0].x, min(area[1].x, area[2].x));
    aabbArea[0].y = min(area[0].y, min(area[1].y, area[2].y));
    aabbArea[1].x = max(area[0].x, max(area[1].x, area[2].x));
    aabbArea[1].y = max(area[0].y, max(area[1].y, area[2].y));

    if(AABB(aabbArea, gl_FragCoord.xy)){
        if(IsInTriangle(area, gl_FragCoord.xy)) outputColor = color;
        else outputColor = NULLCOLOR;
    }
    else outputColor = NULLCOLOR;
}

void DrawRoughTriangle(vec2 coord, in vec2 area[3], vec4 color, out vec4 outputColor) {
    vec2 aabbArea[2];
    aabbArea[0].x = min(area[0].x, min(area[1].x, area[2].x));
    aabbArea[0].y = min(area[0].y, min(area[1].y, area[2].y));
    aabbArea[1].x = max(area[0].x, max(area[1].x, area[2].x));
    aabbArea[1].y = max(area[0].y, max(area[1].y, area[2].y));

    if(AABB(aabbArea, coord)){
        if(IsInTriangle(area, coord)) outputColor = color;
        else outputColor = NULLCOLOR;
    }
    else outputColor = NULLCOLOR;
}


void DrawSmoothTriangle(in vec2 area[3], vec4 color, out vec4 outputColor) {
    float a = 0.0;
    float xCoord = -0.5;
    for(int i = 0; i < SAMPLERTIME; i++){
        xCoord += samplerStep;
        float yCoord = -0.5;
        for(int j = 0; j < SAMPLERTIME; j++){
            yCoord += samplerStep;
            DrawRoughTriangle(vec2(gl_FragCoord.x + xCoord, gl_FragCoord.y + yCoord), area, FULLCOLOR, outputColor);
            a += outputColor.a;
        }
    }
    if(a == 0.0) outputColor = NULLCOLOR;
    else {
        a /= (float)SAMPLERTIME * SAMPLERTIME;
        outputColor = vec4(color.rgb, a * color.a);
    }
}

void DrawSmoothQuads(in vec2 area[4], vec4 color, out vec4 outputColor) {
    float a = 0.0;
    float xCoord = -0.5;
    for(int i = 0; i < SAMPLERTIME; i++){
        xCoord += samplerStep;
        float yCoord = -0.5;
        for(int j = 0; j < SAMPLERTIME; j++){
            yCoord += samplerStep;
            DrawRoughTriangle(vec2(gl_FragCoord.x + xCoord, gl_FragCoord.y + yCoord), vec2[](area[1],area[3],area[2]), FULLCOLOR, outputColor);
            vec4 colorTemp;
            DrawRoughTriangle(vec2(gl_FragCoord.x + xCoord, gl_FragCoord.y + yCoord), vec2[](area[1],area[3],area[0]), FULLCOLOR, colorTemp);
            a += clamp(outputColor.a + colorTemp.a, 0.0, 1.0);
        }
    }
    if(a == 0.0) outputColor = NULLCOLOR;
    else {
        a /= (float)SAMPLERTIME * SAMPLERTIME;
        outputColor = vec4(color.rgb, a * color.a);
    }
}

void DrawRoughCircle(in vec2 center, float radius, vec4 color, out vec4 outputColor) {
    if(AABB(vec2[](center - vec2(radius), center + vec2(radius)), gl_FragCoord.xy)){
        vec2 dist = gl_FragCoord.xy - center;
        if(pow(dist.x, 2.0) + pow(dist.y, 2.0) < pow(radius, 2.0)) outputColor = color;
        else outputColor = NULLCOLOR;
    }
    else outputColor = NULLCOLOR;
}

void DrawRoughCircle(vec2 coord, in vec2 center, float radius, vec4 color, out vec4 outputColor) {
    if(AABB(vec2[](center - vec2(radius), center + vec2(radius)), coord)){
        vec2 dist = coord - center;
        if(pow(dist.x, 2.0) + pow(dist.y, 2.0) < pow(radius, 2.0)) outputColor = color;
        else outputColor = NULLCOLOR;
    }
    else outputColor = NULLCOLOR;
}

void DrawSmoothCircle(in vec2 center, float radius, vec4 color, out vec4 outputColor) {
    float a = 0.0;
    float xCoord = -0.5;
    for(int i = 0; i < SAMPLERTIME; i++){
        xCoord += samplerStep;
        float yCoord = -0.5;
        for(int j = 0; j < SAMPLERTIME; j++){
            yCoord += samplerStep;
            DrawRoughCircle(vec2(gl_FragCoord.x + xCoord, gl_FragCoord.y + yCoord), center, radius, FULLCOLOR, outputColor);
            a += outputColor.a;
        }
    }
    if(a == 0.0) outputColor = NULLCOLOR;
    else {
        a /= (float)SAMPLERTIME * SAMPLERTIME;
        outputColor = vec4(color.rgb, a * color.a);
    }
}

void DrawCape(vec2 coord, vec2 scale) {
    vec4 outputColor;

    DrawSmoothQuads(vec2[](
        vec2(-2, 2) * scale + coord,
        vec2(-4, 2) * scale + coord,
        vec2(-4, 4) * scale + coord,
        vec2(-2, 4) * scale + coord
    ), vec4(vec3(124.0, 181.0, 226.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(-0, 3) * scale + coord,
        vec2(-1, 3) * scale + coord,
        vec2(-1, 4) * scale + coord,
        vec2(-0, 4) * scale + coord
    ), vec4(vec3(124.0, 181.0, 226.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(4, 0) * scale + coord,
        vec2(1, 0) * scale + coord,
        vec2(1, 4) * scale + coord,
        vec2(4, 4) * scale + coord
    ), vec4(vec3(124.0, 181.0, 226.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(1, 0) * scale + coord,
        vec2(-1, 0) * scale + coord,
        vec2(-1, 2) * scale + coord,
        vec2(1, 2) * scale + coord
    ), vec4(vec3(124.0, 181.0, 226.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(-1, 0) * scale + coord,
        vec2(-4, 0) * scale + coord,
        vec2(-4, 1) * scale + coord,
        vec2(-1, 1) * scale + coord
    ), vec4(vec3(124.0, 181.0, 226.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(3, 3) * scale + coord,
        vec2(1, 3) * scale + coord,
        vec2(1, 1) * scale + coord,
        vec2(3, 1) * scale + coord
    ), vec4(vec3(230.0, 215.0, 79.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(2, 2) * scale + coord,
        vec2(0, 2) * scale + coord,
        vec2(0, 1) * scale + coord,
        vec2(2, 1) * scale + coord
    ), vec4(vec3(230.0, 235.0, 240.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(4, 0) * scale + coord,
        vec2(-4, 0) * scale + coord,
        vec2(-4, -1) * scale + coord,
        vec2(4, -1) * scale + coord
    ), vec4(vec3(73.0, 147.0, 82.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(4, -1) * scale + coord,
        vec2(-4, -1) * scale + coord,
        vec2(-4, -3) * scale + coord,
        vec2(4, -3) * scale + coord
    ), vec4(vec3(89.0, 77.0, 63.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothQuads(vec2[](
        vec2(4, -3) * scale + coord,
        vec2(-4, -3) * scale + coord,
        vec2(-4, -5) * scale + coord,
        vec2(4, -5) * scale + coord
    ), vec4(vec3(175.0, 168.0, 150.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
}

void DrawLogo() {
    fragColor = vec4(0.0);

    //fragColor = vec4(vec3(gl_FragCoord.x / ScreenSize.x), ColorModulator.a);
    vec2 coord = ScreenSize / 2.0;
    float scale = ceil(max(ScreenSize.x, ScreenSize.y) / 160.0) * 4.0;
    DrawRoughCircle(coord, sqrt(pow(ScreenSize.x, 2.0) + pow(ScreenSize.y, 2.0)) * sin(ColorModulator.a), vec4(ivec3(83, 125, 163) / 255.0, 1.0), fragColor);
    coord.y += -scale + scale * 2 * sin(ColorModulator.a * 2.0);
    DrawCape(coord, vec2(scale, scale));

    //渐变淡出
    if(fragColor.r == -1.0) fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    fragColor = vec4(fragColor.rgb, ColorModulator.a * fragColor.a);
}

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if(isMojang < 0.0) {
        discard;
    }
    else if(isMojang > 0.0) {
        DrawLogo();
    }
    else {
        if (color.a == 0.0) {
            discard;
        }
        fragColor = color * ColorModulator;
    }
}

