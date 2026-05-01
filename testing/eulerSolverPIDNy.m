function [bromsKraft, integralFel, error_gammal] = eulerSolverPIDNy(malAcceleration, a, integralFel, error_gammal, h, Kp, Ki, Kd)

    error = malAcceleration - a;

    % Integral
    integralFel = integralFel + error*h;
    integralFel = max(min(integralFel, 100), -100);

    % Derivata
    d_error = (error - error_gammal)/h;
    error_gammal = error;

    % PID
    bromsKraft = Kp*error + Ki*integralFel + Kd*d_error;

    % Begränsning
    bromsKraft = 5000 * tanh(bromsKraft/5000);
    bromsKraft = max(0, bromsKraft);
end