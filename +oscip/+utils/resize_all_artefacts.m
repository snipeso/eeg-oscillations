function AllArtefacts = resize_all_artefacts(AllArtefacts)


nChannels = min(cellfun(@(x) size(x,1), AllArtefacts(~cellfun('isempty',AllArtefacts))));
nEpochs = min(cellfun(@(x) size(x,2), AllArtefacts(~cellfun('isempty',AllArtefacts))));


for ArtefactIdx = 1:numel(AllArtefacts)
Art = AllArtefacts{ArtefactIdx};
AllArtefacts{ArtefactIdx} = Art(1:nChannels, 1:nEpochs);
end