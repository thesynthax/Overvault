/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About BasicMovementHandler
* -> Handles basic movement like walking, jogging, sprint
*/

public class BasicMovementHandler : MonoBehaviour
{
    private AnimatorHandler animHandler;
    private InputHandler inputHandler;
    private PlayerMovementBase pMoveBase;
    
    public void Init()
    {
        animHandler = GetComponent<AnimatorHandler>();
        inputHandler = animHandler.inputHandler;
        pMoveBase = animHandler.pMoveBase;
    }

    public void Tick()
    {
        SetColliderRadius();
    }

    public bool ObstacleAhead()
    {
        return true;
    }

    private void SetColliderRadius()
    {
        switch(pMoveBase.states.curState)
		{
			case (0):
				pMoveBase.coll.radius = 0.3f;
				break;
			case (1):
				pMoveBase.coll.radius = 0.3f;
				break;
			case (2):
				pMoveBase.coll.radius = 0.7f;
				break;
			case (3):
				pMoveBase.coll.radius = 0.7f;
				break;
		}
    }
}
