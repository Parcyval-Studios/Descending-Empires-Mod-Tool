using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[System.Serializable]
public abstract class Ability : ScriptableObject
{
    [SerializeField] public Sprite Icon;
    [SerializeField] public string Description;
    [SerializeField] public int cooldownSec;
    [SerializeField] public virtual void Activate(GameObject gameObject) {}
}