
using NUnit.Framework.Interfaces;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public class Movement : MonoBehaviour
{
    [SerializeField] bool debug;

    [Header("Settings")]
    [SerializeField] float speed = 10;
    [SerializeField] float accel = 10;
    [SerializeField] float jumpHeight = 50;
    [SerializeField] LayerMask rayMask;

    [Header("References")]
    [SerializeField] Transform leftRaycast;
    [SerializeField] Transform rightRaycast;
    [SerializeField] Transform foot;
    [Space]
    [SerializeField] Transform pivot;
    [Space]
    [SerializeField] GameObject debugObject;


    Rigidbody2D rb;
    InputAction move;
    InputAction jump;
    bool grounded = false;
    public static Movement instance;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        move = InputSystem.actions.FindAction("Move");
        jump = InputSystem.actions.FindAction("Jump");
        grounded = CheckFloor();
        instance = this;
    }

    void FixedUpdate()
    {
        ProcessMove();
    }

    bool CheckFloor()
    {
        bool g = false;
        RaycastHit2D left = Physics2D.Raycast((Vector2)leftRaycast.position, Vector2.down, Mathf.Infinity, rayMask);
        RaycastHit2D right = Physics2D.Raycast((Vector2)rightRaycast.position, Vector2.down, Mathf.Infinity, rayMask);

        if (debug)
        {
            Instantiate(debugObject, left.point, Quaternion.identity);
            Instantiate(debugObject, right.point, Quaternion.identity);
        }

        g = (left.point.y >= foot.position.y || right.point.y >= foot.position.y);

        grounded = g;
        return g;
    }

    float vel;
    void ProcessMove()
    {
        Vector2 dir = move.ReadValue<Vector2>();

        if (dir != Vector2.zero)
        {
            vel += dir.x * accel * Time.fixedDeltaTime;

            if (Mathf.Abs(vel) > speed) vel = (vel / Mathf.Abs(vel)) * speed;

            transform.position += new Vector3(vel, 0);
        }
        else if (vel != 0)
        {
            int pos = (int)(vel / Mathf.Abs(vel));
            vel -= accel * pos * Time.fixedDeltaTime;
            if (pos * vel < 0) vel = 0;

            transform.position += new Vector3(vel, 0);
        }

        if (jump.IsPressed() && grounded)
        {
            if (!CheckFloor()) return;
            rb.linearVelocityY += jumpHeight;
            if (rb.linearVelocityY > jumpHeight) rb.linearVelocityY = jumpHeight;
            grounded = false;
            print("Jump");
        }

        if (dir.x * pivot.localScale.x < 0)
        {
            pivot.localScale = new Vector3(pivot.localScale.x * -1, 1);
        }
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        CheckFloor();
        RaycastHit2D hit = Physics2D.Raycast(collision.transform.position, Vector2.down);
        if (hit.transform.position.y >= foot.position.y) grounded = true;
    }
}
