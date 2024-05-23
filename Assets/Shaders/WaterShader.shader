Shader "Custom/WaterShader"
{
    Properties
    {
        _Color ("Color", Color) = (0.2, 0.5, 0.7, 1.0)
        _WaveSpeed ("Wave Speed", Float) = 0.2
        _WaveScale ("Wave Scale", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        struct Input
        {
            float3 worldPos;
        };

        float _WaveSpeed;
        float _WaveScale;

        void vert(inout appdata_full v)
        {
            float time = _Time.y * _WaveSpeed;
            float waveHeight = sin(v.vertex.x * _WaveScale + time * 0.75) * 0.2 +
                               sin(v.vertex.z * _WaveScale + time * 0.5) * 0.1 +
                               sin((v.vertex.x + v.vertex.z) * 0.5 * _WaveScale + time) * 0.05;
            v.vertex.y += waveHeight;
        }

        float4 _Color;

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
            o.Alpha = _Color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
