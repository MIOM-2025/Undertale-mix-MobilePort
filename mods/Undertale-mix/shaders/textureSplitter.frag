#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

uniform float ring1;
uniform float ring2;

uniform float push1;
uniform float push2;
const float diminish = 0.05;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    float time = iTime;
	vec2 uv = fragCoord.xy / iResolution.xy;
    float r1 = rand(floor(uv.yy*ring1 )/ring1);
    float r2 = rand(floor(uv.yy*ring2 )/ring2);

    r1 = -1.0 + 2.0 * r1;
    r2 = -1.0 + 2.0 * r2;
    
    r1 *= push1;
    r2 *= push2;
    
    r1 += r2;
    r1 *= diminish;
    
    
    vec4 tex = texture(iChannel0, uv + vec2(r1,0.0));
    if(uv.x+r1 > 1.0 || uv.x+r1 <= 0.0){
     fragColor = vec4(vec3(0.0), texture(iChannel0, fragCoord / iResolution.xy).a);   
    } else {
	 fragColor =tex;
    }
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}