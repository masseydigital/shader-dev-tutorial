Shader "Holistic/StandardSpecPbr"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Specular (R)", 2D) = "white" {}
        _SpecColor ("Specular", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue"="Geometry" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardSpecular 

        sampler2D _MainTex;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandardSpecular o)
        {
            o.Albedo = _Color.rgb;
			o.Smoothness = tex2D (_MainTex, IN.uv_MainTex).r;
            o.Specular = _SpecColor.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
