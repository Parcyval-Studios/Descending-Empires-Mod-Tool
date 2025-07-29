using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface Weapon
{
    Transform transform { get; }
    float DetectionRange { get; set; }
    Transform target { get; set; }
    Vector3 LookDirection { get; }
    float lifeTimeMultiplier { get; set; }
    GameObject projectilePrefab { get; set; }
}