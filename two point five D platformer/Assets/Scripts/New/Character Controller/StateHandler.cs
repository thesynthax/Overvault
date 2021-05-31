/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About StateHandler
* -> Contains all the state variables
*/

[CreateAssetMenu(fileName = "States Handler/States")]
public class StateHandler : ScriptableObject
{
    public int curState = 0;
    public bool onGround = false;
    public int facingDir = 0;
}
