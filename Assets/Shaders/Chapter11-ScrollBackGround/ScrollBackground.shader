Shader "Unity Shader Book/Chapter 11/ScrollBackground"
{
	Properties
	{
	    
		_FarbackgroundTex ("FarTex", 2D) = "white" {}
		_NearbackgroundTex("NearTex",2D) = "white"{}
		_SpeedFar("Speed_Far",Float) = 1
		_SpeedNear("Speed_Near",Float) = 1
		_Multipiler("Layer Multipiler",Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _FarbackgroundTex;
			sampler2D _NearbackgroundTex;
			float _SpeedFar;
			float _SpeedNear;
			float _Multipiler;
			float4 _FarbackgroundTex_ST;
			float4 _NearbackgroundTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _FarbackgroundTex) + frac(float2(_Time.y * _SpeedFar,0));
				o.uv.zw = TRANSFORM_TEX(v.uv, _NearbackgroundTex) + frac(float2(_Time.y * _SpeedNear,0));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col_f = tex2D(_FarbackgroundTex, i.uv.xy);
				fixed4 col_n = tex2D(_NearbackgroundTex, i.uv.zw);
				fixed4 col = lerp(col_f,col_n,col_n.a);
				return col;
			}
			ENDCG
		}
	}
}
