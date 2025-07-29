using UnityEngine;
using System.Collections.Generic;
[CreateAssetMenu(fileName = "NewGood", menuName = "Inventory/Good")]
public class Good : InventoryItem, Mod
{
    [field: Header("Good")]
    public int Value;
}
