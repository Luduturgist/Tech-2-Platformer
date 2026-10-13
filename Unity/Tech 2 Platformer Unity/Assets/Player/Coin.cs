using UnityEngine;

public class Coin : MonoBehaviour
{
    [SerializeField] private AudioClip sfx;

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.tag == "Player")
        {
            Wallet.Instance.Collect();
            Destroy(gameObject);
            if (sfx != null)
            {
                AudioSource.PlayClipAtPoint(sfx, transform.position);
            }
        }
    }
}
