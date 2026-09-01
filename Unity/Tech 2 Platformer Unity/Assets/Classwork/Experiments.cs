using NUnit.Framework;
using UnityEngine;

public class Experiments : MonoBehaviour
{
    [SerializeField] string playerName = "Fern";

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Debug.Log(playerName);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
