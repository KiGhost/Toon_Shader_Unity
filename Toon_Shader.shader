Shader "CustomShaderM"
{
	Properties
    {
		_Color0 ("Main Color", Color) = (0.05, 0.5, 0.1, 1.0)
		_Color1 ("Blend Color", Color) = (1.0, 0.65, 0.05, 1.0)
		_EdgeScale ("Edge Scale", Range(0.0, 10.0)) = 2
		_EdgeThreshold ("Edge Threshold", Range(0.0, 1.0)) = 0.2
		_EdgePower ("Edge Power", Range(1.0, 10.0)) = 4
		_Shininess ("Shininess", Range(1.0, 500.0)) = 50
    }
	
	SubShader 
	{
		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc" // for _LightColor0

			struct appdata
			{
				float4 vertex	: POSITION;
				float3 normal	: NORMAL;
				float4 tangent	: TANGENT;
			};
			
			struct v2f
			{
				float4 position 		: SV_POSITION;
				half3 lightDirWorld		: TEXCOORD0;
				float3 normalWorld		: TEXCOORD1;
				float4 tangentWorld		: TEXCOORD2;
				float3 binormalWorld	: TEXCOORD3;
				float3 viewDirWorld		: TEXCOORD4;
			};

			v2f vert(appdata IN)
			{
				v2f OUT;
				OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.lightDirWorld = (_WorldSpaceLightPos0.xyz - IN.vertex);
				OUT.normalWorld = UnityObjectToWorldNormal(IN.normal);			
				OUT.tangentWorld = mul(_Object2World, IN.tangent);			
				OUT.binormalWorld = cross(IN.normal, IN.tangent.xyz) * IN.tangent.w;
				OUT.viewDirWorld = WorldSpaceViewDir(IN.vertex);
				return OUT;
			}
			
            fixed4 _Color0;
            fixed4 _Color1;
            float _EdgeScale;
            float _EdgeThreshold;
            float _EdgePower;
            float _Shininess;            
			
			fixed4 frag(v2f IN) : SV_Target
			{
				// Normalize Vectors
				float3 normalWorldNorm = normalize(IN.normalWorld);
				float3 lightDirNorm = normalize(IN.lightDirWorld);
				float3 viewDirNorm = normalize(IN.viewDirWorld);
				float3 hNorm = normalize(lightDirNorm + viewDirNorm);
				
				float diffuseColor = dot(lightDirNorm, normalWorldNorm);
				float specularColor = pow(max(0, dot(viewDirNorm, normalWorldNorm)), _Shininess);
				
				// Perform edge detection
				float edge = _EdgeScale * pow(dot(viewDirNorm, normalWorldNorm), _EdgePower);
				edge = step(_EdgeThreshold, edge);
				
				// Calculate final Color
				float3 color;
				color = lerp(_Color0, _Color1, diffuseColor) + specularColor;
				color *= edge;
				
				return fixed4(color, 1.0);
			}	
			ENDCG
		}
	} 
}