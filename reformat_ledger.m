function reformat_ledger(ledger_txt)

if nargin==0
    temp = which('reformat_ledger.m');
    [a,b] = uigetfile(fullfile(temp,'LedgerDir','*.txt'));
    if a==0
        return;
    else
        ledger_txt = fullfile(b,a);
    end
end

% Browsing Ledger
all_c1 = [];
all_c4 = [];
if exist(ledger_txt,'file')
    fileID = fopen(ledger_txt);
    %header
    fgetl(fileID);
    while ~feof(fileID)
        hline = fgetl(fileID);
        cline = regexp(hline,'\t','split');
        all_c1 = [all_c1;strtrim(cline(1))];
        all_c4 = [all_c4;strtrim(cline(4))];
    end
    fclose(fileID);
    fprintf('Ledger File loaded [%s].\n',ledger_txt);
end

% Build and sort strings
str_group = [];
str_region = [];
for i=1:length(all_c1)
    all_c5 = regexp(char(all_c4(i)),' ','split');
    for j= 1:length(all_c5)
        str_group = [str_group;all_c1(i)];
        str_region = [str_region;all_c5(j)];
    end
end

[str_group,ind_sorted] = sort(str_group);
str_region = str_region(ind_sorted);
[str_region,ind_sorted] = sort(str_region);
str_group = str_group(ind_sorted);


% Re-writing new ledger file
[A,B,C] = fileparts(ledger_txt);
B = strrep(B,'_formatted','');
ledger_txt_out = strcat(fullfile(A,B),'_formatted',C);
fileID_out = fopen(ledger_txt_out,'w');		
fwrite(fileID_out,sprintf('%s \t %s \t %s \t %s','Group_name','Atlas_name','Plates','Region'));
fwrite(fileID_out,newline);
for i=1:length(str_group)
    fwrite(fileID_out,sprintf('%s \t %s \t %s \t %s',char(str_group(i)),'-','-',char(str_region(i))));
    fwrite(fileID_out,newline);
end
fclose(fileID_out);
fprintf('Formatted Ledger succesfully written [%s].\n',ledger_txt_out);

end