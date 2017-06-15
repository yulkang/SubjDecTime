clear all;

tt1 = testClass
tt2 = testClass2

%% Identifier
tt1.b = 1
tt2.b = 2

%% Circular reference
tt1.a = tt2
tt2.a = tt1 

%% Saving one, clearing it, modifying the referred object, and loading it.
tt1.a.b
save('testHandleSave.mat', 'tt1');
% tt2.b = 3;

%% Modify classdef to make it incompatible with the saved data
% Defining Static loadobj() after saving, but not setting ConstructOnLoad=true,
% made it constructed on load.
% Setting ConstructOnLoad constructed the contained handles as well, on load.
% Transient property was set to its default value, rather than the value
% set by the constructor on load, when ConstructOnLoad=false.
% Contained object was constructed on load when its own ConstructOnLoad=true,
% even when the container's ConstructOnLoad=false.
load('testHandleSave.mat', 'tt1'); % If I remove 
tt1
tt1.a
% tt2.b

%%
save('testHandleSave2.mat', 'tt1');
load('testHandleSave2.mat', 'tt1');
tt1

%% Circular reference
tt1.a.b
tt1.a.a.b
save('testHandleSave.mat', 'tt1', 'tt2')

%% Loading
clear
load('testHandleSave.mat', 'tt1', 'tt2')
tt1
tt1.a

%%
tt2
tt2.a

%%
tt2.b = 3
tt1.a

%% Load first batch..
clear
load('testHandleSave.mat', 'tt1', 'tt2')
tt2
tt3 = tt2;

%% Modifiy it and then load it again..
tt3.b = 3;
load('testHandleSave.mat', 'tt2')

%% Then tt2 has reference to its original property, rather than to the existing tt1.
tt2
tt1
tt1.a
tt2.a
tt2.a.a

%% Load struct-ized object, 
load('testHandleSave.mat', 'tt1', 'tt2')
tt(1) = tt1;
tt(2) = tt2;
tt(1).a.b = 3;
load('testHandleSave.mat', 'tt2');
tt(1)
tt(2)

%% Then the following two differ from each other! .. Quite confusing..!!
tt2.a.a
tt1.a