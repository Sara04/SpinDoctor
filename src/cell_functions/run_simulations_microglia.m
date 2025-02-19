function [results,femesh_cell,femesh_soma,femesh_neurites]= run_simulations_microglia(mesh,setup_file,tetgen_options,swc_file,soma_file)
%RUN_SIMULATIONS_MICROGLIA computes experiments for a microglia cell.
%   
%   RUN_SIMULATIONS_MICROGLIA(MESH,SETUP_FILE) computes the signal from the
%   setup file for the mesh file only, with tetgen options specified in the
%   setup file.
% 
%   RUN_SIMULATIONS_MICROGLIA(MESH,SETUP_FILE,TETGEN_OPTIONS) computes the signal from the
%   setup file for the mesh file only, with tetgen options specified in the
%   setup file.
% 
%   RUN_SIMULATIONS_MICROGLIA(MESH,SETUP_FILE,TETGEN_OPTIONS,SWC_FILE,SOMA_FILE) computes the signal from the
%   setup file for the soma and process of the microglia cell only, with tetgen options specified in the
%   setup file.
% 
%   mesh : (str) path to mesh
%   setup_file: (str) name of setup file.
%   tetgen_options : (str) (optional) tetgen_options for mesh. Defaults to value from
%                   setup_file.
%   swc_file : (str)(optional) path to swc file.
%   soma_file : (str) (optional) path to soma file.

tic
addpath(genpath('setups'));
addpath(genpath('src'));

% Launch setup here
run(sprintf("%s.m",setup_file));
fprintf("Running %s.m\n",setup_file)


if nargin >=3
    setup.geometry.tetgen_options=string(tetgen_options);
else
    fprintf('Applying default Tetgen parameters %s\n',setup.geometry.tetgen_options);
end

setup.name=string(mesh);
[~,cellname,~] = fileparts(setup.name);

segment_cell = nargin == 5;
if segment_cell
    setup.cell.swc = swc_file; setup.cell.soma = soma_file;
end


[setup, femesh_cell, ~, ~,femesh_soma,femesh_neurites]  = prepare_simulation(setup);

save_magnetization = false; 

if segment_cell
    disp("Running simulations for soma and neurites/processes only");
    include_cell = false;
    if isfield(setup,'mf')
        [mf_cell,mf_soma,mf_neurites,~,~,~] = run_mf_cell(...
            femesh_cell, setup, save_magnetization,femesh_soma,femesh_neurites,include_cell);
        results.mf_cell = mf_cell; results.mf_soma = mf_soma;results.mf_neurites = mf_neurites;
    end
    
    if isfield(setup,'btpde')
       [btpde_cell,btpde_soma,btpde_neurites] = run_btpde_cell(...
           femesh_cell, setup, save_magnetization,femesh_soma,femesh_neurites,include_cell);
        results.btpde_cell = btpde_cell; results.btpde_soma = btpde_soma;results.btpde_neurites = btpde_neurites;
    end
else
    disp("Running simulations for cell only");
    if isfield(setup,'mf')
        [mf_cell,~,~,~,~,~] = run_mf_cell(...
            femesh_cell, setup, save_magnetization);
        results.mf_cell = mf_cell; 
    end
    if isfield(setup,'btpde')
       [btpde_cell,~,~] = run_btpde_cell(...
           femesh_cell, setup, save_magnetization);
        results.btpde_cell = btpde_cell; 
    end
end

results.setup = setup; 
toc