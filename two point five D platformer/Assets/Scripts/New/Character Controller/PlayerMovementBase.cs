/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About PlayerMovementBase
* -> The base class of all character controller related stuff
*/

public class PlayerMovementBase : MonoBehaviour
{
    private GameObject activeModel;
    public Transform modelPlaceholder;
	public GameObject modelInit;
    [HideInInspector] public GameObject modelRootBone;
	[HideInInspector] public Animator anim;
	[HideInInspector] public CapsuleCollider coll;
	[HideInInspector] public Rigidbody rBody;
	[SerializeField] public StateHandler states;
	[HideInInspector] public InputHandler inputHandler;
	[HideInInspector] public Transform mainCam;
	
	private void InitComponents()
	{
		anim = GetComponent<Animator>();
		coll = GetComponent<CapsuleCollider>();
		rBody = GetComponent<Rigidbody>();
		inputHandler = GetComponent<InputHandler>();
	}

    private void InitModel()
	{
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
    }

    private void Update()
    {
        states.onGround = OnGround();
		states.facingDir = FacingDir(modelRootBone.transform.localEulerAngles);
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
