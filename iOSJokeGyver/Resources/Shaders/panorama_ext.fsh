#ifdef GL_ES
 precision mediump float;
#endif
varying vec2 textureCoordinate;

uniform sampler2D imgTexture;
uniform lowp int inkEffect;
uniform lowp vec4 blendColor;

uniform float fB;
uniform lowp int pDir;


void main(void)
{
    vec4 color = vec4(0.0,0.0,0.0,1.0);
    float fC;
    vec2 posTex = vec2(0.0,0.0);
    if(pDir == 0)
    {
        fC = 1.0 + sin (textureCoordinate.s*3.1415)*fB - fB;
        posTex = ((textureCoordinate) * vec2(1.0, fC) + vec2(0.0, (1.0-fC)/2.0));
    }
    if(pDir == 1)
    {
        fC = 1.0 + sin (textureCoordinate.t*3.1415)*fB - fB;
        posTex = ((textureCoordinate) * vec2(fC, 1.0) + vec2((1.0-fC)/2.0, 0.0));
    }
    
    color = texture2D(imgTexture, posTex)*blendColor; //*vec4(1.0, 1.2, 1.5, 1.0);
    
    if(inkEffect == 2)          //INVERT
        color.rgb = vec3(1,1,1)-color.rgb;
    else if(inkEffect == 10)    //MONO
    {
        lowp float mono = 0.3125*color.r + 0.5625*color.g + 0.125*color.b;
        color.rgb = vec3(mono,mono,mono);
    }
    
    gl_FragColor = color; //gl_FragColor
}
