function Colors = get_stage_colors(N)

Colors = ...
    [0.6419    0.4522    0.7243 % N3
    0.3824    0.5324    0.7941 % N2
    0.4917    0.7202    0.4562 % N1
    0.8401    0.3977    0.3364 % w 
    0.8586    0.7172    0.3178]; % r




if N == size(Colors, 1)
   return
elseif N == 3
Colors = Colors([2, 4, 5], :);
else
    Colors = rand(N, 3);
end