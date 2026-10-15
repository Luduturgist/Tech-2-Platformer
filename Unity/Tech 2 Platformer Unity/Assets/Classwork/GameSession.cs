using System;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameSession : MonoBehaviour
{
    [SerializeField] int playerLives = 5;

    static GameSession ActiveSession;

    void Awake()
    {
        int numGameSessions = FindObjectsByType<GameSession>().Length;

        if(numGameSessions > 1)
        {
            Destroy(gameObject);
        }

        else
        {
            DontDestroyOnLoad(gameObject);
            ActiveSession = this;
        }
    }

    public static void ProcessPlayerDeath()
    {
        if (ActiveSession.playerLives > 1)
        {
            ActiveSession.SubtractLife();
        }

        else
        {
            ActiveSession.ResetGameSession();
        }
    }

    private void ResetGameSession()
    {
        SceneManager.LoadScene(0);
   }

   private void SubtractLife()
    {
        playerLives--;

        var currentSceneIndex = SceneManager.GetActiveScene().buildIndex;

        SceneManager.LoadScene(currentSceneIndex);
    }
}
