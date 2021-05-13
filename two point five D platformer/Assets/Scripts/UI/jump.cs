/**
*   Copyright (c) 2021 - 3021 Aansutons Inc.
*/

using UnityEngine;
using UnityEngine.EventSystems;

/** About jump
* -> 
*/

public class jump : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public bool pressed { get; set; }
    public enum CurrentPressState {IsPressed, WasPressed, WasReleased}
    public CurrentPressState currentPressState;
    public virtual void OnPointerDown(PointerEventData ped)
    {
        pressed = true;
        currentPressState = CurrentPressState.IsPressed;
    }
    public virtual void OnPointerUp(PointerEventData ped)
    {
        pressed = false;
        currentPressState = CurrentPressState.WasReleased;
    }

}
