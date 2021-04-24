/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;
using System.Reflection;

/** About UserInput
* ->
*/

public class UserInput : MonoBehaviour
{
    public StateManager stateMgr;
	public PlayerMovement pMove;
    public JoystickControl joystick;
	public ButtonsControl buttons;

	private float horizontal { get; set; }
	private float vertical { get; set; }

    private void Start()
	{
		stateMgr.Init();
		pMove.Init(this, stateMgr);

		if (Camera.main)
			stateMgr.mainCam = Camera.main.transform;
	}

	private void FixedUpdate()
	{
		UpdateInputs(ref stateMgr.AxisDir, ref stateMgr.inputActive, ref stateMgr.sprint, ref stateMgr.jump);

		stateMgr.Tick();
		pMove.Tick();
	}
    private void OnAnimatorMove() 
    {
        pMove.OnAnimMove(stateMgr.charStates.onGround, Time.deltaTime, stateMgr.anim, stateMgr.rBody);
    }

    private void UpdateInputs(ref Vector2 axisDir, ref bool inputActive, ref bool sprint, ref bool jump)
    {
        horizontal = joystick.Horizontal();
        vertical = joystick.Vertical();

        axisDir = new Vector2(horizontal, vertical);

        inputActive = horizontal != 0 ? true : false;

		sprint = buttons.Sprint();
		jump = buttons.jumpScript.pressed || Input.GetKey(KeyCode.Space);
	}

	/* public void ClearLog()
	{
		var assembly = Assembly.GetAssembly(typeof(UnityEditor.Editor));
		var type = assembly.GetType("UnityEditor.LogEntries");
		var method = type.GetMethod("Clear");
		method.Invoke(new object(), null);
	} */
}
