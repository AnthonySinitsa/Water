Shader "Custom/Waves" {
  	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Rnage(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
		_WaveB ("Wave B", Vector) = (0,1,0.25,20)
		_WaveC ("Wave C", Vector) = (1,1,0.15,10)
	}
	SubShader {
		Tags { "RednerType"="Opaque" }
		LOD 200
	
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		#pragma target 3.0

		sampler2D _MainTex

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness, _Metallic;
		fixed4 _Color;
		float4 _WaveA, _WaveB, _WaveC;

		float3 GerstnerWave (
			float4 waveParameters, float3 position, inout float3 tangent, inout float3 binormal
		) {
			float steepness = waveParameters.z;
			float wavelength = waveParameters.w;
			float waveNumber = 2 * UNITY_PI / wavelength;
			float phaseSpeed = sqrt(9.8 / waveNumber);
			float2 direction = normalize(waveParameters.xy);
			float phase = waveNumber * (dot(direction, position.xz) - phaseSpeed * _Time.y);
			float amplitude = steepness / waveNumber;

			tangent += float3(
				-direction.x * direction.x * (steepness * sin(phase)),
				direction.x * (steepness * cos(phase)),
				-direction.x * direction.y * (steepness * sin(phase))
			);
			binormal += float3(
				-direction.x * direction.y * (steepness * sin(phase)),
				direction.y * (steepness * cos(phase)),
				-direction.y * direction.y * (steepness * sin(phase))
			);
			return float3(
				direction.x * (amplitude * cos(phase)),
				amplitude * sin(phase),
				direction.y * (amplitude * cos(phase))
			);
		}

		void vert(inout appdata_full vertexData) {
			float3 gridPoint = vertexData.vertex.xyz;
			float3 tangent = float3(1, 0, 0);
			float3 binormal = float3(0, 0, 1);
			float3 p = gridPoint;
			p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
			p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
			p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
			float3 normal = normalize(cross(binormal, tangent));
			vertexData.vertex.xyz = p;
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