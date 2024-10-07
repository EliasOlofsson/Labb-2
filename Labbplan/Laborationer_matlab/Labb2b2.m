
u = GetSine(0.2);


[y, t, ~] = OpenControl(u);

est_Sine = Est_Sine(y)

plot(t, u)
hold on
plot(t, est_sine)