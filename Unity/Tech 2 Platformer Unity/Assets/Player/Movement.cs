
using NUnit.Framework.Interfaces;
using Unity.VisualScripting;
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

    [SerializeField] float climbSpeed = 5;
    [SerializeField] float ladderJumpTime = 0.4f;
    [SerializeField] float friction = 10;
    [SerializeField] Vector2 death_knockback;
    [SerializeField] float respawnDelay = 2;

    [Space]

    [Header("References")]
    [SerializeField] InputActionAsset inputMap;
    [SerializeField] Transform leftRaycast;
    [SerializeField] Transform rightRaycast;
    [SerializeField] Transform foot;
    [SerializeField] Transform pivot;
    [SerializeField] GameObject debugObject;
    [SerializeField] Animator animator;

    Rigidbody2D rb;
    InputAction move;
    InputAction jump;
    float startingGravityScale;
    bool grounded = false;
    public static Movement instance;
    LayerMask climbingLayer;
    Vector2 PlayerMovement;
    float ladderJumpTimer = 0;
    bool moving = true;

    void Awake()
    {
        climbingLayer = LayerMask.GetMask("Climbing");

        InputActionMap playerInput = inputMap.FindActionMap("Player");

        move = playerInput.FindAction("Move");
        jump = playerInput.FindAction("Jump");

    }

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        startingGravityScale = rb.gravityScale;
        grounded = CheckFloor();
        instance = this;
    }

    void FixedUpdate()
    {
        PlayerMovement = move.ReadValue<Vector2>();
        ProcessMove();

        Climb();

        if (respawn_timer > 0)
        {
            respawn_timer -= Time.fixedDeltaTime;
            if (respawn_timer <= 0)
            {
                respawn_timer = 0;
                FinishDeath();
            }
        }
    }

    private float respawn_timer = 0;
    public void Trigger_Death(Vector2 damage_source)
    {
        if (!moving) return;

        respawn_timer = respawnDelay;
        moving = false;

        Vector2 knockback = death_knockback;
        knockback.x = (rb.linearVelocityX > 0) ? 1 : -1;
        rb.linearVelocity += knockback;
    }

    private void FinishDeath()
    {
        GameManager.ReloadScene();
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
        Vector2 dir = moving ? PlayerMovement : Vector2.zero;
        rb.linearVelocityX = Mathf.MoveTowards(rb.linearVelocityX, 0, friction * Time.fixedDeltaTime); 

        float run_speed = speed;

        if (rb.IsTouchingLayers(climbingLayer))
        {
            run_speed = climbSpeed;
        }

        if (dir != Vector2.zero)
        {
            vel += dir.x * accel * Time.fixedDeltaTime;

            if (Mathf.Abs(vel) > run_speed) vel = (vel / Mathf.Abs(vel)) * run_speed;

            transform.position += new Vector3(vel, 0);
            animator.SetBool("Run", true);
        }
        else if (vel != 0)
        {
            int pos = (int)(vel / Mathf.Abs(vel));
            vel -= accel * pos * Time.fixedDeltaTime;
            if (pos * vel < 0) vel = 0;

            transform.position += new Vector3(vel, 0);
        }
        else
        {
            animator.SetBool("Run", false);
        }

        if (moving && (jump.IsPressed() && (CheckFloor() ||rb.IsTouchingLayers(climbingLayer))))
        {
            if (ladderJumpTimer > 0 && rb.IsTouchingLayers(climbingLayer)) return;

            rb.linearVelocityY += jumpHeight;
            if (rb.linearVelocityY > jumpHeight) rb.linearVelocityY = jumpHeight;
            grounded = false;
            print("Jump");
            ladderJumpTimer = ladderJumpTime;
        }

        if (dir.x * pivot.localScale.x < 0)
        {
            pivot.localScale = new Vector3(pivot.localScale.x * -1, 1);
        }
    }

    private void Climb()
    {
        if (ladderJumpTimer > 0)
        {
            if(rb.IsTouchingLayers(climbingLayer))
            {
                ladderJumpTimer -= Time.fixedDeltaTime;
            }
            else
            {
                ladderJumpTimer = 0;
            }
        }
        

        if(!rb.IsTouchingLayers(climbingLayer) || ladderJumpTimer > 0)
        {
            rb.gravityScale = startingGravityScale;
            animator.SetBool("Climb", false);
            return;
        }
        

        float vMovement = PlayerMovement.y;

        Vector2 climbingVelocity = new Vector2(rb.linearVelocityX, vMovement * Time.fixedDeltaTime * climbSpeed);

        rb.linearVelocity = climbingVelocity;


        rb.gravityScale = 0;

        animator.SetBool("Climb", true);
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        CheckFloor();
        RaycastHit2D hit = Physics2D.Raycast(collision.transform.position, Vector2.down);
        if (hit.transform.position.y >= foot.position.y) grounded = true;
    }
}
