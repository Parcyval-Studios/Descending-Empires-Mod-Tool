using UnityEngine;
using System.Collections.Generic;
[CreateAssetMenu(fileName = "NewTroop", menuName = "Inventory/Troop")]
public class Troop : InventoryItem, Mod
{
    [field: Header("Troop")]
    [Tooltip("leave at 0 if troop is not a ship crew")]
    public int crewValue;
    public int damage;
    //public int armorDamage;
    public int health;
}
