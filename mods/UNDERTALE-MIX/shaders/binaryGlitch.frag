#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

uniform float iTime;
uniform float size;
//https://www.shadertoy.com/view/MlBSzR

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float x = uv.s;
    float y = uv.t;
    
    float glitchStrength = (size + 55.55)/iResolution.y * 5.0;
    
    float psize = 0.04 * glitchStrength;
    float psq = 1.0 / psize;

    float px = floor( x * psq + 0.5) * psize;
    float py = floor( y * psq + 0.5) * psize;
    
	vec4 colSnap = texture( iChannel0, vec2( px,py) );
    
	float lum = pow( 1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, glitchStrength );
    
    float qsize = psize * lum;
    
    float qsq = 1.0 / qsize;

    float qx = floor( x * qsq + 0.5) * qsize;
    float qy = floor( y * qsq + 0.5) * qsize;

    float rx = (px - qx) * lum + x;
    float ry = (py - qy) * lum + y;
    
	vec4 colMove = texture( iChannel0, vec2( rx,ry) );
    
    fragColor = colMove;
}



void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}