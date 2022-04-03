/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

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
    public bool Ragdoll;
    private void Start()
    {
        pMoveBase = GetComponent<PlayerMovementBase>();
        inputHandler = pMoveBase.inputHandler;
        anim = pMoveBase.anim;
        rBody = pMoveBase.rBody;
        coll = pMoveBase.coll;

        childRigidbodies = transform.GetChild(1).GetComponentsInChildren<Rigidbody>();
        childColliders = transform.GetChild(1).GetComponentsInChildren<Collider>();

    }

    private void OnCollisionEnter(Collision other)
    {
        if ((other.gameObject.tag == "ragdoller" && pMoveBase.states.currentState == StateHandler.CurrentState.Sprinting))
        {
            Ragdoll = true;
        }
    } 

    private void Update()
    {
        if (pMoveBase.states.currentState != StateHandler.CurrentState.Sprinting)
            Ragdoll = inputHandler.RagdollButton.Pressing;

        if (Ragdoll)
        {
            Vector3 vel = rBody.velocity;
            anim.enabled = false;

            foreach (Rigidbody rigidbody in childRigidbodies)
            {
                rigidbody.isKinematic = false;
            }
            foreach (Collider collider in childColliders)
            {
                collider.isTrigger = false;
            }
            childRigidbodies[0].velocity = vel;
            coll.enabled = false;
            rBody.isKinematic = true;
        }
        else
        {
            foreach (Rigidbody rigidbody in childRigidbodies)
            {
                rigidbody.isKinematic = true;
            }
            foreach (Collider collider in childColliders)
            {
                collider.isTrigger = true;
            }

            anim.enabled = true;
            coll.enabled = true;
            rBody.isKinematic = false;
        }
    }
}
