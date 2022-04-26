﻿#ifndef WATER_COMMON_INCLUDED
#define WATER_COMMON_INCLUDED

#define SHADOWS_SCREEN 0

#include "WaterInput.hlsl"
#include "CommonUtilities.hlsl"
#include "GerstnerWaves.hlsl"
#include "WaterLighting.hlsl"

#if defined(_STATIC_SHADER)
    #define WATER_TIME 0.0
#else
    #define WATER_TIME _Time.y
#endif

#define DEPTH_MULTIPLIER 1 / _MaxDepth
#define WaterBufferA(uv) SAMPLE_TEXTURE2D(_WaterBufferA, sampler_ScreenTextures_linear_clamp, half2(uv.x, 1-uv.y))
#define WaterBufferAVert(uv) SAMPLE_TEXTURE2D_LOD(_WaterBufferA, sampler_ScreenTextures_linear_clamp, half2(uv.x, 1-uv.y), 0)
#define WaterBufferB(uv) SAMPLE_TEXTURE2D(_WaterBufferB, sampler_ScreenTextures_linear_clamp, half2(uv.x, 1-uv.y))
#define WaterBufferBVert(uv) SAMPLE_TEXTURE2D_LOD(_WaterBufferB, sampler_ScreenTextures_linear_clamp, half2(uv.x, 1-uv.y), 0)

///////////////////////////////////////////////////////////////////////////////
//          	   	       Water debug functions                             //
///////////////////////////////////////////////////////////////////////////////

half3 DebugWaterFX(half3 input, half4 waterFX, half screenUV)
{
    input = lerp(input, half3(waterFX.y, 1, waterFX.z), saturate(floor(screenUV + 0.7)));
    input = lerp(input, waterFX.xxx, saturate(floor(screenUV + 0.5)));
    half3 disp = lerp(0, half3(1, 0, 0), saturate((waterFX.www - 0.5) * 4));
    disp += lerp(0, half3(0, 0, 1), saturate(((1-waterFX.www) - 0.5) * 4));
    input = lerp(input, disp, saturate(floor(screenUV + 0.3)));
    return input;
}

///////////////////////////////////////////////////////////////////////////////
//          	   	      Water shading functions                            //
///////////////////////////////////////////////////////////////////////////////

half3 Scattering(half depth)
{
	const half grad = saturate(exp2(-depth * DEPTH_MULTIPLIER));
	return _ScatteringColor * (1-grad);
}

half3 Absorption(half depth)
{
	return saturate(exp(-depth * DEPTH_MULTIPLIER * 10 * (1-_AbsorptionColor)));	
}

float2 AdjustedDepth(half2 uvs, half4 additionalData)
{
	const float rawD = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_ScreenTextures_point_clamp, uvs);
	const float d = LinearEyeDepth(rawD, _ZBufferParams);
	float x = d * additionalData.x - additionalData.y;

	if(d > _ProjectionParams.z)// TODO might be cheaper alternative
	{
		x = 1024;
	}
	
	float y = rawD * -_ProjectionParams.x;
	return float2(x, y);
}

float AdjustWaterTextureDepth(float input)
{
	return  max(0, (1-input) * 20 - 4);
}

float WaterTextureDepthVert(float2 uv)
{
	return AdjustWaterTextureDepth(WaterBufferBVert(uv).b);// * (_MaxDepth + _VeraslWater_DepthCamParams.x) - _VeraslWater_DepthCamParams.x;
}

float WaterTextureDepth(float2 uv)
{
    return AdjustWaterTextureDepth(WaterBufferB(uv).b);//(1 - SAMPLE_TEXTURE2D_LOD(_WaterDepthMap, sampler_WaterDepthMap_linear_clamp, positionWS.xz * 0.002 + 0.5, 1).r) * (_MaxDepth + _VeraslWater_DepthCamParams.x) - _VeraslWater_DepthCamParams.x;
}

float3 WaterDepth(float3 positionWS, half4 additionalData, half2 screenUVs)// x = seafloor depth, y = water depth
{
	float3 out_depth;
	out_depth.xz = AdjustedDepth(screenUVs, additionalData);
	const float wd = WaterTextureDepth(screenUVs);
	out_depth.y = wd + positionWS.y;
	return out_depth;
}

half3 Refraction(half2 distortion, half depth, half edgeFade)
{
	half3 output = SAMPLE_TEXTURE2D_LOD(_CameraOpaqueTexture, sampler_ScreenTextures_linear_clamp, distortion, depth * 0.25).rgb;
	output *= max(Absorption(depth), 1-edgeFade);
	return output;
}

half2 DistortionUVs(half depth, float3 normalWS, float3 viewDirectionWS)
{
    half3 viewNormal = mul((float3x3)GetWorldToHClipMatrix(), -normalWS).xyz;

	//float4x4 viewMat = GetWorldToViewMatrix();
	//half3 f = viewMat[1].xyz;

	//half d = dot(f, half3(0, 1, 0));

	//half y = normalize(viewNormal.y) + f.y;
	
	//half2 distortion = half2(viewNormal.x, y);
	//half2 distortion = half2(viewNormal.x, viewNormal.y - d);
	
    return viewNormal.xz * clamp(0, 0.1, saturate(depth * 0.05));
}

half4 AdditionalData(float3 postionWS, WaveStruct wave)
{
    half4 data = half4(0.0, 0.0, 0.0, 0.0);
    float3 viewPos = TransformWorldToView(postionWS);
	data.x = length(viewPos / viewPos.z);// distance to surface
    data.y = length(GetCameraPositionWS().xyz - postionWS); // local position in camera space(view direction WS)
	data.z = wave.position.y / _MaxWaveHeight * 0.5 + 0.5; // encode the normalized wave height into additional data
	data.w = wave.foam;// wave.position.x + wave.position.z;
	return data;
}

float4 DetailUVs(float3 positionWS, half noise)
{
    float4 output = positionWS.xzxz * half4(0.4, 0.4, 0.1, 0.1);
    output.xy -= WATER_TIME * 0.1h + (noise * 0.2); // small detail
    output.zw += WATER_TIME * 0.05h + (noise * 0.1); // medium detail
    return output;
}

void DetailNormals(inout float3 normalWS, float4 uvs, half4 waterFX, float depth)
{
    half2 detailBump1 = SAMPLE_TEXTURE2D(_SurfaceMap, sampler_SurfaceMap, uvs.zw).xy * 2 - 1;
	half2 detailBump2 = SAMPLE_TEXTURE2D(_SurfaceMap, sampler_SurfaceMap, uvs.xy).xy * 2 - 1;
	half2 detailBump = (detailBump1 + detailBump2 * 0.5) * saturate(depth * 0.25);

	half3 normal1 = half3(detailBump.x, 0, detailBump.y) * _BoatAttack_Water_MicroWaveIntensity;
	half3 normal2 = half3(1-waterFX.y, 0.5h, 1-waterFX.z) - 0.5;
	normalWS = normalize(normalWS + normal1 + normal2);
}

Varyings WaveVertexOperations(Varyings input)
{

    input.normalWS = float3(0, 1, 0);
	input.fogFactorNoise.y = ((noise((input.positionWS.xz * 0.5) + WATER_TIME) + noise((input.positionWS.xz * 1) + WATER_TIME)) * 0.25 - 0.5) + 1;

	// Detail UVs
    input.uv = DetailUVs(input.positionWS, input.fogFactorNoise.y);

	half4 screenUV = ComputeScreenPos(TransformWorldToHClip(input.positionWS));
	screenUV.xyz /= screenUV.w;

    // shallows mask
    half waterDepth = WaterBufferBVert(screenUV).b;// WaterTextureDepthVert(screenUV);
    //input.positionWS.y += pow(saturate((-waterDepth + 1.5) * 0.4), 2);

	//Gerstner here
	half depthWaveRamp = SAMPLE_TEXTURE2D_LOD(_BoatAttack_RampTexture, sampler_BoatAttack_Linear_Clamp_RampTexture,  waterDepth, 0).b;
	half opacity = depthWaveRamp;// saturate(waterDepth * 0.1 + 0.05);
	
	WaveStruct wave;
	SampleWaves(input.positionWS, opacity, wave);
	input.normalWS = wave.normal;
    input.positionWS += wave.position;

#ifdef SHADER_API_PS4
	input.positionWS.y -= 0.5;
#endif

    // Dynamic displacement
	half4 waterFX = WaterBufferAVert(screenUV.xy);
	input.positionWS.y += waterFX.w * 2 - 1;

	// After waves
	input.positionCS = TransformWorldToHClip(input.positionWS);
	input.screenPosition = ComputeScreenPos(input.positionCS);
    input.viewDirectionWS.xyz = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);

    // Fog
	input.fogFactorNoise.x = ComputeFogFactor(input.positionCS.z);
	input.preWaveSP = screenUV.xyz; // pre-displaced screenUVs

	// Additional data
	input.additionalData = AdditionalData(input.positionWS, wave);

	// distance blend
	half distanceBlend = saturate(abs(length((_WorldSpaceCameraPos.xz - input.positionWS.xz) * 0.005)) - 0.25);
	input.normalWS = lerp(input.normalWS, half3(0, 1, 0), distanceBlend);

	return input;
}

void InitializeInputData(Varyings input, out WaterInputData inputData, float2 screenUV)
{
    float3 depth = WaterDepth(input.positionWS, input.additionalData, screenUV);// TODO - hardcoded shore depth UVs
    // Sample water FX texture
    inputData.waterBufferA = WaterBufferA(input.preWaveSP.xy);
    inputData.waterBufferB = WaterBufferB(input.preWaveSP.xy);
	inputData.waterBufferB.b = AdjustWaterTextureDepth(inputData.waterBufferB.b);

    inputData.positionWS = input.positionWS;
    
    inputData.normalWS = input.normalWS;
    // Detail waves
    DetailNormals(inputData.normalWS, input.uv, inputData.waterBufferA, depth.x);
    
    inputData.viewDirectionWS = input.viewDirectionWS.xyz;
    
    half2 distortion = DistortionUVs(depth.x, inputData.normalWS, input.viewDirectionWS);
	distortion = screenUV.xy + distortion;// * clamp(depth.x, 0, 5);
	float d = depth.x;
	depth.xz = AdjustedDepth(distortion, input.additionalData); // only x y
	distortion = depth.x < 0 ? screenUV.xy : distortion;
    inputData.refractionUV = distortion;
    depth.x = depth.x < 0 ? d : depth.x;

    inputData.detailUV = input.uv;

    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.normalWS);

    inputData.fogCoord = input.fogFactorNoise.x;
    inputData.depth = depth.x;
    inputData.reflectionUV = 0;
    inputData.GI = 0;
}

void InitializeSurfaceData(inout WaterInputData input, out WaterSurfaceData surfaceData, float4 additionalData)
{
	surfaceData.absorption = 0;
	surfaceData.scattering = 0;

	float depth = input.depth;
	
	// Foam
	half depthEdge = saturate(depth.x);// min(saturate(depth.x), input.waterBufferB.b * 0.25 + 0.5);
	//half edgeFoam = pow(saturate(1 - min(depth, input.waterBufferB.b) * 0.25 - 0.5) * depthEdge, 2.4) * 6.8;
	half3 foamShoreRamp = SAMPLE_TEXTURE2D(_BoatAttack_RampTexture, sampler_BoatAttack_Linear_Clamp_RampTexture,  depthEdge).r;
	half3 foamWaveRamp = SAMPLE_TEXTURE2D(_BoatAttack_RampTexture, sampler_BoatAttack_Linear_Clamp_RampTexture,  additionalData.w).g;
	
	half foamBlendMask = max(foamWaveRamp, foamShoreRamp) + input.waterBufferA.r;// + edgeFoam + input.waterBufferA.r;// max(max(waveFoam, edgeFoam), input.waterFX.r * 2);
	foamBlendMask += -1 + _BoatAttack_water_FoamIntensity;
	
	
	half4 mask = half4(0, 0, 0, 0);
	mask.r = saturate(foamBlendMask * 3 - 2);
	mask.g = saturate(foamBlendMask * 3 - 1) - mask.r;
	mask.b = saturate(foamBlendMask * 3) - mask.g - mask.r;
	mask.a = 1 - mask.r - mask.g - mask.b;
	
	mask = saturate(mask);

	half4 foamMap = half4(SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap,  input.detailUV.zw).rgb, 0); //r=thick, g=medium, b=light
	surfaceData.foamMask = length(foamMap * mask);
	
	//surfaceData.foamMask = saturate(length(foamMap * pow(foamBlendMask, 1) /* foamBlend */) * 1.5 - 2 + _BoatAttack_water_FoamIntensity) + input.waterBufferA.r * 0.25;
	//surfaceData.foamMask *= _BoatAttack_water_FoamIntensity;
	surfaceData.foam = 1;//saturate(length(foamMap * foamBlend) * 1.5 - 0.1);
}

float3 WaterShading(WaterInputData input, WaterSurfaceData surfaceData, float4 additionalData, float2 screenUV)
{
	// extra inputs
	half edgeFade = saturate(input.depth * 5);

	// Fresnel
	half fresnelTerm = CalculateFresnelTerm(input.normalWS, input.viewDirectionWS);
	
    // Lighting
	Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS), input.positionWS, 1);
    half volumeShadow = SoftShadows(screenUV, input.positionWS, input.viewDirectionWS, input.depth);
    half3 GI = SampleSH(input.normalWS);

    // SSS
    half3 directLighting = dot(mainLight.direction, half3(0, 1, 0)) * mainLight.color;
    directLighting += saturate(pow(dot(input.viewDirectionWS.xyz, -mainLight.direction) * additionalData.z, 3)) * mainLight.color;
	
    BRDFData brdfData;
    half alpha = 1;
    InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, alpha, brdfData);
	half3 spec = DirectBDRF(brdfData, input.normalWS, mainLight.direction, input.viewDirectionWS) * mainLight.color * mainLight.shadowAttenuation;

	// Foam
	surfaceData.foam *= (GI + directLighting * mainLight.shadowAttenuation) * 3;
	
	// SSS
    half3 sss = directLighting * volumeShadow + GI;
    sss *= Scattering(input.depth);

	// Reflections
	half3 reflection = SampleReflections(input.normalWS, input.viewDirectionWS, screenUV, 0.0);
	reflection *= edgeFade;

	// Refraction
	half3 refraction = Refraction(input.refractionUV, input.depth, edgeFade);

	// Do compositing
	half3 output = lerp(lerp(refraction + sss, reflection + spec, fresnelTerm), surfaceData.foam, surfaceData.foamMask);
	// final
	output = MixFog(output, input.fogCoord);

	// Debug block
	#if defined(_BOATATTACK_WATER_DEBUG)
	[branch] switch(_BoatAttack_Water_DebugPass)
	{
		case 0: // none
			return output;
		case 1: // normalWS
			return pow(half4(input.normalWS.x * 0.5 + 0.5, 0, input.normalWS.z * 0.5 + 0.5, 1), 2.2);
		case 2: // Reflection
			return half4(reflection, 1);
		case 3: // Refraction
			return half4(refraction, 1);
		case 4: // Specular
			return half4(spec, 1);
		case 5: // SSS
			return half4(sss, 1);
		case 6: // Foam
			return half4(surfaceData.foam.xxx, 1) * surfaceData.foamMask;
		case 7: // Foam Mask
			return half4(surfaceData.foamMask.xxx, 1);
		case 8: // buffer A
			return input.waterBufferA;
		case 9: // buffer B
			return input.waterBufferB;
		case 10: // eye depth
			float d = input.depth;
			return half4(frac(d), frac(d * 0.1), 0, 1);
		case 11: // water depth texture
			float wd = WaterTextureDepth(screenUV);
			return half4(frac(wd), frac(wd * 0.1), 0, 1);
	}
	#endif
	
    //return final
    return output;
}

float WaterNearFade(float3 positionWS)
{
    float3 camPos = GetCameraPositionWS();
    camPos.y = 0;
    return 1 - saturate((distance(positionWS, camPos) - _BoatAttack_Water_DistanceBlend) * 0.05);
}

///////////////////////////////////////////////////////////////////////////////
//               	   Vertex and Fragment functions                         //
///////////////////////////////////////////////////////////////////////////////

// Vertex: Used for Standard non-tessellated water
Varyings WaterVertex(Attributes v)
{
    Varyings o = (Varyings)0;
	UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.uv.xy = v.texcoord; // geo uvs
    o.positionWS = TransformObjectToWorld(v.positionOS.xyz);

	o = WaveVertexOperations(o);
    return o;
}

// Fragment for water
half4 WaterFragment(Varyings IN) : SV_Target
{
	UNITY_SETUP_INSTANCE_ID(IN);
	float4 screenUV = 0.0;
	screenUV.xy  = IN.screenPosition.xy / IN.screenPosition.w; // screen UVs
	screenUV.zw  = IN.preWaveSP.xy; // screen UVs

    WaterInputData inputData;
    InitializeInputData(IN, inputData, screenUV.xy);
	
    WaterSurfaceData surfaceData;
    InitializeSurfaceData(inputData, surfaceData, IN.additionalData);

    half4 current;
	//clip(WaterNearFade(IN.positionWS) - 0.5);
    current.a = WaterNearFade(IN.positionWS);
    current.rgb = WaterShading(inputData, surfaceData, IN.additionalData, screenUV.xy);

    return current;

    ////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////

	half4 waterFX = 0;//SAMPLE_TEXTURE2D(_WaterFXMap, sampler_ScreenTextures_linear_clamp, IN.preWaveSP.xy);

	// Depth
	float3 depth = WaterDepth(IN.positionWS, IN.additionalData, screenUV.xy);// TODO - hardcoded shore depth UVs

    // Detail waves
    DetailNormals(IN.normalWS, IN.uv, waterFX, depth.x);

    // Distortion
	half2 distortion = DistortionUVs(depth.x, IN.normalWS, IN.viewDirectionWS);
	distortion = screenUV.xy + distortion;// * clamp(depth.x, 0, 5);
	float d = depth.x;
	depth.xz = AdjustedDepth(distortion, IN.additionalData);
	distortion = depth.x < 0 ? screenUV.xy : distortion;
	depth.x = depth.x < 0 ? d : depth.x;

    // Fresnel
	half fresnelTerm = CalculateFresnelTerm(IN.normalWS, IN.viewDirectionWS.xyz);
	//return fresnelTerm.xxxx;

	// Lighting
	Light mainLight = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));
    half shadow = SoftShadows(screenUV.xy, IN.positionWS, IN.viewDirectionWS.xyz, depth.x);
    half3 GI = SampleSH(IN.normalWS);

    // SSS
    half3 directLighting = dot(mainLight.direction, half3(0, 1, 0)) * mainLight.color;
    directLighting += saturate(pow(dot(IN.viewDirectionWS.xyz, -mainLight.direction) * IN.additionalData.z, 3)) * 5 * mainLight.color;
    half3 sss = directLighting * shadow + GI;

    ////////////////////////////////////////////////////////////////////////////////////////

	// Foam
	half3 foamMap = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap,  IN.uv.zw).rgb; //r=thick, g=medium, b=light
	half depthEdge = saturate(depth.x * 20);
	half waveFoam = saturate(IN.additionalData.z - 0.75 * 0.5); // wave tips
	half depthAdd = saturate(1 - depth.x * 4) * 0.5;
	half edgeFoam = saturate((1 - min(depth.x, depth.y) * 0.5 - 0.25) + depthAdd) * depthEdge;
	half foamBlendMask = max(max(waveFoam, edgeFoam), waterFX.r * 2);
	half3 foamBlend = 0;//SAMPLE_TEXTURE2D(_AbsorptionScatteringRamp, sampler_AbsorptionScatteringRamp, half2(foamBlendMask, 0.66)).rgb;
	half foamMask = saturate(length(foamMap * foamBlend) * 1.5 - 0.1);
	// Foam lighting
	half3 foam = foamMask.xxx * (mainLight.shadowAttenuation * mainLight.color + GI);

    BRDFData brdfData;
    half a = 1;
    InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, a, brdfData);
	half3 spec = DirectBDRF(brdfData, IN.normalWS, mainLight.direction, IN.viewDirectionWS.xyz) * shadow.xxx * mainLight.color;
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, IN.positionWS);
        spec += LightingPhysicallyBased(brdfData, light, IN.normalWS, IN.viewDirectionWS.xyz);
        sss += light.distanceAttenuation * light.color;
    }
#endif

    sss *= Scattering(depth.x);

	// Reflections
	half3 reflection = SampleReflections(IN.normalWS, IN.viewDirectionWS.xyz, screenUV.xy, 0.0);

	// Refraction
	half3 refraction = Refraction(distortion, depth.x, 0);

	// Do compositing
	half3 comp = lerp(lerp(refraction, reflection, fresnelTerm) + sss + spec, foam, foamMask); //lerp(refraction, color + reflection + foam, 1-saturate(1-depth.x * 25));

	// Fog
    float fogFactor = IN.fogFactorNoise.x;
    comp = MixFog(comp, fogFactor);

    // alpha
    float3 camPos = GetCameraPositionWS();
    camPos.y = 0;
    float alpha = 1 - saturate((distance(IN.positionWS, camPos) - 50) * 1);

    //return half4(IN.additionalData.www, alpha);
    
    half3 old = comp;
    half fiftyfifty = round(screenUV.x);
    return half4(lerp(old, current.rgb, fiftyfifty), alpha);

#if defined(_DEBUG_FOAM)
    return half4(foamMask.xxx, 1);
#elif defined(_DEBUG_SSS)
    return half4(sss, 1);
#elif defined(_DEBUG_REFRACTION)
    return half4(refraction, 1);
#elif defined(_DEBUG_REFLECTION)
    return half4(reflection, 1);
#elif defined(_DEBUG_NORMAL)
    return half4(IN.normalWS.x * 0.5 + 0.5, 0, IN.normalWS.z * 0.5 + 0.5, 1);
#elif defined(_DEBUG_FRESNEL)
    return half4(fresnelTerm.xxx, 1);
#elif defined(_DEBUG_WATEREFFECTS)
    return half4(waterFX);
#elif defined(_DEBUG_WATERDEPTH)
    return half4(frac(depth.z).xxx, 1);
#else
    return half4(comp, alpha);
#endif
}

#endif // WATER_COMMON_INCLUDED
