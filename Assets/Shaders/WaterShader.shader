Shader "Custom/WaterShader"
{
    Properties
    {
        _Color ("Color", Color) = (0.2, 0.5, 0.7, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 worldPos;
        };

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
