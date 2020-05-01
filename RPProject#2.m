% Rocket Propulsion Project #2
% Authors: Piper Lincoln and Ebenezer Fanibi

% Inputs
gamma=1.2;
atm_pressure_ratio=[0,0.001,0.002,0.003,0.005,0.010,0.020,0.030,0.050,0.10];
mach_no_shock=(1:0.1:6.874);
mach_exit=(0.001:0.01:0.999);

% No Shock
area_ratio=zeros(10,length(mach_no_shock));
pressure_ratio=zeros(10,length(mach_no_shock));
thrust_coefficient=zeros(10,length(mach_no_shock));
thrust_coefficient_conv=zeros(10,length(mach_no_shock));
thrust_ratio=zeros(10,length(mach_no_shock));
for i=1:length(atm_pressure_ratio)
     for j=1:length(mach_no_shock)
         area_ratio(i,j)=area_finder(gamma,mach_no_shock(j));
         pressure_ratio(i,j)=(1+((gamma-1)/2)*mach_no_shock(j)^2)^(gamma/(1-gamma));
         thrust_coefficient(i,j)=((((2*gamma^2)/(gamma-1))*((2/(gamma+1))^((gamma+1)/(gamma-1)))*(1-(pressure_ratio(i,j))^((gamma-1)/gamma)))^0.5)+(pressure_ratio(i,j)-atm_pressure_ratio(i))*area_ratio(i,j);
         thrust_coefficient_conv(i,j)=(gamma^2*(2/(gamma+1))^((2*gamma)/(gamma-1)))^0.5+((2/(gamma+1))^(gamma/(gamma-1))-atm_pressure_ratio(i));
         thrust_ratio(i,j)=thrust_coefficient(i,j)/thrust_coefficient_conv(i,j);
     end
end

% Shock in Nozzle
area_ratio_s=zeros(10,length(mach_exit));
area_ratio_before=zeros(10,length(mach_exit));
pressure_ratio_s=zeros(10,length(mach_exit));
thrust_coefficient_s=zeros(10,length(mach_exit));
stag_pressure_ratio_s=zeros(10,length(mach_exit));
thrust_coefficient_conv_s=zeros(10,length(mach_exit));
thrust_ratio_s=zeros(10,length(mach_exit));
for i=1:length(atm_pressure_ratio)
    for j=1:length(mach_exit)
        area_ratio_s(i,j)=area_finder(gamma,mach_exit(j));
        pressure_ratio_s(i,j)=(1+((gamma-1)/2)*mach_exit(j)^2)^(gamma/(1-gamma));
        thrust_coefficient_s(i,j)=gamma*(mach_exit(j)^2)*pressure_ratio_s(i,j)*area_ratio_s(i,j);
        stag_pressure_ratio_s(i,j)=atm_pressure_ratio(i)*(1/pressure_ratio_s(i,j));
        area_ratio_before(i,j)=area_ratio_s(i,j)*(1/stag_pressure_ratio_s(i,j));
        thrust_coefficient_conv_s(i,j)=(gamma^2*(2/(gamma+1))^((2*gamma)/(gamma-1)))^0.5+((2/(gamma+1))^(gamma/(gamma-1))-atm_pressure_ratio(i));
        thrust_ratio_s(i,j)=thrust_coefficient_s(i,j)/thrust_coefficient_conv_s(i,j);
    end
end

% Line of Maximum Thrust
max_thrust_line=zeros(11,2);
for i=1:length(atm_pressure_ratio)
    [value,index]=max(thrust_ratio(i,:)); 
    max_thrust_line(i,2)=value;
    max_thrust_line(i,1)=area_ratio(i,index);
end
max_thrust_line(11,1)=1;
max_thrust_line(11,2)=1;

% Shock Line
shock_line=[1100 0.18299; 917.4431 0.18299; 592.9592 0.18878; 355.7755 0.18909; 172.6138 0.19553; 83.8193 0.20284; 55.8796 0.20451; 31.6977 0.21964; 15.0269 0.24143];

% Plotting
hold on
plot(area_ratio(1,:),thrust_ratio(1,:))
plot(area_ratio(2,:),thrust_ratio(2,:))
x_3=[area_ratio(3,1:57) 917.4431 flip(area_ratio_before(3,1:33))];
y_3=[thrust_ratio(3,1:57) 0.18299 flip(thrust_ratio_s(3,1:33))];
plot(x_3,y_3)
x_4=[area_ratio(4,1:53) 592.9592 flip(area_ratio_before(4,1:33))];
y_4=[thrust_ratio(4,1:53) 0.18878 flip(thrust_ratio_s(4,1:33))];
plot(x_4,y_4)
x_5=[area_ratio(5,1:49) 355.7755 flip(area_ratio_before(5,1:33))];
y_5=[thrust_ratio(5,1:49) 0.18909 flip(thrust_ratio_s(5,1:33))];
plot(x_5,y_5)
x_6=[area_ratio(6,1:43) 172.6138 flip(area_ratio_before(6,1:33))];
y_6=[thrust_ratio(6,1:43) 0.19553 flip(thrust_ratio_s(6,1:33))];
plot(x_6,y_6)
x_7=[area_ratio(7,1:38) 83.8193 flip(area_ratio_before(7,1:33))];
y_7=[thrust_ratio(7,1:38) 0.20284 flip(thrust_ratio_s(7,1:33))];
plot(x_7,y_7)
x_8=[area_ratio(8,1:35) 55.8796 flip(area_ratio_before(8,1:33))];
y_8=[thrust_ratio(8,1:35) 0.20451 flip(thrust_ratio_s(8,1:33))];
plot(x_8,y_8)
x_9=[area_ratio(9,1:31) 31.6977 flip(area_ratio_before(9,1:33))];
y_9=[thrust_ratio(9,1:31) 0.21964 flip(thrust_ratio_s(9,1:33))];
plot(x_9,y_9)
x_10=[area_ratio(10,1:26) 15.0269 flip(area_ratio_before(10,1:33))];
y_10=[thrust_ratio(10,1:26) 0.24143 flip(thrust_ratio_s(10,1:33))];
plot(x_10,y_10)
max_line=[1161.66401128980,1.66993009507447; 66.7372595987187,1.49695716925246; 28.3552613248888,1.42801389799220;  11.9104857931294,1.33500850761139; 6.73540604177603,1.27238934879448; 5.10333262275326,1.23324680099266; 3.42053258651476,1.18137319147903; 1 1];
plot(max_line(:,1),max_line(:,2));
plot(shock_line(:,1),shock_line(:,2),'k');
legend('0','0.001','0.002','0.003','0.005','0.010','0.020','0.030','0.050','0.10','Maximum Thrust','Shock')
hold off
xlabel('A_e/A*')
xlim([1,1000])
set(gca, 'XScale', 'log')
ylabel('c_T/c_TConvergent')
ylim([0,1.8])
title('Gamma = 1.2')

function area_ratio=area_finder(gamma,M)
    f=@(AR)AR-(1./M).*((2/(gamma+1))*(1+((gamma-1)/2).*M.^2)).^((gamma+1)/(2*(gamma-1)));
    area_ratio=newtzero(f);
end