/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About CameraControl
* -> Camera Movement
*/

public class CameraControl : MonoBehaviour
{
    public Transform target;
    public Vector3 offset;
    public float xOffset;
    public float camMoveSpeed;
    public StateManager stateMgr;
    private Vector3 velocity = Vector3.zero;


    private void LateUpdate()
    {
        /* if (stateMgr.charStates.curState != 3)
        {
            offset.x = 1.5f;
            offset.z = -5;
        }
        else
        {
            offset.x = 2;
            offset.z = -7;
        } */

        Vector3 desiredPosition = target.position + offset;
        Vector3 smoothedPosition = Vector3.SmoothDamp(transform.position, desiredPosition, ref velocity, camMoveSpeed);
        transform.position = smoothedPosition;
    }
}
