/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;
using UnityEngine.UI;

/** About InputHandler
* -> Manages all the input related stuff, key presses, touches etc
*/

public class InputKey
{
    public bool WasPressed { get; private set; }
    public bool WasReleased { get; private set; }
    public bool IsPressed { get; private set; }

    public string InputName;
    private GameObject UI;

    private enum UIType 
    {
        Joystick, Button, Toggle
    }

    private UIType uiType;

    public InputKey(string s, GameObject ui)
    {
        WasPressed = false;
        WasReleased = false;
        IsPressed = false;

        InputName = s;
        UI = ui;

        if (ui.GetComponent<JoystickControl>())
        {
            uiType = UIType.Joystick;
        }
        else if (ui.GetComponent<Button>())
        {
            uiType = UIType.Button;
        }
        else
        {
            uiType = UIType.Toggle;
        }
    }

    public void Update()
    {
        switch (uiType)
        {
            case (UIType.Joystick):
                IsPressed = Input.GetKey(InputName) || (UI.GetComponent<JoystickControl>().currentPressState == JoystickControl.CurrentPressState.IsPressed);
                WasPressed = Input.GetKeyDown(InputName) || (UI.GetComponent<JoystickControl>().currentPressState == JoystickControl.CurrentPressState.WasPressed);
                WasReleased = Input.GetKeyUp(InputName) || (UI.GetComponent<JoystickControl>().currentPressState == JoystickControl.CurrentPressState.WasReleased);
                break;
            case (UIType.Button):
                IsPressed = Input.GetKey(InputName);
                break;
        }
    }


    public void SetKeyState(bool wasPressed, bool wasReleased, bool pressing)
    {
        WasPressed = wasPressed;
        WasReleased = wasReleased;
        IsPressed = pressing;
    }
}

public enum InputTypes
{
    Idle, //no input
    HorizontalMovement, //joystick left or right / A or D keys
    VerticalMovement, //joystick up or down / W or S keys
    UpperMovement, //jump button / space key
    LowerMovement, //slide or crouch button / LCtrl key
    Sprint, //sprint button / LShift key
}

public class InputHandler : MonoBehaviour
{
    private GameObject MovementUI; //joystick
    private GameObject JumpUI; //jump button
    private GameObject SprintUI; //sprint button
    private GameObject SlideCrouchUI; //slide button

    public InputKey HorizontalJoystick { get; private set; }
    public InputKey VerticalJoystick { get; private set; }
    public InputKey UpperMovementButton { get; private set; }
    public InputKey LowerMovementButton { get; private set; }
    public InputKey SprintButton { get; private set; }

    private void Start()
    {
        HorizontalJoystick = new InputKey("Horizontal", MovementUI);
        VerticalJoystick = new InputKey("Vertical", MovementUI);
        UpperMovementButton = new InputKey("Jump", JumpUI);
        LowerMovementButton = new InputKey("Fire1", SlideCrouchUI);
        SprintButton = new InputKey("Fire3", SprintUI);
    }

    public InputKey GetInputKey(InputTypes inputTypes)
    {
        switch(inputTypes)
        {
            case InputTypes.HorizontalMovement:
                return HorizontalJoystick;
            case InputTypes.VerticalMovement:
                return VerticalJoystick;
            case InputTypes.UpperMovement:
                return UpperMovementButton;
            case InputTypes.LowerMovement:
                return LowerMovementButton;
            case InputTypes.Sprint:
                return SprintButton;
            default:
                return null;
        }
    }
}
