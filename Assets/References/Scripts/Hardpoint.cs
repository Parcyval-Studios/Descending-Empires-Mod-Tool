using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;

public interface Hardpoint
{
   Sprite Icon {get;}
   NetworkVariable <float> Health {get; set;}
   float maxHealth{get; set;}
   void GetDamage(float damage);
   void DestroyRpc();
   bool wreckage { get; set; }
   GameObject gameObject { get ; } 
}
