#ifdef GL_ES
 precision mediump float;
#endif
attribute vec2 position;

uniform mat3 projectionMatrix;
uniform mat3 transformMatrix;
uniform mat3 objectMatrix;
uniform mat3 textureMatrix;

varying vec2 textureCoordinate;

void main()
{
    vec3 pos = vec3(position, 1.0);
    textureCoordinate = (textureMatrix * pos).xy;
    gl_Position = vec4(projectionMatrix * transformMatrix * objectMatrix * pos, 1.0);
}
