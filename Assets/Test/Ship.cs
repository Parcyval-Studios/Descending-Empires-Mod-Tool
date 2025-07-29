using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Netcode;
using UnityEngine.Rendering;
using UnityEngine.Animations;

[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(Health))]
public class Ship : NetworkBehaviour, Mod, Selectable, Unit, Inventory
{   
    [field: Header("Blueprint")]
    [field: SerializeField] public int ID {get; set;}
    [field: SerializeField] public string Name { get; set; }
    public string CustomName { get; set; }
    [field: SerializeField] public string ClassName { get; set; }
    [field: SerializeField] public int ClassTier { get; set; }
    [field: SerializeField] public string Description { get; set; }
    [field: SerializeField] public int Price { get; set; }
    [field: SerializeField] public float BuildTime { get; set; }
    [field: SerializeField] public Sprite Icon { get; set; }
    [field: SerializeField] public Sprite ClassIcon { get; set; }
    public int SizeInInventory { get; set; }
    [field: SerializeField] public int Requirement {get; set;}

    [field: Header("Movement")]
    public bool heavyMovement;
    public bool hasHyperdrive {get; set;}
    [field: SerializeField] public float maxSpeed {get; set;}
    [field: SerializeField] public float baseAcceleration { get; set;}
    [field: SerializeField] public float currentSpeed { get; set;}

    [field: Header("Rotation")]
    [field: SerializeField] public float maxRotationSpeed {get; set;}
    [field: SerializeField] public float rotationAcceleration { get; set;}
    [field: SerializeField] public Quaternion rotationOverride { get; set;}
    public float currentRotationSpeed { get; set;}

    [field: Header("Combat")]
    [field: SerializeField] public List<Ability> Abilities { get; set; }
    [field: SerializeField] public float DetectionRange { get; set; }
    [field: SerializeField] public bool showRange { get; set; } = true;
    [field: SerializeField] public bool showWaypoints { get; set; } = true;

    [field: Header("Storage")]
    [field: SerializeField] public int minCrew {get; set;}
    [field: SerializeField] public int InventoryCapacity {get; set;}
    [field: SerializeField] public List<InventoryItemID> startEquipment {get; set;}
    public NetworkVariable<bool> inCombat { get; set; } = new NetworkVariable<bool>(false);
    [field: SerializeField] public NetworkList<InventoryItemID> Inventory { get; set; }

    [field: SerializeField] public NetworkList<NetworkObjectReference> Connections{get; set;} = new NetworkList<NetworkObjectReference>();
    [field: SerializeField] public List<Transform> EntryPoints {get; set;}
    [field: SerializeField] public NetworkVariable<int> captain {get; set;} 

    [field: Header("Values")]
    public Transform LocalFixedTarget { get; set; }
    public NetworkVariable<Vector3> overrideTarget { get; set; } = new NetworkVariable<Vector3>(
    default, NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Owner);
    public NetworkVariable<bool> overrideState { get; set; } = new NetworkVariable<bool>(
    default, NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Owner);
    public NetworkList<Vector3> Waypoints { get; set; } = new NetworkList<Vector3>(
    default, NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Owner);
    public List<Transform> EnemiesInRange { get; set; } = new List<Transform>();
    public SelectionUi selectionUi { get ; set;} 
    public bool canSelect { get; set; } = true;
    [field: SerializeField] public NetworkVariable<bool> IsLocked { get; set; }
    private int currentWaypointIndex = 0;
    Rigidbody rb;
    Health health;
    float timer = 0;
    float scanInterval = 0.5f;

    void Awake()
    {
        if(NetworkManager.Singleton.IsServer)
        {   
            Inventory = new NetworkList<InventoryItemID>(startEquipment);
        }
    }
    void Start()
    {   
        rb = GetComponent<Rigidbody>();
        health = GetComponent<Health>();
    }

    void FixedUpdate()
    {
        if (IsLocked.Value == true) return;

        timer += Time.deltaTime;
        if (timer >= scanInterval)
        {
            EnemyDetection();
            timer = 0;
        }

        if (!IsServer) return;
        HandleMovement();

    }

Vector3 lastWaypoint;
void HandleMovement()
{   
    currentSpeed = rb.linearVelocity.magnitude;
    if (Waypoints.Count > 0)
        {
            if (Waypoints[0] != lastWaypoint)
            {
                currentWaypointIndex = 0;
                lastWaypoint = Waypoints[0];
            }
            Vector3 currentWaypoint = Waypoints[currentWaypointIndex];
            float distance = Vector3.Distance(transform.position, currentWaypoint);

            Vector3 horizontalTarget = new Vector3(currentWaypoint.x, transform.position.y, currentWaypoint.z);
            if (Vector3.Distance(transform.position, horizontalTarget) > 0.1f)
            {
                Rotate(Quaternion.LookRotation(currentWaypoint - transform.position));
            }

            Move(currentWaypoint);

            if (distance <= 1)
            {
                Waypoints.RemoveAt(currentWaypointIndex);
                if (currentWaypointIndex >= Waypoints.Count)
                {
                    currentWaypointIndex = Waypoints.Count - 1; // Prevent out-of-range index
                }
            }

        }

        else if (LocalFixedTarget != null)
        {
            Vector3 direction = LocalFixedTarget.position - transform.position;
            float distance = direction.magnitude;
            if (distance > DetectionRange - 1)
            {
                Vector3 newTargetPosition = transform.position + direction.normalized * (distance - DetectionRange);
                Move(newTargetPosition);
                Rotate(Quaternion.LookRotation(LocalFixedTarget.position - transform.position));
            }
            else
            {
                Stabilize();
            }
        }
        else
        {
            Stabilize();
        }
    

    
}


float targetSpeed;
public void Move(Vector3 target)
{   
    if (target == Vector3.zero)
        {
            Decelerate(Vector3.zero);
            return;
        }

    float distanceToTarget = Vector3.Distance(transform.position, target);
    float stoppingDistance = CalculateStoppingDistance();
    Vector3 horizontalTarget = new Vector3(target.x, transform.position.y, target.z);

    if (heavyMovement && Vector3.Distance(transform.position, horizontalTarget) > 0.1f) // THE ADDITION OF STOPPING DISTANCE COULD BREAK EVERYTHIN
    {
        Vector3 directionToTarget = (horizontalTarget - transform.position).normalized;
        float angleToWaypoint = Vector3.Angle(transform.forward, directionToTarget);

        targetSpeed = (angleToWaypoint > 45f)
            ? Mathf.Lerp(0, maxSpeed, 1 - (angleToWaypoint / 90f))
            : maxSpeed;
    }
    else
    {
        targetSpeed = maxSpeed;
    }

    if (distanceToTarget > stoppingDistance) // MAYBE RE ADD LATER || Waypoints.Count > 1
    {
        Accelerate(!heavyMovement, target);
    }
    else
    {
        Decelerate(target);
    }

    Vector3 localVelocity = transform.InverseTransformDirection(rb.linearVelocity);
    localVelocity.x = 0;
    if (!heavyMovement)
    {
        localVelocity.y = 0;
    }
    rb.linearVelocity = transform.TransformDirection(localVelocity);
}

private float CalculateStoppingDistance()
{
    float initialSpeed = rb.linearVelocity.magnitude;
    float deceleration = (baseAcceleration) * health.engineMultiplier.Value; // Assume a predefined maximum deceleration value

    if (deceleration <= 0f)
    {
        return float.MaxValue; // Prevent divide-by-zero or invalid deceleration
    }

    return (initialSpeed * initialSpeed) / deceleration;
}


public void Accelerate(bool forward, Vector3 target)
{
    if (forward)
    {
        Vector3 forwardDirection = transform.forward.normalized;
        Vector3 targetVelocity = forwardDirection * targetSpeed;
        Vector3 velocityDifference = targetVelocity - rb.linearVelocity;
        Vector3 forceToApply = Vector3.ClampMagnitude(velocityDifference * rb.mass, (baseAcceleration * health.engineMultiplier.Value) * rb.mass);
        rb.AddForce(forceToApply, ForceMode.Force);
    }
    else
    {   
        Vector3 directionToTarget = (target - transform.position).normalized;

        directionToTarget = transform.InverseTransformDirection(directionToTarget);
        directionToTarget.x = 0;
        directionToTarget = transform.TransformDirection(directionToTarget);

        Vector3 targetVelocity = directionToTarget * targetSpeed;
        Vector3 velocityDifference = targetVelocity - rb.linearVelocity;  // Use rb.velocity instead of rb.linearVelocity
        Vector3 forceToApply = Vector3.ClampMagnitude(velocityDifference * rb.mass, ((baseAcceleration * health.engineMultiplier.Value) * rb.mass));
        rb.AddForce(forceToApply, ForceMode.Force);

    }
}




public void Decelerate(Vector3 target)
{
    if (target == Vector3.zero)
    {
        
        if (rb.linearVelocity.magnitude < 0.1f)
        {
            rb.linearVelocity = Vector3.zero;
        }
        else
        {   
            Debug.LogError("DECELERATE");
            Vector3 stoppingForce = -rb.linearVelocity.normalized * (baseAcceleration * health.engineMultiplier.Value);
            rb.AddForce(stoppingForce, ForceMode.Acceleration);
        }
        return;
    }
    if (rb.linearVelocity.magnitude < 0.1f)
    {
        rb.linearVelocity = Vector3.zero;
        return;
    }

    float distanceToTarget = Vector3.Distance(transform.position, target);

    // Compute the required deceleration
    float requiredDeceleration = (rb.linearVelocity.magnitude * rb.linearVelocity.magnitude) / (distanceToTarget);

    // Ensure the deceleration force is applied in the opposite direction of the current velocity
    Vector3 decelerationForce = -requiredDeceleration * rb.mass * rb.linearVelocity.normalized;
    rb.AddForce(decelerationForce, ForceMode.Force);

    // Prevent overshooting by clamping velocity when nearing the target
    if (Vector3.Distance(transform.position + rb.linearVelocity * Time.fixedDeltaTime, target) < 0.1f)
    {
        rb.linearVelocity = Vector3.zero;
    }
}


public void Rotate(Quaternion targetRotation)
{
    if (heavyMovement)
    {
        // Keep X at 0, preserve Y rotation, set Z to override
        targetRotation = Quaternion.Euler(0, targetRotation.eulerAngles.y, rotationOverride.eulerAngles.z);
    }

    float angleToTarget = Quaternion.Angle(transform.rotation, targetRotation);

    // Calculate the optimal angle to start decelerating using kinematics: theta = v^2 / (2a)
    float currentAngularSpeed = rb.angularVelocity.magnitude * Mathf.Rad2Deg;
    float decelerationStartAngle = (currentAngularSpeed * currentAngularSpeed) / (rotationAcceleration);

    decelerationStartAngle = Mathf.Max(decelerationStartAngle, 5f); // Ensure a minimum threshold to prevent premature deceleration

    if (angleToTarget > decelerationStartAngle)
    {   
        AccelerateRotation(targetRotation);
    }
    else
    {   
        DecelerateRotation(targetRotation);
    }
}

void AccelerateRotation(Quaternion targetRotation)
{
    Quaternion rotationDifference = targetRotation * Quaternion.Inverse(transform.rotation);

    rotationDifference.ToAngleAxis(out float angle, out Vector3 axis);

    if (angle > 180f)
    {
        angle -= 360f;
    }

    Vector3 desiredAngularVelocity = axis * Mathf.Clamp(angle * rotationAcceleration, -maxRotationSpeed, maxRotationSpeed);
    Vector3 desiredAngularVelocityRad = desiredAngularVelocity * Mathf.Deg2Rad;
    Vector3 torque = (desiredAngularVelocityRad - rb.angularVelocity) * rb.mass;

    rb.AddTorque(torque, ForceMode.Force);
}

void DecelerateRotation(Quaternion targetRotation)
{   
    if (rb.angularVelocity.magnitude < 0.1f)
    {
        rb.angularVelocity = Vector3.zero;
        return;
    }

    Quaternion rotationDifference = targetRotation * Quaternion.Inverse(transform.rotation);
    rotationDifference.ToAngleAxis(out float angle, out Vector3 axis);

    if (angle > 180f)
    {
        angle -= 360f;
    }

    if (Mathf.Abs(angle) < 0.75f || axis == Vector3.zero)
    {
        rb.angularVelocity = Vector3.zero;
        return;
    }

    Vector3 angularVelocityDeg = rb.angularVelocity * Mathf.Rad2Deg;
    Vector3 projectedAngularVelocity = Vector3.Project(angularVelocityDeg, axis);
    Vector3 requiredDeceleration = -projectedAngularVelocity / (angle / maxRotationSpeed);
    Vector3 torque = requiredDeceleration * rb.mass * Mathf.Deg2Rad;

    if (Vector3.Dot(torque, rb.angularVelocity) > 0) 
    {
        torque = Vector3.zero;
    }

    rb.AddTorque(torque, ForceMode.Force);
}

void Stabilize()
{
    Decelerate(Vector3.zero);

    if (rb.angularVelocity.magnitude < 0.1f)
    {
        rb.angularVelocity = Vector3.zero;
        
        // Only apply Z override rotation if it's not zero and we're in heavy movement
        if (heavyMovement && rotationOverride.eulerAngles.z != 0)
        {
            Vector3 currentEuler = transform.rotation.eulerAngles;
            float zDiff = Mathf.DeltaAngle(currentEuler.z, rotationOverride.eulerAngles.z);
            
            if (Mathf.Abs(zDiff) > 1f)
            {
                Quaternion targetRot = Quaternion.Euler(0, currentEuler.y, rotationOverride.eulerAngles.z);
                Rotate(targetRot);
            }
        }
        return;
    }
    
    Vector3 decelerationTorque = -rb.angularVelocity * rotationAcceleration;
    rb.AddTorque(decelerationTorque);
}

public IEnumerator Dock(NetworkObjectReference reference, int otherPointIndex, int pointIndex)
{   
    targetSpeed = maxSpeed;
    GameObject otherShip = reference;
    Inventory inventoryOther = otherShip.GetComponent<Inventory>();
    Transform closestPointInventoryOther = inventoryOther.EntryPoints[otherPointIndex];
    Transform closestPoint = EntryPoints[pointIndex];

    if (closestPointInventoryOther != null && closestPoint != null)
    {
        
        
        Vector3 offset = closestPoint.position - closestPoint.root.position;
        Vector3 targetPosition = closestPointInventoryOther.position - offset;
        Debug.DrawLine(closestPoint.transform.position, targetPosition, Color.red);


        Vector3 otherForward = closestPointInventoryOther.forward;
        Vector3 closestForward = closestPoint.forward;

        Vector3 bestAlignment = Vector3.Dot(closestForward, otherForward) > 0 ? otherForward : -otherForward;

        Quaternion targetRotation = Quaternion.LookRotation(
            bestAlignment,
            closestPointInventoryOther.up
        );


        while (Waypoints.Count < 1)
        {
        while (true)
        {   
            //Debug.DrawLine(closestPointInventoryOther.transform.position, closestPoint.transform.position, Color.red);
            float distance = Vector3.Distance(closestPoint.transform.position, closestPointInventoryOther.transform.position);
            if (Waypoints.Count > 0)
            {
                yield break;
            }
            if (distance < 0.1f)
            {   
                Connections.Add(otherShip);
                inventoryOther.Connections.Add(gameObject);
                FixedJoint joint = otherShip.AddComponent<FixedJoint>();
                joint.connectedBody = rb;
                IsLocked.Value = true;
                yield break;
            }


                float stoppingDistance = CalculateStoppingDistance(); 
                if (distance > stoppingDistance)
                {
                    Vector3 directionToTarget = (targetPosition - transform.position).normalized;
                    Vector3 targetVelocity = directionToTarget * targetSpeed;
                    Vector3 velocityDifference = targetVelocity - rb.linearVelocity;
                    Vector3 forceToApply = Vector3.ClampMagnitude(velocityDifference * rb.mass, ((baseAcceleration * health.engineMultiplier.Value) * rb.mass));
                    rb.AddForce(forceToApply, ForceMode.Force);
                }
                else
                {
                    Decelerate(targetPosition);
                }
                
                
                float angleToTarget = Quaternion.Angle(transform.rotation, targetRotation);

                // Calculate the optimal angle to start decelerating using kinematics: theta = v^2 / (2a)
                float currentAngularSpeed = rb.angularVelocity.magnitude * Mathf.Rad2Deg;
                float decelerationStartAngle = (currentAngularSpeed * currentAngularSpeed) / (2 * rotationAcceleration);

                decelerationStartAngle = Mathf.Max(decelerationStartAngle, 5f); // Ensure a minimum threshold to prevent premature deceleration

                if (angleToTarget > decelerationStartAngle)
                {   
                    AccelerateRotation(targetRotation);
                }
                else
                {   
                    DecelerateRotation(targetRotation);
                }

            yield return new WaitForFixedUpdate();
        }
                yield break;
            }
            yield break;
        
    }
}



private static readonly Collider[] _overlapBuffer = new Collider[256]; // Pool instead of allocating

void EnemyDetection()
{
    EnemiesInRange.Clear();

    int count = Physics.OverlapSphereNonAlloc(transform.position, DetectionRange + 1f, _overlapBuffer);
    for (int i = 0; i < count; i++)
    {
        var collider = _overlapBuffer[i];
        var healthComp = collider.GetComponentInParent<Health>();
        if (healthComp != null &&
            healthComp.Team.Value != health.Team.Value &&
            healthComp.Team.Value != 0)
        {
            EnemiesInRange.Add(collider.transform);
        }
    }
}



    private Dictionary<Ability, float> abilityCooldowns = new Dictionary<Ability, float>();

    public bool IsAbilityOnCooldown(Ability ability)
    {
        if (abilityCooldowns.TryGetValue(ability, out float cooldownEndTime))
        {
            return Time.time < cooldownEndTime;
        }
        return false;
    }

    public void StartAbilityCooldown(Ability ability)
    {
        abilityCooldowns[ability] = Time.time + ability.cooldownSec;
    }



    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, DetectionRange);

    }
}
