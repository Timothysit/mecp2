function lineThickness(thickness) 
set(findall(gca, 'Type', 'Line'),'LineWidth',thickness);
end