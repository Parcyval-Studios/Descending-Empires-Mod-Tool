using System.Collections.Generic;
using System.Linq;
using UnityEngine;


[System.Serializable]
public class Pool
{
    public string name;
    public List<GameObject> objects;
    public int nextAvailableIndex;

    public Pool(string poolName)
    {
        name = poolName;
        objects = new List<GameObject>();
        nextAvailableIndex = 0;
    }
    public IEnumerable<GameObject> ActiveObjects =>
        objects.Where(o => o != null && o.activeSelf);
}