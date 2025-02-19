function call_tetgen(filename, options)
%CALL_TETGEN Call Tetgen executable from system with refinement.
%   The tetgen executable is chosen according to the operating system. If an
%   error occurs, you might have to manually change the rights of the Tetgen
%   executable.
%
%   filename: string
%   refinement: [1 x 1]


% Tetgen command for corresponding operating system
if ispc
    tetgen_cmd = "src\tetgen\win64\tetgen";
elseif ismac
    out = system("chmod 775 src/tetgen/mac64/tetgen");
    if out ~= 0
        error_msg = join(["permission denied: src/tetgen/mac64/tetgen,",...
        " please grant 'src/tetgen/mac64/tetgen' executable permission."]);
        error(error_msg)
    end
    tetgen_cmd = "src/tetgen/mac64/tetgen";
elseif isunix
    out = system("chmod 775 src/tetgen/lin64/tetgen");
    if out ~= 0
        error_msg = join(["permission denied: src/tetgen/lin64/tetgen,",...
        " please grant 'src/tetgen/lin64/tetgen' executable permission."]);
        error(error_msg)
    end
    tetgen_cmd = "src/tetgen/lin64/tetgen";
else
    warning("Using Linux Tetgen command.")
    tetgen_cmd = "src/tetgen/tetGen/lin64/tetgen";
end

% Options for Tetgen command
if  nargin == nargin(@call_tetgen) && isnumeric(options) && options > 0
    % Pass refinement to the 'a' flag of Tetgen. This gives a maximum
    % tetrahedron volume (not length, as in earlier versions)
    tetgen_options = "-pqAVCa" + num2str(options);
elseif nargin == nargin(@call_tetgen) && isstring(options)
    tetgen_options = options;
else
    tetgen_options = "-pqAVC";
end

% Call Tetgen
cmd = sprintf("%s %s %s", tetgen_cmd, tetgen_options, filename);
disp(cmd)
system(cmd);
