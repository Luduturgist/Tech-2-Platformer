using Mono.Cecil.Cil;
using UnityEngine;

public class Health : MonoBehaviour
{
    [SerializeField] int health = 10;
    
    public void TakeDamage(int amount)
    {
        Debug.Log("Ow");
        health -= amount;
        if (health <= 0) Die();
    }

    public void Die()
    {
        GameManager.ReloadScene();
    }
}
