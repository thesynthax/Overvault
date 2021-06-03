/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About VaultHandler
* -> All the parkour vault related stuff
*/

public class VaultHandler : MonoBehaviour
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
        
    }

    public int Vault()
    {
        if (inputHandler.JumpButton.Pressing || vaultActive)
        {
            Vector3 origin = transform.position;
			RaycastHit hit = new RaycastHit();
			Vector3 direction = pMoveBase.states.facingDir * transform.forward;

            int vaultRange = -1;

            float inputEnterRoom = ControllerStatics.inputEnterRoom;
			float animTriggerOffset = ControllerStatics.animTriggerOffset;

            float t = 0f;

            if (Physics.Raycast(origin, direction, out hit, ControllerStatics.longVaultDistance + inputEnterRoom, ControllerStatics.obstacle))
            {
                Vector3 startPos = transform.position;
				
				vaultActive = true;

                switch(pMoveBase.GetObstacleType())
                {
                    case(0):
                        switch(pMoveBase.states.curState)
                        {
                            case(3):
                                if (hit.distance <= ControllerStatics.longVaultDistance + inputEnterRoom && hit.distance >= ControllerStatics.longVaultDistance + animTriggerOffset)
                                {
                                    vaultRange = LowShortVault(ControllerStatics.sprintVaultSpeed, ControllerStatics.longVaultDistance, 5, ref t, hit, startPos, direction);
                                }
                                else if (hit.distance <= ControllerStatics.longVaultDistance + animTriggerOffset && hit.distance >= ControllerStatics.longMediumVaultDistance + animTriggerOffset)
							    {
                                    vaultRange = LowShortVault(ControllerStatics.sprintVaultSpeed, ControllerStatics.longMediumVaultDistance, 4, ref t, hit, startPos, direction);
                                }
                                else if (hit.distance <= ControllerStatics.longMediumVaultDistance + animTriggerOffset && hit.distance >= ControllerStatics.mediumVaultDistance + animTriggerOffset)
							    {
                                    vaultRange = LowShortVault(ControllerStatics.sprintVaultSpeed, ControllerStatics.mediumVaultDistance, 3, ref t, hit, startPos, direction);
                                }
                                else if (hit.distance <= ControllerStatics.mediumVaultDistance + animTriggerOffset && hit.distance >= ControllerStatics.shortVaultDistance + animTriggerOffset)
							    {
                                    vaultRange = LowShortVault(ControllerStatics.sprintVaultSpeed, ControllerStatics.shortVaultDistance, 2, ref t, hit, startPos, direction);
                                }
                                else if (hit.distance <= ControllerStatics.shortVaultDistance + animTriggerOffset && hit.distance >= ControllerStatics.nearestVaultDistance)
							    {
                                    vaultRange = LowShortVault(ControllerStatics.sprintVaultSpeed, ControllerStatics.veryShortVaultDistance, 1, ref t, hit, startPos, direction);
                                }
                                break;
                        }
                        break;
                }

                return vaultRange;
            }
            else
            {
                vaultActive = false;
            }
        }

        return -1;
    }

    private int LowShortVault(float speed, float distance, int vaultRange, ref float t, RaycastHit hit, Vector3 startPos, Vector3 direction)
    {
        Vector3 endPos = hit.point - direction.normalized * distance;
        t += Time.deltaTime * ControllerStatics.sprintVaultSpeed;

        if (t > 1)
        {
            vaultActive = false;
        }
        
        Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
        transform.position = targetPos;

        return vaultRange;
    }
}
