using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using Unity.Netcode;

public class ShipHealth : NetworkBehaviour, Health
{
    [field: Header("Values")]
    [field: SerializeField] public bool hasHealthBar { get; set; } = true;
    [field: SerializeField] public float baseHullHealth { get; set; }
    [field: SerializeField] public float maxShield { get; set; }
    [field: SerializeField] public List<GameObject> Hardpoints { get; set; }
    [field: SerializeField] public NetworkVariable<int> Team { get; set; }

    public NetworkVariable<float> engineMultiplier{ get; set; } = new NetworkVariable<float>(1,
        NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Owner);
    public NetworkVariable<float> weaponMultiplier{ get; set; } = new NetworkVariable<float>(1,
        NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Owner);
    public NetworkVariable<float> shieldMultiplier{ get; set; } = new NetworkVariable<float>(1,
        NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Owner);

    [field: SerializeField] public NetworkVariable<float> Health { get; set; }
    [field: SerializeField] public NetworkVariable<float> Shield { get; set; }

    [field: SerializeField] public bool Wreckage { get; set; }
    [field: SerializeField] public List<GameObject> Fragments { get; set; }
    [HideInInspector] public float maxHealth { get; set; }
    [HideInInspector] public float hardpointHealth { get; set; }
    public GameObject ExplosionEffect;


    void Start()
    {   
        if(!IsServer)return;
        maxHealth = baseHullHealth + hardpointHealth;
        Health.Value = maxHealth;
        Shield.Value = maxShield;
    }

    public void ApplyDamage(float damage, Hardpoint hardpoint)
    {   
        if(!IsServer)return;
        if (Shield.Value > 0)
        {
            if (damage >= Shield.Value)
            {
                float remainingDamage = damage - Shield.Value;
                Shield.Value = 0;
                ApplyHealthDamage(remainingDamage, hardpoint);
            }
            else
            {
                Shield.Value -= damage;
            }
        }
        else
        {
            ApplyHealthDamage(damage, hardpoint);
        }
    }

    public void IgnoreShields(float damage, Hardpoint hardpoint)
    {
        if(!IsServer)return;
        ApplyHealthDamage(damage, hardpoint);
    }

    public void IgnoreHealth(float damage)
    {
        if(!IsServer)return;
        if (Shield.Value > 0)
        {
            Shield.Value -= damage;
            if (Shield.Value < 0) Shield.Value = 0;
        }
    }

    private void ApplyHealthDamage(float damage, Hardpoint hardpoint)
    {
        if (hardpoint != null)
        {
            hardpoint.GetDamage(damage);
        }
        Health.Value -= damage;
        if(Health.Value <= 0)
        {   
            #if !UNITY_EDITOR && !INCLUDE_IGNORE
                NetworkingOrders.instance.RemoveShipInfoRpc(GetComponent<NetworkObject>());
            #endif

            DestroyRpc();
        }
    }

    [Rpc(SendTo.Everyone)]
    void DestroyRpc()
    {
        Mod mod = GetComponent<Mod>();
        if(mod != null && mod.CustomName != null )
        {   
            #if !UNITY_EDITOR && !INCLUDE_IGNORE
            GlobalMessage.instance.DefeatMessage(mod.CustomName, Team.Value);
            #endif
        }
        if(ExplosionEffect != null)
        {
            GameObject explosion = ObjectPool.Instance.GetObject(ExplosionEffect);
            explosion.transform.position = transform.position;
        }

        if (Fragments.Count != 0)
        {
            foreach (GameObject part in Fragments)
            {   
                Fragment fragment = part.GetComponent<Fragment>();
                if (fragment != null)
                {   
                    part.transform.SetParent(null);
                    part.SetActive(true);
                    fragment.enabled = true;
                }
            }
        }
        if (IsServer) GetComponent<NetworkObject>().Despawn();
        Destroy(gameObject);
     }


void OnCollisionEnter(Collision collision) 
{   
    GameObject explosion = ObjectPool.Instance.GetObject(ObjectPool.Instance.collisionEffect);
    explosion.transform.position = collision.contacts[0].point;
    if (!IsServer) return;

    Rigidbody RB = GetComponentInParent<Rigidbody>();
    Rigidbody enemyRB = collision.collider.GetComponentInParent<Rigidbody>();
    if (enemyRB != null)
    {
        float ourKE = RB.linearVelocity.sqrMagnitude;
        float enemyKE = enemyRB.linearVelocity.sqrMagnitude;
        if (ourKE > enemyKE)
        {
            float damage = ourKE - enemyKE;
            collision.collider.GetComponentInParent<Health>().IgnoreShields(damage * 100, null);
            IgnoreShields(damage * 110, null);
        }
    }
    else
    {   
        float ourKE = RB.linearVelocity.sqrMagnitude;
        IgnoreShields(ourKE * 100, null);
    }

}   


}






