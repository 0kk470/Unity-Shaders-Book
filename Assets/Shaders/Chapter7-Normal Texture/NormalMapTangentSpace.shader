Shader "Unity Shader Book/Chapter 7/NormalMapInTangentSpace"
{
	Properties
	{
	    _Color("Color",Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map",2D) = "bump"{} //凹凸映射
        _BumpScale("Bump Scale",Range(-2.0,2.0)) = 1 //控制凹凸程度
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20

	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;  //the tangent direction of the vertex
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
				float4 pos : SV_POSITION;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float  _BumpScale;
			fixed4 _Specular;
			float  _Gloss;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//Compute the binormal 副切xian
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;

				//Construct a matrix which transform vectors from object space to tangent space
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				//it equals to "TANGENT_SPACE_ROTATION"

				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//Get the texel in the normal map
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;
				//If the texture is not marked as "Normal map"
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale
				//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				//Or Mark the texture as "Normal Map",and use the build-in function
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal , tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
}
