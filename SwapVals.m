function [Array] = SwapVals(Array, SwitchA, SwitchB)
    Array(Array == SwitchA) = 9999;
    Array(Array == SwitchB) = SwitchA;
    Array(Array == 9999) = SwitchB;