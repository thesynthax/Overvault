/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About AnimatorHandler
* -> Handles all animation related stuff
*/

public class AnimatorHandler : MonoBehaviour
{
    private bool yRootMotion = true;
    [HideInInspector] public PlayerMovementBase pMoveBase;
    [HideInInspector] public InputHandler inputHandler;
    private Animator anim;
    private Rigidbody rBody;
    private CapsuleCollider coll;

    private void Start()
    {
        pMoveBase = GetComponent<PlayerMovementBase>();
        inputHandler = pMoveBase.inputHandler;
        anim = pMoveBase.anim;
        rBody = pMoveBase.rBody;
        coll = pMoveBase.coll;
    }

    private void Update()
    {
        yRootMotion = pMoveBase.states.onGround;
        Animate(pMoveBase.GetObstacleType(), pMoveBase.basicMovement.ObstacleAheadTime, pMoveBase.basicMovement.ObstacleAhead(), pMoveBase.vaultHandler.Vault(), inputHandler.CrouchButton.Pressing, inputHandler.SlideButton.Pressing, inputHandler.JumpButton.Pressing, inputHandler.SprintButton.Pressing, inputHandler.HorizontalJoystick.Pressing || inputHandler.VerticalJoystick.Pressing, inputHandler.HorizontalJoystick.value, inputHandler.VerticalJoystick.value, pMoveBase.states.onGround, pMoveBase.states.facingDir);
    }
    
    public void Animate(int obstacleType, float obstacleAheadTime, bool obstacleAhead, int vaultDistance, bool crouch, bool slide, bool jump, bool sprint, bool inputActive, float horz, float vert, bool onGround, int facingDir)
    {
        anim.SetFloat(AnimatorStatics.Horizontal, horz, 0.01f, Time.deltaTime);
        anim.SetFloat(AnimatorStatics.Vertical, vert, 0.01f, Time.deltaTime);
        anim.SetBool(AnimatorStatics.OnGround, onGround);
        anim.SetInteger(AnimatorStatics.FacingDir, facingDir);
        anim.SetBool(AnimatorStatics.InputActive, inputActive);
		anim.SetBool(AnimatorStatics.sprint, sprint);
		anim.SetBool(AnimatorStatics.Jump, jump || (vaultDistance > -1));
		anim.SetInteger(AnimatorStatics.VaultDistance, vaultDistance);
		anim.SetBool(AnimatorStatics.Slide, slide);
		anim.SetBool(AnimatorStatics.Crouch, crouch);
        anim.SetBool(AnimatorStatics.ObstacleAhead, obstacleAhead);
        anim.SetFloat(AnimatorStatics.ObstacleAheadTime, obstacleAheadTime);
        anim.SetInteger(AnimVars.ObstacleType, obstacleType);	
    }

    /* private void OnAnimatorMove()
    {
        if (pMoveBase.states.onGround && Time.deltaTime > 0)
		{
			Vector3 v = anim.deltaPosition / Time.deltaTime;

			if(!yRootMotion)
				v.y = rBody.velocity.y;

			rBody.velocity = v;
		}
    } */
}
