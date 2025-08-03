function Function = functions(FunctionType, Mode)

switch FunctionType

    case 'aperiodic'
        switch Mode
            case 'fixed'
                % Fixed mode: offset - log10(freqs^exponent)
                Function = @(params, x) params(1) - log10(x.^params(2));

            case 'knee'
                    % Knee mode: offset - log10(knee + freqs^exponent)
                Function = @(params, x) params(1) - log10(params(2) + x.^params(3));
            otherwise
                error('incorrect function mode')
        end
    case 'periodic'
        % @CLAUDE: implement gaussian function from funcs.py here, and make
        % rest of code compatible
    otherwise
        error("haven't implemented this function type yet")
end
% TODO: fill out as needed