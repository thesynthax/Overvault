/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About VaultHandler
* -> All the parkour climbs related stuff
*/

public class ClimbHandler : MonoBehaviour
{
    private AnimatorHandler animHandler;
    private InputHandler inputHandler;
    private PlayerMovementBase pMoveBase;

    private bool climbActive = false;
    
    public void Init()
    {
        animHandler = GetComponent<AnimatorHandler>();
        inputHandler = animHandler.inputHandler;
        pMoveBase = animHandler.pMoveBase;
    }

    public void Tick()
    {
        if (pMoveBase.states.currentState == StateHandler.CurrentState.Climbing)
        {
            pMoveBase.rBody.useGravity = false;
            pMoveBase.coll.isTrigger = true;
        }
    }

    public int Climb()
    {
        if (inputHandler.JumpButton.Pressing || climbActive)
        {
            Vector3 origin = transform.position;
			RaycastHit hit = new RaycastHit();
			Vector3 direction = pMoveBase.states.facingDir * transform.forward;

            int climbType = -1;

            float inputEnterRoom = ControllerStatics.inputEnterRoom;
			float animTriggerOffset = ControllerStatics.animTriggerOffset;

            float t = 0f;

            if ((Physics.Raycast(origin, direction, out hit, ControllerStatics.longVaultDistance + inputEnterRoom, ControllerStatics.obstacle) && pMoveBase.states.curState != 0) || (Physics.Raycast(origin, direction, out hit, inputEnterRoom, ControllerStatics.obstacle) && pMoveBase.states.curState == 0))
            {
                Vector3 startPos = transform.position;
				
				climbActive = true;

                if (pMoveBase.states.currentState != StateHandler.CurrentState.Climbing)
                {
                    switch(pMoveBase.GetObstacleType())
                    {
                        case(1):
                            switch(pMoveBase.states.curState)
                            {
                                case(2):
                                    if (hit.distance <= 2 * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.jogVaultSpeed, 1.5f, 1, ref t, hit, startPos, direction);
                                    break;
                                case(1):
                                    if (hit.distance <= inputEnterRoom)
                                        climbType = Climb(ControllerStatics.walkVaultSpeed, 0.7f, 1, ref t, hit, startPos, direction);
                                    break;
                                case(0):
                                    if (hit.distance <= 0.5f * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.idleVaultSpeed, 0.3f, 1, ref t, hit, startPos, direction);
                                    break;    
                            }
                            break;
                        case(2):
                            switch(pMoveBase.states.curState)
                            {
                                case(3):
                                    if (hit.distance <= 3 * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.sprintVaultSpeed, 1.5f, 1, ref t, hit, startPos, direction);
                                    break;
                                case(2):
                                    if (hit.distance <= 2 * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.jogVaultSpeed, 1.5f, 1, ref t, hit, startPos, direction);
                                    break;
                                case(1):
                                    if (hit.distance <= inputEnterRoom)
                                        climbType = Climb(ControllerStatics.walkVaultSpeed, 0.7f, 1, ref t, hit, startPos, direction);
                                    break;
                                case(0):
                                    if (hit.distance <= 0.5f * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.idleVaultSpeed, 0.3f, 1, ref t, hit, startPos, direction);
                                    break;    
                            }
                            break;
                        case(3):
                            switch(pMoveBase.states.curState)
                            {
                                case(0):
                                    if(hit.distance <= 0.5f * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.idleVaultSpeed, 0.2f, 2, ref t, hit, startPos, direction);
                                    break;
                                case(1):
                                    if(hit.distance <= inputEnterRoom)
                                        climbType = Climb(ControllerStatics.walkVaultSpeed, 0.25f, 2, ref t, hit, startPos, direction);
                                    break;
                                case(2):
                                    if(hit.distance <= 1.2f * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.jogVaultSpeed, 0.25f, 2, ref t, hit, startPos, direction);
                                    break;
                                case(3):
                                    if(hit.distance <= 2f * inputEnterRoom)
                                        climbType = Climb(ControllerStatics.sprintVaultSpeed, 1.4f, 2, ref t, hit, startPos, direction);
                                    break;
                            }
                            break;
                    }
                }

                return climbType;
            }
            else
            {
                climbActive = false;
            }
        }
        

        return -1;
    }

    private int Climb(float speed, float distance, int climbType, ref float t, RaycastHit hit, Vector3 startPos,
        Vector3 direction)
    {
        Vector3 endPos = hit.point - direction.normalized * distance;
        t += Time.deltaTime * speed;

        if (t > 1)
        {
            climbActive = false;
        }

        Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
        transform.position = targetPos;

        return climbType;
    }
}
