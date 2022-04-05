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
    private Animator anim;
    private Rigidbody rBody;
    private CapsuleCollider coll;

    private Rigidbody[] childRigidbodies;
    private Collider[] childColliders;
    
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
/*                     SetKinematic(true);
                    ragdollEndTime = Time.time;
                    ragdollState = RagdollState.blended;

                    foreach (BodyPart bp in parts)
                    {
                        bp.pos = bp.t.position;
                        bp.rot = bp.t.rotation;
                    }

                    ragdolledFeetPos = 0.5f*(anim.GetBoneTransform(HumanBodyBones.LeftToes).position + anim.GetBoneTransform(HumanBodyBones.RightToes).position);
                    ragdolledHipPos = anim.GetBoneTransform(HumanBodyBones.Hips).position;
                    ragdolledHeadPos = anim.GetBoneTransform(HumanBodyBones.Head).position; */

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
    public int animType = -1;
    List<BodyPart> parts = new List<BodyPart>();
    public RagdollState ragdollState = new RagdollState();
    private Vector3 velWhole, velHips, lastPos = Vector3.zero;

    private Vector3 ragdolledHipPos, ragdolledHeadPos, ragdolledFeetPos;
    private float ragdollEndTime = 0f;

    private void Start()
    {
        pMoveBase = GetComponent<PlayerMovementBase>();
        inputHandler = pMoveBase.inputHandler;
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
    }

    private void OnCollisionEnter(Collision other)
    {
        if ((other.gameObject.tag == "ragdoller" && pMoveBase.states.currentState == StateHandler.CurrentState.Sprinting))
        {
            Ragdolled = true;
        }
    } 

    private void Update()
    {
        if (!Ragdolled)
        {
            velWhole = rBody.velocity;
            velHips = childRigidbodies[0].velocity;
        }
    }
    
    private void LateUpdate()
    {
        if (pMoveBase.states.currentState != StateHandler.CurrentState.Sprinting || ragdollState == RagdollState.ragdolled)
        {
            Ragdolled = inputHandler.RagdollButton.Pressing;
        }

        if (!Ragdolled)
        {
            SetKinematic(true);

            anim.enabled = true;
            coll.enabled = true;
            rBody.isKinematic = false;
 
        } 

        animType = -1;

        if (ragdollState == RagdollState.blended)
        {
            Invoke("GetUp", 2f);
        }

    }

    private void GetUp()
    {
        /* anim.enabled = true;
        if (anim.GetBoneTransform(HumanBodyBones.Hips).forward.y > 0)
        {
            if (anim.GetBoneTransform(HumanBodyBones.Hips).right.z < 0)
            {
                animType = 1;
            }
            else
            {
                animType = 3;
            }
        }
        else
        {
            if (anim.GetBoneTransform(HumanBodyBones.Hips).right.z < 0)
            {
                animType = 2;
            }
            else
            {
                animType = 4;
            }
        }

        coll.enabled = true;
        rBody.isKinematic = false;
        
        if (Time.time <= ragdollEndTime + 0.05f)
        {
            Vector3 newRootPos = transform.position + ragdolledHipPos - anim.GetBoneTransform(HumanBodyBones.Hips).position;

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

            Vector3 ragdollDirection = ragdolledHeadPos - ragdolledFeetPos;
            ragdollDirection.y = 0;

            Vector3 meanFeetPosition=0.5f*(anim.GetBoneTransform(HumanBodyBones.LeftFoot).position + anim.GetBoneTransform(HumanBodyBones.RightFoot).position);
            Vector3 animatedDirection=anim.GetBoneTransform(HumanBodyBones.Head).position - meanFeetPosition;
            animatedDirection.y=0;
                                    
            transform.rotation*=Quaternion.FromToRotation(animatedDirection.normalized,ragdollDirection.normalized);
        }

        float blendAmount = 1 - (Time.time - ragdollEndTime - 0.05f)/0.5f;
        blendAmount = Mathf.Clamp01(blendAmount);

        foreach (BodyPart bp in parts)
        {
            if (bp.t != transform)
            { 
                if (bp.t == anim.GetBoneTransform(HumanBodyBones.Hips))
                    bp.t.position = Vector3.Lerp(bp.t.position, bp.pos, blendAmount);
                bp.t.rotation = Quaternion.Slerp(bp.t.rotation, bp.rot, blendAmount);
            }
        }
        
        if (blendAmount == 0)
        {
            ragdollState = RagdollState.animated;
            return;
        }
*/
    }

    private void RagdollOn(Vector3 vWhole, Vector3 vHips)
    {
        //Debug.Log("Whole:" + velWhole + " Hips:" + velHips);
        anim.enabled = false;

        SetKinematic(false);
        rBody.velocity = vWhole;
        childRigidbodies[0].velocity = (vHips + vWhole);
        //Debug.Log("Whole:" + rBody.velocity + " Hips:" + childRigidbodies[0].velocity);
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
