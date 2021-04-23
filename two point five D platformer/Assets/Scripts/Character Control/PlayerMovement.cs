/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About PlayerMovement
* -> Converts variables into game mechanics
*/

public class PlayerMovement : MonoBehaviour
{
    private StateManager stateMgr;
    private UserInput uInput;

	private float previousValue = 0f;
	
    public void Init(UserInput ui, StateManager st)
    {
        stateMgr = st;
        uInput = ui;
    }

    public void Tick()
    {
		int vaultRange = -1;
        stateMgr.facingDir = FacingDir(stateMgr.modelRootBone.transform.localEulerAngles);
        stateMgr.charStates.onGround = OnGround();
		if (stateMgr.jump) 
			vaultRange = Jump();
        Animate(stateMgr.anim, vaultRange, stateMgr.jump, stateMgr.sprint, stateMgr.inputActive, stateMgr.suddenChange, stateMgr.AxisDir.x, stateMgr.AxisDir.y, stateMgr.charStates.onGround, stateMgr.facingDir);
		
		if (stateMgr.charStates.curState >= 0 && stateMgr.charStates.curState <= 3)
		{
			stateMgr.rBody.useGravity = true;
			stateMgr.coll.isTrigger = false;
		}
		else
		{
			stateMgr.rBody.useGravity = false;
			stateMgr.coll.isTrigger = true;
		}
		float currentValue = stateMgr.AxisDir.x;
		stateMgr.suddenChange = suddenChange(previousValue, currentValue);
		previousValue = currentValue;
	}
	
	private bool suddenChange(float previousValue, float currentValue)
	{
		if (Mathf.Abs(currentValue - previousValue) >= 0.025f)
			return true;
		else
			return false;
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

    public void Animate(Animator anim, int vaultDistance, bool jump, bool sprint, bool inputActive, bool suddenChange, float horz, float vert, bool onGround, int facingDir)
    {
        anim.SetFloat(AnimVars.Horizontal, horz, 0.01f, Time.deltaTime);
        anim.SetFloat(AnimVars.Vertical, vert, 0.01f, Time.deltaTime);
        anim.SetBool(AnimVars.OnGround, onGround);
        anim.SetInteger(AnimVars.FacingDir, facingDir);
        anim.SetBool(AnimVars.InputActive, inputActive);
		anim.SetBool(AnimVars.SuddenChange, suddenChange);
		anim.SetBool(AnimVars.sprint, sprint);
		anim.SetBool(AnimVars.Jump, jump);
		anim.SetInteger(AnimVars.VaultDistance, vaultDistance);
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

	
	enum VaultRange
	{
		veryShortRange, shortRange, mediumRange, mediumLongRange, longMediumRange, longRange
	}

	private int Jump()
	{		
		VaultRange vaultRange = new VaultRange();

		Vector3 origin = transform.position + Vector3.up * 0.3f;
		RaycastHit hit = new RaycastHit();
		Vector3 direction = stateMgr.facingDir == 1 ? transform.forward : -transform.forward;

		if (Physics.Raycast(origin, direction, out hit, stateMgr.longVaultDistance, stateMgr.obstacles))
		{
			//uInput.ClearLog();

			if (stateMgr.charStates.curState == 3)
			{
				if (hit.distance <= stateMgr.longVaultDistance && hit.distance >= stateMgr.longMediumVaultDistance)
				{
					vaultRange = VaultRange.longRange;
				}
				else if (hit.distance <= stateMgr.longMediumVaultDistance && hit.distance >= stateMgr.mediumLongVaultDistance)
				{
					vaultRange = VaultRange.longMediumRange;
				}
				else if (hit.distance <= stateMgr.mediumLongVaultDistance && hit.distance >= stateMgr.mediumVaultDistance)
				{
					vaultRange = VaultRange.mediumLongRange;
				}
				else if (hit.distance <= stateMgr.mediumVaultDistance && hit.distance >= stateMgr.shortVaultDistance)
				{
					vaultRange = VaultRange.mediumRange;
				}
				else if (hit.distance <= stateMgr.shortVaultDistance && hit.distance >= stateMgr.veryShortVaultDistance)
				{
					vaultRange = VaultRange.shortRange;
				}
				else if (hit.distance <= stateMgr.veryShortVaultDistance && hit.distance >= stateMgr.nearestVaultDistance)
				{
					vaultRange = VaultRange.veryShortRange;
				}
			}
			else if (stateMgr.charStates.curState == 2)
			{

			}
			else if (stateMgr.charStates.curState == 1)
			{

			}
			else
			{

			}
			

			//Debug.Log(hit.distance);
			Debug.DrawRay(origin, hit.transform.position - origin, Color.green);
			return (int)vaultRange;
		}
		
		return -1;
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
		if (Physics.Raycast(origin, -Vector3.up, out hit, stateMgr.groundDistance, stateMgr.ground))
		{
			isHit = true;
		}
	}
}
