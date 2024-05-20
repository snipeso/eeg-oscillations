function Colors = get_stage_colors(ScoringIndexes)

Indexes = [-3 -2 -1 0 1]'; % N3, N2, N1, W, R

ColorOptions = ...
    [0.6419    0.4522    0.7243
    0.3824    0.5324    0.7941
    0.4917    0.7202    0.4562
    0.8401    0.3977    0.3364
    0.8586    0.7172    0.3178];

N = numel(ScoringIndexes);
if N <= size(ColorOptions, 1)
   Colors = nan(N, 3);
    for ColorIdx = 1:N
        Colors(ColorIdx, :) = ColorOptions(Indexes==ScoringIndexes(ColorIdx), :);
    end
else
    Colors = rand(N, 3);
end