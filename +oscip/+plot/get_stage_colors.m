function Colors = get_stage_colors(N)

Colors = ...
    [0.6419    0.4522    0.7243
    0.3824    0.5324    0.7941
    0.4917    0.7202    0.4562
    0.8401    0.3977    0.3364
    0.8586    0.7172    0.3178];

if N <= size(Colors, 1)
    Colors = Colors(1:N, :);
else
    Colors = rand(N, 3);
end