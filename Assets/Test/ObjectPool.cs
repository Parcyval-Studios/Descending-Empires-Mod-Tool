using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ObjectPool : MonoBehaviour
{
    public static ObjectPool Instance;

    private Dictionary<string, Pool> pools = new Dictionary<string, Pool>();

    public GameObject collisionEffect;

    public AudioSource audioSource;

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
    }

    public GameObject GetObject(GameObject prefab)
    {
        Pool pool = CheckPool(prefab);
        GameObject obj;

        // Check if there's an available inactive object
        if (pool.nextAvailableIndex > 0)
        {
            pool.nextAvailableIndex--;
            obj = pool.objects[pool.nextAvailableIndex];
        }
        else
        {
            // No available objects, instantiate a new one
            obj = Instantiate(prefab, transform);
            obj.name = prefab.name;  // Ensure the name is consistent
            pool.objects.Add(obj);
        }

        obj.SetActive(true);
        return obj;
    }

    public Pool CheckPool(GameObject prefab)
    {
        if (!pools.TryGetValue(prefab.name, out Pool pool))
        {
            pool = new Pool(prefab.name);
            pools[prefab.name] = pool;

            GameObject obj = Instantiate(prefab, transform);
            obj.name = prefab.name;  // Ensure the name is consistent
            obj.SetActive(false);
            pool.objects.Add(obj);
            pool.nextAvailableIndex = 1;
        }

        return pool;
    }

    public void ReturnObject(GameObject obj)
    {   
        if (pools.TryGetValue(obj.name, out Pool pool))
        {
            obj.SetActive(false);

            pool.objects[pool.nextAvailableIndex] = obj;
            pool.nextAvailableIndex++;
        }
        else
        {
            Debug.LogWarning($"Trying to return an object to a pool that doesn't exist: {obj.name}");
        }
    }

public IEnumerable<GameObject> GetAllActiveObjects()
{
    foreach (var pool in pools.Values)
    {
        foreach (var obj in pool.objects)
        {
            if (obj != null && obj.activeSelf)
                yield return obj;
        }
    }
}





} 