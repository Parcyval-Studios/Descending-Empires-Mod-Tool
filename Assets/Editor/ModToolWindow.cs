using UnityEditor;
using UnityEngine;

[InitializeOnLoad]
public class ModToolWindow : EditorWindow
{
    private string descriptionText =
    @"how to use:
    FACTIONS:
    - Right Click in the Project Window, find Create, then Factions, click and press on create Faction
    - Drag your Ships and Items into the Tiers(Levels) of the Faction
    - When finished, export the mod and find it in the Assets/Mods folder, rename the mod to have .faction as the file type
    SHIPS:
    - Create a GameObject and attach the ModTool component.
    - Press Setup
    - Add your ShipModel
    - Enter your Values (ships speed, health, etc.)
    - Add Turrets and add Explosions, Projectile Prefabs, etc.
    - When finished, press Generate to generate the rest of the values (like physic settings, etc.) this was made for you to have to do less)
    GOODS/TROOPS:
    - Right Click in the Project Window, find Create, then Inventory, click and press on create Good or Troop
    - Add it to the Factions Tier"
    ;

    static ModToolWindow()
    {
        // Open window when Unity starts
        EditorApplication.update += OpenOnStartup;
    }

    private static void OpenOnStartup()
    {
        EditorApplication.update -= OpenOnStartup;
        GetWindow<ModToolWindow>("DESCENDING EMPIRES");
    }

    private void OnGUI()
    {
        GUILayout.Label("Mod Tool", EditorStyles.boldLabel);

        EditorGUILayout.HelpBox(
            "keep this window open if you are new here",
            MessageType.Info
        );

        // Draw a non-editable, scrollable text box
        EditorGUILayout.SelectableLabel(
            descriptionText,
            EditorStyles.textArea,
            GUILayout.Height(500) // Makes it bigger
        );
    }
}

