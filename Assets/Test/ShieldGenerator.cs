using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;

public class ShieldGenerator : NetworkBehaviour, Hardpoint
{
    [field: SerializeField] public Sprite Icon {get; set;}
    [field: SerializeField] public float maxHealth{get; set;}
    [field: SerializeField] public bool wreckage { get; set; }
    public float shieldRegenAmountPerSec;
    [field: SerializeField] public NetworkVariable<float> Health {get; set;}
    public GameObject explosionPrefab;
    Health shipHealth;


    void Start()
    {   
        if(!IsServer)return;
        Health.Value = maxHealth;
        shipHealth = GetComponentInParent<Health>();
    }

    void OnEnable()
    {   
        StartCoroutine(RegenerateShields());
        if(!transform.root.GetComponent<NetworkObject>().IsSpawned) return;
        if(!IsServer)return;
        Health.Value = maxHealth;
    }

    public void GetDamage(float damage)
    {
        Health.Value -= damage;
        if(Health.Value <= 0) DestroyRpc();
    }

    [Rpc(SendTo.Everyone)]
    public void DestroyRpc()
    {   
        if(explosionPrefab != null)
        {
            Transform fire = Instantiate(explosionPrefab, transform.parent).transform;
            fire.position = transform.position;
        }
        if (wreckage)
        {
            GameObject part = Instantiate(gameObject, transform.position, transform.rotation);
            Fragment fragment = part.GetComponent<Fragment>();
            if (fragment != null) fragment.enabled = true;
        }

        gameObject.SetActive(false);
    }


    IEnumerator RegenerateShields()
    {
        while (true)
        {
            yield return new WaitForSeconds(1f);
            if (shipHealth.Shield.Value < shipHealth.maxShield)
            {
                shipHealth.Shield.Value += shieldRegenAmountPerSec * shipHealth.shieldMultiplier.Value;
                shipHealth.Shield.Value = Mathf.Clamp(shipHealth.Shield.Value, 0f, shipHealth.maxShield);
            }
        }
    }

    void OnDisable() 
    {
        if(!IsServer)return;
        if(shipHealth != null)
        {
           shipHealth.Shield.Value = 0;
        }

    }
}

