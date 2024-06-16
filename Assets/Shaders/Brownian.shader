Shader "Custom/SineWaveSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0.0,1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0,1.0)) = 0.0
        _Amplitude ("Amplitude", Float) = 0.5
        _Frequency ("Frequency", Float) = 1.0
        _Speed ("Speed", Float) = 1.0
        _WaveDirection ("Wave Direction", Vector) = (1,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        struct Input
        {
            float2 uv_MainTex;
        };

        float _Amplitude, _Frequency, _Speed;
        float4 _WaveDirection;
        fixed4 _Color;

        half _Glossiness;
        half _Metallic;

        float hash(uint n) {
            // integer hash copied from Hugo Elias
            n = (n << 13U) ^ n;
            n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
            return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
        }

        // Custom methods for sine wave and normal calculation
        float BrownianWave(float3 pos)
        {
            float3 direction = hash(asuint(normalize(_WaveDirection.xyz)));
            float wave = dot(direction, pos.xz);
            return _Amplitude * sin(_Frequency * (wave + _Time * _Speed));
        }

        float3 CalculateNormal(float3 pos)
        {
            float delta = 0.01;
            float hL = BrownianWave(pos + float3(-delta, 0, 0));
            float hR = BrownianWave(pos + float3(delta, 0, 0));
            float hD = BrownianWave(pos + float3(0, 0, -delta));
            float hU = BrownianWave(pos + float3(0, 0, delta));
            float3 n = normalize(float3(hL - hR, 2.0 * delta, hD - hU));
            return n;
        }

        void vert (inout appdata_full v)
        {
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            worldPos.y += BrownianWave(worldPos);
            v.vertex = mul(unity_WorldToObject, float4(worldPos, 1.0));
            v.normal = CalculateNormal(worldPos);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo and other surface properties
            o.Albedo = _Color.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
