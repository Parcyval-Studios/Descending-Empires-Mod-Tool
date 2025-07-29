#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Ship))]

public class ShipAiEditor : Editor
{
    /*private static float maxDistance;
    private static GameObject farthestGun;

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        Mod script = target as Mod;

        if (GUILayout.Button("Generate Values"))
        {
            Generate(script);
        }
    }

    public static void Generate(Mod script)
    {
        
    }
    */
}


#endif 