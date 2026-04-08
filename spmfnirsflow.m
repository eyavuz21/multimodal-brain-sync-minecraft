function spmfnirsflow(nirsfile,onsfile,Folder,ctype,regrfile,DownSam,NewFs,ChExcl,ptppath)

load(nirsfile);
load(onsfile);
regrfile

if isempty(regrfile)
    sys=0; % No additional regressors
else load(regrfile)
    sys=1; % Additional regressors : yes
    assignin('base','sys',sys);
    %if strcmp(ctype,'HBO')
       %Regressors(:,2)=[];
    %else
       %Regressors(:,1)=[];
    %end      
end

%% spm_fnirs_temporalpreproc
% Data are already pre-processed, so these steps are skipped.
% Only pre-coloring is applied (smoothing with HRF)

K=[];

% identify channels of interest
% if isfield(P.fname, 'pos')
%     load([P.fname.pos]);
%     mask = zeros(1, R.ch.nch);
%     indx = find(R.ch.mask == 1);
%     if R.ch.label(1,1)>22
%         R.ch.label=R.ch.label-22;
%         save([P.fname.pos],'R')
%     end
%     mask(R.ch.label(indx)) = 1; clear R;
% else
%    P.mask = ones(1, P.nch);
% end

P.mask = ones(1, P.nch);
P.mask(ChExcl) = -1; % -1 Exclude noisy channels from the analysis 
ch_roi = find(P.mask ~= -1);

disp('Temporal Preprocessing')

% MARA? NO
K.M.type = 'no';

% 'Physiological noise removal? NO
K.C.type = 'no';

% 'Change sampling rate?' NO
if DownSam==0
    K.D.type = 'no';
    fs = P.fs;
else K.D.type = 'yes';
    K.D.nfs = NewFs;
    fs = NewFs;
end

% 'Detrending? ';
K.H.type = 'DCT';
K.H.cutoff = 256;

%'Temporal smoothing? ' HRF
K.L.type = 'HRF';

fprintf('Apply a temporal filter to hemoglobin changes... \n');

P.K = K; % update structure P

% change structure array to matrix
y = spm_vec(rmfield(Y, 'od'));
y = reshape(y, [size(Y.hbo,1) P.nch 3]);

[fy, P] = spm_fnirs_preproc(y, P);
[fy] = spm_fnirs_filter(fy, P, fs);

fprintf('Temporal - Completed. \n\n');

%--------------------------------------------------------------------------
% save the results (parameters)
fprintf('Update header of NIRS.mat file...\n');
save(P.fname.nirs, 'P', '-append', spm_get_defaults('mat.format'));
fprintf('Completed. \n\n');

%% Specify 1st Level
disp('Specify 1st Level')

SPM = [];
fprintf('--------------------------------------------------------- \n');
fprintf('Specify GLM-fNIRS for the 1st level analysis...\n');
fprintf('--------------------------------------------------------- \n');

if strcmp(ctype,'HBO')
    str_nirs='HbO';
else str_nirs='HbR';
end

% Folders=regexp(P.fname.nirs,filesep,'split');
% % Folder=[Folders{end-1} filesep Folder];
% Folder=[Folder];

SPM.xBF.UNITS = 'secs';

for i = 1:size(names, 2)
    U(i).name = names(1,i);
    U(i).ons = onsets{1,i}(:);
    U(i).dur = durations{1,i}(:);
    U(i).P.name=Params(i).Pname; 
    U(i).P.h=Params(i).h;
    U(i).P.P=Params(i).P;
end

SPM.Sess.U = U;

% in case of resampling
switch P.K.D.type
    case 'yes'
        fs = P.K.D.nfs;
        ns = P.K.D.ns;
    case 'no'
        fs = P.fs;
        ns = P.ns;
end

SPM.xY.RT = 1/fs;
SPM.nscan = ns;

try
    SPM.xBF.T  = spm_get_defaults('stats.fmri.t');
catch
    SPM.xBF.T  = 16;
end

try
    SPM.xBF.T0 = spm_get_defaults('stats.fmri.t0');
catch
    SPM.xBF.T0 = 8;
end

SPM.xBF.dt = SPM.xY.RT/SPM.xBF.T;
SPM.xBF.Volterra = 1; % 1st Volterra expansion
SPM.Sess.U = spm_get_ons(SPM,1);

fprintf('1st Level - Completed. \n\n');

%--------------------------------------------------------------------------
% Additional regressors - C %%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Specify other regressors...\n');

if sys==1 %Additional regressors. Change here
    Regressors = table2array(Regressors); 
    C= [];
    SPM.Sess.C.name = Regressor_names;
    num_regressors = size(Regressors, 1);
    if num_regressors < SPM.nscan
        num_rows_to_add = SPM.nscan - num_regressors;
        Regressors = [Regressors; zeros(num_rows_to_add, size(Regressors, 2))];
        disp(['Added ', num2str(num_rows_to_add), ' rows of zeros to Regressors.']);
    end
    SPM.Sess.C.C = Regressors;
    disp('adding regressors')
    assignin('base','SPMSess',SPM.Sess);
    assignin('base','Regressors',Regressors);
else
    C= [];
    Cname = cell(1,size(C,2));
    SPM.Sess.C.C = C;
    SPM.Sess.C.name = Cname;
end

fprintf('Completed. \n\n');

disp('Estimate')

%--------------------------------------------------------------------------
%-Intrinsic autocorrelations (Vi) for non-sphericity ReML estimation

cVi   ='none';
% create Vi structure
switch cVi
    case 'none'
        SPM.xVi.V  = speye(sum(ns));
        cVi = 'i.i.d';
    case 'AR(1)'  % assume AR(0.2) in xVi.Vi
        SPM.xVi.Vi = spm_Ce(ns,0.2);
        cVi = 'AR(0.2)';
end

SPM.xVi.form = cVi;

%--------------------------------------------------------------------------
%  generate design matrix using specified parameters
SPM.xY.VY = P.fname.nirs; % file name of Y

SPM0 = SPM;
save_SPM = 0;
for i = 1:size(str_nirs, 1)
    fprintf('Generate design matrix for %s...\n', str_nirs);
    
    [SPM] = spm_fMRI_design(SPM0, save_SPM);
    SPM.xY.type = str_nirs; % hemoglobin type (eg, HbO or HbR)
    SPM.xBF.name= 'hrf'; % Basis functions
    
    if strcmpi(str_nirs, 'HbR')
        if strcmpi(SPM.xBF.name, 'hrf') || strcmpi(SPM.xBF.name, 'hrf (with time derivative)') || strcmpi(SPM.xBF.name, 'hrf (with time and dispersion derivatives)')
            SPM.xX.X(:,1:end-1) = SPM.xX.X(:,1:end-1).*(-1);
        end
    end
    
    fprintf('Completed. \n\n');
    assignin('base','matrix',SPM.xX.X);
    
    %-Design description - for saving and display
    %--------------------------------------------------------------------------
    ntr = length(SPM.Sess.U);
    Bstr = sprintf('[%s] %s', str_nirs, SPM.xBF.name);
    Hstr = sprintf('Cutoff: %d {s}',P.K.H.cutoff);
    Lstr = P.K.L.type;
    if strcmpi(Lstr, 'Gaussian'), Lstr = sprintf('%s, FWHM %d', Lstr, P.K.L.fwhm); end
    
    SPM.xsDes = struct(...
        'Basis_functions',      Bstr,...
        'Number_of_sessions',   sprintf('%d',1),...
        'Trials_per_session',   sprintf('%-3d',ntr),...
        'Interscan_interval',   sprintf('%0.2f {s}',SPM.xY.RT),...
        'High_pass_Filter',     Hstr,...
        'Low_pass_Filter', Lstr);
    
    spm_DesRep('DesMtx',SPM.xX,[],SPM.xsDes);
    
    Folders=regexp(P.fname.nirs,filesep,'split');
    swd = fullfile(P.fname.nirs(1:end-length(Folders{end})),Folder, str_nirs);
    if ~isdir(swd), mkdir(swd), end
    
    SPM.swd = swd;
    
    fprintf('Save SPM.mat... \n');
    save(fullfile(SPM.swd, 'SPM.mat'), 'SPM', spm_get_defaults('mat.format'));
    fprintf('Saving Completed. \n\n');
    name_spm=fullfile(SPM.swd, 'SPM.mat');
    %--------------------------------------------------------------------------
    % Delete files related to previous SPM.mat file (if exist)
    fname = spm_select('FPList', SPM.swd, '^con_.*\.mat$');
    if ~isempty(fname),
        for i = 1:size(fname, 1), delete(deblank(fname(i,:))); end
    end
    
    fname = spm_select('FPList', SPM.swd, '^spmT_.*\.mat$');
    if ~isempty(fname),
        for i = 1:size(fname, 1), delete(deblank(fname(i,:))); end
    end
    
    fname = spm_select('FPList', SPM.swd, '^spmF_.*\.mat$');
    if ~isempty(fname),
        for i = 1:size(fname, 1), delete(deblank(fname(i,:))); end
    end
end

frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
assignin('base','Folder',Folder);
assignin('base','framecdata',frame.cdata);

imwrite(frame.cdata, [fullfile(ptppath,'Results',Folder) filesep 'DesignMatrix_' ctype '.png'],'png'); % changed by AD from end-8 to end-14 % juedui lujing!!!!

%% Estimate
clear SPM
SPM=name_spm;

for i = 1:size(SPM, 1)
    spm_fnirs_spm(deblank(SPM(i,:)));
end
fprintf('Estimation Completed. \n\n');
end