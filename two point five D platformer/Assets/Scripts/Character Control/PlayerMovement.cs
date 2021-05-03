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
	private bool vaultActive = false;
	
    public void Init(UserInput ui, StateManager st)
    {
        stateMgr = st;
        uInput = ui;
    }
	
    public void Tick()
    {
		switch(stateMgr.charStates.curState)
		{
			case (0):
				stateMgr.coll.radius = 0.3f;
				break;
			case (1):
				stateMgr.coll.radius = 0.3f;
				break;
			case (2):
				stateMgr.coll.radius = 0.7f;
				break;
			case (3):
				stateMgr.coll.radius = 0.7f;
				break;
		}

		int vaultRange = -1;
        stateMgr.facingDir = FacingDir(stateMgr.modelRootBone.transform.localEulerAngles);
        stateMgr.charStates.onGround = OnGround();
		
		vaultRange = Jump();
        
		Animate(stateMgr.anim, stateMgr.slide, vaultRange, stateMgr.jump, stateMgr.sprint, stateMgr.inputActive, stateMgr.suddenChange, stateMgr.AxisDir.x, stateMgr.AxisDir.y, stateMgr.charStates.onGround, stateMgr.facingDir);
		
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

		RaycastHit hit = new RaycastHit();
		Vector3 origin = transform.position + transform.up * stateMgr.obsLowShortHeight;
		Vector3 direction = stateMgr.facingDir == 1 ? transform.forward : -transform.forward;
		if (Physics.Raycast(origin, direction, out hit, 10f, stateMgr.obstacles))
		{
			Debug.DrawRay(origin, direction * 10f, Color.blue);
		}
		
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

    public void Animate(Animator anim, bool slide, int vaultDistance, bool jump, bool sprint, bool inputActive, bool suddenChange, float horz, float vert, bool onGround, int facingDir)
    {
        anim.SetFloat(AnimVars.Horizontal, horz, 0.01f, Time.deltaTime);
        anim.SetFloat(AnimVars.Vertical, vert, 0.01f, Time.deltaTime);
        anim.SetBool(AnimVars.OnGround, onGround);
        anim.SetInteger(AnimVars.FacingDir, facingDir);
        anim.SetBool(AnimVars.InputActive, inputActive);
		anim.SetBool(AnimVars.SuddenChange, suddenChange);
		anim.SetBool(AnimVars.sprint, sprint);
		anim.SetBool(AnimVars.Jump, jump || vaultActive);
		anim.SetInteger(AnimVars.VaultDistance, vaultDistance);
		anim.SetBool(AnimVars.Slide, slide);
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
		zeroRange, veryShortRange, shortRange, mediumRange, mediumLongRange, longMediumRange, longRange
	}

	enum ObstacleType
	{
		LowShort, //normal vault animations
		LowMedium, //only kongs and monkey vaults
		LowLong, //can only step over it, no vaults
		HighShort, //just climbing and descending
		HighLong, //climbing, running on it, descending
		SlideUnder //Slide under
	}
	
	private int GetObstacleType()
	{
		ObstacleType obsType = new ObstacleType();
		Vector3 origin = transform.position;
		RaycastHit hit = new RaycastHit();
		Vector3 direction = stateMgr.facingDir == 1 ? transform.forward : -transform.forward;

		if (Physics.Raycast(origin, direction, out hit, stateMgr.longVaultDistance + stateMgr.inputEnterRoom, stateMgr.obstacles)) //Vault or Climb over
		{
			GameObject hitObject = hit.transform.gameObject;
			ObsType o = hitObject.GetComponent<ObsType>();

			obsType = (ObstacleType)o.obstacleType;
			return (int)obsType;
		}
		
		return -1;
	}

	private int Jump()
	{
		if (stateMgr.jump || vaultActive)
		{
			VaultRange vaultRange = new VaultRange();

			Vector3 origin = transform.position;
			RaycastHit hit = new RaycastHit();
			Vector3 direction = stateMgr.facingDir == 1 ? transform.forward : -transform.forward;

			float inputEnterRoom = stateMgr.inputEnterRoom;
			float animTriggerOffset = stateMgr.animTriggerOffset;

			float t = 0;

			if (Physics.Raycast(origin, direction, out hit, stateMgr.longVaultDistance + inputEnterRoom, stateMgr.obstacles))
			{
				Vector3 startPos = transform.position;
				
				vaultActive = true;

				
				switch(GetObstacleType())
				{
					case(0):
						if (stateMgr.charStates.curState == 3)
						{
							if (hit.distance <= stateMgr.longVaultDistance + inputEnterRoom && hit.distance >= stateMgr.longVaultDistance + animTriggerOffset)
							{
								Vector3 endPos = hit.point - direction.normalized * stateMgr.longVaultDistance;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.longRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
								
							}
							else if (hit.distance <= stateMgr.longVaultDistance + animTriggerOffset && hit.distance >= stateMgr.longMediumVaultDistance + animTriggerOffset)
							{
								Vector3 endPos = hit.point - direction.normalized * stateMgr.longMediumVaultDistance;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.longMediumRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							}
							else if (hit.distance <= stateMgr.longMediumVaultDistance + animTriggerOffset && hit.distance >= stateMgr.mediumVaultDistance + animTriggerOffset)
							{
								Vector3 endPos = hit.point - direction.normalized * stateMgr.mediumVaultDistance;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.mediumRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							}
							else if (hit.distance <= stateMgr.mediumVaultDistance + animTriggerOffset && hit.distance >= stateMgr.shortVaultDistance + animTriggerOffset)
							{
								Vector3 endPos = hit.point - direction.normalized * stateMgr.shortVaultDistance;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.shortRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							}
							else if (hit.distance <= stateMgr.shortVaultDistance + animTriggerOffset && hit.distance >= stateMgr.nearestVaultDistance)
							{
								Vector3 endPos = hit.point - direction.normalized * stateMgr.veryShortVaultDistance;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.veryShortRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							} 
						}
						else if (stateMgr.charStates.curState == 2)
						{
							if (hit.distance <= inputEnterRoom)
							{
								int random = Random.Range(1,4);
								stateMgr.anim.SetInteger(AnimVars.Random, random);

								Vector3 endPos = hit.point - direction.normalized * stateMgr.jogVaultDistance;
								t += Time.deltaTime * stateMgr.jogVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							}
						}
						else if (stateMgr.charStates.curState == 1)
						{
							if (hit.distance <= inputEnterRoom)
							{
								int random = Random.Range(1,3);
								stateMgr.anim.SetInteger(AnimVars.Random, random);

								Vector3 endPos = hit.point - direction.normalized * stateMgr.walkVaultDistance;
								t += Time.deltaTime * stateMgr.walkVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							}
						}
						else if (stateMgr.charStates.curState == 0)
				{
					if (hit.distance <= inputEnterRoom)
					{
						int random = Random.Range(1,3);
						stateMgr.anim.SetInteger(AnimVars.Random, random);

						Vector3 endPos = hit.point - direction.normalized * stateMgr.idleVaultDistance;
						t += Time.deltaTime * stateMgr.idleVaultSpeed;

						if (t > 1)
						{
							vaultActive = false;
						}
						
						Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
						transform.position = targetPos;
					}
				}
						break;
					case(1):
						if (stateMgr.charStates.curState == 3)
						{
							if (hit.distance <= inputEnterRoom + 3f && hit.distance >= inputEnterRoom + 1f)
							{
								Vector3 endPos = hit.point - direction.normalized * 2f;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.longRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
								
							}
							else if (hit.distance <= inputEnterRoom + 1f)
							{
								Vector3 endPos = hit.point + direction.normalized * 0.5f;
								t += Time.deltaTime * stateMgr.sprintVaultSpeed;

								if (t > 1)
								{
									vaultActive = false;
								}
								vaultRange = VaultRange.mediumRange;
								Vector3 targetPos = Vector3.Lerp(startPos, endPos, t);
								transform.position = targetPos;
							}
						}
						break;
				}	
				stateMgr.anim.SetInteger(AnimVars.ObstacleType, GetObstacleType());			

				return (int)vaultRange;
			}
			else
			{
				vaultActive = false;
				stateMgr.anim.SetInteger(AnimVars.Random, -1);
			}
		}

		return -1;
	}

	
	// private int Jump()
	// {
	// 	if (stateMgr.jump || vaultActive) 
	// 	{
	// 		//Debug.Log(vaultActive);
	// 		VaultRange vaultRange = new VaultRange();

	// 		Vector3 origin = transform.position;
	// 		RaycastHit hit = new RaycastHit();
	// 		Vector3 direction = stateMgr.facingDir == 1 ? transform.forward : -transform.forward;

	// 		float inputEnterRoom = stateMgr.inputEnterRoom;
	// 		float animPlayRoom = 0.1f;

	// 		float t = 0;

	// 		if (Physics.Raycast(origin, direction, out hit, stateMgr.longVaultDistance + inputEnterRoom, stateMgr.obstacles))
	// 		{
				
	// 			vaultActive = true;
	// 			if (stateMgr.charStates.curState == 3)
	// 			{
					
	// 				//float speed = (Time.deltaTime * stateMgr.jogVaultSpeed) / stateMgr.jog_vault.length;
	// 				//if (hit.distance <= stateMgr.longVaultDistance + inputEnterRoom && hit.distance >= stateMgr.longVaultDistance)
	// 				if (hit.distance <= stateMgr.longVaultDistance + inputEnterRoom && hit.distance >= stateMgr.longVaultDistance)
	// 				{
	// 					/* if (hit.distance <= stateMgr.longVaultDistance + animPlayRoom && hit.distance >= stateMgr.longVaultDistance - animPlayRoom)
	// 					{
	// 						vaultRange = VaultRange.longRange;
	// 					} */
						
	// 				}
	// 				//Debug.Log(hit.distance);
	// 				else if (hit.distance <= stateMgr.longVaultDistance && hit.distance >= stateMgr.longMediumVaultDistance)
	// 				{
	// 					/* if (hit.distance <= stateMgr.longMediumVaultDistance + animPlayRoom && hit.distance >= stateMgr.longMediumVaultDistance - animPlayRoom)
	// 						vaultRange = VaultRange.longMediumRange; */
	// 				}
	// 				else if (hit.distance <= stateMgr.longMediumVaultDistance && hit.distance >= stateMgr.mediumLongVaultDistance)
	// 				{
	// 					/* if (hit.distance <= stateMgr.mediumLongVaultDistance + animPlayRoom && hit.distance >= stateMgr.mediumLongVaultDistance - animPlayRoom)
	// 						vaultRange = VaultRange.mediumLongRange; */
	// 				}
	// 				else if (hit.distance <= stateMgr.longVaultDistance && hit.distance >= stateMgr.mediumVaultDistance)
	// 				{
	// 					/* if (hit.distance <= stateMgr.mediumVaultDistance + animPlayRoom && hit.distance >= stateMgr.mediumVaultDistance - animPlayRoom)
	// 						vaultRange = VaultRange.mediumRange; */
	// 				}
	// 				else if (hit.distance <= stateMgr.mediumVaultDistance && hit.distance >= stateMgr.shortVaultDistance)
	// 				{
	// 					/* if (hit.distance <= stateMgr.shortVaultDistance + animPlayRoom && hit.distance >= stateMgr.shortVaultDistance - animPlayRoom)
	// 						vaultRange = VaultRange.shortRange; */
	// 				}
	// 				else if (hit.distance <= stateMgr.veryShortVaultDistance && hit.distance >= stateMgr.nearestVaultDistance)
	// 				{
	// 					/* //if (hit.distance <= stateMgr.veryShortVaultDistance + animPlayRoom && hit.distance >= stateMgr.veryShortVaultDistance - animPlayRoom)
	// 						vaultRange = VaultRange.veryShortRange; */
	// 				} 
	// 			}
	// 			else if (stateMgr.charStates.curState == 2)
	// 			{

	// 			}
	// 			else if (stateMgr.charStates.curState == 1)
	// 			{

	// 			}
	// 			else
	// 			{

	// 			}
	// 			//Debug.Log(hit.distance + " " + vaultActive);
	// 			//Debug.DrawRay(origin, hit.point - origin, Color.green);
	// 			return (int)vaultRange;
	// 		}
	// 		else
	// 		{
	// 			vaultActive = false;
	// 		}
	// 	}
		

	// 	return -1;
	// }

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
