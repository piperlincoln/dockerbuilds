% Rocket Propulsion Project #1
% Authors: Piper Lincoln and Meghan Collins

% Inputs
gamma=1.667;
r_t=1;
x_co=0.4695;
x_e=7.552;
x=(-2*x_co:(x_co/10):x_e);
area=zeros(1,length(x));
area_throat_cd=pi*r_t^2;
area_throat_b=2.236; % From EES Code Calculation
shock_location=x(99); % From EES Code Calculation

% Find the Mach Distribution for Case Three
m_sub_b=zeros(1,length(x));
radius=zeros(1,length(x));

for i=1:length(x)
    radius(i)=height(x(i));
    area(i)=radius(i)^2*pi;
    area_ratio=area(i)/area_throat_b;
    m_sub_b(i)=min(mach_distribution(area_ratio));
end

% Find the Mach Distribution for Case One and Two and Four
m_sub_cd=zeros(1,length(x));
m_sup_cd=zeros(1,length(x));

for i=1:length(x)
    area_ratio=area(i)/area_throat_cd;
    m_sub_cd(i)=min(mach_distribution(area_ratio));
    m_sup_cd(i)=max(mach_distribution(area_ratio));
end

% Find the Mach Number for After Shock in Case Four
m_shock=zeros(1,length(x));

for i=1:length(x)
    m_shock(i)=shock_mach(m_sup_cd(i));
end

% Case One: P_E=P_SUB
% Case Two: P_E=P_SUP
% Case Three: P_SUB < P_E < P_0
% Case Four: P_SUP < P_E < P_SUB

% Pressure Distribution
pressure_ratio=zeros(4,length(x));
for i=1:length(x)
    if x(i) == 0
        pressure_ratio(1,i)=pressure(1);
        pressure_ratio(2,i)=pressure(1);
        pressure_ratio(3,i)=pressure(m_sub_b(i));
        pressure_ratio(4,i)=pressure(1);
    elseif x(i) < 0
        pressure_ratio(1,i)=pressure(m_sub_cd(i));
        pressure_ratio(2,i)=pressure(m_sub_cd(i));
        pressure_ratio(3,i)=pressure(m_sub_b(i));
        pressure_ratio(4,i)=pressure(m_sub_cd(i));
    elseif (x(i) > 0 && x(i) < 3.6621)
        pressure_ratio(1,i)=pressure(m_sub_cd(i));
        pressure_ratio(2,i)=pressure(m_sup_cd(i));
        pressure_ratio(3,i)=pressure(m_sub_b(i));
        pressure_ratio(4,i)=pressure(m_sup_cd(i));
    else
        pressure_ratio(1,i)=pressure(m_sub_cd(i));
        pressure_ratio(2,i)=pressure(m_sup_cd(i));
        pressure_ratio(3,i)=pressure(m_sub_b(i));
        pressure_ratio(4,i)=pressure(m_shock(i))*(0.2265);
    end
end

% Density Distribution
density_ratio=zeros(4,length(x));
for i=1:length(x)
    if x(i) == 0
        density_ratio(1,i)=density(1);
        density_ratio(2,i)=density(1);
        density_ratio(3,i)=density(m_sub_b(i));
        density_ratio(4,i)=density(1);
    elseif x(i) < 0
        density_ratio(1,i)=density(m_sub_cd(i));
        density_ratio(2,i)=density(m_sub_cd(i));
        density_ratio(3,i)=density(m_sub_b(i));
        density_ratio(4,i)=density(m_sub_cd(i));
    elseif (x(i) > 0 && x(i) < 3.6621)
        density_ratio(1,i)=density(m_sub_cd(i));
        density_ratio(2,i)=density(m_sup_cd(i));
        density_ratio(3,i)=density(m_sub_b(i));
        density_ratio(4,i)=density(m_sup_cd(i));
    else
        density_ratio(1,i)=density(m_sub_cd(i));
        density_ratio(2,i)=density(m_sup_cd(i));
        density_ratio(3,i)=density(m_sub_b(i));
        density_ratio(4,i)=density(m_shock(i));
    end
end

% Temperature Distribution
temperature_ratio=zeros(4,length(x));
for i=1:length(x)
    if x(i) == 0
        temperature_ratio(1,i)=temperature(1);
        temperature_ratio(2,i)=temperature(1);
        temperature_ratio(3,i)=temperature(m_sub_b(i));
        temperature_ratio(4,i)=temperature(1);
    elseif x(i) < 0
        temperature_ratio(1,i)=temperature(m_sub_cd(i));
        temperature_ratio(2,i)=temperature(m_sub_cd(i));
        temperature_ratio(3,i)=temperature(m_sub_b(i));
        temperature_ratio(4,i)=temperature(m_sub_cd(i));
    elseif (x(i) > 0 && x(i) < 3.6621)
        temperature_ratio(1,i)=temperature(m_sub_cd(i));
        temperature_ratio(2,i)=temperature(m_sup_cd(i));
        temperature_ratio(3,i)=temperature(m_sub_b(i));
        temperature_ratio(4,i)=temperature(m_sup_cd(i));
    else
        temperature_ratio(1,i)=temperature(m_sub_cd(i));
        temperature_ratio(2,i)=temperature(m_sup_cd(i));
        temperature_ratio(3,i)=temperature(m_sub_b(i));
        temperature_ratio(4,i)=temperature(m_shock(i));
    end
end

% Velocity Distribution
velocity_ratio=zeros(4,length(x));
for i=1:length(x)
    if x(i) == 0
        velocity_ratio(1,i)=velocity(1,1/temperature_ratio(1,x==0));
        velocity_ratio(2,i)=velocity(1,1/temperature_ratio(2,x==0));
        velocity_ratio(3,i)=velocity(m_sub_b(i),1/temperature_ratio(3,x==0));
        velocity_ratio(4,i)=velocity(1,1/temperature_ratio(4,x==0));
    elseif x(i) < 0
        velocity_ratio(1,i)=velocity(m_sub_cd(i),1/temperature_ratio(1,x==0));
        velocity_ratio(2,i)=velocity(m_sub_cd(i),1/temperature_ratio(2,x==0));
        velocity_ratio(3,i)=velocity(m_sub_b(i),1/temperature_ratio(3,x==0));
        velocity_ratio(4,i)=velocity(m_sub_cd(i),1/temperature_ratio(4,x==0));
    elseif (x(i) > 0 && x(i) < 3.6621)
        velocity_ratio(1,i)=velocity(m_sub_cd(i),1/temperature_ratio(1,x==0));
        velocity_ratio(2,i)=velocity(m_sup_cd(i),1/temperature_ratio(2,x==0));
        velocity_ratio(3,i)=velocity(m_sub_b(i),1/temperature_ratio(3,x==0));
        velocity_ratio(4,i)=velocity(m_sup_cd(i),1/temperature_ratio(2,x==0));
    else
        velocity_ratio(1,i)=velocity(m_sub_cd(i),1/temperature_ratio(1,x==0));
        velocity_ratio(2,i)=velocity(m_sup_cd(i),1/temperature_ratio(2,x==0));
        velocity_ratio(3,i)=velocity(m_sub_b(i),1/temperature_ratio(3,x==0));
        velocity_ratio(4,i)=velocity(m_shock(i),1/temperature_ratio(2,x==0));
    end
end

% Plotting
figure(1)
plot(x,radius)
xlim([-1,8])
ylim([0,3.5])
title('Radius vs. X')

figure(2)
plot(x,area)
title('Area vs. X')

figure(3)
for i=1:length(x)
   if x(i) < 0
       m_1(i)=m_sub_cd(i);
       m_2(i)=m_sub_cd(i);
       m_3(i)=m_sub_b(i);
       m_4(i)=m_sub_cd(i);
   elseif x(i)==0
       m_1(i)=1;
       m_2(i)=1;
       m_3(i)=m_sub_b(i);
       m_4(i)=1;
   elseif (x(i) > 0 && x(i) < 3.6621)
       m_1(i)=m_sub_cd(i);
       m_2(i)=m_sup_cd(i);
       m_3(i)=m_sub_b(i);
       m_4(i)=m_sup_cd(i);
   else
       m_1(i)=m_sub_cd(i);
       m_2(i)=m_sup_cd(i);
       m_3(i)=m_sub_b(i);
       m_4(i)=m_shock(i);
   end
end
hold on
plot(x,m_1)
plot(x,m_2)
plot(x,m_3)
plot(x,m_4)
title('Mach Number vs. X')
legend('Case One', 'Case Two', 'Case Three', 'Case Four')
ylim([0,5])
hold off

figure(4)
hold on
plot(x,pressure_ratio(1,:))
plot(x,pressure_ratio(2,:))
plot(x,pressure_ratio(3,:))
plot(x,pressure_ratio(4,:))
title('Pressure vs. X')
legend('Case One', 'Case Two', 'Case Three', 'Case Four')
ylim([0,1])
hold off

figure(5)
hold on
plot(x,density_ratio(1,:))
plot(x,density_ratio(2,:))
plot(x,density_ratio(3,:))
plot(x,density_ratio(4,:))
title('Density vs. X')
legend('Case One', 'Case Two', 'Case Three', 'Case Four')
%ylim([0,1])
hold off

figure(6)
hold on
plot(x,temperature_ratio(1,:))
plot(x,temperature_ratio(2,:))
plot(x,temperature_ratio(3,:))
plot(x,temperature_ratio(4,:))
title('Temperature vs. X')
legend('Case One', 'Case Two', 'Case Three', 'Case Four')
ylim([0.1,1])
hold off

figure(7)
hold on
plot(x,velocity_ratio(1,:))
plot(x,velocity_ratio(2,:))
plot(x,velocity_ratio(3,:))
plot(x,velocity_ratio(4,:))
title('Velocity vs. X')
legend('Case One', 'Case Two', 'Case Three', 'Case Four')
ylim([0,2])
hold off

% Find Maximum Fractional Departure from Stagnation Density
percent_difference=zeros(1,length(x));
for i=1:length(x)
   percent_difference=100*(density_ratio(3,i)-1);
end
maximum_departure=max(percent_difference);
disp("The maximum fractional departure from constant density is " + maximum_departure + "%.")

function radius=height(x)
    r_dt=1;
    r_ut=2;
    r_cd=2;
    r_cu=3;
    x_co=0.4695;
    a=0.8592;
    b=0.567;
    c=-0.03754;

    if x<0
        radius=r_cu-sqrt((r_ut^2)-(x^2));
    elseif ((x>=0) && (x<=x_co))
        radius=r_cd-sqrt((r_dt^2)-(x^2));
    else
        radius=a+(b*x)+(c*x^2);
    end
end

function roots=mach_distribution(area_ratio)
    gamma=1.667;
    f=@(M)area_ratio-(1./M).*((2/(gamma+1))*(1+((gamma-1)/2).*M.^2)).^((gamma+1)/(2*(gamma-1)));
    roots=newtzero(f);
end

function p_ratio=pressure(m)
    gamma=1.667;
    p_ratio=(1+((gamma-1)/2)*m^2)^(gamma/(1-gamma));
end

function d_ratio=density(m)
    gamma=1.667;
    d_ratio=(1+((gamma-1)/2)*m^2)^(1/(gamma-1));
end

function t_ratio=temperature(m)
    gamma=1.667;
    t_ratio=1/(1+((gamma-1)/2)*m^2);
end

function v_ratio=velocity(m,T)
    gamma=1.667;
    v_ratio=m*sqrt(1/(1+((gamma-1)/2)*m^2))*sqrt(T);
end

function mach=shock_mach(m)
    gamma=1.667;
    mach=((1+(((gamma-1)/2)*m^2))/(gamma*m^2-((gamma-1)/2)))^0.5;
end