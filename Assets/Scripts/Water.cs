using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Water : MonoBehaviour
{
    public Shader waterShader;
    public int size = 10;
    public float waveSpeed = 0.2f;
    public float waveScale = 0.5f;

    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private Mesh mesh;

    void Start()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();

        mesh = new Mesh();
        mesh.name = "Water Mesh";
        mesh.vertices = GenerateVertices();
        mesh.triangles = GenerateTriangles();
        mesh.RecalculateNormals();

        meshFilter.mesh = mesh;

        if (waterShader)
        {
            meshRenderer.material = new Material(waterShader);
        }
    }

    Vector3[] GenerateVertices()
    {
        Vector3[] vertices = new Vector3[(size + 1) * (size + 1)];
        for (int y = 0; y <= size; y++)
        {
            for (int x = 0; x <= size; x++)
            {
                vertices[y * (size + 1) + x] = new Vector3(x, 0, y);
            }
        }
        return vertices;
    }

    int[] GenerateTriangles()
    {
        int[] triangles = new int[size * size * 6];
        int index = 0;
        for (int y = 0; y < size; y++)
        {
            for (int x = 0; x < size; x++)
            {
                triangles[index++] = (y * (size + 1)) + x;
                triangles[index++] = ((y + 1) * (size + 1)) + x;
                triangles[index++] = (y * (size + 1)) + x + 1;

                triangles[index++] = ((y + 1) * (size + 1)) + x;
                triangles[index++] = ((y + 1) * (size + 1)) + x + 1;
                triangles[index++] = (y * (size + 1)) + x + 1;
            }
        }
        return triangles;
    }

    void Update()
    {
        Vector3[] vertices = mesh.vertices;
        float time = Time.time * waveSpeed;

        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vertex = vertices[i];
            vertex.y = SumOfSines(vertex.x * waveScale, vertex.z * waveScale, time);
            vertices[i] = vertex;
        }

        mesh.vertices = vertices;
        mesh.RecalculateNormals();
    }

    float SumOfSines(float x, float z, float t)
    {
        return Mathf.Sin(x + t * 0.75f) * 0.2f + 
            Mathf.Sin(z + t * 0.5f) * 0.1f + 
            Mathf.Sin((x + z) * 0.5f + t) * 0.05f;
    }

}
