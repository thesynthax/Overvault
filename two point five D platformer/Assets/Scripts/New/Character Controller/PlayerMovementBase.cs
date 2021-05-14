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
    public GameObject modelRootBone;
	public Animator anim;
	public CapsuleCollider coll;
	public Rigidbody rBody;
	[HideInInspector] public Transform mainCam;

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
        InitModel();
        SetupComponents();
    }

    private void Update()
    {
        
    }
}
