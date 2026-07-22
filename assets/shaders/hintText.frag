#pragma header
uniform float iTime;
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) * 2.0 - 1.0;
}

float offset(float blocks, vec2 uv) {
	return rand(vec2(iTime, floor(uv.y * blocks)));
}

void main()
{
	vec2 uv = openfl_TextureCoordv;
	float r = flixel_texture2D(bitmap, uv + vec2(offset(16.0, uv) * 0.03, 0.0)).r;	
	float g = flixel_texture2D(bitmap, uv + vec2(offset(8.0, uv) * 0.03 * 0.16666666, 0.0)).g;
	float b = flixel_texture2D(bitmap, uv + vec2(offset(8.0, uv) * 0.03, 0.0)).b;
	float alpha = (r+g+b)/3.;
	vec3 color = vec3(r,g,b);
	
    gl_FragColor = vec4(color,alpha);
    

}