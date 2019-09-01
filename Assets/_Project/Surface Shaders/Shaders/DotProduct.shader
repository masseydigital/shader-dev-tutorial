Shader "Holistic/DotProduct" 
{
	Properties{

	}

	SubShader{

		CGPROGRAM
			#pragma surface surf Lambert

			struct Input {
				float3 viewDir;
			};

			void surf (Input IN, inout SurfaceOutput o) {
				//half dotp = dot(IN.viewDir, o.Normal);		//shade the outer part
				half dotp = 1-dot(IN.viewDir, o.Normal);	//shade the inner part
				o.Albedo = float3(dotp, 1, 1);
			}

		ENDCG
	}

	FallBack "Diffuse"
}