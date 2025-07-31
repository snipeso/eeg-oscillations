function Files = list_filenames(Folder, Extension)
% little function for getting whatever is inside a folder, ignoring the
% stupid dots and turning everything into a string

Files = deblank(string(ls(Folder)));

if exist("Extension", 'var') && ~isempty(Extension)
    Files(~contains(Files, Extension)) = [];
else
    Files(strcmp(Files, ".")) = [];
    Files(strcmp(Files, "..")) = [];

    Files(~contains(Files, '.')) = [];
end