using UnityEngine;
using UnityEngine.InputSystem;

public class ClassPlayer : MonoBehaviour
{
    [SerializeField] private InputActionAsset inputActions;
    InputAction moveAction;

    // runs during initialization
    void Awake()
    {
        InputActionMap playerMap = inputActions.FindActionMap("Player");

        moveAction = playerMap.FindAction("Move", true);

        playerMap.Enable();
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
