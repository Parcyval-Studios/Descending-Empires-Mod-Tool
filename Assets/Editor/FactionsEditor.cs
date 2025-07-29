using UnityEditor;
using UnityEngine;
using System.IO;

[CustomEditor(typeof(Factions))]
public class FactionsEditor : Editor
{
    public override void OnInspectorGUI()
    {
        // Draw the default inspector
        DrawDefaultInspector();

        // Add a button to mark the Factions ScriptableObject as an asset bundle and build it
        if (GUILayout.Button("Export Mod"))
        {
            MarkAndBuildFactionsAssetBundle();
        }
    }

    private void MarkAndBuildFactionsAssetBundle()
    {
        // Get the selected Factions ScriptableObject
        Factions factions = (Factions)target;

        // Use the Factions ScriptableObject name as the asset bundle name
        string assetBundleName = factions.name;

        // Mark the asset for bundling by setting its assetBundleName
        string assetPath = AssetDatabase.GetAssetPath(factions);
        AssetImporter assetImporter = AssetImporter.GetAtPath(assetPath);
        assetImporter.assetBundleName = assetBundleName;

        // Specify the output path for the asset bundle
        string outputPath = "Assets/Mods";
        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }

        // Build the asset bundle for the selected platform
        BuildPipeline.BuildAssetBundles(outputPath, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows);

        Debug.Log($"Mod/Asset bundle '{assetBundleName}' has been marked and built at {outputPath}");

        // Optional: Reset the asset bundle name if you don’t need to keep it marked
        // assetImporter.assetBundleName = null;
    }
}
