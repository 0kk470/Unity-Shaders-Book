// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shader Book/Chapter 10/Reflection"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_ReflectColor("Reflection Color",Color) = (1,1,1,1)
		_ReflectionAmount("ReflectAmount",Range(0,1)) = 1
		_CubeMap("Reflection CubeMap",Cube) = "Skybox"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase" }
		LOD 100


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float3 worldPos:TEXCOORD0;
				fixed3 worldNormal:TEXCOORD1;
				fixed3 worldViewDir:TEXCOORD2;
				fixed3 worldRefl:TEXCOORD3;
				float4 pos : SV_POSITION;
				SHADOW_COORDS(4)
			};

			fixed4 _Color;
			fixed4 _ReflectColor;
			float _ReflectionAmount;
			samplerCUBE _CubeMap;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefl = reflect(-o.worldViewDir,o.worldNormal);

				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

				fixed3 reflection = texCUBE(_CubeMap,i.worldRefl).rgb * _ReflectColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);  //compute the attenuation

				fixed3 color = ambient + lerp(diffuse,reflection,_ReflectionAmount) * atten;


				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
