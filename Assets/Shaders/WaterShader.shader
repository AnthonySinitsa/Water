Shader "Custom/WaterShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _WaveSpeed ("Wave Speed", Float) = 0.2
        _WaveScale ("Wave Scale", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
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
            float _WaveSpeed;
            float _WaveScale;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float sumOfSines(float x, float z, float t)
            {
                return sin(x * 1.0 + t * 0.75) * 0.2 + 
                       sin(z * 1.5 + t * 0.5) * 0.1 + 
                       sin((x + z) * 0.5 + t) * 0.05;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _WaveSpeed;
                float waveHeight = sumOfSines(i.uv.x * _WaveScale, i.uv.y * _WaveScale, t);
                fixed4 col = tex2D(_MainTex, i.uv + waveHeight);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
