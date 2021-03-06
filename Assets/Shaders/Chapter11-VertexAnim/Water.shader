﻿Shader "Unlit/Water"
{
	Properties
	{
	    _Color("Color Tint",Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Magnitude("Distortion Magnitude",Float) = 1 //幅度
		_Frequency("Distortion Frequency",Float) = 1 //pin率
		_InvWaveLength("Distortion Inverse Wave Length",Float) = 10
		_Speed("Speed",Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" "DisableBatching"="True"}
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 offset;
				offset.yzw = float3(0,0,0);
				offset.x = sin(_Frequency *_Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				o.vertex = UnityObjectToClipPos(v.vertex + offset);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv += float2(0,_Time.y * _Speed);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _Color.rgb;
				return col;
			}
			ENDCG
		}
	}
}
