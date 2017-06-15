function log_data = test
% test  Testing the logging package.
%
% See also logging.name, logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

log_data = struct;

%% What this does
disp(' ');
disp('===== What this test does =====');
disp('This test program will generate a random 5-vector,');
disp('plot it, and save the vector (.mat), plot (.eps),');
disp('and command window outputs (.txt).');
disp(' ');
disp('It also saves .json text files that contain useful meta-data');
disp('like the Git hash, the unique identifier to the code''s version.');
disp(' ');
disp('It will save them in a location determined by this program''s');
disp('location, depending on the scheme you choose below.');
disp(' ');
disp('In real use, the data''s location is determined by the ');
disp('location of the ''root'' or ''base_caller'' program that calls logging.name.');
disp('That is, if test1.m calls test2.m, and test2.m calls logging.name,');
disp('the data''s location will be determined by the location of test1.m.');

%% Choose scheme
disp(' ');
disp('===== Choose scheme =====');
disp('Choose a scheme between ''parallel'' and ''subdir''.');
disp(' ');
disp('''parallel'' is the default for logging.name and recommended');
disp('    because it separates code repository, which is small,');
disp('    from data, which can be huge.');
disp(' ');
disp('    For parallel scheme, your code''s Git repository should be ');
disp('        */CodeNData/Code');
disp('    where * is any path. Then, when your code is');
disp('        */CodeNData/Code/proj_1/code.m, ');
disp('    your data will be saved in');
disp('        */CodeNData/Data/proj_1/code/subdir/code_kind_datestr_comment.ext');
disp('    You can change ''/CodeNData/Code'' and ''/CodeNData/Data'' to something else');
disp('    by giving logging.name options ''code_base'' and ''data_base''.');
disp(' ');
disp('''subdir'', another popular scheme, can be chosen, too.');
disp('    Note that unless you add ''Data'' to your .gitignore,');
disp('    Git will detect changes every time data is added.');
disp(' ');
disp('    The scheme puts ''Data'' folder under the same folder as the');
disp('    code''s folder. In the above example, subdir scheme will put the data in');
disp('        */CodeNData/Code/proj_1/Data/subdir/code_kind_datestr_comment.ext');
disp('    You can change ''Data'' to something else');
disp('    by giving logging.name option ''data_subdir''.');
disp(' ');
disp('Prepare yourself by moving repo to appropriate location (parallel)');
disp('or by adding ''Data'' to your .gitignore in your repo''s root folder.');
disp(' ');;
disp('If you have not finished preparation, choose (q)uit.');
disp(' ');
scheme = input_def('Which scheme to use? (p)arallel, (s)ubdir, (q)uit.', ...
    'choices', {'p', 's', 'q'});
disp(' ');

switch scheme
    case 'p'
        scheme = 'parallel';
    case 's'
        scheme = 'subdir';
    case 'q'
        return;
end

%% Check if the folder is under version control by git.
if ~logging.is_versioned
    error('Make sure to put +logging/ folder within a Git repository!');
end

%% Check if there is any change to commit.
% This and the previous steps are for illustrative purposes,
% and can be ommitted in real use.
disp('===== Checking uncommitted changes =====');
disp('logging.name automatically detects changes and asks if to commit.');
disp('If you choose to commit, it will also ask for a commit message.');
disp('Then it will add & commit all uncommitted changes.');
disp(' ');
if logging.get_status % if any uncommitted change is detected,
    disp('Uncommitted changes detected!');
    disp('Do you want to let logging.name commit for you? It will ask for the commit message.');
    disp('Alternatively, you can choose to stop and commit for yourself.');
    disp(' ');
    if ~inputYN_def('Type ENTER or ''y'' to let logging.name commit, and ''n'' to stop. (Y/n) ', true);
        disp(' ');
        disp('You chose to stop and add/commit changes for yourself!');
        disp('Run logging.test again after you do so.');
        return;
    end
else
    disp('No uncommitted changes detected!');
    disp(' ');
end

%% Subject & category (= kind)
subj = 'subj';
kind = 'rand';

%% Generate simple data
disp(' ');
disp('===== Data generation =====');
disp('Generating a random 5-vector: ');
r = rand(1, 5);
disp(r);

%% Plot simple graph
disp('Plotting the vector.');
plot(r);
figure(gcf);
commandwindow;

%% Determine if to save.
% In real use, you may want to start keeping diary before any 
% important outputs are generated.
disp(' ');
disp('===== Saving =====');
if inputYN_def('Save diary, data and figure (Y/n)?  ', true)
    % Get comment. 
    % If 'comment' argument is ommitted, logging.name will ask for it by default,
    % but entering comment becomes cumbersome if you want to use the same comment
    % for many files (data, figure, ..). In such case, it's better 
    % to ask for the comment once and give it as an argument.
    disp(' ');
    disp('I will ask you for a comment to add to the file name.');
    disp('Note that this comment is different from the commit message,');
    disp('which I will ask you separately if you commit via logging.name.');
    disp(' ');
    comment = input('Comment (added to the new file''s name): ', 's');
    disp(' ');
    
    disp('Note that, if your repository has changes,');
    disp('logging.name will ask for a separate commit message.');
    disp(' ');

    disp('Saving diary. Logging happens on call to logging.name.');
    disp('In real use, put diary() before you print important contents.');
    diary_file = logging.name([subj '/diary'], kind, '.txt', comment, {}, 'scheme', scheme);
    diary(diary_file);
    disp(' ');
    
    disp('Saving the data.');
    dat_file = logging.name([subj '/mat'], kind, '.mat', comment, {}, 'scheme', scheme);
    save(dat_file, 'r');
    disp(' ');

    disp('Saving the plot.');
    [fig_file, log_data] = ...
        logging.name([subj '/fig'], kind, '.eps', comment, {dat_file}, 'scheme', scheme);
    print(gcf, fig_file, '-depsc2');
    disp(' ');
    
    disp('===== Look at the .json text file =====');
    disp('Try opening the .json file by clicking the penultimate link.');
    disp('- "base_caller" is what code you should call to generate the figure.');
    disp('- "data_files" is what data files you need.');
    disp('- "hash" uniquely identifies which version of the code you used.');
    disp(' ');
    disp('Check that the contents of the .json file agrees with the following,');
    disp('which is the second output from logging.name:');
    disp(log_data);
    disp(' ');
    disp('===== Open the data file''s folder =====');
    disp('Try opening the data file''s folder by clicking the last link.');
    disp(' ');
    disp('=====');
    disp('This concludes the tutorial. See help logging.name for details. Enjoy!');
    disp('=====');
    disp(' ');
    
    % Close & save diary
    diary off;
end
end