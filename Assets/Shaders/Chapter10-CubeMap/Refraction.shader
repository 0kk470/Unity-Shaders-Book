// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Refraction"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_RefractColor("RefractColor",Color)=(1,1,1,1)
		_RefractAmount("Refraction Amount",Range(0,1)) = 1
		_RefractRatio("RefractRatio",Range(0.1,1)) = 1
		_Cubemap("Refraction Cubemap",Cube) = "_Skybox"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			fixed4 _Color;
			fixed4 _RefractColor;
			float _RefractAmount;
			float _RefractRatio;
			samplerCUBE _Cubemap;
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float3 worldPos:TEXCOORD0;
				fixed3 worldNormal:TEXCOORD1;
				fixed3 worldViewDir:TEXCOORD2;
				fixed3 worldRefr:TEXCOORD3;
				float4 pos : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefr = refract(-normalize(o.worldViewDir),normalize(o.worldNormal),_RefractRatio);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			   fixed3 worldNormal = normalize(i.worldNormal);
			   fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			   fixed3 worldViewDir = normalize(i.worldViewDir);

			   fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			   fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

			   fixed3 refraction = texCUBE(_Cubemap,i.worldRefr).rgb * _RefractColor.rgb;

			   UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

			   fixed3 color = ambient + lerp(diffuse,refraction,_RefractAmount)  * atten;

			   return fixed4(color,1);
			}
			ENDCG
		}
	}
}
