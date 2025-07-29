using System.Collections;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;

public class Laser : MonoBehaviour, Projectile
{   
    [field: Header("Stats")]
    [field: SerializeField] public float Speed { get; set; }
    [field: SerializeField] public float Damage { get; set; }
    public float LifeTime { get; set; }
    [field: Header("Assignments")]
    [field: SerializeField] public GameObject shieldHitEffect;
    [field: SerializeField] public GameObject hullHitEffect; 
    public int Team { get; set; }
    public Transform Target { get; set; }
    [field: Header("Advanced Settings")]
    public float HitAnimationOffset = 0.5f;  // This is the offset of the effect
    public float MaxRayLength = 1f; // This is the maximum ray length (because we are not using colliders)

    private NativeArray<RaycastCommand> _commands;
    private NativeArray<RaycastHit> _results;
    private JobHandle _jobHandle;
    private Vector3 _previousPosition;

    public void Initialize(Vector3 position, Vector3 direction)
    {
        transform.position = position;
        transform.forward = direction;
        _previousPosition = position;
    }

    private void OnEnable()
    {
        _commands = new NativeArray<RaycastCommand>(1, Allocator.Persistent);
        _results = new NativeArray<RaycastHit>(1, Allocator.Persistent);
        _previousPosition = transform.position;
        StartCoroutine(LaserLifeTime());
    }

    private void OnDisable()
    {
        _jobHandle.Complete();
        _commands.Dispose();
        _results.Dispose();
    }

private void Update()
{
    Vector3 nextPosition = transform.position + transform.forward * Speed * Time.deltaTime;

    Vector3 direction = nextPosition - _previousPosition;
    float distance = direction.magnitude;

    if (Physics.Raycast(_previousPosition, direction.normalized, out RaycastHit hit, distance))
    {
        HandleHit(hit);
        ObjectPool.Instance.ReturnObject(gameObject);
    }
    else
    {
        transform.position = nextPosition;
        _previousPosition = nextPosition;
    }
}


    private void PerformRaycast(Vector3 fromPosition, Vector3 toPosition)
    {
        Vector3 direction = (toPosition - fromPosition).normalized;
        float distance = Vector3.Distance(fromPosition, toPosition);
        _commands[0] = new RaycastCommand(fromPosition, direction, Mathf.Max(distance, MaxRayLength));
        _jobHandle = RaycastCommand.ScheduleBatch(_commands, _results, 1, default);
        Debug.DrawLine(fromPosition, fromPosition + direction * MaxRayLength, Color.red, Time.deltaTime);


        _jobHandle.Complete();

        if (_results[0].collider != null)
        {
            HandleHit(_results[0]);
            ObjectPool.Instance.ReturnObject(gameObject);
        }
    }

    private void HandleHit(RaycastHit hit)
    {
        Health targetHealth = hit.collider.GetComponentInParent<Health>();

        if (targetHealth != null && targetHealth.Team.Value != Team)
        {
            Hardpoint targetHardpoint = hit.collider.GetComponent<Hardpoint>();
            targetHealth.ApplyDamage(Damage, targetHardpoint);
            
            if (targetHealth.Shield.Value >= 25)
            {
                GameObject hitEffect = ObjectPool.Instance.GetObject(shieldHitEffect);
                Vector3 offsetPosition = hit.point + (-transform.forward * HitAnimationOffset);
                hitEffect.transform.position = offsetPosition;
                hitEffect.transform.localRotation = Quaternion.LookRotation(hit.normal);
            }
            else
            {
                GameObject hitEffect = ObjectPool.Instance.GetObject(hullHitEffect);
                hitEffect.transform.position = hit.point;
                hitEffect.transform.localRotation = Quaternion.LookRotation(hit.normal);
            }
        }


    }

    private IEnumerator LaserLifeTime()
    {
        yield return new WaitForSeconds(LifeTime);
        ObjectPool.Instance.ReturnObject(gameObject);
    }
}
