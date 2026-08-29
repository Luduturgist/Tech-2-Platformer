using UnityEngine;

public class Damage : MonoBehaviour
{
    [SerializeField] int damage = 1;

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            collision.gameObject.GetComponent<Health>().TakeDamage(damage);
        }
    }
}
