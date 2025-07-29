using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;

[CreateAssetMenu(menuName = "Abilities/Weapon Boost")]
public class WeaponBoost_Ability : Ability
{   
    bool canUse = true;

    public override void Activate(GameObject gameObject)
    {
            Debug.Log("BOOST"+ gameObject.name);
            WeaponBoostServerRpc();

            #warning add cooldown
            //MonoBehaviour shipMonoBehaviour = gameObject.GetComponent<MonoBehaviour>();
            //shipMonoBehaviour.StartCoroutine(Cooldown());
    }

    [ServerRpc]
    void WeaponBoostServerRpc()
    {

    }

    IEnumerator Cooldown()
    {
        canUse = false;
        yield return new WaitForSeconds(cooldownSec);
        canUse = true;
    }






}
