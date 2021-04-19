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

	public float horizontal { get; private set; }
	public float vertical { get; private set; }
	public bool jump { get; private set; }
	public bool walk { get; private set; }
	public bool sprint { get; private set; }

    private void Start()
	{
		stateMgr.Init();
		//pMove.Init(this, stateMgr);

		if (Camera.main)
			stateMgr.mainCam = Camera.main.transform;
	}

	private void Update()
	{
		//UpdateInputs(stateMgr.mainCam, ref stateMgr.moveDir);

		stateMgr.Tick();
		//pMove.Tick();
	}
}
