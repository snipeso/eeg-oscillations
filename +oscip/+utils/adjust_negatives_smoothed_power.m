function Power = adjust_negatives_smoothed_power(Power)


P = Power(:);
if any(P<=0)
Power(Power<=0) = min(P(P>0), 'all');
end

