//绘制时的坐标直接用屏幕上的像素点为单位表示
//两倍超采样
//可以用AABB先判断在不在需要绘制的空间内

#define PI 3.14159265358
#define FULLCOLOR vec4(1.0, 1.0, 1.0, 1.0)
#define NULLCOLOR vec4(-1.0, 0.0, 0.0, 0.0)
#define SAMPLERTIME 3

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

vec2 RotateDot(vec2 dot, vec2 pivot, float angle) {
    vec2 temp = dot;
    dot.x = (temp.x - pivot.x) * cos(angle / 180.0 * PI) - (temp.y - pivot.y) * sin(angle / 180.0 * PI) + pivot.x ;
    dot.y = (temp.x - pivot.x) * sin(angle / 180.0 * PI) + (temp.y - pivot.y) * cos(angle / 180.0 * PI) + pivot.y ;

    return dot;
}