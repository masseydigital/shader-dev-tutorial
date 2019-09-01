Shader "Holistic/VF/VfMat"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ScaleUvX ("Scale X", Range(1,10)) = 1
		_ScaleUvY ("Scale Y", Range(1,10)) = 1
    }
    SubShader
    {
		Tags{"Queue" = "Transparent"}
		GrabPass{}
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
			sampler2D _GrabTexture;	//This must be named liked this
            float4 _MainTex_ST;
			float _ScaleUvX;
			float _ScaleUvY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.uv.x = sin(o.uv.x * _ScaleUvX);
				o.uv.y = sin(o.uv.y * _ScaleUvY);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_GrabTexture, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
