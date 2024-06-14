Shader "Custom/BrownianWater" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Amplitude ("Amplitude", Range(0, 1)) = 0.1
        _Frequency ("Frequency", Range(0, 10)) = 1.0
        _Speed ("Speed", Range(0, 10)) = 1.0
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
        half _Amplitude;
        half _Frequency;
        half _Speed;

        // Random direction method
        float2 RandomDirection() {
            return normalize(float2(Random.Range(-1, 1), Random.Range(-1, 1)));
        }

        // Brownian wave method
        float BrownianWave(float2 position, float time) {
            float frequency = _Frequency;
            float amplitude = _Amplitude;
            float value = 0.0;
            float persistence = 0.5;
            float lacunarity = 2.0;
            for (int i = 0; i < 4; i++) {
                value += Mathf.PerlinNoise(position.x * frequency, position.y * frequency) * amplitude;
                frequency *= lacunarity;
                amplitude *= persistence;
            }
            return value * Mathf.Sin(time * _Speed);
        }

        // Calculate normal method
        void CalculateNormal(float3 position, inout float3 normal) {
            float3 dx = ddx(position);
            float3 dy = ddy(position);
            normal = normalize(cross(dx, dy));
        }

        void vert(inout appdata_full v, out Input o) {
            float2 randomDir = RandomDirection();
            float wave = BrownianWave(v.vertex.xz + _Time.y * _Speed, _Time.y);
            v.vertex.y += wave * _Amplitude; // Displace the vertex in y direction
            CalculateNormal(v.vertex, v.normal); // Calculate normal

            o.uv_MainTex = v.texcoord;
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
