using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;
using System;

public interface Inventory
{   
    GameObject gameObject { get; }
    int InventoryCapacity {get; set;}
    int minCrew {get; set;}
    List<InventoryItemID> startEquipment {get; set;}
    NetworkList<InventoryItemID> Inventory { get; set; }
    NetworkVariable<bool> inCombat { get; set; }
    NetworkList<NetworkObjectReference> Connections{get; set;}
    List<Transform> EntryPoints {get; set;}
    NetworkVariable<int> captain {get; set;}
    IEnumerator Dock(NetworkObjectReference reference, int pointIndex, int otherPointIndex);
}
