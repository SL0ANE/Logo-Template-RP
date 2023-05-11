#define TMLKEYPADSIZE 11.0
#define TMLKEYPADSPACE 29.0

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
    dots[0] = RotateDot(dots[0], coord, angle);
    dots[1] = RotateDot(dots[1], coord, angle);
    dots[2] = RotateDot(dots[2], coord, angle);
    dots[3] = RotateDot(dots[3], coord, angle);

    DrawSmoothQuads(dots, vec4(vec3(90.0, 90.0, 90.0) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);
}

void DrawTmlInnerRing(vec2 coord, float scale) {
    vec4 backGroundColor = fragColor;
    vec4 outputColor;

    float angle = -30.0 - 120 * (sin(ColorModulator.a * PI - PI / 2) / 2.0 + 0.5);

    DrawSmoothCircle(coord, scale * 102.0, vec4(ivec3(90, 90, 90) / 255.0, 1.0), outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    DrawSmoothCircle(coord, scale * 77.0, backGroundColor, outputColor);
    if(outputColor.a > 0.0) fragColor = vec4(mix(fragColor.rgb, outputColor.rgb, outputColor.a), 1.0);

    for(int i = 0; i < 15; i++){
        DrawTmlTooth(coord, scale, angle);
        angle += 300.0 / 14.0;
    }

    vec2 cutCircle = coord - vec2(0.0, scale * 79);
    DrawSmoothCircle(RotateDot(cutCircle, coord, 120 - 120 * (sin(ColorModulator.a * PI - PI / 2) / 2.0 + 0.5)), scale * 38.0, backGroundColor, outputColor);
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