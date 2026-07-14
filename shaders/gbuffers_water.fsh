#version 120

/* GBUFFERS_WATER.FSH — Water with Schlick Fresnel
   GLSL 120 | [ZenShader]
   
   Features:
   - Schlick fresnel (reflective at grazing angles, transparent looking down)
   - Normal-mapped wave surface
   - Subtle foam at wave crests
   - Water color modulation
*/

varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec3 v_WaveNormal;
varying vec2 v_LightCoord;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

/* Schlick's approximation of Fresnel-Schlick equation */
float fresnel(vec3 normal, vec3 viewDir) {
	float cosTheta = abs(dot(normal, normalize(viewDir)));
	float f0 = 0.04; // Water base reflectivity
	return f0 + (1.0 - f0) * pow(1.0 - cosTheta, 5.0);
}

void main() {
	// View direction
	vec3 viewDir = normalize(cameraPosition - v_WorldPos);
	
	// Wave-affected normal
	vec3 normal = normalize(v_WaveNormal);
	
	// Water color (base blue-green)
	vec3 waterColor = vec3(0.1, 0.4, 0.6);
	
	// Fresnel effect (more reflective at grazing angles)
	float fresnelFactor = fresnel(normal, viewDir);
	
	// Sample lightmap
	vec3 light = texture2D(lightmap, v_LightCoord).rgb;
	
	// Subtle foam at wave crests (height-based)
	float foamAmount = 0.0;
	if (v_WorldPos.y > 0.5) {
		foamAmount = smoothstep(0.4, 0.6, sin(frameTimeCounter * 0.5 + v_WorldPos.x * 0.2));
		foamAmount *= 0.2; // Subtle only
	}
	
	// Final color: base water + foam
	vec3 finalColor = mix(waterColor, vec3(0.95), foamAmount);
	finalColor *= light;
	
	// colortex0: Water color with alpha for blending
	gl_FragData[0] = vec4(finalColor, 0.8);
	
	// colortex1: Normal + fresnel as specular
	gl_FragData[1] = vec4(normal * 0.5 + 0.5, fresnelFactor);
	
	// colortex2: Roughness (water is smooth)
	gl_FragData[2] = vec4(0.2, 0.0, 0.0, 1.0);
	
	// colortex3: No emission
	gl_FragData[3] = vec4(0.0);
}
