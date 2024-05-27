#version 300 es
#ifdef GL_ES
 precision highp float;
#endif
in vec2 position;

uniform mat3 projectionMatrix;
uniform mat3 transformMatrix;
uniform mat3 objectMatrix;
uniform mat3 textureMatrix;

out vec2 textureCoordinate;

void main()
{
    vec3 pos = vec3(position, 1);
    textureCoordinate = (textureMatrix * pos).xy;
    gl_Position = vec4(projectionMatrix * transformMatrix * objectMatrix * pos, 1);
}
