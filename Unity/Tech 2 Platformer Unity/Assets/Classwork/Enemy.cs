using UnityEngine;

public class Enemy : MonoBehaviour
{
    [SerializeField] private float moveSpeed = 1;

    Rigidbody2D enemyCharacter;
    
    void Start()
    {
        enemyCharacter = GetComponent<Rigidbody2D>();
    }

    void Update()
    {
        enemyCharacter.linearVelocity = new Vector2(moveSpeed, 0);
    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.tag == "Player") return;

        print("thing");
        transform.localScale = new Vector2(-transform.localScale.x, transform.localScale.y);
        moveSpeed *= -1;
    }
}
