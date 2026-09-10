using UnityEngine;
using UnityEngine.InputSystem;

public class ClassPlayer : MonoBehaviour
{
    [SerializeField] private InputActionAsset inputActions;
    [SerializeField] private float runSpeed = 10;
    [SerializeField] private float runAcceleration = 50;
    [SerializeField] private float runDeceleration = 50;
    [SerializeField] Transform pivot;
    InputAction moveAction;
    public Vector2 MoveInput { get; private set; }
    Rigidbody2D playerCharacter;
    Animator playerAnimator;

    // runs during initialization
    void Awake()
    {
        playerCharacter = GetComponent<Rigidbody2D>();
        
        InputActionMap playerMap = inputActions.FindActionMap("Player");

        moveAction = playerMap.FindAction("Move", true);

        playerAnimator = GetComponentInChildren<Animator>();

        playerMap.Enable();
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        MoveInput = moveAction.ReadValue<Vector2>();

        Run();
    }

    private void Run()
    {
        float hMovement = MoveInput.x * runSpeed;

        float targetSpeed = MoveInput.x * runSpeed;

        float speedChange;

        if (hMovement * pivot.localScale.x < 0)
        {
            pivot.localScale = new Vector3(-pivot.localScale.x, pivot.localScale.y, pivot.localScale.z);
        }

        if(Mathf.Abs(targetSpeed) > Mathf.Epsilon)
        {
            speedChange = runAcceleration;
        }

        else
        {
            speedChange = runDeceleration;
        }
        float newSpeed = Mathf.MoveTowards(playerCharacter.linearVelocity.x, targetSpeed, speedChange * Time.deltaTime);

        playerCharacter.linearVelocity = new Vector2(newSpeed, playerCharacter.linearVelocity.y);
        
        //playerCharacter.linearVelocity = new Vector2(hMovement, playerCharacter.linearVelocity.y);

        bool isHSpeed = playerCharacter.linearVelocityX != 0;
        playerAnimator.SetBool("Run", isHSpeed);
    }
}
