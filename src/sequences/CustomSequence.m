classdef CustomSequence < Sequence
    %CUSTOMSEQUENCE Custom gradient sequence (time profile).
    %   This represents a custom gradient sequence. The sequence is parametrized
    %   by a time profile function, taking delta and Delta as arguments.
    
    properties
        timeprofile
    end
    
    methods
        function obj = CustomSequence(delta, Delta, timeprofile,TE)
            %SEQUENCE Construct an instance of this class
            %   Here it is assumed that the sequence is parametrized by the two
            %   parameters delta and Delta only.
            obj@Sequence(delta, Delta,TE);
            obj.timeprofile = timeprofile;
        end
        
        function f = call(obj, t)
            %CALL Call the custom time profile at time t.
            %   This method calls the timeprofile function passed by the user.
            f = obj.timeprofile(t, obj.delta, obj.Delta);
        end
        
        function t = diffusion_time(obj)
        %DIFFUSION_TIME Get diffusion time of the custom sequence.
            t = obj.Delta - obj.delta / 3;
        end
        
        function [timelist, interval_str, timeprofile_str] = intervals(obj)
            %INTERVALS Get intervals of the custom sequence.
            %   This function returns a list of important time steps (including
            %   start and stop), a list of strings representing the intervals
            %   between these time steps and a list of strings representing the
            %   behavior of the sequence on each of these intervals.
            %   There is only one interval for the custom sequence.
            timelist = [0 obj.TE];
            interval_str = "[0, TE]";
            timeprofile_str = "custom time profile";
        end
        
        function s = string(obj, simplified)
            %STRING Convert custom sequence to string.
            f = functions(obj.timeprofile).function;
            if ~startsWith(f, "@")
                f = "@" + f;
            end
            if nargin == 2 && simplified
                s = sprintf("%s_%s_d%g_D%g", class(obj), f, ...
                    obj.delta, obj.Delta);
            else
                s = sprintf("%s(delta=%g, Delta=%g, %s)", class(obj), ...
                    obj.delta, obj.Delta, f);
            end
        end
    end
end
