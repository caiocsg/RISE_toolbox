function outcell=print_solution(obj,varlist,compact_form,precision,equation_format,file2save2)

if isempty(obj)
    outcell=struct();
    return
end

if nargin<6
    file2save2=[];
    if nargin<5
        equation_format=[];
        if nargin<4
            precision=[];
            if nargin<3
                compact_form=[];
                if nargin<2
                    varlist=[];
                end
            end
        end
    end
end
if isempty(equation_format),equation_format=false;end
if isempty(compact_form),compact_form=false;end
if isempty(varlist)
    varlist=obj(1).endogenous.name(obj(1).endogenous.is_original & ~obj(1).endogenous.is_auxiliary);
end

nobj=numel(obj);
mycell=cell(0,1);
string='';
for kk=1:numel(obj)
    state_names={};
    endo_names=obj(kk).endogenous.name;
    exo_names=obj(kk).exogenous.name;
    % get the location of the variables: can be model specific
    ids=locate_variables(varlist,obj(1).endogenous.name);
    var_names=endo_names(ids);
    if nobj>1
        string=int2str(kk);
    end
    mycell=[mycell;{sprintf('\n%s',['MODEL ',string,' SOLUTION'])}]; %#ok<*AGROW>
    
    if isempty(obj(kk).solution.m_x{1})
        mycell=[mycell;{sprintf('\n%s','MODEL HAS NOT BEEN SOLVED AT LEAST UP TO THE FIRST ORDER')}];
    else
        the_regimes=obj(kk).markov_chains.regimes;
        nregs=obj(kk).markov_chains.regimes_number;
        nchains=obj(kk).markov_chains.chains_number;
        chain_names=obj(kk).markov_chains.chain_names;
        tmp=cell(1,nregs);
        for ireg=1:nregs
            for ichain=1:nchains
                new_item=[chain_names{ichain},' = ',sprintf('%0.0f',the_regimes{ireg+1,ichain+1})];
                if ichain==1
                    tmp{ireg}=new_item;
                else
                    tmp{ireg}=[tmp{ireg},' & ',new_item];
                end
            end
        end
        the_regimes=tmp;
        solver=obj(kk).options.solver;
        if isnumeric(solver)
            solver=int2str(solver);
        end
        mycell=[mycell;{sprintf('%s :: %s','SOLVER',solver)}];
        h=obj(kk).markov_chains.regimes_number;
        if obj(kk).options.solve_expect_order>1
            mycell=[mycell;{sprintf('\n%s','PRINTING RESULTS ONLY FOR EXPECTATION ORDER 1')}];
        end
        for ii=1:h
            
            data=build_printing_array(ii);
            
            B=concatenate(data,precision);
            body_format='';
            % start from the end
            for bb=size(B,2):-1:1
                body_format=['%',int2str(B{2,bb}),'s ',body_format]; 
            end
            nrows=size(B{1,1},1);
            number_of_headers=size(B,2);
            mycell=[mycell;{sprintf('\n%s %4.0f : %s','Regime',ii,the_regimes{ii})}];
            if equation_format
                B0=B{1,1};
                for icols=2:number_of_headers
                    Bi=B{1,icols};
                    tmp=[Bi(1,:),'='];
                    for irows=2:size(Bi,1)
                        tmp=[tmp,Bi(irows,:),B0(irows,:),'+']; 
                    end
                    tmp(isspace(tmp))=[];
                    tmp=strrep(tmp,'+-','-');
                    tmp=strrep(tmp,'-+','-');
                    tmp=strrep(tmp,'steadystate','');
                    tmp=tmp(1:end-1);
                    mycell=[mycell;{sprintf('%s',tmp)}];
                end
            else
                for rr=1:nrows
                    data_ii=cell(1,number_of_headers);
                    for jj=1:number_of_headers
                        data_ii{jj}=B{1,jj}(rr,:);
                    end
                    mycell=[mycell;{sprintf(body_format,data_ii{:})}];
                end
            end
        end
    end
end

if nargout
    outcell=mycell;
else
    if ~isempty(file2save2)
        fid=fopen(file2save2,'w');
    else
        fid=1;
    end
    for irow=1:numel(mycell)
        fprintf(fid,'%s \n',mycell{irow});
    end
    if ~isempty(file2save2)
        fclose(fid);
    end
    
end

    function data=build_printing_array(regime_index)
        bigtime=[
            obj(kk).solution.ss{regime_index}(ids,:)'
            obj(kk).solution.bgp{regime_index}(ids,:)'
            ];
        if regime_index==1
            state_names=[state_names,'steady state','bal. growth']; %#ok<*AGROW>
        end
        if obj(kk).options.solve_order>0
            mx=obj(kk).solution.m_x{regime_index}(ids,:)';
            me=obj(kk).solution.m_e{regime_index}(ids,:,1)';
            msig=obj(kk).solution.m_sig{regime_index}(ids,:)';
            if regime_index==1
                state_names=[state_names,strcat(endo_names,'{-1}'),exo_names,'@sig'];
            end
            mxx=[];
            mxe=[];
            mxsig=[];
            mee=[];
            mesig=[];
            msigsig=[];
            if obj(kk).options.solve_order>1
                mxx=0.5*obj(kk).solution.m_x_x{regime_index}(ids,:)';
                [xx_names,mxx]=mykron(strcat(endo_names,'{-1}'),strcat(endo_names,'{-1}'),mxx,compact_form);
                %-----%-----%
                mxe=obj(kk).solution.m_x_e{regime_index}(ids,:)';
                [xe_names,mxe]=mykron(strcat(endo_names,'{-1}'),exo_names,mxe);
                %-----%-----%
                mxsig=obj(kk).solution.m_x_sig{regime_index}(ids,:)';
                %-----%-----%
                mee=0.5*obj(kk).solution.m_e_e{regime_index}(ids,:)';
                [ee_names,mee]=mykron(exo_names,exo_names,mee,compact_form);
                %-----%-----%
                mesig=obj(kk).solution.m_e_sig{regime_index}(ids,:)';
                %-----%-----%
                msigsig=0.5*obj(kk).solution.m_sig_sig{regime_index}(ids,:)';
                %-----%-----%
                endo_names_sig=mykron(strcat(endo_names,'{-1}'),{'@sig'});
                exo_names_sig=mykron(exo_names,{'@sig'});
                sigsig=mykron({'@sig'},{'@sig'});
                if compact_form
                    mx=mx+mxsig; mxsig=[]; endo_names_sig={};
                    me=me+mesig; mesig=[]; exo_names_sig={};
                    msig=msig+msigsig; msigsig=[];sigsig={};
                end
                state_names=[state_names,...
                    xx_names,...
                    xe_names,...
                    endo_names_sig,...
                    ee_names,...
                    exo_names_sig,...
                    sigsig];
            end
            bigtime=[
                bigtime
                mx
                me
                msig
                mxx
                mxe
                mxsig
                mee
                mesig
                msigsig
                ];
        end
        bigtime=full(bigtime);
        bigtime(abs(bigtime)<1e-9)=0;
        keep_rows=any(bigtime,2);
        bigtime=bigtime(keep_rows,:);
        % now process and print
        these_states=state_names(keep_rows);
        data=[{'Endo Name'},var_names
            these_states(:),num2cell(bigtime)];
        clear these_states bigtime
    end
end

function [C,M1]=mykron(A,B,M0,compact)
if nargin<4
    compact=false;
    if nargin<3
        M0=[];
    end
end
M1=M0;
if ischar(A),A=cellstr(A);end
if ischar(B),B=cellstr(B);end
if compact,M1=zeros(size(M0));end
iter=0;
grand_iter=0;
C=cell(1,numel(A)*numel(B));
for ia=1:numel(A)
    for ib=1:numel(B)
        grand_iter=grand_iter+1;
        if compact && ib<ia
            continue
        end
        iter=iter+1;
        C{iter}=[A{ia},',',B{ib}];
        if compact
            if ib==ia
                M1(iter,:)=M0(grand_iter,:);
            else
                M1(iter,:)=2*M0(grand_iter,:);
            end
        end
    end
end
C=C(1:iter);
if compact
    M1=M1(1:iter,:);
end
end
