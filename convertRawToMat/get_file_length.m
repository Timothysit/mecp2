function file_length = get_file_length(fid)
% From: https://stackoverflow.com/questions/849739/how-do-you-get-the-size-of-a-file-in-matlab
% extracts file length in bytes from a file opened by fopen
% fid is file handle returned from fopen

% store current seek
current_seek = ftell(fid);
% move to end
fseek(fid, 0, 1);
% read end position
file_length = ftell(fid);
% move to previous position
fseek(fid, current_seek, -1);

end
