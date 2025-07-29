using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;


public class Engine : NetworkBehaviour, Hardpoint
{
    [field: SerializeField] public Sprite Icon {get; set;}
    [field: SerializeField] public float maxHealth{get; set;}
    public bool hasHyperdrive;
    [field: SerializeField] public bool wreckage { get; set; }
    [field: SerializeField] public NetworkVariable<float> Health {get; set;}
    public float additionalAcceleration;

    public bool controlGlow = false;
    [System.Serializable]
    public struct EmissionMaterial
    {
        public Renderer renderer;
        public int materialIndex;
        public Color baseEmissionColor;
    }

    [HideInInspector] public List<EmissionMaterial> emissionMats = new List<EmissionMaterial>();
    public Renderer[] glowRenderers;
    private MaterialPropertyBlock propBlock;

    Unit unit;
    public GameObject explosionPrefab;

    
    void Awake()
    {
        propBlock = new MaterialPropertyBlock();
        unit = GetComponentInParent<Unit>();
    }
    void Start() 
    {   
        if(!IsServer)return;
        unit = GetComponentInParent<Unit>();
        unit.baseAcceleration += additionalAcceleration;
    }

    public void GetDamage(float damage)
    {
        Health.Value -= damage;
        if(Health.Value <= 0) DestroyRpc();
    }

    void OnEnable()
    {   
        if(!transform.root.GetComponent<NetworkObject>().IsSpawned) return;
        if(!IsServer)return;
        Health.Value = maxHealth;
        unit.baseAcceleration += additionalAcceleration;
    }

#warning if repaired it's not restored
    void OnDisable() 
    {
        if(!IsServer)return;
        unit.baseAcceleration -= additionalAcceleration; 
    }

   [Rpc(SendTo.Everyone)]
public void DestroyRpc()
{
        if (controlGlow && emissionMats.Count != 0)
        {
            foreach (var emat in emissionMats)
            {
                emat.renderer.GetPropertyBlock(propBlock, emat.materialIndex);
                propBlock.SetColor("_EmissionColor", Color.black); // zero emission
                emat.renderer.SetPropertyBlock(propBlock, emat.materialIndex);
            }
        }

    if (explosionPrefab != null)
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


        private float lastIntensity = -1f;
        void Update()
        {
            if (!controlGlow || emissionMats.Count == 0) return;

            float normSpeed = Mathf.Clamp01(unit.currentSpeed / unit.maxSpeed);
            float intensity = normSpeed * 5f;

            if (Mathf.Approximately(intensity, lastIntensity)) return;
            lastIntensity = intensity;

            for (int i = 0; i < emissionMats.Count; i++)
            {
                var emat = emissionMats[i];
                var finalColor = emat.baseEmissionColor * intensity;

                emat.renderer.GetPropertyBlock(propBlock, emat.materialIndex);
                propBlock.SetColor("_EmissionColor", finalColor);
                emat.renderer.SetPropertyBlock(propBlock, emat.materialIndex);
            }
        }

}
