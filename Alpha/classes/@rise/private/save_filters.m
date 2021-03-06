function obj=save_filters(obj)

Fields={'filtered_variables','Expected_filtered_variables',...
    'updated_variables','Expected_updated_variables',...
    'smoothed_variables','Expected_smoothed_variables',...
    'smoothed_shocks','Expected_smoothed_shocks',...
    'smoothed_measurement_errors','Expected_smoothed_measurement_errors',...
    'filtered_regime_probabilities','updated_regime_probabilities',...
    'smoothed_regime_probabilities',...
    'filtered_state_probabilities','updated_state_probabilities',...
    'smoothed_state_probabilities'};
rolling=[];
Expected_rolling=[];

nobs=obj.data.nobs;
reg_names=obj.markov_chains.regime_names;

for ifield=1:numel(Fields)
    ff=Fields{ifield};
    if isfield(obj.filtering,ff)
        obj.filtering.(ff)=push_filter_to_time_series(obj.filtering.(ff),ff);
    end
end

nsteps=size(Expected_rolling,2);
obj.filtering.rolling_multistep=struct();
if nsteps>1
    smpl=obj.data.nobs;
    mynames=strcat(num2str((0:nsteps)'),{'-step'});
    mynames=mynames(:)';
    % re-order in terms of dates x nsteps x nvars
    h=obj.markov_chains.regimes_number;
    for ireg=1:h
        rolling{ireg}=permute(rolling{ireg},[3,2,1]); %#ok<AGROW>
    end
    Expected_rolling=permute(Expected_rolling,[3,2,1]);
    nvars=obj.endogenous.number(2);
    vnames=obj.endogenous.name;
    rmse=nan(nvars,nsteps,h);
    expect_rmse=nan(nvars,nsteps);
    for ivar_=1:nvars
        thisUpdate=double(obj.filtering.smoothed_variables.(vnames{ivar_}));
        thisExpectedUpdate=double(obj.filtering.Expected_smoothed_variables.(vnames{ivar_}));
        for ireg=1:h
            rolling_batch=[thisUpdate(:,ireg),rolling{ireg}(2:end,:,ivar_)];
            obj.filtering.rolling_multistep.filtered_variables.(['regime_',sprintf('%0.0f',ireg)]).(vnames{ivar_})=...
                rise_time_series(obj.dates_smoothing,rolling_batch,mynames);
            rmse(ivar_,:,ireg)=hairy_rmse_fksterr(rolling_batch);
        end
        rolling_batch=[thisExpectedUpdate,Expected_rolling(2:end,:,ivar_)];
        obj.filtering.rolling_multistep.Expected_filtered_variables.(vnames{ivar_})=...
            rise_time_series(obj.dates_smoothing,rolling_batch,mynames);
        expect_rmse(ivar_,:)=hairy_rmse_fksterr(rolling_batch);
    end
    obj.filtering.rolling_multistep.rmse=rise_time_series(1,permute(rmse,[2,1,3]),vnames);
    obj.filtering.rolling_multistep.Expected_rmse=rise_time_series(1,permute(expect_rmse,[2,1]),vnames);
end
    function rmse=hairy_rmse_fksterr(batch)
        actual=batch(:,1)';
        fkst=batch(:,2:end); clear batch;
        fkst_errors=nan(size(fkst));
        for t=1:smpl
            hbar=min(nsteps,smpl-t);
            steps=t+(1:hbar);
            fkst_errors(t,1:hbar)=actual(steps)-fkst(t,1:hbar);
        end
        rmse=nan(1,nsteps);
        for istep=1:nsteps
            % discard the nans at the end
            this=fkst_errors(1:end-istep,istep);
            rmse(1,istep)=mean(this.^2);
        end
        rmse=sqrt(rmse);
    end
    function out=push_filter_to_time_series(filtdata,filtname)
        if isempty(filtdata)
            out.filtname=[];
            return
        end
        variables_flag=~isempty(strfind(filtname,'_variables'));
        shocks_flag=~isempty(strfind(filtname,'_shocks'));
        measerrs_flag=~isempty(strfind(filtname,'_measurement_errors'));
        filtered_flag=~isempty(strfind(filtname,'filtered_'));
        regimes_flag=~isempty(strfind(filtname,'_regime_'));
        if filtered_flag
            dateInfo=obj.dates_filtering;
        else
            dateInfo=obj.dates_smoothing;
        end
        reprocess_filters()
        [~,c,p]=size(filtdata);
        if ismember(p,[nobs,nobs+1]) % this is not very robust...
            filtdata=permute(filtdata,[3,1,2]);
        elseif ismember(c,[nobs,nobs+1])
            filtdata=permute(filtdata,[2,1,3]); % time x names x regimes
        end
        
        out=struct();
        if variables_flag
            nvars=obj.endogenous.number(2);
            vnames=obj.endogenous.name;
        elseif shocks_flag
            vnames=obj.exogenous.name;
            nvars=sum(obj.exogenous.number);
            % add the observations on the exogenous observed variables in
            % order to do things in one go. otherwise there will be a crash
            % here...
            net_nexo=nvars-obj.exogenous.number(2);
            nloops=size(filtdata,2)/net_nexo;
            current_reg_nbr=size(filtdata,3);
            tmp=nan(nobs,nvars*nloops,current_reg_nbr);
            % now push in the unobserved shocks and the observed ones (only
            % for the first period)
            % locate the observed shocks
            iobs=ismember(vnames,obj.observables.name(~obj.observables.is_endogenous));
            xxx=obj.data.x;
            if ~isempty(xxx)
                tmp(:,iobs,:)=repmat(transpose(xxx),[1,1,current_reg_nbr]);
            end
            not_iobs=setdiff(1:nvars,find(iobs));
            index=not_iobs;
            for iloop=2:nloops
                index=[index,not_iobs+nvars]; %#ok<AGROW>
            end
            tmp(:,index,:)=filtdata;
            filtdata=tmp;
        elseif measerrs_flag
            vnames=obj.observables.name;
            nvars=obj.observables.number(1);
        else % probabilities
            if regimes_flag
                vnames=reg_names;
            else
                vnames=obj.markov_chains.state_names;
            end
            nvars=numel(vnames);
        end
        others=reg_names;
        for ivar=1:nvars
            datta=squeeze(filtdata(:,ivar:nvars:end,:));
            if size(datta,2)~=numel(others)
                others='';
            end
            if isempty(others)
                out.(vnames{ivar})=rise_time_series(dateInfo,datta);
            else
                out.(vnames{ivar})=rise_time_series(dateInfo,datta,others);
            end
        end
        function reprocess_filters()
            if strcmp(filtname,'Expected_filtered_variables')
                Expected_rolling=filtdata;
                filtdata(:,2:end,:)=[]; 
            elseif strcmp(filtname,'filtered_variables')
                rolling=filtdata;
                for istate=1:numel(filtdata)
                    filtdata{istate}(:,2:end,:)=[]; 
                end
            end
            if iscell(filtdata)
                h=numel(filtdata);
                tmp0=squeeze(filtdata{1});
                tmp_=zeros([size(tmp0),h]); tmp_(:,:,1)=tmp0;
                for istate=2:h
                    tmp_(:,:,istate)=squeeze(filtdata{istate});
                end
                filtdata=tmp_; clear tmp tmp0
            end
        end
    end
end
