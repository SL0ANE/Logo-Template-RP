#version 150

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;
uniform vec2 ScreenSize;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec2 texCoord0;
out float depth;
out float isMojang;

float vertexId = mod(gl_VertexID, 4.0);
vec2 atlasSize = textureSize(Sampler0, 0);
vec2 onepixel = 1./atlasSize;
#define markerCoord vec2(0.0f, onepixel.y * 11.0f)

//检查贴图上的固定位置的半透明像素是不是符合某个值来判断是否为mojangLogo

float isMojangLogo() {
    float flag = 0.0;

    if(atlasSize.x == 512.0) {
        vec4 testMarker = textureLod(Sampler0, markerCoord, 0);
        if(testMarker.a > 0.07 && testMarker.a < 0.08) {
            flag = 1.0;
            if(UV0.y > 0.5) return -1.0;
            else if((vertexId == 0.0 || vertexId == 3.0) && UV0.y == 0.5) return -1.0;
        }
    }

    return flag;
}

void main() {
    vec3 _Position = Position;
    isMojang = isMojangLogo();
    if(isMojang > 0.0) {
        if(vertexId == 1.0) {
            _Position.x -= ScreenSize.x * 0.5;
            _Position.y += ScreenSize.y * 0.5;
        }
        else if(vertexId == 2.0) {
            _Position.x += ScreenSize.x;
            _Position.y += ScreenSize.y * 0.5;
        }
        else if(vertexId == 3.0) {
            _Position.x += ScreenSize.x;
            _Position.y -= ScreenSize.y * 0.5;
        }
        else if(vertexId == 0.0) {
            _Position.x -= ScreenSize.x;
            _Position.y -= ScreenSize.y * 0.5;
        }
    }

    gl_Position = ProjMat * ModelViewMat * vec4(_Position, 1.0);
    depth = Position.z;

    texCoord0 = UV0;
}
