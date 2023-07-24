#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;
out vec4 mask;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    if(ivec3(Color.rgb * 255.0) == ivec3(239, 50, 61)) {
        vertexColor = vec4(0.0, 0.0, 0.0, Color.a);
    }
    else vertexColor = Color;
}
