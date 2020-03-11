%SPAWN Spawn a child process (DOS/WINDOWS)
%  rval = spawn('child process','arg1','arg2',. .'arg9');
% 
%  child process  - any executable  
%  arg1 . . arg9  - arguments passed to the child process
%  rval           - return value from child process
%
%  Description
%  SPAWN a child process (console or windows executable).
%  Use this in preference to the DOS() function if you need 
%  the return value from the child process. DOS() will always 
%  resturn 0 because it executes the child process via COMMAND.COM
%  COMMAND.COM returns 0 if it has finished succesfully regardless 
%  of the child process return value.
%
%  See also
%  DOS, ! (exclamation point) under PUNCT.

%  Copyright (C) W.J.Glenn (2000)
%  bglenn&zip.com.au
