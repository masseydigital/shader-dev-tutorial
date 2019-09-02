Shader "Holistic/Advanced/SphericalFog"
{
    Properties
    {
		_FogCenter("Fog Center/Radius", Vector) = (0,0,0,0.5)
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_InnerRatio("Inner Ratio", Range(0.0, 0.9)) = 0.5
		_Density("Density", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			float CalculateFogIntensity(
			float3 sphereCenter,
			float sphereRadius, 
			float innerRatio, 
			float density, 
			float3 cameraPosition,
			float3 viewDirection,
			float maxDistance)
			{
				// calculate ray-sphere intersection
				float3 localCam = cameraPosition - sphereCenter;

				// calculate a, b, c values
				float a = dot (viewDirection, viewDirection);
				float b = 2 * dot (viewDirection, localCam);
				float c = dot (localCam, localCam) - sphereRadius * sphereRadius;

				// calculate the discriminant to figure out how many intersections
				float d = b * b - 4 * a * c;
				if(d <= 0.0f)
					return 0;

				// calculate our two distances
				float DSqrt = sqrt(d);
				float dist = max(( -b - DSqrt) / 2*a, 0);
				float dist2 = max(( -b + DSqrt) / 2*a, 0);

				// set the back depth, start position and step distance
				float backDepth = min(maxDistance, dist2);
				float sample = dist;
				float stepDistance = (backDepth - dist) / 10;

				// set the strength of the fog as we step closer, center strength, and clarity
				float stepContribution = density;
				float centerValue = 1/(1 - innerRatio);
				float clarity = 1;

				// start stepping
				for(int seg=0; seg < 10; seg++){
					float3 position = localCam + viewDirection * sample;
					float val = saturate(centerValue * (1-length(position) / sphereRadius));
					float fogAmount = saturate(val * stepContribution);
					clarity *= (1-fogAmount);
					sample += stepDistance;
				}

				return 1 - clarity;
			}

            struct v2f
            {
                float3 view : TEXCOORD0;
                float4 pos : SV_POSITION;
				float4 projPos : TEXCOORD1;
            };

            float4 _FogCenter;
			fixed4 _FogColor;
			float _InnerRatio;
			float _Density;
			sampler2D _CameraDepthTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                float4 wPos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.view = wPos.xyz - _WorldSpaceCameraPos;
				o.projPos = ComputeScreenPos(o.pos);

				float inFrontOf = (o.pos.z/o.pos.w) > 0;
				o.pos.z *= inFrontOf;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 color = half4(1,1,1,1);
				float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj (_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos))));
				float3 viewDir = normalize(i.view);

				float fog = CalculateFogIntensity(
					_FogCenter.xyz,
					_FogCenter.w,
					_InnerRatio,
					_Density,
					_WorldSpaceCameraPos,
					viewDir,
					depth
				);

				color.rgb = _FogColor.rgb;
				color.a = fog;

				return color;
            }
            ENDCG
        }
    }
}
