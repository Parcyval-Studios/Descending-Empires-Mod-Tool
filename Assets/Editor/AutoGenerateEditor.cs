using UnityEngine;
using UnityEditor;
using Unity.VisualScripting;
using Unity.Netcode.Components;
using Unity.Netcode;

[CustomEditor(typeof(ModTool))]
public class ModToolEditor : Editor
{
    private void OnEnable()
    {
        // Hide the ModTool script field itself in the Inspector
        ModTool modToolScript = (ModTool)target;
        
        // Hide other Network-related components in the Inspector
        if (modToolScript.GetComponent<NetworkObject>() != null)
        UnityEditorInternal.InternalEditorUtility.SetIsInspectorExpanded(modToolScript.GetComponent<NetworkObject>(), false);
        if (modToolScript.GetComponent<NetworkTransform>() != null)
            UnityEditorInternal.InternalEditorUtility.SetIsInspectorExpanded(modToolScript.GetComponent<NetworkTransform>(), false);
        if (modToolScript.GetComponent<NetworkRigidbody>() != null)
            UnityEditorInternal.InternalEditorUtility.SetIsInspectorExpanded(modToolScript.GetComponent<NetworkRigidbody>(), false);
    }

    public override void OnInspectorGUI()
    {
        // Draw the remaining ModTool fields in the Inspector
        DrawDefaultInspector();

        ModTool autoGenerateScript = (ModTool)target;

        // Add buttons for Setup and Generate
        if (GUILayout.Button("Setup"))
        {       
            autoGenerateScript.Setup();
        }
        if (GUILayout.Button("Generate"))
        {       
            autoGenerateScript.Generate();
        }
    }
}
