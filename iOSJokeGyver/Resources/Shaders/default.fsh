#version 300 es
#ifdef GL_ES
 precision highp float;
#endif
in vec2 textureCoordinate;

uniform sampler2D imgTexture;
uniform lowp int inkEffect;
uniform lowp vec4 blendColor;

out vec4 fragColor;

void main()
{
    lowp vec4 color = texture(imgTexture, textureCoordinate) * blendColor;

    if(inkEffect == 2)            //INVERT
        color.rgb = vec3(1.0,1.0,1.0)-color.rgb;
    else if(inkEffect == 10)    //MONO
    {
        float mono = 0.3125*color.r + 0.5625*color.g + 0.125*color.b;
        color.rgb = vec3(mono,mono,mono);
    }
    
    fragColor = color; //gl_FragColor
}
