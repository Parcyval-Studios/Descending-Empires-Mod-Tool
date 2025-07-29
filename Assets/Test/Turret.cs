using System.Collections;
using System.Collections.Generic;
using Unity.Netcode;
using UnityEngine;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;

public class Turret : NetworkBehaviour, Weapon, Hardpoint
{   
    [field: SerializeField] public Sprite Icon {get; set;}
    [field: SerializeField] public float maxHealth{get; set;}
    [field: SerializeField] public NetworkVariable<float> Health {get; set;}
    [field: SerializeField] public bool wreckage { get; set; }

    [Header("Movement")]
    public float horizontalRotationSpeed = 5.0f;
    public float verticalRotationSpeed = 5.0f;
    public float maxVerticalRotation = 30.0f;
    private Quaternion baseRotationOffset;
    [Header("Combat")]
    public int targetRememberTime = 2;
    [Tooltip("predicts where the enemy will be when the shot arrives and shoots that point, only works with high rotation speed")]
    public bool projectilePrediction;
    public float fireRate;
    [Tooltip("time between shots if there are multiple barrels -> burst shots")]
    public float timeBetweenBarrelShots = 0.1f;
    [field: SerializeField] public float DetectionRange {get; set;}
    [Tooltip("the time for still shooting at it after the turret is not directly pointing at the target anymore")]
    float FireCountdown;
    [Tooltip("1 will make the projectile live as long as the detectionRange")]
    [field: SerializeField] public float lifeTimeMultiplier { get; set; }
    [Header("Assignments")]
    [Tooltip("the point from where the projectile is fired (should be an empty transform))")]
    public List<Transform> barrels = new List<Transform>();
    [Tooltip("the static FIXED base of the turret")]
    public Transform turretBase;
    [Tooltip("the rotating part of the turret")]
    public Transform turretBarrel;
    [Tooltip("the point from where the raycast detects enemies (note that it should be placed where it doesn't hit the own turret)")]
    public Animation shotAnimation;
    [field: SerializeField] public GameObject projectilePrefab { get; set; }
    public GameObject muzzleFlashPrefab;
    public GameObject firePrefab;
    public GameObject fragmentPrefab;

    [Header("Audio")]
    public AudioClip sound;
    public AudioSource audioSource;
    private Vector3 lastPosition;
    private Vector3 velocity;
    public Transform target {get; set;}
    Unit unit;
    Health health;
    Transform ship;
    Projectile projectile;
    ObjectPool pool;
    float rememberTarget;

    void Start()
    {
        if (shotAnimation != null) shotAnimation.clip.legacy = true;
        unit = GetComponentInParent<Unit>();
        pool = ObjectPool.Instance;
        lastPosition = target != null ? target.position : Vector3.zero;
        projectile = projectilePrefab.GetComponent<Projectile>();
        health = GetComponentInParent<Health>();
        ship = transform.root;
        Health.Value = maxHealth;
        float lifeTimeMultiplierr = lifeTimeMultiplier;
        lifeTimeMultiplier = (DetectionRange / projectile.Speed * lifeTimeMultiplierr);
        baseRotationOffset = Quaternion.Inverse(ship.rotation) * turretBase.rotation;
    }

    void OnEnable()
    {   
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
        if(firePrefab != null)
        {
            Transform fire = Instantiate(firePrefab, transform.parent).transform;
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

    Transform localFixedTarget;
    private void Update()
    {     
        if (unit.IsLocked.Value == true) return;

        if (FireCountdown > 0){ FireCountdown -= Time.deltaTime; }
        if (unit.overrideTarget.Value != Vector3.zero)
        {
            RotateTurretToOverride();
            return;
        }

        localFixedTarget = unit.LocalFixedTarget;
        if(localFixedTarget != null && target != localFixedTarget)
        {
            EnemyDetection();
        }
        
        if (rememberTarget <= 0 && FireCountdown <= 0)
        {   
            EnemyDetection();
        }
        if(target != null)
        {   
            HasDirectSight();
            RotateTurret();   
        }
        else
        {
            rememberTarget = 0;
        }
    }


    RaycastHit hitt;
    void HasDirectSight()
    {   
        if (projectilePrediction)
        {
            if (rememberTarget <= 0)
            {
                if (IsEnemyInSight(target))
                {
                    rememberTarget = targetRememberTime;
                }

            }
            else
            {
                rememberTarget -= Time.deltaTime;
            }
            return;
        }
        if(rememberTarget <= 0)
        {   
            Vector3 fwd = turretBarrel.forward;
            Debug.DrawRay(turretBarrel.transform.position, fwd * DetectionRange, Color.green);
            if (Physics.Raycast(turretBarrel.transform.position, fwd, out hitt, DetectionRange))
            {   
                if(hitt.collider.transform == target)
                {
                    rememberTarget = targetRememberTime;
                }
            }
        }
        else
        {
            rememberTarget -= Time.deltaTime;
        }
    }

    private void CalculateEnemyVelocity()
    {
        if (target != null)
        {
            velocity = (target.position - lastPosition) / Time.deltaTime;
            lastPosition = target.position;
        }
    }

    void RotateTurret()
    {
        if (turretBase == null || turretBarrel == null || ship == null) return;

        Vector3 aimPosition = target != null ? target.position : turretBase.position;

        if (projectilePrediction)
        {
            aimPosition = CalculatePredictedPosition();
        }

        AimBaseAndBarrel(aimPosition);

        if (rememberTarget > 0f)
        {
            Shoot();
        }
    }

    void RotateTurretToOverride()
    {
        if (turretBase == null || turretBarrel == null || ship == null) return;

        Vector3 overridePosition = unit.overrideTarget.Value;

        if (!IsTargetInSight(overridePosition)) return;

        AimBaseAndBarrel(overridePosition);

        if (unit.overrideState.Value == true) Shoot();
    }

    void AimBaseAndBarrel(Vector3 aimPosition)
    {
        Vector3 directionToTarget = aimPosition - turretBase.position;

        // ----- BASE ROTATION -----
        Vector3 flatDirection = Vector3.ProjectOnPlane(directionToTarget, ship.up);
        if (flatDirection.sqrMagnitude > 0.001f)
        {
           Quaternion desiredBaseRotation = Quaternion.LookRotation(flatDirection, ship.up);

            // Transform to local relative to ship, zero pitch/roll, keep yaw
            Quaternion localDesired = Quaternion.Inverse(ship.rotation) * desiredBaseRotation;
            localDesired = Quaternion.Euler(0f, localDesired.eulerAngles.y, 0f);

            // 🔑 Apply the mounting offset
            Quaternion finalRotation = ship.rotation * localDesired * baseRotationOffset;

            turretBase.rotation = Quaternion.RotateTowards(
                turretBase.rotation,
                finalRotation,
                horizontalRotationSpeed * Time.deltaTime
            );

        }

        Vector3 localTargetPos = turretBase.InverseTransformPoint(aimPosition);
        float targetPitch = -Mathf.Atan2(localTargetPos.y, localTargetPos.z) * Mathf.Rad2Deg;

        Vector3 currentEuler = turretBarrel.localEulerAngles;
        if (currentEuler.x > 180f) currentEuler.x -= 360f;

        float newPitch = Mathf.MoveTowards(currentEuler.x, targetPitch, verticalRotationSpeed * Time.deltaTime);

        turretBarrel.localEulerAngles = new Vector3(newPitch, 0f, 0f);
    }

    private Vector3 CalculatePredictedPosition()
    {
        CalculateEnemyVelocity(); // Update enemy velocity if needed

        Vector3 targetDirection = target.position - turretBarrel.position;
        Vector3 targetVelocity = velocity;
        float projectileSpeed = projectile.Speed;

        // Set up the quadratic equation for timeToImpact calculation
        float a = targetVelocity.sqrMagnitude - projectileSpeed * projectileSpeed;
        float b = 2 * Vector3.Dot(targetDirection, targetVelocity);
        float c = targetDirection.sqrMagnitude;
        float discriminant = b * b - 4 * a * c;

        float timeToImpact;

        // If discriminant < 0 or `a` is nearly zero, fallback to direct aim
        if (discriminant < 0 || Mathf.Approximately(a, 0))
        {
            timeToImpact = targetDirection.magnitude / projectileSpeed;
        }
        else
        {
            // Calculate the smaller positive root for timeToImpact
            timeToImpact = (-b - Mathf.Sqrt(discriminant)) / (2 * a);
            if (timeToImpact < 0)
            {
                timeToImpact = (-b + Mathf.Sqrt(discriminant)) / (2 * a);
            }
        }

        // Predicted aim position based on calculated impact time
        return target.position + targetVelocity * timeToImpact;
    }

    public void Shoot()
    {

    #if UNITY_EDITOR
            Debug.DrawLine(turretBarrel.position, turretBarrel.position + turretBarrel.forward * DetectionRange, Color.blue);
#endif

        if (FireCountdown <= 0 && health.weaponMultiplier.Value > 0)
        {
            StartCoroutine(shooting()); FireCountdown = fireRate / health.weaponMultiplier.Value;
        }
    }

    IEnumerator shooting()
    {
        if(shotAnimation != null) shotAnimation.Play();
        foreach (Transform shootPoint in barrels)
        {
            audioSource.PlayOneShot(sound);
            
            GameObject projectile = pool.GetObject(projectilePrefab);
            Projectile laser = projectile.GetComponent<Projectile>();
            laser.Initialize(shootPoint.position, shootPoint.forward);
            laser.LifeTime = lifeTimeMultiplier;
            projectile.SetActive(true);
            projectile.GetComponent<Projectile>().Team = health.Team.Value;

            if(muzzleFlashPrefab != null)
            {
                GameObject muzzleFlash = pool.GetObject(muzzleFlashPrefab);
                muzzleFlash.transform.position = shootPoint.position;
                muzzleFlash.transform.rotation = shootPoint.rotation;
                muzzleFlash.SetActive(true);
            }

            yield return new WaitForSeconds(timeBetweenBarrelShots);
        }
    }

    private float timer = 0f;
    void EnemyDetection()
    {
        timer += Time.deltaTime;
        if (timer >= 0.5f)
        {
            if (localFixedTarget != null)
            {
                if (IsEnemyInSight(localFixedTarget))
                {
                    target = localFixedTarget;
                    return;
                }

                var health = localFixedTarget.GetComponentInParent<Health>();
                if (health != null && health.Hardpoints != null)
                {
                    foreach (var hp in health.Hardpoints)
                    {
                        if (IsEnemyInSight(hp.transform))
                        {
                            target = hp.transform;
                            return;
                        }
                    }
                }
            }

            // 2. Use batched raycast for all enemies
            int enemyCount = unit.EnemiesInRange.Count;
            if (enemyCount == 0)
            {
                target = null;
                rememberTarget = 0;
                return;
            }

            var commands = new NativeArray<RaycastCommand>(enemyCount, Allocator.TempJob);
            var results = new NativeArray<RaycastHit>(enemyCount, Allocator.TempJob);

            Vector3 origin = turretBarrel.position;
            float detectionRange = DetectionRange;

            for (int i = 0; i < enemyCount; i++)
            {
                Vector3 direction = (unit.EnemiesInRange[i].position - origin).normalized;
                commands[i] = new RaycastCommand(origin, direction, detectionRange);
            }

            JobHandle handle = RaycastCommand.ScheduleBatch(commands, results, 1);
            handle.Complete();

            float nearestDistanceSqr = detectionRange * detectionRange;
            Transform nearestEnemy = null;

            for (int i = 0; i < enemyCount; i++)
            {
                if (results[i].collider != null &&
                    results[i].collider.transform == unit.EnemiesInRange[i])
                {
                    float distSqr = (unit.EnemiesInRange[i].position - transform.position).sqrMagnitude;
                    if (distSqr < nearestDistanceSqr)
                    {
                        nearestDistanceSqr = distSqr;
                        nearestEnemy = unit.EnemiesInRange[i];
                    }
                }
            }

            if (nearestEnemy != null)
            {
                target = nearestEnemy;
            }
            else
            {
                rememberTarget = 0;
                target = null;
            }

            commands.Dispose();
            results.Dispose();
            timer = 0f; // Reset timer after processing
         }
    }

    bool IsEnemyInSight(Transform potentialTarget)
    {
        if (potentialTarget == null)
            return false;

        Vector3 directionToTarget = potentialTarget.position - turretBarrel.position;

        if (Physics.Raycast(turretBarrel.position, directionToTarget.normalized, out RaycastHit hit, DetectionRange))
        {
            return hit.collider.transform == potentialTarget;
        }

        return false;
    }
    bool IsTargetInSight(Vector3 targetPosition)
    {
        Vector3 directionToTarget = targetPosition - turretBarrel.position;

        if (Physics.Raycast(turretBarrel.position, directionToTarget.normalized, out RaycastHit hit, DetectionRange))
        {
            return hit.transform.root != turretBarrel.root;
        }

        return true;
    }

    public Vector3 LookDirection 
    { 
        get 
        { 
            return turretBarrel != null ? turretBarrel.forward : transform.forward; 
        } 
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow; // Set the color of the gizmo
        Gizmos.DrawWireSphere(transform.position, DetectionRange); // Draw the detection range as a wireframe sphere
    }
}