function names=load_varlist(obj,names)
% retrieves the list of all the variables
% entering the object or equation
    if nargin<2
        names={};
    end
    if isa(obj,'planar')
        if isempty(obj.args)
            if ischar(obj.func)
                names=union(names,obj.func);
            end
        else
            for iarg=1:numel(obj.args)
                if isa(obj.args{iarg},'planar')
                    names=load_varlist(obj.args{iarg},names);
                end
            end
        end
    end
end
