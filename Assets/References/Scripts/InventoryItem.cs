using UnityEngine;
using System.Collections.Generic;

// Base class for inventory items
public abstract class InventoryItem : ScriptableObject, Mod
{
    [field: SerializeField] public string Name { get; set; }
    public string CustomName { get; set; }
    [field: SerializeField] public string ClassName { get; set; }
    [field: SerializeField] public int ClassTier { get; set; }
    [field: SerializeField] public string Description { get; set; }
    [field: SerializeField] public int Price { get; set; }
    [field: SerializeField] public float BuildTime { get; set; }
    [field: SerializeField] public Sprite Icon { get; set; }
    [field: SerializeField] public Sprite ClassIcon { get; set; }
    [field: SerializeField] public int SizeInInventory { get; set; }
    [field: SerializeField] public int ID { get; set; }
    [field: SerializeField] public int Requirement { get; set; }
}
