Shader "Custom/Brownian" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Octaves ("Octaves", Int) = 4
        _Lacunarity ("Lacunarity", Float) = 2.0
        _Gain ("Gain", Float) = 0.5
        _WaveBase ("Base Wave (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
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

        half _Glossiness, _Metallic;
        fixed4 _Color;
        float4 _WaveBase;
        int _Octaves;
        float _Lacunarity, _Gain;

        float hash(uint n) {
            n = (n << 13U) ^ n;
            n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
            return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
        }

        float3 ExpSineWave(float3 position, float timeOffset) {
            float3 sum = float3(0, 0, 0);
            float amplitude = 1.0;
            float frequency = 1.0;

            for (int i = 0; i < _Octaves; i++) {
                float waveNumber = 2 * UNITY_PI / (_WaveBase.w / frequency);
                float phaseSpeed = sqrt(9.8 / waveNumber);
                float2 direction = normalize(float2(hash(i * 13U), hash(i * 31U)) * 2.0 - 1.0);
                float phase = waveNumber * (dot(direction, position.xz) - phaseSpeed * timeOffset);
                float currentWave = amplitude * exp(sin(phase));

                sum += float3(direction.x * currentWave, currentWave, direction.y * currentWave);

                frequency *= _Lacunarity;
                amplitude *= _Gain;
            }

            return sum;
        }

        float3 CalculateNormal(float3 gridPoint, float3 displacement) {
            float3 dx = float3(0.01, 0, 0);
            float3 dz = float3(0, 0, 0.01);

            float3 displacementX = ExpSineWave(gridPoint + dx, _Time.y);
            float3 displacementZ = ExpSineWave(gridPoint + dz, _Time.y);

            float3 tangent = dx + displacementX - displacement;
            float3 binormal = dz + displacementZ - displacement;
            return normalize(cross(tangent, binormal));
        }

        void vert(inout appdata_full vertexData) {
            float3 gridPoint = vertexData.vertex.xyz;
            float3 displacement = ExpSineWave(gridPoint, _Time.y);

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
