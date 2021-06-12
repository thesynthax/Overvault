/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About SlideCrouchHandler
* -> 
*/

public class SlideCrouchHandler : MonoBehaviour
{
    private AnimatorHandler animHandler;
    private InputHandler inputHandler;
    private PlayerMovementBase pMoveBase;

    private bool vaultActive = false;
    
    public void Init()
    {
        animHandler = GetComponent<AnimatorHandler>();
        inputHandler = animHandler.inputHandler;
        pMoveBase = animHandler.pMoveBase;
    }

    public void Tick()
    {
        if (pMoveBase.states.currentState == StateHandler.CurrentState.Sliding)
        {
            pMoveBase.coll.radius = 0.5f;
            if (pMoveBase.states.facingDir == 1)
                pMoveBase.coll.center = new Vector3(0, 0.5f, 0.4f);
            else if (pMoveBase.states.facingDir == -1)
                pMoveBase.coll.center = new Vector3(0, 0.5f,- 0.4f);
            else if (pMoveBase.states.facingDir == 0)
            {

            }
            pMoveBase.coll.height = 0.8f;
        }
        else if (pMoveBase.states.currentState == StateHandler.CurrentState.Crouching)
        {
            pMoveBase.coll.radius = 0.5f;
            pMoveBase.coll.center = new Vector3(0, 0.5f, 0);
            pMoveBase.coll.height = 0.8f;
        }
        else
        {
            pMoveBase.coll.center = new Vector3(0, 1f, 0);
            pMoveBase.coll.height = 2f;
        }
    }
}
