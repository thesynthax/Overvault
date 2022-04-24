// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ANGRYMESH/Nature Pack/URP/Tree Leaf"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Cutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		[Header(Base)]_Glossiness("Base Smoothness", Range( 0 , 1)) = 0.5
		_OcclusionStrength("Base Tree AO", Range( 0 , 1)) = 0.5
		_BumpScale("Base Normal Intensity", Range( 0 , 2)) = 1
		_Color("Base Color", Color) = (1,1,1,1)
		[NoScaleOffset]_MainTex("Base Albedo (A Opacity)", 2D) = "gray" {}
		[NoScaleOffset][Normal]_BumpMap("Base NormalMap", 2D) = "bump" {}
		[Header(Backface)]_BackFaceColor("Back Face Color", Color) = (1,1,1,0)
		[Header(Tint Color)]_TintColor1("Tint Color 1", Color) = (1,1,1,0)
		_TintColor2("Tint Color 2", Color) = (1,1,1,0)
		_TintNoiseTile("Tint Noise Tile", Range( 0.001 , 30)) = 10
		[Header(Wind Trunk (use common settings for both materials))]_WindTrunkAmplitude("Wind Trunk Amplitude", Range( 0 , 3)) = 1
		_WindTrunkStiffness("Wind Trunk Stiffness", Range( 1 , 3)) = 3
		[Header(Wind Leaf)]_WindLeafAmplitude("Wind Leaf Amplitude", Range( 0 , 3)) = 1
		_WindLeafSpeed("Wind Leaf Speed", Range( 0 , 10)) = 2
		_WindLeafScale("Wind Leaf Scale", Range( 0 , 30)) = 15
		_WindLeafStiffness("Wind Leaf Stiffness", Range( 0 , 2)) = 0
		[ASEEnd][Header(Translucency)]_Strenght1("Strenght", Range( 0 , 10)) = 1.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Strength", Range( 0, 50 ) ) = 1
		_TransNormal( "Normal Distortion", Range( 0, 1 ) ) = 0.5
		_TransScattering( "Scattering", Range( 1, 50 ) ) = 2
		_TransDirect( "Direct", Range( 0, 1 ) ) = 0.9
		_TransAmbient( "Ambient", Range( 0, 1 ) ) = 0.1
		_TransShadow( "Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Off
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 3.0

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
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#define _TRANSLUCENCY_ASE 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#include "VS_indirect.cginc"
			#pragma multi_compile GPU_FRUSTUM_ON __
			#pragma instancing_options procedural:setup


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TintColor1;
			half4 _TintColor2;
			half4 _BackFaceColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _WindLeafScale;
			half _WindLeafSpeed;
			half _WindLeafAmplitude;
			half _WindLeafStiffness;
			half _TintNoiseTile;
			half _BumpScale;
			half _Glossiness;
			half _OcclusionStrength;
			half _Cutoff;
			half _Strenght1;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D AG_TintNoiseTexture;
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;
			half AG_TintNoiseTile;
			half AG_TintNoiseContrast;
			half AG_TintToggle;
			sampler2D _BumpMap;
			half AG_TreesAO;
			half AG_TranslucencyIntensity;
			half AG_TranslucencyDistance;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g124 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g124 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g124 = _TimeParameters.x * temp_output_101_0_g124;
				float temp_output_73_0_g124 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red1622 = v.ase_color.r;
				float temp_output_1428_0 = pow( abs( VColor_Red1622 ) , _WindTrunkStiffness );
				float temp_output_48_0_g124 = temp_output_1428_0;
				float temp_output_28_0_g124 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g124 ) + ( ( temp_output_101_0_g124 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g124 ) ) ) * temp_output_73_0_g124 ) * temp_output_48_0_g124 );
				float temp_output_49_0_g124 = 0.0;
				float3 appendResult63_g124 = (float3(temp_output_28_0_g124 , ( ( sin( ( ( temp_output_99_0_g124 * ase_worldPos.y ) + mulTime10_g124 ) ) * temp_output_73_0_g124 ) * temp_output_49_0_g124 ) , temp_output_28_0_g124));
				half3 Wind_Trunk1629 = ( appendResult63_g124 + ( temp_output_73_0_g124 * ( temp_output_48_0_g124 + temp_output_49_0_g124 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				float temp_output_99_0_g125 = ( _WindLeafScale * AGW_WindScale );
				float temp_output_101_0_g125 = ( _WindLeafSpeed * AGW_WindSpeed );
				float mulTime10_g125 = _TimeParameters.x * temp_output_101_0_g125;
				half VColor_Blue1625 = v.ase_color.b;
				float temp_output_73_0_g125 = ( AGW_WindToggle * ( VColor_Blue1625 * _WindLeafAmplitude ) * AGW_WindAmplitude );
				half Wind_HorizontalAnim1432 = temp_output_1428_0;
				float temp_output_48_0_g125 = Wind_HorizontalAnim1432;
				float temp_output_28_0_g125 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g125 ) + ( ( temp_output_101_0_g125 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g125 ) ) ) * temp_output_73_0_g125 ) * temp_output_48_0_g125 );
				float temp_output_49_0_g125 = VColor_Blue1625;
				float3 appendResult63_g125 = (float3(temp_output_28_0_g125 , ( ( sin( ( ( temp_output_99_0_g125 * ase_worldPos.y ) + mulTime10_g125 ) ) * temp_output_73_0_g125 ) * temp_output_49_0_g125 ) , temp_output_28_0_g125));
				half3 Wind_Leaf1630 = ( appendResult63_g125 + ( temp_output_73_0_g125 * ( temp_output_48_0_g125 + temp_output_49_0_g125 ) * ( (2.0 + (_WindLeafStiffness - 0.0) * (0.0 - 2.0) / (2.0 - 0.0)) * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				half3 Output_Wind548 = mul( GetWorldToObjectMatrix(), float4( ( ( Wind_Trunk1629 + Wind_Leaf1630 ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				float4 temp_cast_2 = (1.0).xxxx;
				float2 appendResult8_g123 = (float2(ase_worldPos.x , ase_worldPos.z));
				float4 lerpResult17_g123 = lerp( _TintColor1 , _TintColor2 , saturate( ( tex2Dlod( AG_TintNoiseTexture, float4( ( appendResult8_g123 * ( 0.001 * AG_TintNoiseTile * _TintNoiseTile ) ), 0, 0.0) ).r * (0.001 + (AG_TintNoiseContrast - 0.001) * (60.0 - 0.001) / (10.0 - 0.001)) ) ));
				float4 lerpResult19_g123 = lerp( temp_cast_2 , lerpResult17_g123 , AG_TintToggle);
				float4 vertexToFrag18_g123 = lerpResult19_g123;
				o.ase_texcoord8 = vertexToFrag18_g123;
				
				o.ase_texcoord7.xy = v.texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind548;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
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
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN , half ase_vface : VFACE ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_MainTex162 = IN.ase_texcoord7.xy;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				float4 vertexToFrag18_g123 = IN.ase_texcoord8;
				half4 TintColor1462 = vertexToFrag18_g123;
				float4 temp_output_163_0 = ( _Color * tex2DNode162 * TintColor1462 );
				float4 switchResult320 = (((ase_vface>0)?(temp_output_163_0):(( temp_output_163_0 * _BackFaceColor ))));
				half4 Output_Albedo1053 = switchResult320;
				
				float2 uv_BumpMap1127 = IN.ase_texcoord7.xy;
				float3 unpack1127 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap1127 ), _BumpScale );
				unpack1127.z = lerp( 1, unpack1127.z, saturate(_BumpScale) );
				float3 break105_g127 = unpack1127;
				float switchResult107_g127 = (((ase_vface>0)?(break105_g127.z):(-break105_g127.z)));
				float3 appendResult108_g127 = (float3(break105_g127.x , break105_g127.y , switchResult107_g127));
				float3 normalizeResult136 = normalize( appendResult108_g127 );
				half3 Output_Normal1110 = normalizeResult136;
				
				half Output_Smoothness223 = (-1.0 + (_Glossiness - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				
				half VColor_Alpha1626 = IN.ase_color.a;
				float lerpResult201 = lerp( 1.0 , VColor_Alpha1626 , ( _OcclusionStrength * AG_TreesAO ));
				half Output_AO207 = saturate( lerpResult201 );
				
				half Alpha_Albedo317 = tex2DNode162.a;
				half Alpha_Color1103 = _Color.a;
				half Output_OpacityMask1642 = ( Alpha_Albedo317 * Alpha_Color1103 );
				
				float lerpResult14_g126 = lerp( 0.0 , AG_TranslucencyIntensity , saturate( ( ( 1.0 - (0.0 + (distance( WorldPosition , _WorldSpaceCameraPos ) - 0.0) * (1.0 - 0.0) / (AG_TranslucencyDistance - 0.0)) ) * VColor_Alpha1626 ) ));
				half Output_Transluncency1685 = ( lerpResult14_g126 * _Strenght1 );
				half3 temp_cast_1 = (Output_Transluncency1685).xxx;
				
				float3 Albedo = Output_Albedo1053.rgb;
				float3 Normal = Output_Normal1110;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = Output_Smoothness223;
				float Occlusion = Output_AO207;
				float Alpha = Output_OpacityMask1642;
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = temp_cast_1;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _Strenght1;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
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

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#define _TRANSLUCENCY_ASE 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "VS_indirect.cginc"
			#pragma multi_compile GPU_FRUSTUM_ON __
			#pragma instancing_options procedural:setup


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TintColor1;
			half4 _TintColor2;
			half4 _BackFaceColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _WindLeafScale;
			half _WindLeafSpeed;
			half _WindLeafAmplitude;
			half _WindLeafStiffness;
			half _TintNoiseTile;
			half _BumpScale;
			half _Glossiness;
			half _OcclusionStrength;
			half _Cutoff;
			half _Strenght1;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D AG_TintNoiseTexture;
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g124 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g124 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g124 = _TimeParameters.x * temp_output_101_0_g124;
				float temp_output_73_0_g124 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red1622 = v.ase_color.r;
				float temp_output_1428_0 = pow( abs( VColor_Red1622 ) , _WindTrunkStiffness );
				float temp_output_48_0_g124 = temp_output_1428_0;
				float temp_output_28_0_g124 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g124 ) + ( ( temp_output_101_0_g124 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g124 ) ) ) * temp_output_73_0_g124 ) * temp_output_48_0_g124 );
				float temp_output_49_0_g124 = 0.0;
				float3 appendResult63_g124 = (float3(temp_output_28_0_g124 , ( ( sin( ( ( temp_output_99_0_g124 * ase_worldPos.y ) + mulTime10_g124 ) ) * temp_output_73_0_g124 ) * temp_output_49_0_g124 ) , temp_output_28_0_g124));
				half3 Wind_Trunk1629 = ( appendResult63_g124 + ( temp_output_73_0_g124 * ( temp_output_48_0_g124 + temp_output_49_0_g124 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				float temp_output_99_0_g125 = ( _WindLeafScale * AGW_WindScale );
				float temp_output_101_0_g125 = ( _WindLeafSpeed * AGW_WindSpeed );
				float mulTime10_g125 = _TimeParameters.x * temp_output_101_0_g125;
				half VColor_Blue1625 = v.ase_color.b;
				float temp_output_73_0_g125 = ( AGW_WindToggle * ( VColor_Blue1625 * _WindLeafAmplitude ) * AGW_WindAmplitude );
				half Wind_HorizontalAnim1432 = temp_output_1428_0;
				float temp_output_48_0_g125 = Wind_HorizontalAnim1432;
				float temp_output_28_0_g125 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g125 ) + ( ( temp_output_101_0_g125 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g125 ) ) ) * temp_output_73_0_g125 ) * temp_output_48_0_g125 );
				float temp_output_49_0_g125 = VColor_Blue1625;
				float3 appendResult63_g125 = (float3(temp_output_28_0_g125 , ( ( sin( ( ( temp_output_99_0_g125 * ase_worldPos.y ) + mulTime10_g125 ) ) * temp_output_73_0_g125 ) * temp_output_49_0_g125 ) , temp_output_28_0_g125));
				half3 Wind_Leaf1630 = ( appendResult63_g125 + ( temp_output_73_0_g125 * ( temp_output_48_0_g125 + temp_output_49_0_g125 ) * ( (2.0 + (_WindLeafStiffness - 0.0) * (0.0 - 2.0) / (2.0 - 0.0)) * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				half3 Output_Wind548 = mul( GetWorldToObjectMatrix(), float4( ( ( Wind_Trunk1629 + Wind_Leaf1630 ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind548;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
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
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex162 = IN.ase_texcoord2.xy;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				half Alpha_Albedo317 = tex2DNode162.a;
				half Alpha_Color1103 = _Color.a;
				half Output_OpacityMask1642 = ( Alpha_Albedo317 * Alpha_Color1103 );
				
				float Alpha = Output_OpacityMask1642;
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
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
			#define _TRANSLUCENCY_ASE 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "VS_indirect.cginc"
			#pragma multi_compile GPU_FRUSTUM_ON __
			#pragma instancing_options procedural:setup


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TintColor1;
			half4 _TintColor2;
			half4 _BackFaceColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _WindLeafScale;
			half _WindLeafSpeed;
			half _WindLeafAmplitude;
			half _WindLeafStiffness;
			half _TintNoiseTile;
			half _BumpScale;
			half _Glossiness;
			half _OcclusionStrength;
			half _Cutoff;
			half _Strenght1;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D AG_TintNoiseTexture;
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g124 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g124 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g124 = _TimeParameters.x * temp_output_101_0_g124;
				float temp_output_73_0_g124 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red1622 = v.ase_color.r;
				float temp_output_1428_0 = pow( abs( VColor_Red1622 ) , _WindTrunkStiffness );
				float temp_output_48_0_g124 = temp_output_1428_0;
				float temp_output_28_0_g124 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g124 ) + ( ( temp_output_101_0_g124 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g124 ) ) ) * temp_output_73_0_g124 ) * temp_output_48_0_g124 );
				float temp_output_49_0_g124 = 0.0;
				float3 appendResult63_g124 = (float3(temp_output_28_0_g124 , ( ( sin( ( ( temp_output_99_0_g124 * ase_worldPos.y ) + mulTime10_g124 ) ) * temp_output_73_0_g124 ) * temp_output_49_0_g124 ) , temp_output_28_0_g124));
				half3 Wind_Trunk1629 = ( appendResult63_g124 + ( temp_output_73_0_g124 * ( temp_output_48_0_g124 + temp_output_49_0_g124 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				float temp_output_99_0_g125 = ( _WindLeafScale * AGW_WindScale );
				float temp_output_101_0_g125 = ( _WindLeafSpeed * AGW_WindSpeed );
				float mulTime10_g125 = _TimeParameters.x * temp_output_101_0_g125;
				half VColor_Blue1625 = v.ase_color.b;
				float temp_output_73_0_g125 = ( AGW_WindToggle * ( VColor_Blue1625 * _WindLeafAmplitude ) * AGW_WindAmplitude );
				half Wind_HorizontalAnim1432 = temp_output_1428_0;
				float temp_output_48_0_g125 = Wind_HorizontalAnim1432;
				float temp_output_28_0_g125 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g125 ) + ( ( temp_output_101_0_g125 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g125 ) ) ) * temp_output_73_0_g125 ) * temp_output_48_0_g125 );
				float temp_output_49_0_g125 = VColor_Blue1625;
				float3 appendResult63_g125 = (float3(temp_output_28_0_g125 , ( ( sin( ( ( temp_output_99_0_g125 * ase_worldPos.y ) + mulTime10_g125 ) ) * temp_output_73_0_g125 ) * temp_output_49_0_g125 ) , temp_output_28_0_g125));
				half3 Wind_Leaf1630 = ( appendResult63_g125 + ( temp_output_73_0_g125 * ( temp_output_48_0_g125 + temp_output_49_0_g125 ) * ( (2.0 + (_WindLeafStiffness - 0.0) * (0.0 - 2.0) / (2.0 - 0.0)) * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				half3 Output_Wind548 = mul( GetWorldToObjectMatrix(), float4( ( ( Wind_Trunk1629 + Wind_Leaf1630 ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind548;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
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
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex162 = IN.ase_texcoord2.xy;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				half Alpha_Albedo317 = tex2DNode162.a;
				half Alpha_Color1103 = _Color.a;
				half Output_OpacityMask1642 = ( Alpha_Albedo317 * Alpha_Color1103 );
				
				float Alpha = Output_OpacityMask1642;
				float AlphaClipThreshold = _Cutoff;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
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
			#define _TRANSLUCENCY_ASE 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "VS_indirect.cginc"
			#pragma multi_compile GPU_FRUSTUM_ON __
			#pragma instancing_options procedural:setup


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TintColor1;
			half4 _TintColor2;
			half4 _BackFaceColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _WindLeafScale;
			half _WindLeafSpeed;
			half _WindLeafAmplitude;
			half _WindLeafStiffness;
			half _TintNoiseTile;
			half _BumpScale;
			half _Glossiness;
			half _OcclusionStrength;
			half _Cutoff;
			half _Strenght1;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D AG_TintNoiseTexture;
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;
			half AG_TintNoiseTile;
			half AG_TintNoiseContrast;
			half AG_TintToggle;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g124 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g124 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g124 = _TimeParameters.x * temp_output_101_0_g124;
				float temp_output_73_0_g124 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red1622 = v.ase_color.r;
				float temp_output_1428_0 = pow( abs( VColor_Red1622 ) , _WindTrunkStiffness );
				float temp_output_48_0_g124 = temp_output_1428_0;
				float temp_output_28_0_g124 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g124 ) + ( ( temp_output_101_0_g124 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g124 ) ) ) * temp_output_73_0_g124 ) * temp_output_48_0_g124 );
				float temp_output_49_0_g124 = 0.0;
				float3 appendResult63_g124 = (float3(temp_output_28_0_g124 , ( ( sin( ( ( temp_output_99_0_g124 * ase_worldPos.y ) + mulTime10_g124 ) ) * temp_output_73_0_g124 ) * temp_output_49_0_g124 ) , temp_output_28_0_g124));
				half3 Wind_Trunk1629 = ( appendResult63_g124 + ( temp_output_73_0_g124 * ( temp_output_48_0_g124 + temp_output_49_0_g124 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				float temp_output_99_0_g125 = ( _WindLeafScale * AGW_WindScale );
				float temp_output_101_0_g125 = ( _WindLeafSpeed * AGW_WindSpeed );
				float mulTime10_g125 = _TimeParameters.x * temp_output_101_0_g125;
				half VColor_Blue1625 = v.ase_color.b;
				float temp_output_73_0_g125 = ( AGW_WindToggle * ( VColor_Blue1625 * _WindLeafAmplitude ) * AGW_WindAmplitude );
				half Wind_HorizontalAnim1432 = temp_output_1428_0;
				float temp_output_48_0_g125 = Wind_HorizontalAnim1432;
				float temp_output_28_0_g125 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g125 ) + ( ( temp_output_101_0_g125 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g125 ) ) ) * temp_output_73_0_g125 ) * temp_output_48_0_g125 );
				float temp_output_49_0_g125 = VColor_Blue1625;
				float3 appendResult63_g125 = (float3(temp_output_28_0_g125 , ( ( sin( ( ( temp_output_99_0_g125 * ase_worldPos.y ) + mulTime10_g125 ) ) * temp_output_73_0_g125 ) * temp_output_49_0_g125 ) , temp_output_28_0_g125));
				half3 Wind_Leaf1630 = ( appendResult63_g125 + ( temp_output_73_0_g125 * ( temp_output_48_0_g125 + temp_output_49_0_g125 ) * ( (2.0 + (_WindLeafStiffness - 0.0) * (0.0 - 2.0) / (2.0 - 0.0)) * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				half3 Output_Wind548 = mul( GetWorldToObjectMatrix(), float4( ( ( Wind_Trunk1629 + Wind_Leaf1630 ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				float4 temp_cast_2 = (1.0).xxxx;
				float2 appendResult8_g123 = (float2(ase_worldPos.x , ase_worldPos.z));
				float4 lerpResult17_g123 = lerp( _TintColor1 , _TintColor2 , saturate( ( tex2Dlod( AG_TintNoiseTexture, float4( ( appendResult8_g123 * ( 0.001 * AG_TintNoiseTile * _TintNoiseTile ) ), 0, 0.0) ).r * (0.001 + (AG_TintNoiseContrast - 0.001) * (60.0 - 0.001) / (10.0 - 0.001)) ) ));
				float4 lerpResult19_g123 = lerp( temp_cast_2 , lerpResult17_g123 , AG_TintToggle);
				float4 vertexToFrag18_g123 = lerpResult19_g123;
				o.ase_texcoord3 = vertexToFrag18_g123;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind548;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
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
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN , half ase_vface : VFACE ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex162 = IN.ase_texcoord2.xy;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				float4 vertexToFrag18_g123 = IN.ase_texcoord3;
				half4 TintColor1462 = vertexToFrag18_g123;
				float4 temp_output_163_0 = ( _Color * tex2DNode162 * TintColor1462 );
				float4 switchResult320 = (((ase_vface>0)?(temp_output_163_0):(( temp_output_163_0 * _BackFaceColor ))));
				half4 Output_Albedo1053 = switchResult320;
				
				half Alpha_Albedo317 = tex2DNode162.a;
				half Alpha_Color1103 = _Color.a;
				half Output_OpacityMask1642 = ( Alpha_Albedo317 * Alpha_Color1103 );
				
				
				float3 Albedo = Output_Albedo1053.rgb;
				float3 Emission = 0;
				float Alpha = Output_OpacityMask1642;
				float AlphaClipThreshold = _Cutoff;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#define _TRANSLUCENCY_ASE 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#include "VS_indirect.cginc"
			#pragma multi_compile GPU_FRUSTUM_ON __
			#pragma instancing_options procedural:setup


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TintColor1;
			half4 _TintColor2;
			half4 _BackFaceColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _WindLeafScale;
			half _WindLeafSpeed;
			half _WindLeafAmplitude;
			half _WindLeafStiffness;
			half _TintNoiseTile;
			half _BumpScale;
			half _Glossiness;
			half _OcclusionStrength;
			half _Cutoff;
			half _Strenght1;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D AG_TintNoiseTexture;
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;
			half AG_TintNoiseTile;
			half AG_TintNoiseContrast;
			half AG_TintToggle;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g124 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g124 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g124 = _TimeParameters.x * temp_output_101_0_g124;
				float temp_output_73_0_g124 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red1622 = v.ase_color.r;
				float temp_output_1428_0 = pow( abs( VColor_Red1622 ) , _WindTrunkStiffness );
				float temp_output_48_0_g124 = temp_output_1428_0;
				float temp_output_28_0_g124 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g124 ) + ( ( temp_output_101_0_g124 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g124 ) ) ) * temp_output_73_0_g124 ) * temp_output_48_0_g124 );
				float temp_output_49_0_g124 = 0.0;
				float3 appendResult63_g124 = (float3(temp_output_28_0_g124 , ( ( sin( ( ( temp_output_99_0_g124 * ase_worldPos.y ) + mulTime10_g124 ) ) * temp_output_73_0_g124 ) * temp_output_49_0_g124 ) , temp_output_28_0_g124));
				half3 Wind_Trunk1629 = ( appendResult63_g124 + ( temp_output_73_0_g124 * ( temp_output_48_0_g124 + temp_output_49_0_g124 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				float temp_output_99_0_g125 = ( _WindLeafScale * AGW_WindScale );
				float temp_output_101_0_g125 = ( _WindLeafSpeed * AGW_WindSpeed );
				float mulTime10_g125 = _TimeParameters.x * temp_output_101_0_g125;
				half VColor_Blue1625 = v.ase_color.b;
				float temp_output_73_0_g125 = ( AGW_WindToggle * ( VColor_Blue1625 * _WindLeafAmplitude ) * AGW_WindAmplitude );
				half Wind_HorizontalAnim1432 = temp_output_1428_0;
				float temp_output_48_0_g125 = Wind_HorizontalAnim1432;
				float temp_output_28_0_g125 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g125 ) + ( ( temp_output_101_0_g125 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g125 ) ) ) * temp_output_73_0_g125 ) * temp_output_48_0_g125 );
				float temp_output_49_0_g125 = VColor_Blue1625;
				float3 appendResult63_g125 = (float3(temp_output_28_0_g125 , ( ( sin( ( ( temp_output_99_0_g125 * ase_worldPos.y ) + mulTime10_g125 ) ) * temp_output_73_0_g125 ) * temp_output_49_0_g125 ) , temp_output_28_0_g125));
				half3 Wind_Leaf1630 = ( appendResult63_g125 + ( temp_output_73_0_g125 * ( temp_output_48_0_g125 + temp_output_49_0_g125 ) * ( (2.0 + (_WindLeafStiffness - 0.0) * (0.0 - 2.0) / (2.0 - 0.0)) * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) );
				half3 Output_Wind548 = mul( GetWorldToObjectMatrix(), float4( ( ( Wind_Trunk1629 + Wind_Leaf1630 ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				float4 temp_cast_2 = (1.0).xxxx;
				float2 appendResult8_g123 = (float2(ase_worldPos.x , ase_worldPos.z));
				float4 lerpResult17_g123 = lerp( _TintColor1 , _TintColor2 , saturate( ( tex2Dlod( AG_TintNoiseTexture, float4( ( appendResult8_g123 * ( 0.001 * AG_TintNoiseTile * _TintNoiseTile ) ), 0, 0.0) ).r * (0.001 + (AG_TintNoiseContrast - 0.001) * (60.0 - 0.001) / (10.0 - 0.001)) ) ));
				float4 lerpResult19_g123 = lerp( temp_cast_2 , lerpResult17_g123 , AG_TintToggle);
				float4 vertexToFrag18_g123 = lerpResult19_g123;
				o.ase_texcoord3 = vertexToFrag18_g123;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind548;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
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
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN , half ase_vface : VFACE ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex162 = IN.ase_texcoord2.xy;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				float4 vertexToFrag18_g123 = IN.ase_texcoord3;
				half4 TintColor1462 = vertexToFrag18_g123;
				float4 temp_output_163_0 = ( _Color * tex2DNode162 * TintColor1462 );
				float4 switchResult320 = (((ase_vface>0)?(temp_output_163_0):(( temp_output_163_0 * _BackFaceColor ))));
				half4 Output_Albedo1053 = switchResult320;
				
				half Alpha_Albedo317 = tex2DNode162.a;
				half Alpha_Color1103 = _Color.a;
				half Output_OpacityMask1642 = ( Alpha_Albedo317 * Alpha_Color1103 );
				
				
				float3 Albedo = Output_Albedo1053.rgb;
				float Alpha = Output_OpacityMask1642;
				float AlphaClipThreshold = _Cutoff;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	/*ase_lod*/
	
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18801
1920;0;1920;1019;2734.716;1667.369;1;True;False
Node;AmplifyShaderEditor.VertexColorNode;1621;-5248,640;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1622;-4992,640;Half;False;VColor_Red;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1627;-4608,640;Inherit;False;1622;VColor_Red;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;1662;-4352,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1484;-4608,736;Half;False;Property;_WindTrunkStiffness;Wind Trunk Stiffness;14;0;Create;True;0;0;0;False;0;False;3;2;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1625;-4992,736;Half;False;VColor_Blue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1428;-4224,640;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1628;-3200,736;Inherit;False;1625;VColor_Blue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1442;-3200,1120;Half;False;Property;_WindLeafStiffness;Wind Leaf Stiffness;18;0;Create;True;0;0;0;False;0;False;0;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1391;-3200,832;Half;False;Property;_WindLeafAmplitude;Wind Leaf Amplitude;15;0;Create;True;0;0;0;False;1;Header(Wind Leaf);False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1432;-3968,640;Half;False;Wind_HorizontalAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1390;-3200,1024;Half;False;Property;_WindLeafSpeed;Wind Leaf Speed;16;0;Create;True;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1389;-3200,928;Half;False;Property;_WindLeafScale;Wind Leaf Scale;17;0;Create;True;0;0;0;False;0;False;15;15;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1459;-5248,-384;Half;False;Property;_TintNoiseTile;Tint Noise Tile;12;0;Create;True;0;0;0;False;0;False;10;10;0.001;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1458;-5248,-576;Half;False;Property;_TintColor2;Tint Color 2;11;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1457;-5248,-768;Half;False;Property;_TintColor1;Tint Color 1;10;0;Create;True;0;0;0;False;1;Header(Tint Color);False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1433;-3200,640;Inherit;False;1432;Wind_HorizontalAnim;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1485;-4608,832;Half;False;Property;_WindTrunkAmplitude;Wind Trunk Amplitude;13;0;Create;True;0;0;0;False;1;Header(Wind Trunk (use common settings for both materials));False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1400;-2816,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1571;-2816,1024;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;2;False;3;FLOAT;2;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1656;-3968,768;Inherit;False;AG Global Wind - Tree;-1;;124;b3a3869a2b12ed246ae10bcce7d41e6e;0;6;48;FLOAT;0;False;49;FLOAT;0;False;96;FLOAT;1;False;94;FLOAT;1;False;95;FLOAT;1;False;97;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1655;-2560,640;Inherit;False;AG Global Wind - Tree;-1;;125;b3a3869a2b12ed246ae10bcce7d41e6e;0;6;48;FLOAT;0;False;49;FLOAT;0;False;96;FLOAT;1;False;94;FLOAT;1;False;95;FLOAT;1;False;97;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1660;-4864,-768;Inherit;False;AG Global Tint Color;0;;123;1dcc860732522ee469468f952b4e8aa1;0;3;27;COLOR;0,0,0,0;False;28;COLOR;0,0,0,0;False;22;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1462;-4480,-768;Half;False;TintColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1630;-2176,640;Half;False;Wind_Leaf;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1629;-3584,768;Half;False;Wind_Trunk;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1463;-2814.538,-1760;Inherit;False;1462;TintColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;162;-2816,-1984;Inherit;True;Property;_MainTex;Base Albedo (A Opacity);7;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1631;-1792,640;Inherit;False;1629;Wind_Trunk;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1632;-1792,736;Inherit;False;1630;Wind_Leaf;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;165;-2816,-2176;Half;False;Property;_Color;Base Color;6;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1396;-1536,640;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;332;-2432,-1792;Half;False;Property;_BackFaceColor;Back Face Color;9;0;Create;True;0;0;0;False;1;Header(Backface);False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;-2432,-1920;Half;False;Alpha_Albedo;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1103;-2432,-2176;Half;False;Alpha_Color;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-2432,-2048;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;1374;-1536,768;Half;False;Global;AGW_WindDirection;AGW_WindDirection;20;0;Create;True;0;0;0;False;0;False;0,0,0;-0.4521585,-0.3420203,0.8237566;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1373;-1280,640;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-2048,-2000;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-5248,128;Inherit;False;317;Alpha_Albedo;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;1376;-1280,768;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1105;-5248,224;Inherit;False;1103;Alpha_Color;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;320;-1920,-2176;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1375;-1024,640;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1099;-4992,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1053;-1664,-2176;Half;False;Output_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;548;-768,640;Half;False;Output_Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1642;-4736,128;Half;False;Output_OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1691;-2048,-1280;Inherit;False;AG Flip Normals;-1;;127;02ae90bb716acd647b8ac9db8603316a;0;1;110;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-5248,-1984;Half;False;Property;_OcclusionStrength;Base Tree AO;4;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1687;-2560,-768;Inherit;False;AG Global Transluncency;-1;;126;478210ebafb74104ba79a094e66bfe96;0;1;15;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;0,-1984;Inherit;False;223;Output_Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;289;-2816,-1280;Half;False;Property;_BumpScale;Base Normal Intensity;5;0;Create;False;0;0;0;False;0;False;1;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;549;0,-1504;Inherit;False;548;Output_Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;136;-1792,-1280;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-5248,-1280;Half;False;Property;_Glossiness;Base Smoothness;3;0;Create;False;0;0;0;False;1;Header(Base);False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;913;-4864,-2000;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1626;-4992,832;Half;False;VColor_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-4224,-2176;Half;False;Output_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1111;0,-2080;Inherit;False;1110;Output_Normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-4608,-1280;Half;False;Output_Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1686;-2560,-672;Half;False;Property;_Strenght1;Strenght;19;0;Create;False;0;0;0;False;1;Header(Translucency);False;1.5;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1109;0,-2176;Inherit;False;1053;Output_Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1115;0,-1696;Half;False;Property;_Cutoff;Alpha Cutoff;2;0;Create;False;0;0;0;True;0;False;0.5;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;201;-4736,-2176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;713;-4864,-1280;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1636;-5248,-2080;Inherit;False;1626;VColor_Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1690;0,-1600;Inherit;False;1685;Output_Transluncency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-5248,-2176;Half;False;Constant;_White1;White1;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;0,-1888;Inherit;False;207;Output_AO;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1110;-1536,-1280;Half;False;Output_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1689;-2176,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;915;-4480,-2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1685;-1920,-768;Half;False;Output_Transluncency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1127;-2432,-1280;Inherit;True;Property;_BumpMap;Base NormalMap;8;2;[NoScaleOffset];[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;914;-5248,-1888;Half;False;Global;AG_TreesAO;AG_TreesAO;21;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1688;-2816,-768;Inherit;False;1626;VColor_Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1638;0,-1792;Inherit;False;1642;Output_OpacityMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1683;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1684;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1681;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1679;640,-2176;Half;False;True;-1;2;;0;2;ANGRYMESH/Nature Pack/URP/Tree Leaf;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;17;False;False;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;4;Include;;False;;Native;Include;VS_indirect.cginc;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Pragma;instancing_options procedural:setup;False;;Custom;Hidden/InternalErrorShader;0;0;Standard;36;Workflow;1;Surface;0;  Refraction Model;0;  Blend;0;Two Sided;0;Fragment Normal Space,InvertActionOnDeselection;0;Transmission;0;  Transmission Shadow;0.5,False,-1;Translucency;1;  Translucency Strength;1,True,1686;  Normal Distortion;0.5,False,-1;  Scattering;1,False,-1;  Direct;0.8,False,-1;  Ambient;1,False,-1;  Shadow;1,False,-1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;_FinalColorxAlpha;0;Meta Pass;1;Override Baked GI;0;Extra Pre Pass;0;DOTS Instancing;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;6;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1680;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1682;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.CommentaryNode;1675;-2816,-896;Inherit;False;1276.589;100;;0;Translucency;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;889;-5248,512;Inherit;False;4733.918;100;;0;// Vertex Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;230;-5248,-1408;Inherit;False;894.165;100;;0;// Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1643;0,-2304;Inherit;False;894.5891;100;;0;// Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1641;-5248,0;Inherit;False;769.246;100;;0;// Alpha Cutout;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;240;-2816,-1408;Inherit;False;1535.996;100;;0;// Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;210;-5248,-2304;Inherit;False;1280.537;100;;0;// AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;237;-2816,-2304;Inherit;False;1406.922;100;;0;// Albedo Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1453;-5248,-896;Inherit;False;1020.68;100;;0;// Tint Color;1,1,1,1;0;0
WireConnection;1622;0;1621;1
WireConnection;1662;0;1627;0
WireConnection;1625;0;1621;3
WireConnection;1428;0;1662;0
WireConnection;1428;1;1484;0
WireConnection;1432;0;1428;0
WireConnection;1400;0;1628;0
WireConnection;1400;1;1391;0
WireConnection;1571;0;1442;0
WireConnection;1656;48;1428;0
WireConnection;1656;96;1485;0
WireConnection;1655;48;1433;0
WireConnection;1655;49;1628;0
WireConnection;1655;96;1400;0
WireConnection;1655;94;1389;0
WireConnection;1655;95;1390;0
WireConnection;1655;97;1571;0
WireConnection;1660;27;1457;0
WireConnection;1660;28;1458;0
WireConnection;1660;22;1459;0
WireConnection;1462;0;1660;0
WireConnection;1630;0;1655;0
WireConnection;1629;0;1656;0
WireConnection;1396;0;1631;0
WireConnection;1396;1;1632;0
WireConnection;317;0;162;4
WireConnection;1103;0;165;4
WireConnection;163;0;165;0
WireConnection;163;1;162;0
WireConnection;163;2;1463;0
WireConnection;1373;0;1396;0
WireConnection;1373;1;1374;0
WireConnection;363;0;163;0
WireConnection;363;1;332;0
WireConnection;320;0;163;0
WireConnection;320;1;363;0
WireConnection;1375;0;1376;0
WireConnection;1375;1;1373;0
WireConnection;1099;0;319;0
WireConnection;1099;1;1105;0
WireConnection;1053;0;320;0
WireConnection;548;0;1375;0
WireConnection;1642;0;1099;0
WireConnection;1691;110;1127;0
WireConnection;1687;15;1688;0
WireConnection;136;0;1691;0
WireConnection;913;0;203;0
WireConnection;913;1;914;0
WireConnection;1626;0;1621;4
WireConnection;207;0;915;0
WireConnection;223;0;713;0
WireConnection;201;0;231;0
WireConnection;201;1;1636;0
WireConnection;201;2;913;0
WireConnection;713;0;216;0
WireConnection;1110;0;136;0
WireConnection;1689;0;1687;0
WireConnection;1689;1;1686;0
WireConnection;915;0;201;0
WireConnection;1685;0;1689;0
WireConnection;1127;5;289;0
WireConnection;1679;0;1109;0
WireConnection;1679;1;1111;0
WireConnection;1679;4;224;0
WireConnection;1679;5;208;0
WireConnection;1679;6;1638;0
WireConnection;1679;7;1115;0
WireConnection;1679;15;1690;0
WireConnection;1679;8;549;0
ASEEND*/
//CHKSM=4771A7CACB6E499C8283DDAA1195E07B05FC4581