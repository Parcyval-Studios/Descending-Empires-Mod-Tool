
using System.Collections;
using UnityEngine;

public class Return : MonoBehaviour
{
    public int delay = 5;
    private WaitForSeconds waitForSeconds;
    private ObjectPool objectPool;

    private void Awake()
    {
        waitForSeconds = new WaitForSeconds(delay);
        objectPool = ObjectPool.Instance;
    }

    private void OnEnable()
    {
        StartCoroutine(Disable());
    }

    IEnumerator Disable()
    {
        yield return waitForSeconds;
        objectPool.ReturnObject(gameObject);
    }
}
