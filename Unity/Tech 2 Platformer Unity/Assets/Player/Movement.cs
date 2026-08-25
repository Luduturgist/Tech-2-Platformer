using UnityEngine;
using UnityEngine.InputSystem;

public class Movement : MonoBehaviour
{
    [SerializeField] float speed = 10;
    [SerializeField] float height = 50;
    [SerializeField] Transform pivot;

    Rigidbody2D rb;
    InputAction move;
    InputAction jump;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        move = InputSystem.actions.FindAction("Move");
        jump = InputSystem.actions.FindAction("Jump");
    }

    void Update()
    {
        Vector2 dir = move.ReadValue<Vector2>();

        transform.position += new Vector3(dir.x * speed * Time.deltaTime, 0);

        if (jump.WasPressedThisDynamicUpdate())
        {
            rb.linearVelocityY += height;
            if (rb.linearVelocityY > height) rb.linearVelocityY = height;
        }

        if (dir.x * pivot.localScale.x < 0)
        {
            pivot.localScale = new Vector3(pivot.localScale.x * -1, 1);
        }
    }
}
