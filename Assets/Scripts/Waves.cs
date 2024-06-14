using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Waves : MonoBehaviour
{
    public int resolution = 10;
    public float scale = 10f;

    public int octaves = 4;
    public float lacunarity = 2.0f;
    public float gain = 0.5f;

    private MeshFilter meshFilter;
    private bool isMeshGenerated = false;
    private Material material;

    void Start() {
        meshFilter = GetComponent<MeshFilter>();
        material = GetComponent<Renderer>().material;
        GenerateMesh();
    }

    void Update()
    {
        if (material != null) {
            material.SetInt("_Octaves", octaves);
            material.SetFloat("_Lacunarity", lacunarity);
            material.SetFloat("_Gain", gain);
        }
    }

    void GenerateMesh()
    {
        Mesh mesh = new Mesh();
        Vector3[] vertices = new Vector3[(resolution + 1) * (resolution + 1)];
        Vector2[] uv = new Vector2[(resolution + 1) * (resolution + 1)];
        int[] triangles = new int[resolution * resolution * 6];

        float stepSize = scale / resolution;

        // Generate vertices and UVs
        for (int y = 0; y <= resolution; y++)
        {
            for (int x = 0; x <= resolution; x++)
            {
                int index = y * (resolution + 1) + x;
                vertices[index] = new Vector3(x * stepSize - scale / 2, 0, y * stepSize - scale / 2);
                uv[index] = new Vector2((float)x / resolution, (float)y / resolution);
            }
        }

        // Generate triangles
        int triIndex = 0;
        for (int y = 0; y < resolution; y++)
        {
            for (int x = 0; x < resolution; x++)
            {
                int vertexIndex = y * (resolution + 1) + x;

                // First triangle
                triangles[triIndex++] = vertexIndex;
                triangles[triIndex++] = vertexIndex + resolution + 1;
                triangles[triIndex++] = vertexIndex + resolution + 2;

                // Second triangle
                triangles[triIndex++] = vertexIndex;
                triangles[triIndex++] = vertexIndex + resolution + 2;
                triangles[triIndex++] = vertexIndex + 1;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();

        meshFilter.mesh = mesh;
        isMeshGenerated = true;
    }

    void OnValidate()
    {
        if (meshFilter != null && isMeshGenerated)
        {
            GenerateMesh();
        }
    }
}
