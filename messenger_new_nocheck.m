function [answer_real] = messenger_new_nocheck(t,ask,answer_expected)
% This function is to receive all the data from tcpip server.
% There is no check to the specified ending character of the received data.
% This function is only use time as the control.
% First, it'll pause for  1 second before reading any data, this will
% increase the stability
% Then, if Matlab dont receiev any new data in the next coming 2 seconds,
% it will end reading.

    if t.NumBytesAvailable > 0
        disp(read(t,t.NumBytesAvailable,"char"));
    end

if ~isempty(ask)
    ask = string(ask);
    writeline(t,ask); % ask horizons the name of the small body
end
response=[];
% answer_expected = char(answer_expected);
pause(1)
tic
while(1) % waiting for the last line
    if t.NumBytesAvailable > 0
        response =[response read(t,t.NumBytesAvailable,"char")];
        tic
elseif toc>1
        break
    end
end

answer_real=char(response);


end

