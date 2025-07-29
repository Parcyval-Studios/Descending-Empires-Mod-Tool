// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_URP_VFX_Pyro_MV_Emission_Dissolve"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_ErosionSmoothness("Erosion Smoothness", Float) = 1
		_EmissiveErosionSmoothness("Emissive Erosion Smoothness", Float) = 1
		_Specular("Specular", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_SmokeTint("Smoke Tint", Color) = (1,1,1,0)
		[Space(33)][Header(Depth Fade)][Space(13)]_DepthFadeLerp("Depth Fade Lerp", Float) = 1
		_DFEroSS("DF Ero SS", Float) = 0
		_DFEroSSS("DF Ero SSS", Float) = 1
		[Space(33)][Header(Flipbook)][Space(13)]_Flipbook("Flipbook", 2D) = "white" {}
		[Space(33)][Header(Motion Vector)][Space(13)]_MotionVector("Motion Vector", 2D) = "white" {}
		_FlipbookColumns("Flipbook Columns", Float) = 8
		_FlipbookRows("Flipbook Rows", Float) = 8
		_FlipbookSpeed("Flipbook Speed", Float) = 64
		_FlipbookStartFrame("Flipbook Start Frame", Float) = 0
		_MVInfluence("MV Influence", Float) = 0.003
		_MVOffsetFrame("MV Offset Frame", Float) = 1
		[Space(33)][Header(Emissive)][Space(13)]_EmissiveLUT("Emissive LUT", 2D) = "white" {}
		_EmissiveMult("Emissive Mult", Float) = 1
		_EmissiveTint("Emissive Tint", Color) = (1,1,1,0)
		_EmissiveHueShift("Emissive Hue Shift", Float) = 0
		_EmissiveLUTRange("Emissive LUT Range", Float) = 1
		_EmissiveLUTOffset("Emissive LUT Offset", Float) = 0
		[Space(33)][Header(Cam Depth Fade)][Space(13)]_CamDepthFadeLength("Cam Depth Fade Length", Float) = 1
		_CamDepthFadeOffset("Cam Depth Fade Offset", Float) = 0
		[Space(33)][Header(Fake SSS)][Space(13)]_FakeSubsurfaceScatteringSmokeBiasColor("Fake Subsurface Scattering Smoke Bias Color", Color) = (0,0,0,0)
		_FakeSubsurfaceScatteringSmokeBiasScale("Fake Subsurface Scattering Smoke Bias Scale", Float) = 0
		[Space(13)][Header(AR)][Space(13)]_Cull1("Cull", Float) = 2
		_Src1("Src", Float) = 5
		_Dst1("Dst", Float) = 10
		_ZWrite1("ZWrite", Float) = 0
		_ZTest1("ZTest", Float) = 2


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//[HideInInspector][ToggleUI] _AddPrecomputedVelocity("Add Precomputed Velocity", Float) = 1
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Lit" }

		Cull [_Cull1]
		ZWrite [_ZWrite1]
		ZTest [_ZTest1]
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend [_Src1] [_Dst1], SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite1]
			ZTest [_ZTest1]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_FORWARD

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD7;
				#endif	
				#if defined(USE_APV_PROBE_OCCLUSION)
					float4 probeOcclusion : TEXCOORD8;
				#endif
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
				float4 ase_texcoord10 : TEXCOORD10;
				float4 ase_texcoord11 : TEXCOORD11;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;
			sampler2D _EmissiveLUT;


			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord11.x = eyeDepth;
				
				output.ase_texcoord9 = input.texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord10 = input.texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord11.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif
				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.tSpace0 = float4( normalInput.normalWS, vertexInput.positionWS.x );
				output.tSpace1 = float4( normalInput.tangentWS, vertexInput.positionWS.y );
				output.tSpace2 = float4( normalInput.bitangentWS, vertexInput.positionWS.z );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				OUTPUT_SH4( vertexInput.positionWS, normalInput.normalWS.xyz, GetWorldSpaceNormalizeViewDir( vertexInput.positionWS ), output.lightmapUVOrVertexSH.xyz, output.probeOcclusion );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					output.lightmapUVOrVertexSH.zw = input.texcoord.xy;
					output.lightmapUVOrVertexSH.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				output.texcoord1 = input.texcoord1;
				output.texcoord2 = input.texcoord2;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (input.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( input.tSpace0.xyz );
					float3 WorldTangent = input.tSpace1.xyz;
					float3 WorldBiTangent = input.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = input.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 texCoord78 = input.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord9.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 temp_output_235_0 = ( _FakeSubsurfaceScatteringSmokeBiasColor * _FakeSubsurfaceScatteringSmokeBiasScale );
				
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float emissionDissolve213 = input.ase_texcoord10.x;
				float smoothstepResult216 = smoothstep( emissionDissolve213 , ( emissionDissolve213 + _EmissiveErosionSmoothness ) , break151.b);
				float2 temp_cast_3 = (( ( saturate( ( saturate( smoothstepResult216 ) * break151.g ) ) * _EmissiveLUTRange ) + _EmissiveLUTOffset )).xx;
				float3 hsvTorgb4_g5 = RGBToHSV( ( ( input.ase_color * tex2D( _EmissiveLUT, temp_cast_3 ) ) * _EmissiveTint ).rgb );
				float3 hsvTorgb8_g5 = HSVToRGB( float3(( hsvTorgb4_g5.x + _EmissiveHueShift ),( hsvTorgb4_g5.y + 0.0 ),( hsvTorgb4_g5.z + 0.0 )) );
				float emissionInt146 = input.ase_texcoord9.w;
				
				float3 temp_cast_7 = (_Specular).xxx;
				
				float eyeDepth = input.ase_texcoord11.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord10.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float3 BaseColor = ( ( _SmokeTint * saturate( break151.r ) ) + temp_output_235_0 ).rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = ( float4( ( temp_output_182_0 * ( ( saturate( hsvTorgb8_g5 ) * emissionInt146 ) * _EmissiveMult ) ) , 0.0 ) + temp_output_235_0 ).rgb;
				float3 Specular = temp_cast_7;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = input.positionCS;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = input.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = input.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, input.dynamicLightmapUV.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
					inputData.bakedGI = SAMPLE_GI( SH, GetAbsolutePositionWS(inputData.positionWS),
						inputData.normalWS,
						inputData.viewDirectionWS,
						input.positionCS.xy,
						input.probeOcclusion,
						inputData.shadowMask );
				#else
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
				#endif

				#ifdef _ASE_LIGHTING_SIMPLE
					half4 color = UniversalFragmentBlinnPhong( inputData, surfaceData);
				#else
					half4 color = UniversalFragmentPBR( inputData, surfaceData);
				#endif

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					#define SUM_LIGHT_TRANSMISSION(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 transmission = max( 0, -dot( inputData.normalWS, Light.direction ) ) * atten * Transmission;\
						color.rgb += BaseColor * transmission;

					SUM_LIGHT_TRANSMISSION( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSMISSION( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSMISSION( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#define SUM_LIGHT_TRANSLUCENCY(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 lightDir = Light.direction + inputData.normalWS * normal;\
						half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );\
						half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;\
						color.rgb += BaseColor * translucency * strength;

					SUM_LIGHT_TRANSLUCENCY( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSLUCENCY( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSLUCENCY( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), input.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, input.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif				
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			float3 _LightDirection;
			float3 _LightPosition;

			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord3 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord5 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = positionCS;
				output.clipPosV = positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(	PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 texCoord78 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord3.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord5.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord3 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord5 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(	PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 texCoord78 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord3.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord5.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma shader_feature EDITOR_VISUALIZATION

			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD2;
					float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;
			sampler2D _EmissiveLUT;


			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord5 = screenPos;
				
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord7.x = eyeDepth;
				
				output.ase_texcoord4 = input.texcoord0;
				output.ase_color = input.ase_color;
				output.ase_texcoord6 = input.texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord7.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = positionWS;
				#endif

				output.positionCS = MetaVertexPosition( input.positionOS, input.texcoord1.xy, input.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(input.positionOS.xyz, input.texcoord0.xy, input.texcoord1.xy, input.texcoord2.xy, VizUV, LightCoord);
					output.VizUV = float4(VizUV, 0, 0);
					output.LightCoord = LightCoord;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = output.positionCS;
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.texcoord0 = input.texcoord0;
				output.texcoord1 = input.texcoord1;
				output.texcoord2 = input.texcoord2;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 texCoord78 = input.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord4.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 temp_output_235_0 = ( _FakeSubsurfaceScatteringSmokeBiasColor * _FakeSubsurfaceScatteringSmokeBiasScale );
				
				float4 screenPos = input.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float emissionDissolve213 = input.ase_texcoord6.x;
				float smoothstepResult216 = smoothstep( emissionDissolve213 , ( emissionDissolve213 + _EmissiveErosionSmoothness ) , break151.b);
				float2 temp_cast_3 = (( ( saturate( ( saturate( smoothstepResult216 ) * break151.g ) ) * _EmissiveLUTRange ) + _EmissiveLUTOffset )).xx;
				float3 hsvTorgb4_g5 = RGBToHSV( ( ( input.ase_color * tex2D( _EmissiveLUT, temp_cast_3 ) ) * _EmissiveTint ).rgb );
				float3 hsvTorgb8_g5 = HSVToRGB( float3(( hsvTorgb4_g5.x + _EmissiveHueShift ),( hsvTorgb4_g5.y + 0.0 ),( hsvTorgb4_g5.z + 0.0 )) );
				float emissionInt146 = input.ase_texcoord4.w;
				
				float eyeDepth = input.ase_texcoord7.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord6.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float3 BaseColor = ( ( _SmokeTint * saturate( break151.r ) ) + temp_output_235_0 ).rgb;
				float3 Emission = ( float4( ( temp_output_182_0 * ( ( saturate( hsvTorgb8_g5 ) * emissionInt146 ) * _EmissiveMult ) ) , 0.0 ) + temp_output_235_0 ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = input.VizUV.xy;
					metaInput.LightCoord = input.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend [_Src1] [_Dst1], SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite1]
			ZTest [_ZTest1]
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_TRANSFER_INSTANCE_ID( input, output );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord2 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord5 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;

				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 texCoord78 = input.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord2.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 temp_output_235_0 = ( _FakeSubsurfaceScatteringSmokeBiasColor * _FakeSubsurfaceScatteringSmokeBiasScale );
				
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord5.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float3 BaseColor = ( ( _SmokeTint * saturate( break151.r ) ) + temp_output_235_0 ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
			//#define SHADERPASS SHADERPASS_DEPTHNORMALS

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldTangent : TEXCOORD2;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD3;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD4;
				#endif
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord6.x = eyeDepth;
				
				output.ase_texcoord5 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord7 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				float3 normalWS = TransformObjectToWorldNormal( input.normalOS );
				float4 tangentWS = float4( TransformObjectToWorldDir( input.tangentOS.xyz ), input.tangentOS.w );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = vertexInput.positionWS;
				#endif

				output.worldNormal = normalWS;
				output.worldTangent = tangentWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			void frag(	PackedVaryings input
						, out half4 outNormalWS : SV_Target0
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float3 WorldNormal = input.worldNormal;
				float4 WorldTangent = input.worldTangent;

				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 texCoord78 = input.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord5.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord6.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord7.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float3 Normal = float3(0, 0, 1);
				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(WorldNormal);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float crossSign = (WorldTangent.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
							float3 bitangent = crossSign * cross(WorldNormal.xyz, WorldTangent.xyz);
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent.xyz, bitangent, WorldNormal.xyz));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = WorldNormal;
					#endif
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend [_Src1] [_Dst1], SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite1]
			ZTest [_ZTest1]
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_GBUFFER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif
			
			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				#if defined(USE_APV_PROBE_OCCLUSION)
					float4 probeOcclusion : TEXCOORD8;
				#endif
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
				float4 ase_texcoord10 : TEXCOORD10;
				float4 ase_texcoord11 : TEXCOORD11;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;
			sampler2D _EmissiveLUT;


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord11.x = eyeDepth;
				
				output.ase_texcoord9 = input.texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord10 = input.texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord11.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.tSpace0 = float4( normalInput.normalWS, vertexInput.positionWS.x);
				output.tSpace1 = float4( normalInput.tangentWS, vertexInput.positionWS.y);
				output.tSpace2 = float4( normalInput.bitangentWS, vertexInput.positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				OUTPUT_SH4( vertexInput.positionWS, normalInput.normalWS.xyz, GetWorldSpaceNormalizeViewDir( vertexInput.positionWS ), output.lightmapUVOrVertexSH.xyz, output.probeOcclusion );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					output.lightmapUVOrVertexSH.zw = input.texcoord.xy;
					output.lightmapUVOrVertexSH.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );

				output.fogFactorAndVertexLight = half4(0, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				output.texcoord1 = input.texcoord1;
				output.texcoord2 = input.texcoord2;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			FragmentOutput frag ( PackedVaryings input
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (input.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( input.tSpace0.xyz );
					float3 WorldTangent = input.tSpace1.xyz;
					float3 WorldBiTangent = input.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = input.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 texCoord78 = input.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord9.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 temp_output_235_0 = ( _FakeSubsurfaceScatteringSmokeBiasColor * _FakeSubsurfaceScatteringSmokeBiasScale );
				
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float emissionDissolve213 = input.ase_texcoord10.x;
				float smoothstepResult216 = smoothstep( emissionDissolve213 , ( emissionDissolve213 + _EmissiveErosionSmoothness ) , break151.b);
				float2 temp_cast_3 = (( ( saturate( ( saturate( smoothstepResult216 ) * break151.g ) ) * _EmissiveLUTRange ) + _EmissiveLUTOffset )).xx;
				float3 hsvTorgb4_g5 = RGBToHSV( ( ( input.ase_color * tex2D( _EmissiveLUT, temp_cast_3 ) ) * _EmissiveTint ).rgb );
				float3 hsvTorgb8_g5 = HSVToRGB( float3(( hsvTorgb4_g5.x + _EmissiveHueShift ),( hsvTorgb4_g5.y + 0.0 ),( hsvTorgb4_g5.z + 0.0 )) );
				float emissionInt146 = input.ase_texcoord9.w;
				
				float3 temp_cast_7 = (_Specular).xxx;
				
				float eyeDepth = input.ase_texcoord11.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord10.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float3 BaseColor = ( ( _SmokeTint * saturate( break151.r ) ) + temp_output_235_0 ).rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = ( float4( ( temp_output_182_0 * ( ( saturate( hsvTorgb8_g5 ) * emissionInt146 ) * _EmissiveMult ) ) , 0.0 ) + temp_output_235_0 ).rgb;
				float3 Specular = temp_cast_7;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = input.positionCS;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = WorldNormal;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( WorldViewDirection );

				inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = input.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, input.dynamicLightmapUV.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
					inputData.bakedGI = SAMPLE_GI( SH, GetAbsolutePositionWS(inputData.positionWS),
						inputData.normalWS,
						inputData.viewDirectionWS,
						input.positionCS.xy,
						input.probeOcclusion,
						inputData.shadowMask );
				#else
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(input.positionCS,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData
				(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord1 = screenPos;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );

				output.positionCS = TransformWorldToHClip(positionWS);

				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 texCoord78 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 screenPos = input.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord3.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				surfaceDescription.Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord1 = screenPos;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				output.positionCS = TransformWorldToHClip(positionWS);

				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.vertex = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].vertex, input[1].vertex, input[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 texCoord78 = input.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 screenPos = input.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord3.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				surfaceDescription.Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
						clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "MotionVectors"
			Tags { "LightMode"="MotionVectors" }

			ColorMask RG

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_SRP_VERSION 170003
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif
	
            #define SHADERPASS SHADERPASS_MOTION_VECTORS

            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
		    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
			#endif

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MotionVectorsCommon.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 positionOld : TEXCOORD4;
				#if _ADD_PRECOMPUTED_VELOCITY
					float3 alembicMotionVector : TEXCOORD5;
				#endif
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 positionCSNoJitter : TEXCOORD0;
				float4 previousPositionCSNoJitter : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _SmokeTint;
			float4 _EmissiveTint;
			float4 _FakeSubsurfaceScatteringSmokeBiasColor;
			float _Cull1;
			float _CamDepthFadeLength;
			float _Smoothness;
			float _Specular;
			float _EmissiveMult;
			float _EmissiveHueShift;
			float _EmissiveLUTOffset;
			float _EmissiveLUTRange;
			float _EmissiveErosionSmoothness;
			float _DepthFadeLerp;
			float _DFEroSSS;
			float _FakeSubsurfaceScatteringSmokeBiasScale;
			float _CamDepthFadeOffset;
			float _MVOffsetFrame;
			float _MVInfluence;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _DFEroSS;
			float _ErosionSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_texcoord2 = input.ase_texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord5 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(APLICATION_SPACE_WARP_MOTION)
					// We do not need jittered position in ASW
					output.positionCSNoJitter = mul(_NonJitteredViewProjMatrix, mul(UNITY_MATRIX_M, input.positionOS));;
					output.positionCS = output.positionCSNoJitter;
				#else
					// Jittered. Match the frame.
					output.positionCS = vertexInput.positionCS;
					output.positionCSNoJitter = mul( _NonJitteredViewProjMatrix, mul( UNITY_MATRIX_M, input.positionOS));
				#endif

				float4 prevPos = ( unity_MotionVectorsParams.x == 1 ) ? float4( input.positionOld, 1 ) : input.positionOS;

				#if _ADD_PRECOMPUTED_VELOCITY
					prevPos = prevPos - float4(input.alembicMotionVector, 0);
				#endif

				output.previousPositionCSNoJitter = mul( _PrevViewProjMatrix, mul( UNITY_PREV_MATRIX_M, prevPos ) );

				ApplyMotionVectorZBias( output.positionCS );
				return output;
			}

			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}

			half4 frag(	PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float2 texCoord78 = input.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float time144 = input.ase_texcoord2.z;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				half2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				half2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float smoothstepResult200 = smoothstep( _DFEroSS , ( _DFEroSS + _DFEroSSS ) , break151.r);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( smoothstepResult200 ) );
				float lerpResult237 = lerp( 1.0 , distanceDepth176 , _DepthFadeLerp);
				float temp_output_182_0 = saturate( ( saturate( break151.a ) * lerpResult237 ) );
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float ero224 = input.ase_texcoord5.y;
				float smoothstepResult225 = smoothstep( ero224 , ( ero224 + _ErosionSmoothness ) , break151.g);
				

				float Alpha = saturate( ( saturate( ( saturate( ( temp_output_182_0 * input.ase_color.a ) ) * camFade208 ) ) * saturate( smoothstepResult225 ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(APLICATION_SPACE_WARP_MOTION)
					return float4( CalcAswNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 1 );
				#else
					return float4( CalcNdcMotionVectorFromCsPositions( input.positionCSNoJitter, input.previousPositionCSNoJitter ), 0, 0 );
				#endif
			}		
			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.TexCoordVertexDataNode;106;-5504,1536;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-5120,1664;Inherit;False;time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-5504,1280;Inherit;False;Property;_MVOffsetFrame;MV Offset Frame;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-5504,1152;Inherit;False;144;time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-5504,384;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;-5504,640;Inherit;False;Property;_FlipbookColumns;Flipbook Columns;10;0;Create;True;0;0;0;False;0;False;8;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-5504,768;Inherit;False;Property;_FlipbookRows;Flipbook Rows;11;0;Create;True;0;0;0;False;0;False;8;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-5504,512;Inherit;False;Property;_FlipbookStartFrame;Flipbook Start Frame;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-5504,896;Inherit;False;Property;_FlipbookSpeed;Flipbook Speed;12;0;Create;True;0;0;0;False;0;False;64;64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-5248,1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-5120,640;Inherit;False;144;time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;134;-5120,1024;Inherit;False;0;0;7;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;-1;False;4;FLOAT2;0;FLOAT;1;FLOAT;2;INT;3
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;82;-5120,384;Inherit;False;0;0;7;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;-1;False;4;FLOAT2;0;FLOAT;1;FLOAT;2;INT;3
Node;AmplifyShaderEditor.TexturePropertyNode;74;-4736,0;Inherit;True;Property;_MotionVector;Motion Vector;9;0;Create;True;0;0;0;False;3;Space(33);Header(Motion Vector);Space(13);False;ef0125a275e5556439e96d9915ff3993;ef0125a275e5556439e96d9915ff3993;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;121;-4736,1024;Inherit;True;Property;_TextureSample2;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;84;-4736,384;Inherit;True;Property;_TextureSample1;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;136;-4096,768;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-3584,640;Inherit;False;144;time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;123;-4352,1024;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;122;-4352,384;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-4096,384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-3840,768;Inherit;False;Constant;_Float1;Float 1;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;140;-3584,768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-4096,1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;126;-3840,384;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;127;-3840,1024;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;141;-3584,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-3584,384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-3328,768;Inherit;False;Property;_MVInfluence;MV Influence;14;0;Create;True;0;0;0;False;0;False;0.003;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-3584,1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-3328,384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-3328,1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-3072,1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;133;-3072,256;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;72;-3200,-256;Inherit;True;Property;_Flipbook;Flipbook;8;0;Create;True;0;0;0;False;3;Space(33);Header(Flipbook);Space(13);False;40c577513a2966146a51d3a2cd119743;40c577513a2966146a51d3a2cd119743;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;83;-2816,0;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;132;-2816,1024;Inherit;True;Property;_TextureSample3;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;150;-2432,0;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-2048,1376;Inherit;False;Property;_DFEroSSS;DF Ero SSS;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-2048,1280;Inherit;False;Property;_DFEroSS;DF Ero SS;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;151;-2176,0;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-1888,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;200;-1664,1280;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;176;-1488,1280;Inherit;False;True;True;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-1408,896;Inherit;False;Constant;_Float2;Float 2;30;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;-1408,1024;Inherit;False;Property;_DepthFadeLerp;Depth Fade Lerp;5;0;Create;True;0;0;0;False;3;Space(33);Header(Depth Fade);Space(13);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;-1152,2560;Inherit;False;Property;_CamDepthFadeLength;Cam Depth Fade Length;22;0;Create;True;0;0;0;False;3;Space(33);Header(Cam Depth Fade);Space(13);False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-1152,2688;Inherit;False;Property;_CamDepthFadeOffset;Cam Depth Fade Offset;23;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;105;-1408,640;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;237;-1152,768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;206;-1152,2432;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-1152,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;212;-5504,1920;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;37;-1536,-384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;207;-896,2432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;182;-896,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;-5120,2048;Inherit;False;ero;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-896,256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-640,2432;Inherit;False;camFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-1152,1152;Inherit;False;Property;_ErosionSmoothness;Erosion Smoothness;0;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-1152,1024;Inherit;False;224;ero;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;165;-640,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-512,384;Inherit;False;208;camFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-896,1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-512,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;225;-896,1024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;209;-256,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;227;-720,1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;459.26,31.68577;Inherit;False;1238;166;Auto Register Variables;5;54;53;52;51;50;Lush was here! <3;0.4872068,0.2971698,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-512,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;90;-1792,0;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;507.2599,79.68589;Inherit;False;Property;_Cull1;Cull;26;0;Create;True;0;0;0;True;3;Space(13);Header(AR);Space(13);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;763.2599,79.68589;Inherit;False;Property;_Src1;Src;27;0;Create;True;0;0;0;True;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;1019.26,79.68589;Inherit;False;Property;_Dst1;Dst;28;0;Create;True;0;0;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;1531.26,79.68589;Inherit;False;Property;_ZTest1;ZTest;30;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;1275.26,79.68589;Inherit;False;Property;_ZWrite1;ZWrite;29;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-640,0;Inherit;False;Property;_Specular;Specular;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-640,128;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;119;-1536,-768;Inherit;False;Property;_SmokeTint;Smoke Tint;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-768,-384;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-5120,1792;Inherit;False;emissionInt;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-5120,1920;Inherit;False;emissionDissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-256,1536;Inherit;False;Property;_EmissiveMult;Emissive Mult;17;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;113;-1536,1664;Inherit;True;Property;_EmissiveLUT;Emissive LUT;16;0;Create;True;0;0;0;False;3;Space(33);Header(Emissive);Space(13);False;-1;f57767c513f8ca64dbef45a46c4349a2;f57767c513f8ca64dbef45a46c4349a2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-896,1664;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-640,1808;Inherit;False;Property;_EmissiveHueShift;Emissive Hue Shift;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;116;-640,1664;Inherit;False;HueShift;-1;;5;9f07e9ddd8ab81c47b3582f22189b65b;0;4;14;COLOR;0,0,0,0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;118;-896,1792;Inherit;False;Property;_EmissiveTint;Emissive Tint;18;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1152,1664;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;-1792,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-1792,1792;Inherit;False;Property;_EmissiveLUTOffset;Emissive LUT Offset;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;-128,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-256,1792;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-256,1664;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-256,1920;Inherit;False;146;emissionInt;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-2048,1792;Inherit;False;Property;_EmissiveLUTRange;Emissive LUT Range;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-2048,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-2048,640;Inherit;False;213;emissionDissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;112;-2304,1664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-2304,1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;222;-256,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;216;-1792,640;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;-1792,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;219;-1616,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-2048,896;Inherit;False;Property;_EmissiveErosionSmoothness;Emissive Erosion Smoothness;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;230;-128,1024;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;234;-384,-384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;-80,768;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;236;-384,928;Inherit;False;Property;_FakeSubsurfaceScatteringSmokeBiasScale;Fake Subsurface Scattering Smoke Bias Scale;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;233;-384,768;Inherit;False;Property;_FakeSubsurfaceScatteringSmokeBiasColor;Fake Subsurface Scattering Smoke Bias Color;24;0;Create;True;0;0;0;False;3;Space(33);Header(Fake SSS);Space(13);False;0,0,0,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;91;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;92;0,0;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;Vefects/SH_Vefects_URP_VFX_Pyro_MV_Emission_Dissolve;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;21;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_Cull1;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;True;_ZWrite1;True;3;True;_ZTest1;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;True;4;True;12;all;0;True;True;1;5;True;_Src1;10;True;_Dst1;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_ZWrite1;True;3;True;_ZTest1;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;44;Lighting Model;0;0;Workflow;0;638489975902210172;Surface;1;638489974111807992;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;Receive SSAO;1;0;Motion Vectors;1;0;  Add Precomputed Velocity;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;11;False;True;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;93;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;94;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;95;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;96;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;5;True;_Src1;10;True;_Dst1;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;True;;True;3;True;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;5;True;_Src1;10;True;_Dst1;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;True;;True;3;True;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;99;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;100;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;241;0,100;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;MotionVectors;0;10;MotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=MotionVectors;False;False;0;;0;0;Standard;0;False;0
WireConnection;144;0;106;3
WireConnection;86;0;143;0
WireConnection;86;1;142;0
WireConnection;134;0;78;0
WireConnection;134;1;77;0
WireConnection;134;2;76;0
WireConnection;134;3;79;0
WireConnection;134;4;80;0
WireConnection;134;5;86;0
WireConnection;82;0;78;0
WireConnection;82;1;77;0
WireConnection;82;2;76;0
WireConnection;82;3;79;0
WireConnection;82;4;80;0
WireConnection;82;5;148;0
WireConnection;121;0;74;0
WireConnection;121;1;134;0
WireConnection;84;0;74;0
WireConnection;84;1;82;0
WireConnection;123;0;121;0
WireConnection;122;0;84;0
WireConnection;125;0;122;0
WireConnection;125;1;136;0
WireConnection;140;0;149;0
WireConnection;124;0;123;0
WireConnection;124;1;136;0
WireConnection;126;0;125;0
WireConnection;126;1;137;0
WireConnection;127;0;124;0
WireConnection;127;1;137;0
WireConnection;141;0;140;0
WireConnection;129;0;126;0
WireConnection;129;1;140;0
WireConnection;128;0;127;0
WireConnection;128;1;141;0
WireConnection;131;0;129;0
WireConnection;131;1;138;0
WireConnection;130;0;128;0
WireConnection;130;1;138;0
WireConnection;135;0;130;0
WireConnection;135;1;134;0
WireConnection;133;0;82;0
WireConnection;133;1;131;0
WireConnection;83;0;72;0
WireConnection;83;1;133;0
WireConnection;132;0;72;0
WireConnection;132;1;135;0
WireConnection;150;0;83;0
WireConnection;150;1;132;0
WireConnection;150;2;140;0
WireConnection;151;0;150;0
WireConnection;202;0;201;0
WireConnection;202;1;203;0
WireConnection;200;0;151;0
WireConnection;200;1;201;0
WireConnection;200;2;202;0
WireConnection;176;0;200;0
WireConnection;105;0;151;3
WireConnection;237;0;238;0
WireConnection;237;1;176;0
WireConnection;237;2;240;0
WireConnection;206;0;204;0
WireConnection;206;1;205;0
WireConnection;177;0;105;0
WireConnection;177;1;237;0
WireConnection;207;0;206;0
WireConnection;182;0;177;0
WireConnection;224;0;212;2
WireConnection;104;0;182;0
WireConnection;104;1;37;4
WireConnection;208;0;207;0
WireConnection;165;0;104;0
WireConnection;226;0;229;0
WireConnection;226;1;228;0
WireConnection;211;0;165;0
WireConnection;211;1;210;0
WireConnection;225;0;151;1
WireConnection;225;1;229;0
WireConnection;225;2;226;0
WireConnection;209;0;211;0
WireConnection;227;0;225;0
WireConnection;223;0;209;0
WireConnection;223;1;227;0
WireConnection;90;0;151;0
WireConnection;120;0;119;0
WireConnection;120;1;90;0
WireConnection;146;0;106;4
WireConnection;213;0;212;1
WireConnection;113;1;171;0
WireConnection;115;0;89;0
WireConnection;115;1;118;0
WireConnection;116;14;115;0
WireConnection;116;15;117;0
WireConnection;89;0;37;0
WireConnection;89;1;113;0
WireConnection;171;0;173;0
WireConnection;171;1;172;0
WireConnection;199;0;182;0
WireConnection;199;1;61;0
WireConnection;114;0;116;0
WireConnection;114;1;147;0
WireConnection;61;0;114;0
WireConnection;61;1;62;0
WireConnection;173;0;112;0
WireConnection;173;1;174;0
WireConnection;112;0;220;0
WireConnection;220;0;219;0
WireConnection;220;1;151;1
WireConnection;222;0;223;0
WireConnection;216;0;151;2
WireConnection;216;1;218;0
WireConnection;216;2;215;0
WireConnection;215;0;218;0
WireConnection;215;1;217;0
WireConnection;219;0;216;0
WireConnection;230;0;199;0
WireConnection;230;1;235;0
WireConnection;234;0;120;0
WireConnection;234;1;235;0
WireConnection;235;0;233;0
WireConnection;235;1;236;0
WireConnection;92;0;234;0
WireConnection;92;2;230;0
WireConnection;92;9;107;0
WireConnection;92;4;108;0
WireConnection;92;6;222;0
ASEEND*/
//CHKSM=F7099D5E0799791211E0A3471464160E0F895B46