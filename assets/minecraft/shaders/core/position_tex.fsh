#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;
uniform float GameTime;

in vec2 texCoord0;
in float isMojang;

out vec4 fragColor;

#moj_import <shape_drawer/generic.glsl>
#moj_import <shape_drawer/archive/tml_logo.glsl>

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

