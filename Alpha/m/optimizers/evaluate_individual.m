function indiv=evaluate_individual(bird,objective,lb,ub,nonlcon,varargin)
if nargin<1
    indiv=struct('x',{},'f',{},'viol',{},'fitness',{},'violstrength',{});
else
    % correct the bounds
    bird(bird<lb)=lb(bird<lb);
    bird(bird>ub)=ub(bird>ub);
    % evaluate
    fval=objective(bird,varargin{:});
    % evaluate the constraints if any
    % I think a persistent variable that recognizes the input could
    % work well but that is not the concern of the optimizer
    if isempty(nonlcon)
        vv=0;
    else
        % nonlcon should have the same inputs as objective
        vv=nonlcon(bird,varargin{:});
    end
    indiv=struct('x',bird,...
        'f',fval,...
        'viol',vv,...
        'fitness',compute_fitness(fval),...
        'violstrength',sqrt(sum(vv.^2)));
end
end
