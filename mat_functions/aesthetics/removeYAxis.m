function removeYAxis()
%REMOVEAXIS Remove X and Y axis from plot
   ax1 = gca;                   % gca = get current axis
   ax1.YAxis.Visible = 'off';   % remove y-axis
end

