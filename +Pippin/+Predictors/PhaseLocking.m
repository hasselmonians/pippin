function PhaseLocking(self)
    %TODO. See chapter 11

    if ~any(strcmp('PhaseLocking', arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0)))
        keyboard
        self.predictors(end+1).name = 'PhaseLocking';
        % [cos(phi) sin(phi)]
    else
        warning('Is already a field, not appending');
    end
    
end