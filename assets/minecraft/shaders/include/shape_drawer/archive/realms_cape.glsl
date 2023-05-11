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