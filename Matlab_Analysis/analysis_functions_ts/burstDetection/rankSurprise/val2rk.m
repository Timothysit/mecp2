%% Utility - Rank computation
 
function [ranks]=val2rk(values)
%Convert values to ranks, with mean of ranks for tied values. Alternative
%and faster version of "tiedrank" in statistical toolbox of Matlab 6-7.
lp=length(values);
[y,cl]=sort(values);
rk(cl)=(1:lp);
[y,cl2]=sort(-values);
rk2(cl2)=(1:lp);
ranks=(lp+1-rk2+rk)/2;
end 
