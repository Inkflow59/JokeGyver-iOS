#version 300 es
#ifdef GL_ES
 precision highp float;
#endif
in lowp vec2 position;

uniform mat3 projectionMatrix;
uniform mat3 transformMatrix;
uniform mat3 objectMatrix;
uniform mat4 colorMatrix;

out vec4 vColor;

void main()
{
    lowp vec4 colorA = colorMatrix[0];
    lowp vec4 colorB = colorMatrix[1];
    lowp vec4 colorC = colorMatrix[2];
    lowp vec4 colorD = colorMatrix[3];

    lowp vec4 hozA = mix(colorA, colorB, position.x);
    lowp vec4 hozB = mix(colorC, colorD, position.x);
    vColor = mix(hozA, hozB, position.y);

    vec3 pos = vec3(position, 1.0);
    gl_Position = vec4(projectionMatrix * transformMatrix * objectMatrix * pos, 1.0);
}
