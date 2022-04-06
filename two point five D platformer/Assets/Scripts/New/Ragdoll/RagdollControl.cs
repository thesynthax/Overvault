/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;
using System.Collections.Generic;

/** About RagdollControl
* -> 
*/

public class RagdollControl : MonoBehaviour
{
    private PlayerMovementBase pMoveBase;
    private InputHandler inputHandler;
    private AnimatorHandler animHandler;
    private Animator anim;
    private Rigidbody rBody;
    private CapsuleCollider coll;

    private Rigidbody[] childRigidbodies;
    private Collider[] childColliders;
    
    [SerializeField] private bool ragdolled;
    public bool Ragdolled
    {
        get
        {
            return ragdollState != RagdollState.animated;
        }
        set
        {
            if (value)
            {
                if (ragdollState == RagdollState.animated)
                {
                    ragdollState = RagdollState.ragdolled;
                    RagdollOn(velWhole, velHips);
                }
            }
            else
            {
                if (ragdollState == RagdollState.ragdolled)
                {
                    if (childRigidbodies[0].velocity.magnitude < 0.05f)
                    {
                        ragdollEndTime = Time.time;
                        anim.enabled = true;
                        coll.enabled = true;
                        rBody.isKinematic = false;
                        ragdollState = RagdollState.blended;

                        foreach (BodyPart bp in parts)
                        {
                            bp.pos = bp.t.position;
                            bp.rot = bp.t.rotation;
                        }

                        ragdolledFeetPos = 0.5f*(anim.GetBoneTransform(HumanBodyBones.LeftToes).position + anim.GetBoneTransform(HumanBodyBones.RightToes).position);
                        ragdolledHipPos = anim.GetBoneTransform(HumanBodyBones.Hips).position;
                        ragdolledHeadPos = anim.GetBoneTransform(HumanBodyBones.Head).position;

                        string getUpAnim;
                        if (anim.GetBoneTransform(HumanBodyBones.Hips).forward.y > 0)
                        {
                            if (anim.GetBoneTransform(HumanBodyBones.Hips).right.z < 0)
                            {
                                //animType = 1;
                                getUpAnim = AnimationStatesStatics.GetUpFromBack;
                            }
                            else
                            {
                                //animType = 3;
                                getUpAnim = AnimationStatesStatics.GetUpFromBackMirror;
                            }
                        }
                        else
                        {
                            if (anim.GetBoneTransform(HumanBodyBones.Hips).right.z < 0)
                            {
                                //animType = 2;
                                getUpAnim = AnimationStatesStatics.GetUpFromBelly;
                            }
                            else
                            {
                                //animType = 4;
                                getUpAnim = AnimationStatesStatics.GetUpFromBellyMirror;
                            }
                        }
                        anim.Play(getUpAnim, 0, 0);
                        SetKinematic(true);
                    }
                }
            }
        }
    }

    public enum RagdollState
    {
        animated, blended, ragdolled
    }

    public class BodyPart
    {
        public Transform t;
        public Vector3 pos;
        public Quaternion rot;
    }
    [HideInInspector] public int animType = -1;
    [HideInInspector] public bool gettingup = false;
    List<BodyPart> parts = new List<BodyPart>();
    public RagdollState ragdollState = new RagdollState();
    private Vector3 velWhole, velHips, lastPos = Vector3.zero;

    private Vector3 ragdolledHipPos, ragdolledHeadPos, ragdolledFeetPos;
    private float ragdollEndTime = -100f;

    private void Start()
    {
        pMoveBase = GetComponent<PlayerMovementBase>();
        inputHandler = pMoveBase.inputHandler;
        animHandler = GetComponent<AnimatorHandler>();
        anim = pMoveBase.anim;
        rBody = pMoveBase.rBody;
        coll = pMoveBase.coll;

        ragdollState = RagdollState.animated;

        childRigidbodies = transform.GetChild(1).GetComponentsInChildren<Rigidbody>();
        childColliders = transform.GetChild(1).GetComponentsInChildren<Collider>();


        foreach(Rigidbody r in childRigidbodies)
        {
            BodyPart bp = new BodyPart();
            bp.t = r.GetComponent<Transform>();
            parts.Add(bp);
        }

        childRigidbodies[0].constraints = RigidbodyConstraints.FreezePositionZ;
        
        if (!Ragdolled)
        {
            SetKinematic(true);

            anim.enabled = true;
            coll.enabled = true;
            rBody.isKinematic = false;
 
        } 
    }

    private void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.tag == "ragdoller" && pMoveBase.states.currentState == StateHandler.CurrentState.Sprinting)
        {
            Ragdolled = true;
        }
    } 

    private void Update()
    {
        ragdolled = Ragdolled;

        if (!Ragdolled)
        {
            velWhole = rBody.velocity;
            velHips = childRigidbodies[0].velocity;
        }
        else
        {
            Invoke("GetUp", 3f);
        }
    }
    
    private void LateUpdate()
    {
        if (pMoveBase.states.currentState != StateHandler.CurrentState.Sprinting || ragdollState == RagdollState.ragdolled)
        {
            //Ragdolled = inputHandler.RagdollButton.Pressing;
        }

        animType = -1;
        if (ragdollState == RagdollState.blended)
        {
            if (Time.time <= ragdollEndTime + 0.05f)
            {
                Vector3 rootHipDifference = anim.GetBoneTransform(HumanBodyBones.Hips).position - transform.position;
                anim.GetBoneTransform(HumanBodyBones.Hips).position -= new Vector3(rootHipDifference.x, 0, 0);
                Vector3 newRootPos = transform.position + rootHipDifference;

                RaycastHit[] hits = Physics.RaycastAll(new Ray(newRootPos, Vector3.down));
                newRootPos.y = 0;

                foreach (RaycastHit hit in hits)
                {
                    if (!hit.transform.IsChildOf(transform))
                    {
                        newRootPos.y=Mathf.Max(newRootPos.y, hit.point.y);
                    }
                }
                transform.position = newRootPos;
            }

            float blendAmount = 1 - (Time.time - ragdollEndTime - 0.05f)/0.5f;
            blendAmount = Mathf.Clamp01(blendAmount);

            foreach (BodyPart bp in parts)
            {
                //if (bp.t == anim.GetBoneTransform(HumanBodyBones.Hips))
                //    bp.t.position = Vector3.Lerp(bp.t.position, bp.pos, blendAmount);
                bp.t.rotation = Quaternion.Slerp(bp.t.rotation, bp.rot, blendAmount);
            }
            
    /*         SetKinematic(true);
            anim.enabled = true;
            
            if (anim.GetBoneTransform(HumanBodyBones.Hips).forward.y > 0)
            {
                if (anim.GetBoneTransform(HumanBodyBones.Hips).right.z < 0)
                {
                    animType = 1;
                    gettingup = false;
                }
                else
                {
                    animType = 3;
                    gettingup = false;
                }
            }
            else
            {
                if (anim.GetBoneTransform(HumanBodyBones.Hips).right.z < 0)
                {
                    animType = 2;
                    gettingup = false;
                }
                else
                {
                    animType = 4;
                    gettingup = false;
                }
            }

            coll.enabled = true;
            rBody.isKinematic = false; */

            if (blendAmount < Mathf.Epsilon)
            {
                ragdollState = RagdollState.animated;
                animType = -1;
                return;
            }
        }

    }

    private void GetUp()
    {   
        Ragdolled = false;
    }

    private void RagdollOn(Vector3 vWhole, Vector3 vHips)
    {
        animHandler.Animate(false,0,0,0,0,0,0,false,0,false,false,false,false,false,0,0,true,0);
        anim.enabled = false;

        SetKinematic(false);
        rBody.velocity = vWhole;
        childRigidbodies[0].velocity = (vHips + vWhole);
        coll.enabled = false;
        rBody.isKinematic = true;
    }

    private void SetKinematic(bool value)
    {
        foreach (Rigidbody rigidbody in childRigidbodies)
        {
            rigidbody.isKinematic = value;
        }
        foreach (Collider collider in childColliders)
        {
            collider.enabled = !value;
        }
    }

    private Vector3 GetVelocity(Transform t)
    {
        Vector3 v = (transform.position - lastPos) / Time.deltaTime;
        lastPos = transform.position;

        return v;
    }
}
