function [FEFs, SCs, MDs, exKernel, inKernel] = remapping( tlen,FEF_C_in, FEF_E_in, FEF_A_in, SC_C_in, SC_E_in, SC_A_in, ...
    FEF_input_node, SC_output_node, Ex_kernel_width_input, In_kernel_width_input, Inter_Areal_Kernel_in, FEF_in_time  )
%function [FEFs, SCs, MDs, exKernel, inKernel] = remapping( tlen,FEF_C_in, FEF_E_in, FEF_A_in, SC_C_in, SC_E_in, SC_A_in, ...
%    FEF_input_node, SC_output_node, Ex_kernel_width_input, In_kernel_width_input, Inter_Areal_Kernel_in, FEF_in_time  )
%
%   Network simulation of receptive field remapping, with 3 brain areas
%   (FEF, MD, and SC). FEF layer takes sensory input, and SC provides a
%   corrolary discharge projected via MD pathway back to FEF.
%
% INPUTS
%   tlen                       Length of simulation time steps ( > 3000 )
%   FEF_C_in                   Excitatory kernel's coefficient for FEF
%   FEF_E_in                   Inhibitory kernel's coefficient for FEF
%   FEF_A_in                   Decay rate for FEF layer
%   SC_C_in                    Excitatory kernel's coefficient for SC
%   SC_E_in                    Excitatory kernel's coefficient for SC
%   SC_A_in                    Decay rate for SC layer
%   FEF_input_node             Input node number for FEF (>0 & <100)
%   SC_output_node             Output node number for SC (>0 & <100)
%   Ex_kernel_width_input      Excitatory kernel width (<100)
%   In_kernel_width_input      Inhibitory kernel width (< 100)
%   Inter_Areal_Kernel_in      Excitatory interareal kernel width (<100)
%   FEF_in_time                Time of excitatory input to FEF layer
%
% OUTPUTS
%   FEFs                       Network activity of FEF layer [100, tlen]
%   SCs                        Network activity of SC layer [100, tlen]
%   MDs                        Network activity of MD layer [100, tlen]
%   exKernel                   Excitatory kernel [100,1]
%   inKernel                   Inhibitory kernel [100,1]


% define network parameters

FEF_n = 100;        % 100 network nodes
FEF_k = 1:1:FEF_n;  % unit indices
FEF_A = FEF_A_in;   % shunting decay rate
FEF_B = 90;         % shunting ceiling
FEF_C = FEF_C_in;   % excitatory kernel's coefficient
FEF_E = FEF_E_in;   % inhibitory kernel's coefficient
FEF_D = 30;         % shunting floor (hyperpolarization term)

FEF_u =  Ex_kernel_width_input; % excitatory kernel width 
FEF_v =  In_kernel_width_input; % inhibitory kernel width


SC_n = 100;
SC_k = 1:1:SC_n;
SC_A = FEF_A_in; % 1000;
SC_B = 90;
SC_C = FEF_C_in; %2;
SC_D = 30;
SC_E = FEF_E_in; %2.15;
SC_u =  Ex_kernel_width_input;
SC_v =  In_kernel_width_input;
SC_in_time = 1500;

MD_n = 100;
MD_k = 1:1:MD_n;
MD_A = FEF_A_in; % 1000;
MD_B = 90;
MD_C = FEF_C_in; %2;
MD_D = 30;
MD_E = FEF_E_in; %2.15;
MD_u =  Ex_kernel_width_input;
MD_v =  In_kernel_width_input;


interArealKernel = ones(1,Inter_Areal_Kernel_in);

% ======================================== generate kernels

FEF_Ck = zeros(FEF_n,FEF_n);    % FEF excitatory kernel map for entire FEF layer
FEF_Ek = zeros(FEF_n,FEF_n);    % FEF inhibitory map for entire FEF layer

SC_Ck = zeros(SC_n,SC_n);
SC_Ek = zeros(SC_n,SC_n);

MD_Ck = zeros(MD_n,MD_n);
MD_Ek = zeros(MD_n,MD_n);

for i = 1:1:FEF_n
    FEF_Ck(i,:) = FEF_C*exp(-FEF_u^(-2)*((FEF_k-i).^2)); % FEF excitatory kernel
    FEF_Ek(i,:) = FEF_E*exp(-FEF_v^(-2)*((FEF_k-i).^2)); % FEF inhibitory kernel
end

for i = 1:1:SC_n
    SC_Ck(i,:) = SC_C*exp(-SC_u^(-2)*((SC_k-i).^2)); % SC excitatory kernel
    SC_Ek(i,:) = SC_E*exp(-SC_v^(-2)*((SC_k-i).^2)); % SC inhibitory kernel
end

for i = 1:1:MD_n
    MD_Ck(i,:) = MD_C*exp(-MD_u^(-2)*((MD_k-i).^2)); % MD excitatory kernel
    MD_Ek(i,:) = MD_E*exp(-MD_v^(-2)*((MD_k-i).^2)); % MD inhibitory kernel
end

exKernel = FEF_Ck(50,:);
inKernel = FEF_Ek(50,:);
%figure(); 
%plot(1:FEF_n,FEF_Ck(50,:),1:FEF_n,FEF_Ek(50,:),1:FEF_n, FEF_Ck(50,:)-FEF_Ek(50,:))

%figure(); 
%plot(1:SC_n,SC_Ck(50,:),1:SC_n,SC_Ek(50,:),1:SC_n, SC_Ck(50,:)-SC_Ek(50,:))


% ======================================== shunting equations + numerical
% integration using Euler's method
h = .00001; % Euler step
% tlen = 8000;
FEFs = zeros(tlen, FEF_n);
SCs = zeros(tlen, SC_n);
MDs = zeros(tlen, MD_n);

%  inputs

FEF_I = zeros(1,FEF_n);
SC_I = zeros(1,SC_n);
MD_I = zeros(1,MD_n);


SC_layer = zeros(1,SC_n);
FEF_layer = zeros(1,FEF_n);
MD_layer = zeros(1,MD_n);

%tic
for t = 1:tlen

    % only send rectified signals to next layer
    SC_layer_input = max(SC_layer,0);  
    FEF_layer_input = max(FEF_layer,0);
    MD_layer_input = max(MD_layer, 0);
    
   if t>0 && t < 3000
       % Set stimulation node activity
       FEF_I = setStimulationNode(FEF_I, FEF_input_node, FEF_in_time, t)
       SC_I = setStimulationNode(SC_I, SC_output_node, SC_in_time, t)
   else
       % Set/reset stimulation node activity
       FEF_I = resetStimulationNode(FEF_I, FEF_input_node)
       SC_I = resetStimulationNode(SC_I, SC_output_node)
   end

     
    % network integration
    FEF_input = FEF_I(ones(1,FEF_n),:)+ convn(MD_layer_input(ones(1,FEF_n),:),interArealKernel,'same');
    FEF_Excitation = sum(FEF_input.*FEF_Ck,2);
    FEF_Inhibition = sum(FEF_input.*FEF_Ek,2);
    FEF_layer = FEF_layer + h.*(-FEF_A*FEF_layer + (FEF_B-FEF_layer).*FEF_Excitation' - (FEF_layer+FEF_D).*FEF_Inhibition');
  
    FEFs(t,:) = FEF_layer;
 
    
    SC_input = SC_I(ones(1,SC_n),:)+ convn(FEF_layer_input(ones(1,SC_n),:), interArealKernel,'same');
    SC_Excitation = sum(SC_input.*SC_Ck,2);
    SC_Inhibition = sum(SC_input.*SC_Ek,2);
    SC_layer = SC_layer + h.*(-SC_A*SC_layer + (SC_B-SC_layer).*SC_Excitation' - (SC_layer+SC_D).*SC_Inhibition');

    SCs(t,:) = SC_layer;
  
    % MD layer takes input from both SC and FEF
    MD_input = MD_I(ones(1,MD_n),:) + convn(SC_layer_input(ones(1,MD_n),:),interArealKernel,'same') + convn(FEF_layer_input(ones(1,MD_n),:),interArealKernel,'same');
    MD_Excitation = sum(MD_input.*MD_Ck,2);
    MD_Inhibition = sum(MD_input.*MD_Ek,2);
    MD_layer = MD_layer + h.*(-MD_A*MD_layer + (MD_B-MD_layer).*MD_Excitation' - (MD_layer+MD_D).*MD_Inhibition');
    %MD_layer = zeros(1,MD_n);
    MDs(t,:) = MD_layer;
    
end
%toc
%figure(1); meshc(FEFs);
%figure(2); meshc(SCs);

end

function network = setStimulationNode(network, node, inputTime, t)

    network(node-2) = .2*exp(-.00001*(inputTime-t)^2); 
    network(node-1) = .5*exp(-.00001*(inputTime-t)^2); 
    network(node) = exp(-.00001*(inputTime-t)^2);
    network(node+1) = .5*exp(-.00001*(inputTime-t)^2);
    network(node+2) = .2*exp(-.00001*(inputTime-t)^2); 
end

function network = resetStimulationNode(network, node)
    network(node-2) = 0;
    network(node-1) = 0;
    network(node) = 0;
    network(node+1) = 0;
    network(node+2) = 0;
end