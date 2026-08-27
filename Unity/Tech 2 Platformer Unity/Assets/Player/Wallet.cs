using TMPro;
using UnityEngine;

public class Wallet : MonoBehaviour
{
    [SerializeField] TMP_Text text;
    [SerializeField] int coins = 0;
    public static Wallet Instance;

    private void Start()
    {
        Instance = this;
        UpdateUI();
    }

    public void Collect(int amount = 1)
    {
        coins += amount;
        UpdateUI();
    }

    void UpdateUI()
    {
        text.text = "Coins: " + coins;
    }

}
