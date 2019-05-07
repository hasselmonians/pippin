function [m1] = stepModel(self)

    warning('off','stats:classreg:regr:LinearFormula:TermNotFound');
    warning('off', 'stats:classreg:regr:LinearFormula:NoNewTerms');

    %%
    tbl = table();
    predInd = [];
    for i = 2:length(self.predictors)
        for k = 1:size(self.predictors(i).data,2)
            eval(['tbl.' self.predictors(i).name '_' num2str(k) '= self.predictors(i).data(:,k);'])
            predInd = [predInd i-1];
        end
    end

    tbl.spike = self.SpikeTrain;

    %%
    m0 = fitglm(tbl, 'constant', 'Distribution', 'Poisson');
    m1 = m0;
    pAdd = 0.05;
    pRemove = 0.10;
    
    %%
    outerTrunk = 0;
    while outerTrunk == 0
        trunc=0; nAdd = 0;
        while trunc == 0 
            [m1, trunc] = larger(m1, predInd, pAdd);
            nAdd = nAdd + 1;
        end

        trunc=0; nRem=0;
        while trunc == 0
            [m1, trunc] = smaller(m1, predInd, pRemove);
            nRem = nRem + 1; 
        end
        
        if nRem == 1
            outerTrunk = 1;
        else
            outerTrunk = 0;
        end
        
    end
    
end

function [m1, trunc] = larger(m0, predInd, pAdd)
    for term = 1:max(predInd)
        m = m0;
        inds = find(predInd==term);
        for subTerm = 1:sum(predInd==term)
            v = zeros(1, length(predInd)+1);
            v(inds(subTerm)) = 1;
            m = m.addTerms(v);
        end
        newModel{term} = m;
    end


    [dDev, modelInd] = max(cellfun(@(x) m0.Deviance - x.Deviance, newModel));
    p = gammainc(dDev/2,5/2,'upper');

    if p < pAdd
        disp('adding')
        m1 = newModel{modelInd};
        trunc=0;
    else
        m1 = m0; trunc=1;
    end

end


function [m1, trunc] = smaller(m0, predInd, pRemove)
  
    for term = 1:max(predInd)
        m = m0;
        inds = find(predInd==term);
        for subTerm = 1:sum(predInd==term)
            v = zeros(1, length(predInd)+1);
            v(inds(subTerm)) = 1;
            m = m.removeTerms(v);
        end
        newModel{term} = m;
    end


    [dDev] = (cellfun(@(x) x.Deviance - m0.Deviance, newModel));
    dDev(dDev == 0) = inf;
    
    [dDev, modelInd] = min(dDev);
    
    p = gammainc(dDev/2,5/2,'upper');

    if p > pRemove
        disp('dropping')
        m1 = newModel{modelInd};
        trunc=0;
    else
        m1 = m0; trunc=1;
    end

end

