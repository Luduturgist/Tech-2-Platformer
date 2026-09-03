using UnityEngine;
using UnityEngine.InputSystem;

public class ClassPlayer : MonoBehaviour
{
    [SerializeField] private InputActionAsset inputActions;
    [SerializeField] float speed = 10;
    InputAction moveAction;
    public Vector2 MoveInput { get; private set; }
    Rigidbody2D playerCharacter;

    // runs during initialization
    void Awake()
    {
        playerCharacter = GetComponent<Rigidbody2D>();
        
        InputActionMap playerMap = inputActions.FindActionMap("Player");

        moveAction = playerMap.FindAction("Move", true);

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
        float hMovement = MoveInput.x * speed;

        playerCharacter.linearVelocity = new Vector2(hMovement, playerCharacter.linearVelocity.y);
    }
}
