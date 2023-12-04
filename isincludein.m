function res=isincludein(s1,s2)

% isincludein.m : test if a string is included in the end of another string
%
% PROTOTYPE :
%   res=isincludein(s1,s2)
%
% DESCRIPTION
%   Test if the string s2 is included in the end of the string s1
% 
% INPUT
%   s1,s2: two strings
%
% OUTPUT
%   res: a boolean, true if s2 is included in the end of s1, false if it is
%   not

if length(s2)>length(s1) % if s2 is bigger than s1, s2 cannot be included in s1
    res=false;
else
    
    s11=s1((length(s1)-length(s2)+1):length(s1)); % taking the string at the end of s1 with the same length than s2
    if s11==s2 % if the two strings are equal, the result is true
        res=true;
    else
        res=false;
    end
end
end