function Files = list_filenames(Folder, Extension)
% little function for getting whatever is inside a folder, ignoring the
% stupid dots and turning everything into a string. Provide '' to extension
% if you want folders
arguments
    Folder
    Extension = '.'
end

% Files = deblank(string(ls(Folder)));
Files = deblank(string(split(ls(Folder))));

if exist("Extension", 'var') && ~strcmp(Extension, '.')
    Files(~contains(Files, Extension)) = [];
elseif isempty(Extension) % folder
 Files(contains(Files, '.')) = [];

else
    Files(strcmp(Files, ".")) = [];
    Files(strcmp(Files, "..")) = [];

    Files(~contains(Files, '.')) = [];
end