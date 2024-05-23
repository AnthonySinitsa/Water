using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Water : MonoBehaviour
{
    public Shader waterShader;
    public int size = 10;
    public int resolution = 20; // Number of vertices per unit length
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
            meshRenderer.material.SetFloat("_WaveSpeed", waveSpeed);
            meshRenderer.material.SetFloat("_WaveScale", waveScale);
        }
    }

    Vector3[] GenerateVertices()
    {
        int vertexCount = (size * resolution + 1) * (size * resolution + 1);
        Vector3[] vertices = new Vector3[vertexCount];
        for (int y = 0; y <= size * resolution; y++)
        {
            for (int x = 0; x <= size * resolution; x++)
            {
                vertices[y * (size * resolution + 1) + x] = new Vector3(x / (float)resolution, 0, y / (float)resolution);
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
