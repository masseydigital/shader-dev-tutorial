Shader "Holistic/Advanced/SimpleOutline"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Width", Range(0.002, 0.1)) = 0.005
    }
    SubShader
    {
		ZWrite Off
        CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		float _Outline;
		float4 _OutlineColor;
		sampler2D _MainTex;
		
		struct Input{
			float2 uv_MainTex;
		};

		void vert(inout appdata_full v){
			v.vertex.xyz += v.normal * _Outline;
		}

		void surf (Input IN, inout SurfaceOutput o){
			o.Emission = _OutlineColor.rgb;
		}
		ENDCG
		
		ZWrite On
		CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
