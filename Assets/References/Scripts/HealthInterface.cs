using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;
using Unity.Netcode.Components;

public interface Health
{
    NetworkVariable<int> Team {get; set;}
    float baseHullHealth {get; set;}
    float maxShield {get; set;}
    List<GameObject> Hardpoints {get; set;}

    NetworkVariable<float> Health {get; set;}
    NetworkVariable<float>Shield {get; set;}

    float maxHealth {get; set;}
    float hardpointHealth {get; set;}

    bool hasHealthBar{get; set;}

    void ApplyDamage(float damage, Hardpoint hardpoint);
    void IgnoreShields(float damage, Hardpoint hardpoint);
    void IgnoreHealth(float damage);

    NetworkVariable<float> engineMultiplier{get; set;}
    NetworkVariable<float> weaponMultiplier{get; set;}
    NetworkVariable<float> shieldMultiplier{get; set;}

    bool Wreckage { get; set; }
    List<GameObject> Fragments { get; set; }

    GameObject gameObject { get ; } 
}