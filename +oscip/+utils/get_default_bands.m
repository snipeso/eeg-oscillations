function [DefaultBands, BandLabels] = get_default_bands()

DefaultBands = [4 8;
    8 12; 
    12 16;
    16 25;
    25 35;
    35 60];
BandLabels = {'Theta', 'Alpha', 'Sigma', 'Beta', 'Iota', 'Gamma'}';
