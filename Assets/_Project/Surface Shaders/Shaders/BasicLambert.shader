Shader "Holistic/Basic/BasicLambert" 
{
	Properties{
		_Colour("Colour", Color) = (1,1,1,1)
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Spec("Specular", Range(0,1)) = 0.5					//size of Specular
		_Gloss("Gloss", Range(0,1)) = 0.5					//power of Specular
	}

	SubShader{
		Tags{
			"Queue" = "Geometry"
		}

		CGPROGRAM
			#pragma surface surf Lambert

			float4 _Colour;
			half _Spec;
			fixed _Gloss;

			struct Input {
				float2 uv_MainTex;
			};

			void surf (Input IN, inout SurfaceOutput o) {
				o.Albedo = _Colour.rgb;
				o.Specular = _Spec;
				o.Gloss = _Gloss;
			}

		ENDCG
	}

	FallBack "Diffuse"
}