/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About StateManager
* -> Contains all the variables for the character controller
*/

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(CapsuleCollider))]
[RequireComponent(typeof(Rigidbody))]
public class StateManager : MonoBehaviour
{
    [Header("References")]
	public Transform modelPlaceholder;
	public GameObject modelInit;
    public GameObject modelRootBone;
	[Space]
	public Animator anim;
	public CapsuleCollider coll;
	public Rigidbody rBody;
	public CharacterStates charStates;
	public UserInput uInput;
	[Space]
	[HideInInspector] public Transform mainCam;
	[Header("Variables")]
    public Vector2 AxisDir = Vector2.zero;
    public int facingDir;
    public bool inputActive;
	[Space]
	[SerializeField] private int _curState;
	[SerializeField] private bool _onGround;

	[Header("Constants")]
	public float jumpForce = 8f;
	public float groundDistance = 0.634f;
	public LayerMask ground;
	//Private
	private GameObject activeModel;
    public void Init()
	{
		InitModel();
		SetupComponents();
	}

	public void Tick()
	{
		UpdateStates();
		UpdateCharStateNames();
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

		rBody.useGravity = true;
		rBody.isKinematic = false;
	}

	private void UpdateCharStateNames()
	{
		_curState = charStates.curState;
		_onGround = charStates.onGround;
	}

    private void UpdateStates()
	{
		
	}

	private bool RequirementsCleared()
	{
		if (anim.isHuman)
			return true;
		return false;
	}
}
