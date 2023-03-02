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
#define TMLKEYPADSIZE 11.0
#define TMLKEYPADSPACE 29.0
#define PI 3.14159265358

float samplerStep = 1.0 / (SAMPLERTIME + 1);

vec4 lerpColor(vec3 x, vec3 y, float t) {
    return vec4(mix(x.x, y.x, t), mix(x.y, y.y, t), mix(x.z, y.z, t), 1.0);
}

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

void DrawLine(in vec2 point[2], float bold, vec4 color, out vec4 outputColor) {
    vec4 _outputColor;
    outputColor = fragColor;

    DrawSmoothCircle(point[0], bold / 2.0, color, _outputColor);
    if(_outputColor.a > 0.0) outputColor = vec4(mix(outputColor.rgb, _outputColor.rgb, _outputColor.a), 1.0);

    DrawSmoothCircle(point[1], bold / 2.0, color, _outputColor);
    if(_outputColor.a > 0.0) outputColor = vec4(mix(outputColor.rgb, _outputColor.rgb, _outputColor.a), 1.0);

    float rad = atan(point[0].x - point[1].x, point[0].y - point[1].y);

    if(point[0].x < point[1].x || (point[0].x == point[1].x && point[0].y < point[1].y)) {
        float rad = atan(point[1].x - point[0].x, point[1].y - point[0].y);
        DrawSmoothQuads(vec2[](
            point[1] + vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2),
            point[0] + vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2),
            point[0] - vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2),
            point[1] - vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2)
        ), color, _outputColor);
    }
    else {
        float rad = atan(point[0].x - point[1].x, point[0].y - point[1].y);
        DrawSmoothQuads(vec2[](
            point[0] + vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2),
            point[1] + vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2),
            point[1] - vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2),
            point[0] - vec2(sin(rad + PI / 2) * bold / 2, cos(rad + PI / 2) * bold / 2)
        ), color, _outputColor);
    }
    if(_outputColor.a > 0.0) outputColor = vec4(mix(outputColor.rgb, _outputColor.rgb, _outputColor.a), 1.0);

}

vec2 RotateDot(inout vec2 dot, vec2 pivot, float angle) {
    vec2 temp = dot;
    dot.x = (temp.x - pivot.x) * cos(angle / 180.0 * PI) - (temp.y - pivot.y) * sin(angle / 180.0 * PI) + pivot.x ;
    dot.y = (temp.x - pivot.x) * sin(angle / 180.0 * PI) + (temp.y - pivot.y) * cos(angle / 180.0 * PI) + pivot.y ;

    return dot;
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

void DrawRealmsLogo() {
    fragColor = vec4(0.0);

    //fragColor = vec4(vec3(gl_FragCoord.x / ScreenSize.x), ColorModulator.a);
    vec2 coord = ScreenSize / 2.0;
    float scale = ceil(min(ScreenSize.x, ScreenSize.y) / 160.0) * 4.0;
    DrawSmoothCircle(coord, sqrt(pow(ScreenSize.x, 2.0) + pow(ScreenSize.y, 2.0)) * sin(ColorModulator.a), vec4(ivec3(83, 125, 163) / 255.0, 1.0), fragColor);
    coord.y += -scale + scale * 2 * sin(ColorModulator.a * 2.0);
    DrawCape(coord, vec2(scale, scale));

    //渐变淡出
    if(fragColor.r == -1.0) fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    fragColor = vec4(fragColor.rgb, ColorModulator.a * fragColor.a);
}

void DrawTmlKeypad(vec2 coord, float scale) {
    vec4 outputColor;
    vec4 backGroundColor = fragColor;
    
    float xCoord = -TMLKEYPADSPACE;
    for(int i = 0; i < 3; i++) {
        float yCoord =  -TMLKEYPADSPACE;
        for(int j = 0; j < 3; j++) {
            float thisScale = scale * (sin(clamp(-(i + j) / 6.0 + 2.0 * clamp(ColorModulator.a * 2 - 1.0, 0.0, 1.0), 0.0, 1.0) * PI - PI / 2) + 1.0) / 2.0;
            DrawSmoothQuads(vec2[](
                vec2(TMLKEYPADSIZE, TMLKEYPADSIZE) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                vec2(-TMLKEYPADSIZE, TMLKEYPADSIZE) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                vec2(-TMLKEYPADSIZE, -TMLKEYPADSIZE) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                vec2(TMLKEYPADSIZE, -TMLKEYPADSIZE) * thisScale + vec2(xCoord, yCoord) * scale + coord
            ), vec4(vec3(90.0, 90.0, 90.0) / 255.0, 1.0), outputColor);
            if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
            

            if(i == 0 && j == 0){
                DrawSmoothTriangle(vec2[](
                    vec2(-(TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1) / 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1) / 3.0, -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
            }
            else if(i == 2 && j == 0){
                DrawSmoothTriangle(vec2[](
                    vec2((TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1) / 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1) / 3.0, -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
            }
            else if(i == 0 && j == 2){
                DrawSmoothTriangle(vec2[](
                    vec2(-(TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1) / 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1) / 3.0, (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
            }
            else if(i == 2 && j == 2){
                DrawSmoothTriangle(vec2[](
                    vec2((TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1) / 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1) / 3.0, (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
            }
            else if(i == 1 && j == 1){
                DrawSmoothTriangle(vec2[](
                    vec2((TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1) / 5.0 * 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1) / 5.0 * 3.0, (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

                DrawSmoothTriangle(vec2[](
                    vec2(-(TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1), (TMLKEYPADSIZE + 1) / 5.0 * 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1) / 5.0 * 3.0, (TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

                DrawSmoothTriangle(vec2[](
                    vec2((TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1) / 5.0 * 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2((TMLKEYPADSIZE + 1) / 5.0 * 3.0, -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

                DrawSmoothTriangle(vec2[](
                    vec2(-(TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1), -(TMLKEYPADSIZE + 1) / 5.0 * 3.0) * thisScale + vec2(xCoord, yCoord) * scale + coord,
                    vec2(-(TMLKEYPADSIZE + 1) / 5.0 * 3.0, -(TMLKEYPADSIZE + 1)) * thisScale + vec2(xCoord, yCoord) * scale + coord
                ), backGroundColor, outputColor);
                if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
            }

            yCoord += TMLKEYPADSPACE;

        }
        xCoord += TMLKEYPADSPACE;
    }
}

void DrawTmlTooth(vec2 coord, float scale, float angle) {
    vec4 outputColor;
    vec2 dots[4] = vec2[](
        vec2(12.0, 125.0) * scale + coord,
        vec2(-12.0, 125.0) * scale + coord,
        vec2(-19.0, 100.0) * scale + coord,
        vec2(19.0, 100.0) * scale + coord
    );
    RotateDot(dots[0], coord, angle);
    RotateDot(dots[1], coord, angle);
    RotateDot(dots[2], coord, angle);
    RotateDot(dots[3], coord, angle);

    DrawSmoothQuads(dots, vec4(vec3(90.0, 90.0, 90.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
}

void DrawTmlInnerRing(vec2 coord, float scale) {
    vec4 backGroundColor = fragColor;
    vec4 outputColor;

    float angle = -150.0 - 360 * (sin(ColorModulator.a * PI - PI / 2) / 2.0 + 0.5);

    DrawSmoothCircle(coord, scale * 102.0, vec4(ivec3(90, 90, 90) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothCircle(coord, scale * 77.0, backGroundColor, outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    for(int i = 0; i < 15; i++){
        DrawTmlTooth(coord, scale, angle);
        angle += 300.0 / 14.0;
    }

    vec2 cutCircle = coord - vec2(0.0, scale * 79);
    DrawSmoothCircle(RotateDot(cutCircle, coord, -360 * (sin(ColorModulator.a * PI - PI / 2) / 2.0 + 0.5)), scale * 38.0, backGroundColor, outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothCircle(coord, scale * 72.0, vec4(ivec3(90, 90, 90) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothCircle(coord, scale * 66.0, backGroundColor, outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
}

void DrawGear(vec2 coord, float scale) {
    if(fragColor.a > 0.0) {
        DrawTmlInnerRing(coord, scale);
        DrawTmlKeypad(coord, scale);

        vec4 outputColor;

        float progress = sin((clamp(ColorModulator.a, 0.9, 1.0) - 0.9) * 10 * PI - PI / 2) / 2.0 + 0.5;

        DrawLine(vec2[](
            (vec2(8, 3.2) * progress + vec2(0, -102)) * scale + coord,
            (vec2(-8, -3.2) * progress + vec2(0, -102)) * scale + coord
        ), 6.0 * progress  * scale, vec4(ivec3(90, 90, 90) / 255.0, progress), outputColor);
        if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

        progress = sin((clamp(ColorModulator.a, 0.8, 0.9) - 0.8) * 10 * PI - PI / 2) / 2.0 + 0.5;

        DrawLine(vec2[](
            (vec2(4, 1.6) * progress + vec2(0, -114)) * scale + coord,
            (vec2(-4, -1.6) * progress + vec2(0, -114)) * scale + coord
        ), 6.0 * progress * scale, vec4(ivec3(90, 90, 90) / 255.0, progress), outputColor);
        if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

        progress = sin((clamp(ColorModulator.a, 0.7, 0.8) - 0.7) * 10 * PI - PI / 2) / 2.0 + 0.5;

        DrawLine(vec2[](
            (vec2(2, 0.8) * progress + vec2(0, -126)) * scale + coord,
            (vec2(-2, -0.8) * progress + vec2(0, -126)) * scale + coord
        ), 6.0 * progress * scale, vec4(ivec3(90, 90, 90) / 255.0, progress), outputColor);
        if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
    }
}

void DrawTmlLogo() {
    fragColor = vec4(0.0);
    vec4 outputColor;
    vec4 backGroundColor = lerpColor(vec3(206, 206, 206) / 255.0, vec3(232, 232, 232) / 255.0, gl_FragCoord.y / ScreenSize.y);

    //fragColor = vec4(vec3(gl_FragCoord.x / ScreenSize.x), ColorModulator.a);
    vec2 coord = ScreenSize / 2.0;
    float scale = (ceil(min(ScreenSize.x, ScreenSize.y) / 720.0) + 1.0) / 2.0;
    DrawSmoothQuads(vec2[](
        vec2(clamp((sin(ColorModulator.a * PI - PI / 2)) * (ScreenSize.x + ScreenSize.y) - ScreenSize.y, 0, ScreenSize.x), clamp((sin(ColorModulator.a * PI - PI / 2)) * (ScreenSize.x + ScreenSize.y), 0, ScreenSize.y)),
        vec2(0.0, clamp((sin(ColorModulator.a * PI - PI / 2)) * (ScreenSize.x + ScreenSize.y), 0, ScreenSize.y)),
        vec2(-ScreenSize.x / 2.0, -ScreenSize.y / 2.0) + coord,
        vec2((sin(ColorModulator.a * PI - PI / 2)) * (ScreenSize.x + ScreenSize.y), 0)
    ), backGroundColor, outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
    //coord.y += -scale + scale * 2 * sin(ColorModulator.a * 2.0);
    DrawGear(coord, scale);

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
        if(gl_FragCoord.x + abs(gl_FragCoord.x - ScreenSize.x) != ScreenSize.x &&
           gl_FragCoord.y + abs(gl_FragCoord.y - ScreenSize.y) != ScreenSize.y) discard;
        DrawTmlLogo();
    }
    else {
        if (color.a == 0.0) {
            discard;
        }
        fragColor = color * ColorModulator;
    }
}

