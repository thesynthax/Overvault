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
    public float ObstacleAheadTime = 0f;
    
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
        Vector3 origin = transform.position;
		Vector3 direction = pMoveBase.states.facingDir * transform.forward;
        float errorDistance = 0.01f;
		float distance = errorDistance;

        switch(pMoveBase.states.curState)
        {
            case(0):
                distance += 0.6f;
                break;
            case(1):
                distance += 0.6f;
                break;
            case(2):
                distance += 0.6f;
                break;
            case(3):
                distance += 0.8f;
                break;
        }

        if (Physics.Raycast(origin, direction, distance, ControllerStatics.obstacle))
            ObstacleAheadTime += Time.deltaTime;
        else
            ObstacleAheadTime = 0f;

        return Physics.Raycast(origin, direction, distance, ControllerStatics.obstacle) && pMoveBase.GetObstacleType() != -1;
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
				pMoveBase.coll.radius = 0.4f;
				break;
			case (3):
				pMoveBase.coll.radius = 0.7f;
				break;
		}
    }
}
