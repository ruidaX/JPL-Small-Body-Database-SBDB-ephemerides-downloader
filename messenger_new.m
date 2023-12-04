function [answer_real] = messenger_new(t,ask,answer_expected)
% messenger is like an ask and answer function, t is communication handle,
% ask is the command send to telnet system, expected_answser is the
% expected reply from the system, c is real reply.
if ~isempty(ask)
    writeline(t,ask); % ask horizons the name of the small body
    pause(0.1); % because of the poor internet
end
response=[];
answer_expected = char(answer_expected);
tic
while(isincludein(response,answer_expected)==0) % waiting for the last line
    if t.NumBytesAvailable > 0
        response =[response read(t,t.NumBytesAvailable,"char")];
        tic
    elseif toc>20
        fprintf('**********No expected answer for***********\n');
        fprintf('*******************************************\n ');
        fprintf([answer_expected '\n']);
        fprintf('*******************************************\n ');
        disp("current answer:");
        disp(char(response));
        break;
%         error('check what you ask');
    end
end
answer_real=char(response);


end

