function removeXAxis()
%REMOVEAXIS Remove X and Y axis from plot
   ax1 = gca;                   % gca = get current axis
   ax1.XAxis.Visible = 'off';   % remove x-axis
end

