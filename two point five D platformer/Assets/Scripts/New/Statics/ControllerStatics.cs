/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;

/** About ControllerStatics
* -> 
*/

public static class ControllerStatics
{
    public static float groundDistance = 0.634f;
    public static LayerMask ground = 1 << LayerMask.NameToLayer("ground");
    public static LayerMask obstacle = 1 << LayerMask.NameToLayer("Obstacles");
    public static LayerMask groundAndObs = ground.value | obstacle.value;
}
