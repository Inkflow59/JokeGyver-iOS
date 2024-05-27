#ifdef GL_ES
 precision mediump float;
#endif
varying vec2 textureCoordinate;

uniform sampler2D imgTexture;
uniform lowp int inkEffect;
uniform lowp vec4 blendColor;

uniform float fA;
uniform float fB;

uniform lowp int pDir;


void main()
{
    lowp vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
    mediump vec2 posTex;
    
    if(pDir != 0)
    {
        float ScreenX = (fA-(fA-fB)*(1.0-textureCoordinate.y));
        posTex = textureCoordinate * vec2(ScreenX, 1.0) + vec2((1.0-ScreenX)/2.0, 0.0);
        color = texture2D(imgTexture, posTex);
    }
    else
    {
        float ScreenY = (fA-(fA-fB)*textureCoordinate.x);
        posTex = textureCoordinate * vec2(1.0, ScreenY) + vec2(0.0, (1.0-ScreenY)/2.0);
        color = texture2D(imgTexture, posTex);
    }
    color = color * blendColor; //*vec4(1.0, 1.2, 1.5, 1.0);
    
    if(inkEffect == 2)          //INVERT
        color.rgb = vec3(1,1,1)-color.rgb;
    else if(inkEffect == 10)    //MONO
    {
        lowp float mono = 0.3125*color.r + 0.5625*color.g + 0.125*color.b;
        color.rgb = vec3(mono,mono,mono);
    }
    
    gl_FragColor = color; //glFragColor
}
