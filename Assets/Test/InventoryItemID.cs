using Unity.Netcode;
using System;

[System.Serializable]
public struct InventoryItemID : INetworkSerializable, IEquatable<InventoryItemID>
{
    public int itemID;
    public int value;

    // Optional: A constructor for easier instantiation.
    public InventoryItemID(int id, int amount)
    {
        this.itemID = id;
        this.value = amount;
    }

    public bool Equals(InventoryItemID other)
    {
        return itemID == other.itemID && value == other.value;
    }

    public override bool Equals(object obj)
    {
        if (obj is InventoryItemID)
        {
            return Equals((InventoryItemID)obj);
        }
        return false;
    }

    public override int GetHashCode()
    {
        return HashCode.Combine(itemID, value);
    }

    // This method handles the serialization and deserialization process.
    public void NetworkSerialize<T>(BufferSerializer<T> serializer) where T : IReaderWriter
    {
        serializer.SerializeValue(ref itemID);
        serializer.SerializeValue(ref value);
    }
}