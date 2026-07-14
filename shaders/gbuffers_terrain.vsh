#version 120

/* GBUFFERS_TERRAIN.VSH — Main terrain vertex shader
   GLSL 120 | [ZenShader]
   
   Outputs:
   - Position, normal, UV, light coords for lighting calculations
   - Packed material info for deferred pass
*/

attribute vec3 mc_Entity;
attribute vec2 mc_midTexCoord;

varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec2 v_LightCoord;
varying vec4 v_ShadowCoord;
varying vec3 v_BlockData;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

void main() {
	// Basic vertex transform
	vec4 viewPos = gbufferModelView * vec4(gl_Vertex, 1.0);
	gl_Position = gbufferProjection * viewPos;
	
	// World position (for later calculations)
	v_WorldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;
	
	// Normal to view space
	v_Normal = normalize(mat3(gbufferModelView) * gl_Normal);
	
	// UV coordinates
	v_TexCoord = gl_MultiTexCoord0.xy;
	
	// Light map (sky & block light)
	v_LightCoord = gl_MultiTexCoord1.xy / 16.0;
	
	// Vertex color (used for biome tinting, etc.)
	v_Color = gl_Color;
	
	// Block ID passed from entity attribute
	v_BlockData.x = mc_Entity.x;
	v_BlockData.y = mc_Entity.y;
	v_BlockData.z = mc_Entity.z;
}
