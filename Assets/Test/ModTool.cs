#if UNITY_EDITOR
using UnityEngine;
using System.Linq;
using Unity.Netcode;
using Unity.Netcode.Components;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.Collections.Generic;

[ExecuteInEditMode]
public class ModTool : MonoBehaviour
{   
    [Tooltip("combine meshes to a single model to increase performance A LOT, don't enable if your model has seperate mesh parts for destruction")]
    public bool combineMesh = false;
    Health health;
    Unit unit;
    Mod mod;
    public void Generate() 
    {   
        health = GetComponent<Health>();
        unit = GetComponent<Unit>();
        mod = GetComponent<Mod>();
        
        if (health != null)
        {
            CalculateHealth(); 
            health.Hardpoints.Clear();
        }
        else
        {
            Debug.LogError("No Health Script found");
        }
        transform.localScale = new Vector3(1,1,1);
        if(GetComponent<Rigidbody>())
        {
            GetComponent<Rigidbody>().useGravity = false;
            GetComponent<Rigidbody>().interpolation = RigidbodyInterpolation.Interpolate;
            GetComponent<Rigidbody>().angularDamping = 0;
            GetComponent<Rigidbody>().linearDamping = 0;
            CalculateBoundingBox(gameObject);
            if(mod != null)
            {   
                //GetComponent<Rigidbody>().linearDamping = mod.ClassTier;
                //GetComponent<Rigidbody>().angularDamping = mod.ClassTier;
                //GetComponent<Rigidbody>().mass = mod.ClassTier * 2;
            }
            
        }
        AddFragments();
        FindHardpointsRecursive(transform);
        CalculateEngineGlow();
        CalculateDetectionRange();
        RegisterNetwork();
        if(combineMesh)
        {
            CombineMesh();
        }
        
        EditorUtility.SetDirty(gameObject);
        DestroyImmediate(this);
    }

    void AddFragments()
    {

        Health health = transform.root.GetComponent<Health>();

        foreach (GameObject child in health.Fragments)
        {   
            if (health.Fragments.Contains(child)) continue;
            health.Fragments.Add(child);
        }
        foreach (GameObject child in health.Fragments)
        {
            if (child.GetComponent<Hardpoint>() == null)
            {
                Rigidbody rb = child.AddComponent<Rigidbody>();
                rb.linearDamping = 0.5f;
                rb.mass = GetComponent<Rigidbody>().mass / health.Fragments.Count;
                Fragment fragment = child.gameObject.AddComponent<Fragment>();
                fragment.Wreckage = health.Wreckage;
                fragment.Value = (mod.Price / health.Fragments.Count) / 2;
                fragment.enabled = false;
            }
            else
            {
                if (!child.GetComponent<Hardpoint>().wreckage) continue;
                Fragment fragment = child.gameObject.AddComponent<Fragment>();
                fragment.Wreckage = health.Wreckage;
                fragment.Value = (mod.Price / health.Fragments.Count) / 2;
                fragment.enabled = false;
                fragment.mass = GetComponent<Rigidbody>().mass / health.Fragments.Count;
                fragment.linearDamping = 0.15f;
                fragment.enabled = false;
            }


            /*if (fragment.Wreckage && child.GetComponent<Hardpoint>() == null)
            {
                child.AddComponent<NetworkObject>();
                child.AddComponent<NetworkTransform>();
            }*/
            if (child.GetComponent<Hardpoint>() == null)
            {
                child.gameObject.SetActive(false);
            }


        }   
            foreach (GameObject hardpoint in health.Hardpoints)
            {   
                if (hardpoint.GetComponent<Hardpoint>() == null) continue;
                if(!hardpoint.GetComponent<Hardpoint>().wreckage) continue;
                Fragment fragment = hardpoint.gameObject.AddComponent<Fragment>();
                fragment.Wreckage = health.Wreckage;
                fragment.Value = (mod.Price / health.Fragments.Count) / 2;
                fragment.enabled = false;
                fragment.mass = GetComponent<Rigidbody>().mass / health.Fragments.Count;
                fragment.linearDamping = 0.15f;
                fragment.enabled = false;
            }
    }


    void FindHardpointsRecursive(Transform parent)
    {

        Hardpoint hardpoint = parent.GetComponent<Hardpoint>();
        if (hardpoint != null)
        {
            GameObject hardpointObject = parent.gameObject;
            if (!health.Hardpoints.Contains(hardpointObject))
            {
                health.Hardpoints.Add(hardpointObject);
            }
        }
        else
        {
            Debug.LogWarning("No Hardpoint Found in: " + parent);
        }

        for (int i = 0; i < parent.childCount; i++)
        {
            FindHardpointsRecursive(parent.GetChild(i));
        }
        
        
    }

void CalculateEngineGlow()
{
    foreach (GameObject hardpointt in health.Hardpoints)
    {
        Engine engine = hardpointt.GetComponent<Engine>();
        if (engine != null)
        {
            if (engine.emissionMats == null)
                engine.emissionMats = new List<Engine.EmissionMaterial>();

            engine.emissionMats.Clear();

            foreach (var rend in engine.glowRenderers)
            {
                var mats = rend.sharedMaterials;
                for (int i = 0; i < mats.Length; i++)
                {
                    var mat = mats[i];
                    if (mat.HasProperty("_EmissionColor") && mat.name.Contains("Engine"))
                    {
                        Color baseColor = mat.GetColor("_EmissionColor");
                        engine.emissionMats.Add(new Engine.EmissionMaterial
                        {
                            renderer = rend,
                            materialIndex = i,
                            baseEmissionColor = baseColor
                        });
                    }
                }
            }
        }
    }
}

    


Transform FindDeepChild(Transform parent, string name)
{
    foreach (Transform child in parent)
    {
        if (child.name == name)
            return child;

        Transform result = FindDeepChild(child, name);
        if (result != null)
            return result;
    }
    return null;
}


void CalculateDetectionRange()
{
    Transform weapons = FindDeepChild(transform, "Hardpoints");
    if (weapons != null)
    {
        float maxForwardDistanceToGun = 0f;
        float maxGunRange = 0f;

        foreach (Transform gunTransform in weapons)
        {
            GameObject gun = gunTransform.gameObject;
            Weapon weapon = gun.GetComponent<Weapon>();

            if (weapon != null)
            {
                // Calculate the forward distance along the ship's forward axis
                Vector3 localGunPosition = transform.InverseTransformPoint(gun.transform.position);
                float forwardDistance = Mathf.Max(0f, localGunPosition.z); // Only consider guns in front

                if (forwardDistance > maxForwardDistanceToGun)
                {
                    maxForwardDistanceToGun = forwardDistance;
                }

                if (weapon.DetectionRange > maxGunRange)
                {
                    maxGunRange = weapon.DetectionRange;
                }
            }
        }

        if (weapons.childCount > 0)
        {
            // Calculate detection range based only on forward distance + max gun range
            unit.DetectionRange = maxForwardDistanceToGun + maxGunRange;
            Debug.Log("Calculated Detection Range: " + unit.DetectionRange);
        }
        else
        {
            Debug.LogWarning("No Weapons Found");
        }
    }
    else
    {
        Debug.LogError("No 'Hardpoint' Transform Found.");
    }
}


    float temporalHealth;
    void CalculateHealth()
    {
        temporalHealth = 0;
        foreach (GameObject hardpoint in health.Hardpoints)
        {
            temporalHealth += hardpoint.GetComponent<Hardpoint>().maxHealth;
        }
        GetComponent<Health>().hardpointHealth = temporalHealth;
        Debug.Log("Calculated Hardpoint Health: " + temporalHealth);
    }



    void RegisterNetwork()
    {
        if(gameObject.GetComponent<NetworkObject>() == null)
        {
            gameObject.AddComponent<NetworkObject>();
            GetComponent<NetworkObject>().hideFlags = HideFlags.HideInInspector;
            Debug.Log("Added NetworkObject ID");
        }
        if(gameObject.GetComponent<NetworkTransform>() == null)
        {
            gameObject.AddComponent<NetworkTransform>();
            GetComponent<NetworkTransform>().hideFlags = HideFlags.HideInInspector;
            Debug.Log("Added NetworkObject NetworkTransform");
        }
        if(gameObject.GetComponent<NetworkRigidbody>() == null && gameObject.GetComponent<Rigidbody>())
        {
            gameObject.AddComponent<NetworkRigidbody>();
            GetComponent<NetworkRigidbody>().hideFlags = HideFlags.HideInInspector;
            Debug.Log("Added NetworkObject NetworkRigidbody");
        }
    }

void GenerateColliders()
{
    Transform modelTransform = transform.Find("Model");
    Transform colliderTransform = transform.Find("Collider");
    if (colliderTransform != null) Destroy(colliderTransform.gameObject);
    
    if (modelTransform == null)
    {
        Debug.LogError("No child object named 'Model' found.");
        return;
    }

    Mesh combinedMesh = new Mesh();
    
    Vector3[] vertices = new Vector3[0];
    int[] triangles = new int[0];
    
    Quaternion rotation = Quaternion.Euler(-90, 0, 0);
    
    foreach (MeshFilter meshFilter in modelTransform.GetComponentsInChildren<MeshFilter>())
    {
        Mesh mesh = meshFilter.sharedMesh;

        if (mesh == null)
            continue;

        int vertexCount = vertices.Length;
        int newVertexCount = vertexCount + mesh.vertexCount;

        Vector3[] newVertices = new Vector3[newVertexCount];
        int[] newTriangles = new int[triangles.Length + mesh.triangles.Length];

        System.Array.Copy(vertices, newVertices, vertexCount);
        System.Array.Copy(triangles, newTriangles, triangles.Length);
        
        for (int i = 0; i < mesh.vertexCount; i++)
        {
            newVertices[vertexCount + i] = rotation * mesh.vertices[i];
        }
        
        for (int i = 0; i < mesh.triangles.Length; i++)
        {
            newTriangles[triangles.Length + i] = mesh.triangles[i] + vertexCount;
        }

        vertices = newVertices;
        triangles = newTriangles;
    }

    combinedMesh.vertices = vertices;
    combinedMesh.triangles = triangles;

    combinedMesh.RecalculateNormals();
    combinedMesh.RecalculateBounds();

    GameObject collidersObject = new GameObject("Collider");
    collidersObject.transform.SetParent(transform);
    collidersObject.transform.localPosition = Vector3.zero;
    collidersObject.transform.localRotation = Quaternion.identity;
    collidersObject.transform.localScale = modelTransform.localScale;

    MeshCollider meshCollider = collidersObject.AddComponent<MeshCollider>();
    meshCollider.sharedMesh = combinedMesh;
    meshCollider.convex = true;

    Debug.Log("Combined mesh collider created and attached to 'Collider' with correct transform.");
}

void CombineMesh()
{   
    string folderPath = PrefabUtilityHelper.GetCurrentPrefabAssetPath();
    Debug.Log(folderPath);
    Transform modelTransform = transform.Find("Model");
    if(modelTransform != null && !modelTransform.gameObject.GetComponent<MeshCombiner>() && modelTransform.childCount != 0)
    {
        MeshCombiner combiner = modelTransform.gameObject.AddComponent<MeshCombiner>();
        combiner.CreateMultiMaterialMesh = true;
        combiner.CombineMeshes(true);
        Mesh mesh = combiner.GetComponent<MeshFilter>().sharedMesh;
        combiner.FolderPath = SaveCombinedMesh(mesh, folderPath);
        foreach (Transform child in modelTransform)
        {
            DestroyImmediate(child.gameObject);
        }
        if (combiner != null)
        {
            DestroyImmediate(combiner);
        }

    }

}
private string SaveCombinedMesh(Mesh mesh, string folderPath)
	{
        Debug.Log("Combined Meshes and Created New Model + Multi-Material Mesh");
		bool meshIsSaved = AssetDatabase.Contains(mesh); // If is saved then only show it in the project view.

		folderPath = folderPath.Replace('\\', '/');
		if(!meshIsSaved && !AssetDatabase.IsValidFolder("Assets/"+folderPath))
		{
			string[] folderNames = folderPath.Split('/');
			folderNames = folderNames.Where((folderName) => !folderName.Equals("")).ToArray();
			folderNames = folderNames.Where((folderName) => !folderName.Equals(" ")).ToArray();

			folderPath = "/"; // Reset folder path.
			for(int i = 0; i < folderNames.Length; i++)
			{
				folderNames[i] = folderNames[i].Trim();
				if(!AssetDatabase.IsValidFolder("Assets"+folderPath+folderNames[i]))
				{
					string folderPathWithoutSlash = folderPath.Substring(0, folderPath.Length-1); // Delete last "/" character.
					AssetDatabase.CreateFolder("Assets"+folderPathWithoutSlash, folderNames[i]);
				}
				folderPath += folderNames[i]+"/";
			}
			folderPath = folderPath.Substring(1, folderPath.Length-2); // Delete first and last "/" character.
		}



		if(!meshIsSaved)
		{
			string meshPath = "Assets/"+folderPath+"/"+mesh.name+".asset";
			int assetNumber = 1;
			while(AssetDatabase.LoadAssetAtPath(meshPath, typeof(Mesh)) != null) // If Mesh with same name exists, change name.
			{
				meshPath = "Assets/"+folderPath+"/"+mesh.name+" ("+assetNumber+").asset";
				assetNumber++;
			}

			AssetDatabase.CreateAsset(mesh, meshPath);
			AssetDatabase.SaveAssets();
			Debug.Log("<color=#ff9900><b>Mesh \""+mesh.name+"\" was saved in the \""+folderPath+"\" folder.</b></color>"); // Show info about saved mesh.
		}


		EditorGUIUtility.PingObject(mesh); // Show Mesh in the project view.
		return folderPath;
	}

    public void Setup()
    {
            GameObject model;
            Transform modelTransform = transform.Find("Model");
        if (modelTransform == null)
        {
            model = new GameObject("Model");
            model.transform.SetParent(transform);
            model.transform.localPosition = new Vector3(0, 0, 0);
            modelTransform = model.transform;
            }
            Transform fragmentsTransform = transform.Find("Fragments");
            if (fragmentsTransform == null)
            {
                GameObject hardPoints = new GameObject("Fragments");
                hardPoints.transform.SetParent(transform);
                hardPoints.transform.localPosition = new Vector3(0, 0, 0);
            }
            Transform hardPointsTransform = transform.Find("Hardpoints");
            if (hardPointsTransform == null)
            {
                GameObject hardPoints = new GameObject("Hardpoints");
                hardPoints.transform.SetParent(modelTransform);
                hardPoints.transform.localPosition = new Vector3(0, 0, 0);
            }
            
            EditorUtility.SetDirty(gameObject);
    }
     float density = 1.0f; // Adjust density based on your game

    public void CalculateBoundingBox(GameObject ship)
    {
        if (ship == null) return;

        // Get all mesh renderers in the prefab's children
        MeshRenderer[] objectColliders = ship.GetComponentsInChildren<MeshRenderer>();

        if (objectColliders.Length == 0)
        {
            Debug.LogError("No colliders found on the object to spawn.");
            return;
        }

        // Initialize bounds based on the first collider
        Bounds bounds = objectColliders[0].bounds;

        // Expand bounds to include all other colliders
        foreach (MeshRenderer col in objectColliders)
        {
            bounds.Encapsulate(col.bounds);
        }

        // Calculate center and size for the bounding box
        Vector3 boxCenter = bounds.center - ship.transform.position;
        Vector3 boxSize = bounds.size;

        // Calculate volume of the bounding box
        float volume = boxSize.x * boxSize.y * boxSize.z;

        // Calculate mass based on density and volume
        float mass = density * volume;

        // Calculate inertia tensor for a cuboid
        Vector3 inertiaTensor = new Vector3
        (
            (1.0f / 12.0f) * mass * (boxSize.y * boxSize.y + boxSize.z * boxSize.z),
            (1.0f / 12.0f) * mass * (boxSize.x * boxSize.x + boxSize.z * boxSize.z),
            (1.0f / 12.0f) * mass * (boxSize.x * boxSize.x + boxSize.y * boxSize.y)
        );

        // Apply the calculated mass and inertia tensor to the Rigidbody
        Rigidbody rb = ship.GetComponent<Rigidbody>();
        if (rb != null)
        {
            rb.mass = mass;
            //rb.inertiaTensor = inertiaTensor;
            //rb.inertiaTensorRotation = Quaternion.identity; // No rotation applied to inertia tensor
        }
        else
        {
            Debug.LogError("No Rigidbody found on the ship.");
        }
    }

}


public static class PrefabUtilityHelper
{
    /// <summary>
    /// Gets the asset path of the currently selected prefab or the prefab being edited in prefab mode.
    /// Removes "Assets/" and the object name from the path.
    /// </summary>
    /// <returns>The modified path of the prefab without "Assets/" and the prefab name, or an empty string if not in prefab mode.</returns>
    public static string GetCurrentPrefabAssetPath()
    {
        var prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
        if (prefabStage != null)
        {
            string fullPath = prefabStage.assetPath;
            if (fullPath.StartsWith("Assets/"))
            {
                fullPath = fullPath.Substring("Assets/".Length);
            }
            string directoryPath = System.IO.Path.GetDirectoryName(fullPath);
            return directoryPath;
        }
        else
        {
            return string.Empty;
        }
    }
}

#endif