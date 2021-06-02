/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About PlayerMovementBase
* -> The base class of all character controller related stuff
*/

public class PlayerMovementBase : MonoBehaviour
{
	[SerializeField] private GameObject modelInit;
	public StateHandler states;
	[HideInInspector] public Animator anim;
	[HideInInspector] public CapsuleCollider coll;
	[HideInInspector] public Rigidbody rBody;
	[HideInInspector] public InputHandler inputHandler;
	[HideInInspector] public Transform mainCam;
	private GameObject modelRootBone;
	private GameObject activeModel;
	private Transform modelPlaceholder;

	[HideInInspector] public BasicMovementHandler basicMovement;
	[HideInInspector] public VaultHandler vaultHandler;
	
	private void InitComponents()
	{
		anim = GetComponent<Animator>();
		coll = GetComponent<CapsuleCollider>();
		rBody = GetComponent<Rigidbody>();
		inputHandler = GetComponent<InputHandler>();

		basicMovement = GetComponent<BasicMovementHandler>();
		vaultHandler = GetComponent<VaultHandler>();
	}

    private void InitModel()
	{
		modelPlaceholder = transform.GetChild(1);
		activeModel = Instantiate(modelInit) as GameObject;
		activeModel.transform.parent = modelPlaceholder;
		activeModel.transform.localEulerAngles = Vector3.zero;
		activeModel.transform.localPosition = Vector3.zero;
		activeModel.transform.localScale = Vector3.one;
        modelRootBone = modelPlaceholder.GetChild(0).GetChild(2).gameObject;
	}

	private void SetupComponents()
	{
		Animator modelAnim = activeModel.GetComponent<Animator>();
		anim.avatar = modelAnim.avatar;
		anim.applyRootMotion = true;
		anim.updateMode = AnimatorUpdateMode.AnimatePhysics;
		anim.cullingMode = AnimatorCullingMode.AlwaysAnimate;
		Destroy(modelAnim);

		//rBody.useGravity = false;
		rBody.isKinematic = false;
        mainCam = Camera.main.transform;
	}
    private void Start()
    {
		InitComponents();
        InitModel();
        SetupComponents();

		basicMovement.Init();
		vaultHandler.Init();
    }
	
    private void Update()
    {
		UpdateStates();
		PhysicControl();

        states.onGround = OnGround();
		states.facingDir = FacingDir(modelRootBone.transform.localEulerAngles);

		basicMovement.Tick();
		vaultHandler.Tick();
    }

	private void PhysicControl()
	{
		if (states.curState >= 0 && states.curState <= 3)
		{
			rBody.useGravity = true;
			coll.isTrigger = false;
		}
		else
		{
			rBody.useGravity = false;
			coll.isTrigger = true;
		}
	}
	private void UpdateStates()
	{
		AnimatorStateInfo currentAnim = anim.GetCurrentAnimatorStateInfo(0);
		if (currentAnim.IsName(AnimationStatesStatics.Idle) || currentAnim.IsName(AnimationStatesStatics.IdleMirror))
			states.curState = 0; //Idle
		else if (currentAnim.IsName(AnimationStatesStatics.Walk) || currentAnim.IsName(AnimationStatesStatics.WalkBwdLeft) || currentAnim.IsName(AnimationStatesStatics.WalkBwdRight) | currentAnim.IsName(AnimationStatesStatics.WalkMirror) || currentAnim.IsName(AnimationStatesStatics.WalkTurn) || currentAnim.IsName(AnimationStatesStatics.WalkTurnMirror))
			states.curState = 1; //Walk
		else if (currentAnim.IsName(AnimationStatesStatics.Jog) || currentAnim.IsName(AnimationStatesStatics.JogMirror) || currentAnim.IsName(AnimationStatesStatics.JogTurn) || currentAnim.IsName(AnimationStatesStatics.JogTurnMirror) || currentAnim.IsName(AnimationStatesStatics.StopJog) || currentAnim.IsName(AnimationStatesStatics.StopJogMirror) || currentAnim.IsName(AnimationStatesStatics.StartJog) || currentAnim.IsName(AnimationStatesStatics.StartJogMirror))
			states.curState = 2; //Jog
		else if (currentAnim.IsName(AnimationStatesStatics.Sprint) || currentAnim.IsName(AnimationStatesStatics.SprintMirror) || currentAnim.IsName(AnimationStatesStatics.SprintTurn) || currentAnim.IsName(AnimationStatesStatics.SprintTurnMirror) || currentAnim.IsName(AnimationStatesStatics.StopSprint) || currentAnim.IsName(AnimationStatesStatics.StopSprintMirror) || currentAnim.IsName(AnimationStatesStatics.StartSprint) || currentAnim.IsName(AnimationStatesStatics.StartSprintMirror))
			states.curState = 3; //Sprint
		else
			states.curState = 4; //On-hold (i.e when you can't do anything else, eg. Vault, Jump, Airborne)
	}

	enum ObstacleType
	{
		LowShort, //vault
		LowMedium, //idle, walk, jog - step up and run. sprint - vault
		LowLong, //can only step over it, no vaults
		Medium, //climb, but not able to hang on ledge
		High, //climb, able to hang on ledge
	}

	public int GetObstacleType()
	{
		ObstacleType obsType = new ObstacleType();
		Vector3 origin = transform.position;
		Vector3 direction = states.facingDir * transform.forward;
		float distance = ControllerStatics.longVaultDistance + ControllerStatics.inputEnterRoom;
		float errorDistance = 0.01f;
		RaycastHit hit = new RaycastHit();

		if (Physics.Raycast(origin, direction, out hit, distance, ControllerStatics.obstacle))
		{
			if (!Physics.Raycast(origin + transform.up * (ControllerStatics.obsLowHeight + errorDistance), direction, distance, ControllerStatics.obstacle))
			{
				if (!Physics.Raycast(hit.point + transform.up * (ControllerStatics.obsLowHeight + errorDistance) + transform.forward * (ControllerStatics.obsShortLength + errorDistance), Vector3.down, 2 * errorDistance, ControllerStatics.obstacle))
				{
					obsType = ObstacleType.LowShort;
				}
				else
				{
					if (!Physics.Raycast(hit.point + transform.up * (ControllerStatics.obsLowHeight + errorDistance) + transform.forward * (ControllerStatics.obsMediumLength + errorDistance), Vector3.down, 2 * errorDistance, ControllerStatics.obstacle))
					{
						obsType = ObstacleType.LowMedium;
					}
					else
					{
						obsType = ObstacleType.LowLong;
					}
				}
			}
			else
			{
				if (!Physics.Raycast(origin + transform.up * (ControllerStatics.obsMedHeight + errorDistance), direction, distance, ControllerStatics.obstacle))
				{
					obsType = ObstacleType.Medium;
				}
				else
				{
					if (!Physics.Raycast(origin + transform.up * (ControllerStatics.obsHighHeight + errorDistance), direction, distance, ControllerStatics.obstacle))
					{
						obsType = ObstacleType.High;
					}
				}
			}
			return (int)obsType;
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
		if (Physics.Raycast(origin, -Vector3.up, out hit, ControllerStatics.groundDistance, ControllerStatics.groundAndObs))
		{
			isHit = true;
		}
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
}
