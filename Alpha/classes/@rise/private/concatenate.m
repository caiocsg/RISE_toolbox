function B=concatenate(data,precision)
if nargin<2
    precision=[];
end
if isempty(precision)
    precision='%8.6f';
else
    if ~ischar(precision)
        error('precision must be of the type %8.6f')
    end
    precision(isspace(precision))=[];
    if ~strncmp(precision(1),'%',1)||...
            ~all(isstrprop(precision([2,4]),'digit'))||...
            ~isstrprop(precision(end),'alpha')
        error('precision must be of the type %8.6f')
    end
end

B=cell(2,0);
[span,nargs]=size(data);

for ii=1:nargs
    A='';
    for jrow=1:span
        add_on=data{jrow,ii};
        if isnumeric(add_on)
            add_on=num2str(add_on,precision);
        end
        A=char(A,add_on);
    end
    A=A(2:end,:);
    B=[B,{A,size(A,2)+2}']; %#ok<AGROW>
end
end
% function B=concatenate(data,precision)
%
% B=cell(2,0);
% nargs=size(data,2);
%
% for ii=1:nargs
%     if ii==1
%         span=numel(data{2,1});
%     end
%     A=data{1,ii};
%     add_on=data{2,ii};
%     if iscellstr(add_on)
%         add_on=char(add_on);
%     end
%     if isempty(add_on)
%         A=char(A,repmat('--',span,1));
%     elseif isnumeric(add_on)
%         for jj=1:span
%             A=char(A,num2str(add_on(jj),precision));
%         end
%     elseif ischar(A)
%         A=char(A,add_on);
%     else
%         error([mfilename,':: unknown type'])
%     end
%     B=[B,{A,size(A,2)+2}']; %#ok<AGROW>
%
% end