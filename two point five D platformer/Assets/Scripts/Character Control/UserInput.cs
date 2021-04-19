/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About UserInput
* ->
*/

public class UserInput : MonoBehaviour
{
    public StateManager stateMgr;
	public PlayerMovement pMove;
    public JoystickControl joystick;

	private float horizontal { get; set; }
	private float vertical { get; set; }
	public bool jump { get; private set; }
	public bool walk { get; private set; }
	public bool sprint { get; private set; }

    private void Start()
	{
		stateMgr.Init();
		pMove.Init(this, stateMgr);

		if (Camera.main)
			stateMgr.mainCam = Camera.main.transform;
	}

	private void FixedUpdate()
	{
		UpdateInputs(ref stateMgr.AxisDir, ref stateMgr.inputActive);

		stateMgr.Tick();
		pMove.Tick();
	}
    private void OnAnimatorMove() 
    {
        pMove.OnAnimMove(stateMgr.charStates.onGround, Time.deltaTime, stateMgr.anim, stateMgr.rBody);
    }

    private void UpdateInputs(ref Vector2 axisDir, ref bool inputActive)
    {
        horizontal = joystick.Horizontal();
        vertical = joystick.Vertical();

        axisDir = new Vector2(horizontal, vertical);

        inputActive = horizontal != 0 ? true : false;
    }
}
