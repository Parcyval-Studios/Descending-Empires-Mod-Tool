using UnityEngine;

public class SimpleExplosionSound : MonoBehaviour
{
    [SerializeField] private AudioClip[] sounds;
    [SerializeField] private AudioSource audioSource;
    
    private void OnEnable()
    {
        if (sounds.Length > 0 && audioSource != null)
        {
            audioSource.PlayOneShot(sounds[Random.Range(0, sounds.Length)]);
        }
    }
}