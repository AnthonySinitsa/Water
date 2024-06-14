Shader "Custom/Brownian" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Frequency ("Wave Frequency", Range(0,10)) = 1.0
        _Amplitude ("Wave Amplitude", Range(0,1)) = 1.0
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
            float3 worldPos;
            float3 customNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Frequency;
        float _Amplitude;

        // Random direction generator function
        float3 GetRandomDirection(float2 uv) {
            float randomX = frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            float randomZ = frac(sin(dot(uv, float2(93.9898, 67.345))) * 43758.5453);
            return normalize(float3(randomX, 0, randomZ) * 2.0 - 1.0);
        }

        // Brownian wave function
        float BrownianWave(float3 pos) {
            return sin(_Frequency * (pos.x + pos.z + _Time.y)) * _Amplitude;
        }

        // Normal calculation function
        float3 CalculateNormal(float3 pos, float waveHeight) {
            float3 dx = float3(0.01, 0, 0);
            float3 dz = float3(0, 0, 0.01);
            float waveX = cos(_Frequency * (pos.x + pos.z + _Time.y)) * waveHeight;
            float waveZ = cos(_Frequency * (pos.x + pos.z + _Time.y)) * waveHeight;

            float3 tangent = dx + waveX - waveHeight;
            float3 binormal = dz + waveZ - waveHeight;
            return normalize(cross(tangent, binormal));
        }

        void vert(inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // Apply Brownian wave to the vertex positions
            float wave = BrownianWave(v.vertex);
            v.vertex.y += wave;

            // Calculate normals based on the modified vertex positions
            o.customNormal = CalculateNormal(v.vertex, _Amplitude);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            // Use the custom normal calculated in the vertex shader
            o.Normal = IN.customNormal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
