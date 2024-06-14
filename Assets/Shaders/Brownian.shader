Shader "Custom/Brownian" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _InitialAmplitude ("Initial Amplitude", Float) = 1.0
        _InitialFrequency ("Initial Frequency", Float) = 1.0
        _Lacunarity ("Lacunarity (Frequency Multiplier)", Float) = 1.18
        _Gain ("Gain (Amplitude Multiplier)", Float) = 0.82
        _Octaves ("Number of Octaves", Int) = 5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _InitialAmplitude, _InitialFrequency, _Lacunarity, _Gain;
        int _Octaves;

        float hash(uint n) {
            n = (n << 13U) ^ n;
            n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
            return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
        }

        float3 FractionalBrownianWave(float3 position, float timeOffset) {
            float amplitude = _InitialAmplitude;
            float frequency = _InitialFrequency;
            float3 sumDisplacement = float3(0, 0, 0);

            for (int i = 0; i < _Octaves; i++) {
                float2 direction = normalize(float2(hash(uint(i)), hash(uint(i + 1))));
                float waveNumber = 2 * UNITY_PI * frequency;
                float phaseSpeed = sqrt(9.8 / waveNumber);
                float phase = waveNumber * (dot(direction, position.xz) - phaseSpeed * timeOffset);

                float expSinPhase = exp(sin(phase));
                float3 displacement = float3(
                    direction.x * amplitude * expSinPhase,
                    amplitude * expSinPhase,
                    direction.y * amplitude * expSinPhase
                );

                sumDisplacement += displacement;

                amplitude *= _Gain;
                frequency *= _Lacunarity;
            }

            return sumDisplacement;
        }

        float3 CalculateNormal(float3 gridPoint, float3 displacement) {
            float3 dx = float3(0.01, 0, 0);
            float3 dz = float3(0, 0, 0.01);

            float3 displacementX = FractionalBrownianWave(gridPoint + dx, _Time.y);
            float3 displacementZ = FractionalBrownianWave(gridPoint + dz, _Time.y);

            float3 tangent = dx + displacementX - displacement;
            float3 binormal = dz + displacementZ - displacement;
            return normalize(cross(tangent, binormal));
        }

        void vert(inout appdata_full vertexData) {
            float3 gridPoint = vertexData.vertex.xyz;
            float3 displacement = FractionalBrownianWave(gridPoint, _Time.y);

            float3 newPosition = gridPoint + displacement;
            float3 normal = CalculateNormal(gridPoint, displacement);

            vertexData.vertex.xyz = newPosition;
            vertexData.normal = normal;
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
