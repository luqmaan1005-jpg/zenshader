#version 120

/* GBUFFERS_TERRAIN.FSH — Main terrain fragment shader
   GLSL 120 | [ZenShader]
   
   Outputs to gbuffers:
   - colortex0 (RGBA16F): Diffuse color + block light
   - colortex1 (RGBA16F): Normal + material flags
   - colortex2 (RGBA16F): Specular intensity + roughness
   - colortex3 (RGBA8): Emissive / glow mask
*/

varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec2 v_LightCoord;
varying vec3 v_BlockData;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float frameTimeCounter;

/* Material lookup based on block ID */
vec3 getBlockMaterial(float blockId) {
	// blockId.x = specular, blockId.y = roughness, blockId.z = emission
	
	if (blockId < 1.5) return vec3(0.15, 0.95, 0.0); // Stone
	if (blockId < 2.5) return vec3(0.0, 1.0, 0.0);   // Dirt
	if (blockId < 3.5) return vec3(0.1, 0.85, 0.0);  // Wood
	if (blockId < 4.5) return vec3(0.12, 0.80, 0.0); // Planks
	if (blockId < 5.5) return vec3(0.5, 0.1, 0.0);   // Glass/Smooth stone
	if (blockId < 6.5) return vec3(0.6, 0.3, 0.0);   // Iron
	if (blockId < 7.5) return vec3(0.7, 0.25, 0.0);  // Gold
	if (blockId < 8.5) return vec3(0.65, 0.15, 0.0); // Quartz
	if (blockId < 9.5) return vec3(0.0, 0.0, 0.95);  // Lava (emissive)
	
	// Default
	return vec3(0.05, 0.9, 0.0);
}

void main() {
	// Sample diffuse texture
	vec4 texColor = texture2D(texture, v_TexCoord);
	
	// Apply vertex color (biome tint, etc.)
	vec3 diffuse = texColor.rgb * v_Color.rgb;
	
	// Sample lightmap
	vec3 lightSample = texture2D(lightmap, v_LightCoord).rgb;
	
	// Apply block & sky light
	diffuse *= lightSample;
	
	// Get material properties from block ID
	vec3 material = getBlockMaterial(v_BlockData.x);
	float specular = material.x;
	float roughness = material.y;
	float emission = material.z;
	
	// Encode normal to [0,1]
	vec3 normal = normalize(v_Normal) * 0.5 + 0.5;
	
	// colortex0: Diffuse + block light
	gl_FragData[0] = vec4(diffuse, texColor.a);
	
	// colortex1: Normal + specular flag
	gl_FragData[1] = vec4(normal, specular);
	
	// colortex2: Roughness + metallic
	gl_FragData[2] = vec4(roughness, 0.0, 0.0, 1.0);
	
	// colortex3: Emission / glow
	gl_FragData[3] = vec4(emission, 0.0, 0.0, 1.0);
}
