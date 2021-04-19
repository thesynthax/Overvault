/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About PlayerMovement
* -> 
*/

public class PlayerMovement : MonoBehaviour
{
    private StateManager stateMgr;
    private UserInput uInput;
	
    public void Init(UserInput ui, StateManager st)
    {
        stateMgr = st;
        uInput = ui;
    }

    public void Tick()
    {
        stateMgr.facingDir = FacingDir(stateMgr.modelRootBone.transform.localEulerAngles);
        stateMgr.charStates.onGround = OnGround();
        Animate(stateMgr.anim, stateMgr.inputActive,stateMgr.AxisDir.x, stateMgr.AxisDir.y, stateMgr.charStates.onGround, stateMgr.facingDir);
        Move(stateMgr.AxisDir.x);
    }

    public void Move(float horz)
    {
        
    }

    private int FacingDir(Vector3 rootRotation)
    {
        int facingDir = 0;
        if ((rootRotation.y <= 30 && rootRotation.y >= 0) || (rootRotation.y < 360 && rootRotation.y >= 330))
        {
            facingDir = 1;
        }
        else if (rootRotation.y <= 210 && rootRotation.y >= 150)
        {
            facingDir = -1;
        }
        return facingDir;
    }

    public void Animate(Animator anim, bool inputActive, float horz, float vert, bool onGround, int facingDir)
    {
        anim.SetFloat(AnimVars.Horizontal, horz, 0.01f, Time.deltaTime);
        anim.SetFloat(AnimVars.Vertical, vert, 0.01f, Time.deltaTime);
        anim.SetBool(AnimVars.OnGround, onGround);
        anim.SetInteger(AnimVars.FacingDir, facingDir);
        anim.SetBool(AnimVars.InputActive, inputActive);
		anim.SetBool(AnimVars.SuddenChange, true);
    }
	
    public void OnAnimMove(bool onGround, float time, Animator anim, Rigidbody rBody)
	{
		if (onGround && time > 0f)
		{
			Vector3 v = anim.deltaPosition / time;

			v.y = rBody.velocity.y;
			rBody.velocity = v;
		}
	}

    private bool OnGround()
	{
		bool r = false;

		Vector3 origin = transform.position + (Vector3.up * 0.55f);

		RaycastHit hit = new RaycastHit();
		bool isHit = false;
		FindGround(origin, ref hit, ref isHit);

		if (!isHit)
		{
			for (int i = 0; i < 4; i++)
			{
				Vector3 newOrigin = origin;

				switch (i)
				{
					case 0:
						newOrigin += Vector3.forward / 3;
						break;
					case 1:
						newOrigin -= Vector3.forward / 3;
						break;
					case 2:
						newOrigin += Vector3.right / 3;
						break;
					case 3:
						newOrigin -= Vector3.right / 3;
						break;
				}

				FindGround(newOrigin, ref hit, ref isHit);

				if (isHit)
				{
					break;
				}
			}
		}

		r = isHit;

		return r;
	}

	private void FindGround(Vector3 origin, ref RaycastHit hit, ref bool isHit)
	{
		Debug.DrawRay(origin, -Vector3.up * 0.5f, Color.red);
		if (Physics.Raycast(origin, -Vector3.up, out hit, stateMgr.groundDistance))
		{
			isHit = true;
		}
	}
}
