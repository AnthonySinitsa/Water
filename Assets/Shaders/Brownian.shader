Shader "Custom/Brownian" {
  	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
		_WaveB ("Wave B", Vector) = (0,1,0.25,20)
		_WaveC ("Wave C", Vector) = (1,1,0.15,10)
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
		float4 _WaveA, _WaveB, _WaveC;
		

		float3 ExpSineWave(float4 waveParameters, float3 position, float timeOffset) {
            float steepness = waveParameters.z;
            float wavelength = waveParameters.w;
            float waveNumber = 2 * UNITY_PI / wavelength;
            float phaseSpeed = sqrt(9.8 / waveNumber);
            float2 direction = normalize(waveParameters.xy);
            float phase = waveNumber * (dot(direction, position.xz) - phaseSpeed * timeOffset);
            float amplitude = steepness / waveNumber;

            float expSinPhase = exp(sin(phase));

            return float3(
                direction.x * amplitude * expSinPhase,
                amplitude * expSinPhase,
                direction.y * amplitude * expSinPhase
            );
        }

		float3 CalculateNormal(float3 gridPoint, float3 displacement) {
            float3 dx = float3(0.01, 0, 0);
            float3 dz = float3(0, 0, 0.01);

            float3 displacementX = ExpSineWave(_WaveA, gridPoint + dx, _Time.y) +
                                   ExpSineWave(_WaveB, gridPoint + dx, _Time.y) +
                                   ExpSineWave(_WaveC, gridPoint + dx, _Time.y);

            float3 displacementZ = ExpSineWave(_WaveA, gridPoint + dz, _Time.y) +
                                   ExpSineWave(_WaveB, gridPoint + dz, _Time.y) +
                                   ExpSineWave(_WaveC, gridPoint + dz, _Time.y);

            float3 tangent = dx + displacementX - displacement;
            float3 binormal = dz + displacementZ - displacement;
            return normalize(cross(tangent, binormal));
        }

		void vert(inout appdata_full vertexData) {
			float3 gridPoint = vertexData.vertex.xyz;
            float3 displacement = ExpSineWave(_WaveA, gridPoint, _Time.y) +
                                  ExpSineWave(_WaveB, gridPoint, _Time.y) +
                                  ExpSineWave(_WaveC, gridPoint, _Time.y);

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