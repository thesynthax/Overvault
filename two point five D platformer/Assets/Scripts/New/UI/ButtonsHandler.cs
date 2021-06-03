/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;
using UnityEngine.UI;

/** About ButtonsHandler
* -> 
*/

public class ButtonsHandler : MonoBehaviour
{
    private Toggle crouch;
    private Button slide;
    public StateHandler states;

    private void Start()
    {
        foreach (Transform t in transform.GetComponentInChildren<Transform>())
        {
            if (t.name == "Crouch")
                crouch = t.GetComponent<Toggle>();
            else if (t.name == "Slide")
                slide = t.GetComponent<Button>();
        }
    }

    private void Update()
    {
        if (states.curState == 1 || states.curState == 2 || states.curState == 0)
        {
            crouch.interactable = true;
            slide.interactable = false;

            crouch.gameObject.SetActive(true);
            slide.gameObject.SetActive(false);
        }
        else if (states.curState == 3)
        {
            crouch.interactable = false;
            slide.interactable = true;

            crouch.gameObject.SetActive(false);
            slide.gameObject.SetActive(true);
        }
        else
        {
            slide.interactable = false;
        }
    }
}
