using UnityEngine;

public interface Mod
{
    int ID { get; set; }
    string Name { get; set; }
    string ClassName { get; set; }
    int ClassTier { get; set; }
    string CustomName { get; set; }
    string Description { get; set; }

    Sprite ClassIcon { get; set; }
    Sprite Icon { get; set; }

    int Price { get; }
    float BuildTime { get; }

    int SizeInInventory { get; set; }
    int Requirement { get; set; }

}