using UnityEngine;
using UnityEditor;
using System.IO;

public class CenterPivotEditor : EditorWindow
{
    [MenuItem("Tools/Center Mesh Pivot")]
    public static void ShowWindow()
    {
        GetWindow<CenterPivotEditor>("Center Mesh Pivot");
    }

    void OnGUI()
    {
        if (GUILayout.Button("Center Pivot of Selected Meshes"))
        {
            CenterSelectedMeshPivots();
        }
    }

    private void CenterSelectedMeshPivots()
    {
        foreach (GameObject obj in Selection.gameObjects)
        {
            MeshFilter meshFilter = obj.GetComponent<MeshFilter>();
            if (meshFilter == null || meshFilter.sharedMesh == null)
            {
                Debug.LogWarning($"No MeshFilter found on {obj.name}");
                continue;
            }

            Mesh originalMesh = meshFilter.sharedMesh;
            Mesh newMesh = Instantiate(originalMesh);

            Vector3[] vertices = newMesh.vertices;
            Bounds bounds = newMesh.bounds;
            Vector3 offset = bounds.center;

            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i] -= offset;
            }

            newMesh.vertices = vertices;
            newMesh.RecalculateBounds();
            newMesh.RecalculateNormals();

            // Save new mesh asset
            string path = "Assets/CenteredMeshes";
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            string assetPath = $"{path}/{obj.name}_CenteredPivot.asset";
            AssetDatabase.CreateAsset(newMesh, assetPath);
            AssetDatabase.SaveAssets();

            // Assign new mesh
            meshFilter.sharedMesh = AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);

            // Move object to compensate for pivot shift
            obj.transform.position += obj.transform.TransformVector(offset);
        }

        Debug.Log("Pivot centering complete.");
    }
}
