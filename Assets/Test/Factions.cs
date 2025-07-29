using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Faction", menuName = "Faction/Faction Ship List")]
public class Factions : ScriptableObject
{
    [Header("Faction")]
    public Sprite Icon;
    public string Name;
    public string Description;

    [Header("Description")]
    public float Version;

    public bool isMod = true;
    [Tooltip("built for the fleet assault mode")]public bool FleetAssaultCompatible;

    [Header("Tech Upgrades")]
    [Tooltip("generate the tech upgrades or use your custom ones")] public bool autoGenerateTechUpgrades = true;

    [Header("Ship Tiers")]
    public List<Object> Level1Troops;
    public List<Object> Level2Troops;
    public List<Object> Level3Troops;
    public List<Object> Level4Troops;
    public List<Object> Level5Troops;
    public List<Object> Level6Troops;
    public List<Object> Level7Troops;
    public List<Object> Level8Troops;
    public List<Object> Level9Troops;
    public List<Object> Level10Troops;

    [Header("Ground Troops")]
    public List<Troop> GroundTroops;

    [Header("Buildings")]
    public List<Object> Buildings;

    [Header("Items")]
    public List<InventoryItem> Items;

    [Header("Base")]
    public GameObject Base;

    [Header("Music")]
    public List<AudioClip> nonCombatMusic;
    public List<AudioClip> combatMusic;
}