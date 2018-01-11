// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shader Book/Chapter 11/BillBoard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color Tint",Color) = (1,1,1,1)
		_VerticalBillboarding("Vertical Restraints",Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" "DisableBatching"="True" }
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VerticalBillboarding;
			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				float3 center=float3(0,0,0);
				float3 viewer = mul(unity_ObjectToWorld,float4(_WorldSpaceCameraPos,1));
				float3 normalDir = viewer - center;
				normalDir.y *= _VerticalBillboarding;
				normalDir = normalize(normalDir);

				float3 upDir = abs(normalDir.y) > 0.999?float3(0,0,1):float3(0,1,0);

				float3 rightDir = normalize(cross(normalDir,upDir));

				upDir = normalize(cross(normalDir,rightDir));
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.vertex = UnityObjectToClipPos(float4(localPos,1));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
