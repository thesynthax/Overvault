/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/** About ButtonsControl
* -> Handles all the UI Buttons logic 
*/

public class ButtonsControl : MonoBehaviour
{
    private GameObject sprintButton;
    private GameObject jumpButton;

    [HideInInspector] public jump jumpScript;

    private void Start()
    {
        foreach (Transform child in transform.GetComponentInChildren<Transform>())
        {
            if (child.name.Equals("Sprint"))
            {
                sprintButton = child.gameObject;
            }
            if (child.name.Equals("Jump"))
            {
                jumpButton = child.gameObject;
                jumpScript = jumpButton.GetComponent<jump>();
            }
        }
    }

    public bool Sprint()
    {
        Toggle sprintToggle = sprintButton.GetComponent<Toggle>();
        bool pressed = sprintToggle.isOn || Input.GetKey(KeyCode.LeftShift);

        Image sprintButtonImage = sprintButton.GetComponent<Image>();
        sprintButtonImage.color = pressed ? Color.grey : Color.white;

        return pressed; 
    }
}
