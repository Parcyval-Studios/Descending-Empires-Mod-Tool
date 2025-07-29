using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectionUi : MonoBehaviour
{
   public Unit shipAi;
   public LineRenderer waypointLineRenderer;

   public Transform rangeCircle;
   public Transform verticalRangeCircle;
   private int rangeCircleSegments = 100; // Number of segments for the circle
   [HideInInspector] public Material whiteMaterial;
   public bool showWaypoints;
   public bool showRange;
   public Transform target;
   

    public void UpdateWaypoints()
    {
        if (showWaypoints)
        {
            DrawWaypoints();
        }
    }
    public void UpdateRange(Unit ship)
    {   
        shipAi = ship;
        transform.localPosition = Vector3.zero;
        if(showWaypoints)
        {
            DrawWaypoints();
        }
        if(!showRange)return;
        if(shipAi == null)return;
        DrawRange();
        DrawVerticalRange();
    }



    void Start()
    {
        waypointLineRenderer.positionCount = 1;
    }
   void Update()
   {    
        if(target != null)transform.position = target.position;
        else
        {
            ObjectPool.Instance.ReturnObject(gameObject);
        }

        waypointLineRenderer.SetPosition(0, transform.position);
   }

void DrawWaypoints()
{
        
        int waypointCount = shipAi.Waypoints.Count;
        if(waypointCount == 0)
        {
            waypointLineRenderer.positionCount = 0;
            if(shipAi.LocalFixedTarget != null)
            {   
                waypointLineRenderer.positionCount = 2;
                waypointLineRenderer.SetPosition(0, transform.position);
                waypointLineRenderer.SetPosition(1, shipAi.LocalFixedTarget.position);
                LineRendererColor(true);
            }
            return;
        }
        LineRendererColor(false);
        // Set the number of positions in the LineRenderer
        waypointLineRenderer.positionCount = waypointCount + 1;

        // Set the first position to the current position
        waypointLineRenderer.SetPosition(0, transform.position);

        // Set the positions based on the waypoints
        for (int i = 0; i < waypointCount; i++)
        {
            waypointLineRenderer.SetPosition(i + 1, shipAi.Waypoints[i]);
        }

            if(shipAi.LocalFixedTarget != null)
            {   
                waypointLineRenderer.positionCount = waypointLineRenderer.positionCount + 1;
                waypointLineRenderer.SetPosition(waypointLineRenderer.positionCount + 1, shipAi.LocalFixedTarget.position);
                LineRendererColor(true);
            }

    }

    public void DrawRange()
    {   
        rangeCircle.localScale = (shipAi.DetectionRange * 2) * Vector3.one;
    }

    public void DrawVerticalRange()
    {
        verticalRangeCircle.localScale = (shipAi.DetectionRange * 2) * Vector3.one;
    }


   public void LineRendererColor(bool red)
   {
      if(waypointLineRenderer == null)return;
      if (red) waypointLineRenderer.material.color = Color.red;
      else waypointLineRenderer.material.color = Color.white;
   }
}
