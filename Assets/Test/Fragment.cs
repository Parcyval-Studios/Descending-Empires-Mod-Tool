using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;

public class Fragment : MonoBehaviour
{
    [HideInInspector] public bool Wreckage = false;
    public int Value;

    private Rigidbody rb;
    private NetworkObject netObj;
    private Hardpoint hp;
    public float linearDamping;
    public float mass;

    private IEnumerator Start()
    {
        hp = GetComponent<Hardpoint>();
        transform.SetParent(null);
        if (hp != null)
        {
            ((MonoBehaviour)hp).enabled = false;
        }

        rb = GetComponent<Rigidbody>();

        if (rb == null)
        {
            rb = gameObject.AddComponent<Rigidbody>();
            rb.linearDamping = linearDamping;
            rb.mass = mass;
        }

        if (!Wreckage)
        {
            while (transform.localScale.x > 0.01f)
            {
                transform.localScale -= Vector3.one * 0.15f * Time.deltaTime;
                yield return null;
            }
            transform.localScale = Vector3.zero;

            if (netObj != null && netObj.IsSpawned)
            {
                netObj.Despawn();
            }
            Destroy(gameObject);
        }
        else
        {
            /*if (NetworkManager.Singleton.IsServer && netObj != null && !netObj.IsSpawned)
            {
                netObj.Spawn();
                rb.AddForce(new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f)).normalized * 1, ForceMode.Impulse);
            }*/
        }
    }

    public void DestroyFragment()
    {
        if (netObj != null && netObj.IsSpawned)
        {
            netObj.Despawn(true);
        }
        Destroy(gameObject);
    }
}
