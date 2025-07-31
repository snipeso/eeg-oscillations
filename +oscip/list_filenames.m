function Folder = list_filenames(Folder, Extension)
% little function for getting whatever is inside a folder, ignoring the
% stupid dots and turning everything into a string

Folder = deblank(string(ls(Folder)));

if exist("Extension", 'var') && ~isempty(Extension)
    Folder(~contains(Extension)) = [];
else
    Folder(strcmp(Folder, ".")) = [];
    Folder(strcmp(Folder, "..")) = [];

    Folder(~contains(Folder, '.')) = [];
end