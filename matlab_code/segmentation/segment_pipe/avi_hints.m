% if any variable is of structure type then we can use reshape it and save
% in one dimensional matrix like here instead of using for lop. this way we
% can reduce the complexity of program.
%
% vatsa 10.12.2016

input_dir = '/athe/c/maize/analysis_images/segext/segext_1476207286/lesions';
myFolderDirs = dir(input_dir);
% just i wanna test on single 5 number index.
name = myFolderDirs(5);
d1 = reshape(name,1,[]).';
d1.name


% in case i was making folder of leaf name, only with number part. I should
% replace the code with this. because here I am not gonna use for loop.
%
name2 = 'DSC_0094';
aa = reshape(name2,8,[]).';
leaf_number = aa(5:8);