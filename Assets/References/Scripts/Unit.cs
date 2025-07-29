
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;

public interface Unit
{ 
    Transform LocalFixedTarget { get; set; } 
    NetworkList<Vector3> Waypoints { get; set; }
    public List<Transform> EnemiesInRange {get; set;}
    NetworkVariable<Vector3> overrideTarget {get; set;}
    NetworkVariable<bool> overrideState {get; set;}
    float DetectionRange { get; set;}

    NetworkVariable<bool> IsLocked { get; set;}

    bool hasHyperdrive {get; set;}

    float maxSpeed { get; set;}
    float baseAcceleration { get; set;}
    float currentSpeed { get; set;}

    float maxRotationSpeed { get; set;}
    float rotationAcceleration { get; set;}
    float currentRotationSpeed { get; set;}

    Quaternion rotationOverride { get; set;}

    void Move(Vector3 target);
    void Rotate(Quaternion target);

    public List<Ability> Abilities {get;} 
    bool IsAbilityOnCooldown(Ability ability);
    void StartAbilityCooldown(Ability ability);
}