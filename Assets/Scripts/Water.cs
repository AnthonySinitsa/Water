using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Water : MonoBehaviour
{
    public Shader waterShader;
    public int size = 10;
    public int resolution = 20;
    public float waveSpeed = 0.2f;
    public float waveScale = 0.5f;

    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private Mesh mesh;
    private Material waterMaterial;

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
            waterMaterial = new Material(waterShader);
            meshRenderer.material = waterMaterial;
        }
    }

    void Update()
    {
        // Update shader properties dynamically
        if (waterMaterial)
        {
            waterMaterial.SetFloat("_WaveSpeed", waveSpeed);
            waterMaterial.SetFloat("_WaveScale", waveScale);
        }
    }

    Vector3[] GenerateVertices()
    {
        int vertexCount = (size * resolution + 1) * (size * resolution + 1);
        Vector3[] vertices = new Vector3[vertexCount];
        float halfSize = size / 2f;
        for (int y = 0; y <= size * resolution; y++)
        {
            for (int x = 0; x <= size * resolution; x++)
            {
                vertices[y * (size * resolution + 1) + x] = new Vector3(x / (float)resolution - halfSize, 0, y / (float)resolution - halfSize);
            }
        }
        return vertices;
    }

    int[] GenerateTriangles()
    {
        int[] triangles = new int[size * size * resolution * resolution * 6];
        int index = 0;
        for (int y = 0; y < size * resolution; y++)
        {
            for (int x = 0; x < size * resolution; x++)
            {
                triangles[index++] = (y * (size * resolution + 1)) + x;
                triangles[index++] = ((y + 1) * (size * resolution + 1)) + x;
                triangles[index++] = (y * (size * resolution + 1)) + x + 1;

                triangles[index++] = ((y + 1) * (size * resolution + 1)) + x;
                triangles[index++] = ((y + 1) * (size * resolution + 1)) + x + 1;
                triangles[index++] = (y * (size * resolution + 1)) + x + 1;
            }
        }
        return triangles;
    }
}
