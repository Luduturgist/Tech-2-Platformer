using Unity.VisualScripting;
using UnityEngine;

public class Parallax : MonoBehaviour
{
    [SerializeField] Transform track;
    [SerializeField] float scale = 0.5f;

    float origin;
    float offset;

    void Start()
    {
        offset = transform.position.x;
        if (!track) track = Movement.instance.transform;
        Update();
    }

    float last;
    private void Update()
    {
        if (last == X()) return;

        float diff = (X() - offset);
        transform.position = new Vector3(diff * scale + offset, transform.position.y, transform.position.z);

        last = X();
    }

    float X() { return track.transform.position.x; }

}
