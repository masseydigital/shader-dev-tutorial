Shader "Holistic/Advanced/Extrude"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Amount ("Extrude", Range(-1,1)) = 0.01
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        sampler2D _MainTex;
		float _Amount;

        struct Input
        {
            float2 uv_MainTex;
        };

		struct appdata{
			float4 vertex: POSITION;
			float3 normal : NORMAL;
			float4 texcoord: TEXCOORD0;
		};

		void vert(inout appdata v){
			v.vertex.xyz += v.normal * _Amount;
		}

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
