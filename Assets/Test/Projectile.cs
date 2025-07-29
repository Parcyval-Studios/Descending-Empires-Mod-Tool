using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public interface Projectile
{
    float LifeTime {get; set;}
    float Speed {get; set;}
    Transform Target {get; set;}
    int Team { get; set;}
    void Initialize(Vector3 position, Vector3 direction);
}