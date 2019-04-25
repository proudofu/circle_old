function [alpha, beta, gamma, R_fit] = fit_led_power(led_power, led_setting)

% f = ezfit(led_power, led_setting,'led_setting(led_power) = alpha*(led_power^beta)+gamma; alpha=400; beta=1; gamma=1');
% gamma = f.m(3);

%f = ezfit(led_power, led_setting,'led_setting(led_power) = alpha*(led_power^beta); alpha=400; beta=1');
l1 = log(led_power);l2=log(led_setting);
bfun = robustfit(l1,l2);
alpha = exp(bfun(1));
beta = bfun(2);
gamma = 0;


%alpha = f.m(1);
%beta = f.m(2);

%R_fit = f.r2;
R_fit = 0;

%clear('f');

end

