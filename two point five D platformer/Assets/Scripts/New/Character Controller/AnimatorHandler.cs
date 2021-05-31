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
        Animate(pMoveBase.basicMovement.ObstacleAhead(), inputHandler.CrouchButton.Pressing, inputHandler.SlideButton.Pressing, inputHandler.JumpButton.Pressing, inputHandler.SprintButton.Pressing, inputHandler.HorizontalJoystick.Pressing || inputHandler.VerticalJoystick.Pressing, inputHandler.HorizontalJoystick.value, inputHandler.VerticalJoystick.value, pMoveBase.states.onGround, pMoveBase.states.facingDir);
    }
    
    public void Animate(bool obstacleAhead, bool crouch, bool slide, bool jump, bool sprint, bool inputActive, float horz, float vert, bool onGround, int facingDir)
    {
        anim.SetFloat(AnimatorStatics.Horizontal, horz, 0.01f, Time.deltaTime);
        anim.SetFloat(AnimatorStatics.Vertical, vert, 0.01f, Time.deltaTime);
        anim.SetBool(AnimatorStatics.OnGround, onGround);
        anim.SetInteger(AnimatorStatics.FacingDir, facingDir);
        anim.SetBool(AnimatorStatics.InputActive, inputActive);
		anim.SetBool(AnimatorStatics.sprint, sprint);
		anim.SetBool(AnimatorStatics.Jump, jump);// || vaultActive);
		//anim.SetInteger(AnimatorStatics.VaultDistance, vaultDistance);
		anim.SetBool(AnimatorStatics.Slide, slide);
		anim.SetBool(AnimatorStatics.Crouch, crouch);
        anim.SetBool(AnimatorStatics.ObstacleAhead, obstacleAhead);
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
