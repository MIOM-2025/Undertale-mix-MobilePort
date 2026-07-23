#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

uniform float spotX;
uniform float spotY;
uniform float size;
vec2 lightXY;

vec4 circle(vec2 xy, vec2 pos, float r, vec4 c) {
	float p = abs(distance(xy*iResolution.xy, pos*iResolution.xy));
    
    return vec4(step(p, r)) * c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy;
    vec2 xy = fragCoord/res;
	vec2 lightXY = vec2(spotX, spotY);
    
	vec4 texColor = circle(xy, lightXY, res.y/size, texture(iChannel0, xy));
    fragColor = texColor;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}