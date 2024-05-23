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
        Tags { "LightMode" = "ForwardBase" }

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
            float x = v.vertex.x * _WaveScale;
            float z = v.vertex.z * _WaveScale;

            float waveHeight = 
                sin(x * 1.5 + time * 0.75) * 0.1 + 
                sin(z * 1.2 + time * 0.5 + 3.14 / 3.0) * 0.2 + 
                sin((x + z) * 0.6 + time * 1.0) * 0.15 + 
                sin(x * 0.8 + z * 1.3 + time * 0.7) * 0.1 + 
                sin(z * 0.9 + x * 1.4 + time * 1.2) * 0.05;

            v.vertex.y += waveHeight;
        }

        float4 _Color;

        void surf(Input IN, inout SurfaceOutput o)
        {
            float diffuseLighting = max(1.5, dot(normalize(IN.worldPos - _WorldSpaceLightPos0.xyz), o.Normal));
            o.Albedo = _Color.rgb * diffuseLighting;
            o.Normal = normalize(cross(ddx(IN.worldPos), ddy(IN.worldPos)));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
