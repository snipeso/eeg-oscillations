function vertical_text(Text, ShiftX, ShiftY)
arguments
    Text
    ShiftX = .15;
    ShiftY = .5;
end
% used especially for y labels of grid plots like topoplots

X = get(gca, 'XLim');
Y = get(gca, 'YLim');
text(X(1)-diff(X)*ShiftX, Y(1)+diff(Y)*ShiftY, Text, ...
    'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);