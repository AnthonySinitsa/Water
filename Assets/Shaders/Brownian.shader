Shader "Custom/Brownian" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _WaveCount ("Wave Count", Range(1, 10)) = 5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        float _Glossiness;
        float _Metallic;
        float _WaveCount;
        fixed4 _Color;

        struct Input {
            float2 uv_MainTex;
        };

        float hash(uint n) {
            n = (n << 13U) ^ n;
            n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
            return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
        }

        float2 BrownianWave(float2 position, float frequency, float amplitude) {
            float2 direction = float2(hash(uint(position.x)), hash(uint(position.y))) * 2.0 - 1.0;
            float wave = sin(dot(position, direction) * frequency);
            float2 derivative = direction * frequency * cos(dot(position, direction) * frequency);
            return float2(wave * amplitude, length(derivative) * amplitude);
        }

        float2 CalculateNormal(float2 position) {
            float sumWave = 0.0;
            float2 sumDerivative = float2(0.0, 0.0);
            float frequency = 1.0;
            float amplitude = 1.0;

            for (int i = 0; i < _WaveCount; i++) {
                float2 waveResult = BrownianWave(position, frequency, amplitude);
                sumWave += waveResult.x;
                sumDerivative += waveResult.y * amplitude;

                frequency *= 1.18;
                amplitude *= 0.82;
            }

            return sumDerivative;
        }

        void vert (inout appdata_full v) {
            float2 position = v.vertex.xy;
            float2 normalDerivative = CalculateNormal(position);
            v.normal.xy = normalDerivative;
            v.vertex.y += normalDerivative.x; // Apply wave height to vertex position
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
