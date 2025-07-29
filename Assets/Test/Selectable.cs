using UnityEngine;

public interface Selectable
{
    bool showRange { get; set; }
    bool showWaypoints { get; set; }
    GameObject gameObject { get ; } 
    SelectionUi selectionUi { get ; set;}
    bool canSelect { get; set; }
}

