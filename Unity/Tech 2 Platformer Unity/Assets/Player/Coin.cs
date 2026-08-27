using UnityEngine;

public class Coin : MonoBehaviour
{
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.tag == "Player")
        {
            Wallet.Instance.Collect();
            Destroy(gameObject);
        }
    }
}
