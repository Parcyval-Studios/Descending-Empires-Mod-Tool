using UnityEditor;
using UnityEngine;

public class CreateAssetBundles : MonoBehaviour
{
    [MenuItem("Mods/Build Mods")]
    static void BuildAllAssetBundles()
    {
        BuildPipeline.BuildAssetBundles("Assets/Mods", BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows);
    }
}