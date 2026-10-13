using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class level_trigger : MonoBehaviour
{
    [SerializeField] int level = -1;
    [SerializeField] float delat = 0.5f;
    [SerializeField] float slow_mult = 0.4f;

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.tag == "Player")
        {
            StartCoroutine(LoadLevelDelay());
        }
    }

        private IEnumerator LoadLevelDelay()
        {
            Time.timeScale = slow_mult;
            
            yield return new WaitForSecondsRealtime(delat);

            Time.timeScale = 1;
            SceneManager.LoadScene(level >= 0 ? level : SceneManager.GetActiveScene().buildIndex + 1);

        }

}
