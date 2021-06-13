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
    public float camMoveSpeed;
    public PlayerMovementBase pMoveBase;
    private Vector3 velocity = Vector3.zero;


    private void LateUpdate()
    {
        if (pMoveBase.slideCrouchHandler.UnderObstacleTime() < 0.1f)
        {
            offset.y = 0.5f;
        }
        else
        {
            offset.y = -0.3f;
        }

        Vector3 desiredPosition = target.position + offset;
        Vector3 smoothedPosition = Vector3.SmoothDamp(transform.position, desiredPosition, ref velocity, camMoveSpeed);
        transform.position = smoothedPosition;
    }
    
}
