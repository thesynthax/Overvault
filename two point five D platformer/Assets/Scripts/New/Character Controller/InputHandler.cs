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
    public bool Pressing { get; private set; }
    public float value { get; set; }
    public string InputName;
    private GameObject UI;

    public bool KeyboardInput = false;

    private enum UIType 
    {
        Joystick, Button, Toggle
    }

    private UIType uiType;

    public InputKey(string s, GameObject ui)
    {
        Pressing = false;

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
        KeyboardInput = Input.GetAxis(InputName) == 0 ? false : true;

        switch (uiType)
        {
            case (UIType.Joystick):
                Pressing = (Input.GetAxis(InputName) != 0) || (UI.GetComponent<JoystickControl>().currentPressState == JoystickControl.CurrentPressState.Pressing);
                break;
            case (UIType.Button):
                Pressing = (Input.GetAxis(InputName) != 0) || (UI.GetComponent<UIButton>().currentPressState == UIButton.CurrentPressState.Pressing);
                break;
            case (UIType.Toggle):
                Pressing = (Input.GetAxis(InputName) != 0) || (UI.GetComponent<UIToggle>().currentPressState == UIToggle.CurrentPressState.On);
                break;
        }
    }


    public void SetKeyState(bool pressing)
    {
        Pressing = pressing;
    }
}

public enum InputTypes
{
    Idle, //no input
    HorizontalMovement, //joystick left or right / A or D keys
    VerticalMovement, //joystick up or down / W or S keys
    UpperMovement, //jump button / space key
    LowerMovement, //slide button or crouch toggle / LCtrl key
    Sprint, //sprint toggle / LShift key
}

public class InputHandler : MonoBehaviour
{
    [SerializeField] private GameObject MovementUI; //joystick
    [SerializeField] private GameObject JumpUI; //jump button
    [SerializeField] private GameObject SprintUI; //sprint toggle
    [SerializeField] private GameObject SlideUI; //slide button
    [SerializeField] private GameObject CrouchUI; //crouch toggle

    public InputKey HorizontalJoystick { get; private set; }
    public InputKey VerticalJoystick { get; private set; }
    public InputKey JumpButton { get; private set; }
    public InputKey SlideButton { get; private set; }
    public InputKey CrouchButton { get; private set; }
    public InputKey SprintButton { get; private set; }

    private void Start()
    {
        HorizontalJoystick = new InputKey("Horizontal", MovementUI);
        VerticalJoystick = new InputKey("Vertical", MovementUI);
        JumpButton = new InputKey("Jump", JumpUI);
        SlideButton = new InputKey("Fire1", SlideUI);
        CrouchButton = new InputKey("Fire1", CrouchUI);
        SprintButton = new InputKey("Fire3", SprintUI);
    }

    private void Update() 
    {
        HorizontalJoystick.Update();
        VerticalJoystick.Update();
        SlideButton.Update();
        CrouchButton.Update();
        SprintButton.Update();

        HorizontalJoystick.value = HorizontalJoystick.KeyboardInput ? Input.GetAxis("Horizontal") : MovementUI.GetComponent<JoystickControl>().GetHorizontal();
        VerticalJoystick.value = VerticalJoystick.KeyboardInput ? Input.GetAxis("Vertical") : MovementUI.GetComponent<JoystickControl>().GetVertical();
        JumpButton.value = JumpButton.KeyboardInput ? Input.GetAxis("Jump") : BoolToFloat(JumpUI.GetComponent<UIButton>().currentPressState == UIButton.CurrentPressState.Pressing);
        SlideButton.value = SlideButton.KeyboardInput ? Input.GetAxis("Fire1") : BoolToFloat(SlideUI.GetComponent<UIButton>().currentPressState == UIButton.CurrentPressState.Pressing);
        CrouchButton.value = CrouchButton.KeyboardInput ? Input.GetAxis("Fire1") : BoolToFloat(CrouchUI.GetComponent<UIToggle>().currentPressState == UIToggle.CurrentPressState.On);
        SprintButton.value = SprintButton.KeyboardInput ? Input.GetAxis("Fire3") : BoolToFloat(SprintUI.GetComponent<UIToggle>().currentPressState == UIToggle.CurrentPressState.On);        
    }

    private float BoolToFloat(bool value)
    {
        return (value ? 1 : 0);
    }

    /* public InputKey GetInputKey(InputTypes inputTypes)
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
    } */
}
