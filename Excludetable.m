close all; clear; clc;
Excludechannels = readcell('C:\Users\emre.yavuz\Desktop\DataGLM\Exclude.xlsx');
Excludechannels = Excludechannels(:, 2:end);
save('C:\Users\emre.yavuz\Desktop\DataGLM\Channels2Exclude.mat', 'Excludechannels');