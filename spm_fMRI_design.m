function [SPM] = spm_fMRI_design(SPM,save_SPM)
% Assembles a design for fMRI studies
% FORMAT [SPM] = spm_fMRI_design(SPM)
%
% 1st level
%--------------------------------------------------------------------------
% SPM.
%       xY: [1x1 struct] - data structure
%    nscan: [1xs double] - nscan(s) = number of scans in session s
%      xBF: [1x1 struct] - Basis function structure
%     Sess: [1xs struct] - Session structure array
%       xX: [1x1 struct] - Design matrix structure
%
%
%    2nd level
%    ----------------------------------------------------------------------
%    SPM.xY
%           RT: - repetition time {seconds)
%
%    SPM.xBF
%            T: - microtime resolution (number of time bins per scan)
%           T0: - microtime onset (reference time bin, see slice timing)
%        UNITS: - 'scans'|'secs' - units in which onsets are specified
%     Volterra: - 1|2 - order of [Volterra] convolution
%           dt: - length of time bin {seconds}
%         name: - name of basis set
%       length: - support of basis set {seconds}
%        order: - order of basis set
%           bf: - basis set matrix
%
%    SPM.Sess(s)
%            U: - Input structure array
%            C: - User specified covariate structure
%          row: - scan   indices for session s
%          col: - effect indices for session s
%           Fc: - F Contrast information for input-specific effects
%
%    SPM.xX
%            X: - design matrix
%           iH: - vector of H partition (indicator variables) indices
%           iC: - vector of C partition (covariates)          indices
%           iB: - vector of B partition (block effects)       indices
%           iG: - vector of G partition (nuisance variables)  indices
%         name: - cellstr of names for design matrix columns
%
%
%        3rd level
%        ------------------------------------------------------------------
%        SPM.Sess(s).U
%               dt: - time bin length {seconds}
%             name: - {1 x j} cell of names for each input or cause
%              ons: - (q x 1) onsets for q  trials {in UNITS}
%              dur: - (q x 1) durations for trials {in UNITS}
%                P: - Parameter stucture
%                u: - (t x j) inputs or stimulus function matrix
%              pst: - (1 x k) peristimulus times (seconds)
%             orth: - boolean: orthogonalise inputs?
%
%
%        SPM.Sess(s).C
%
%                C: - [kx1 double] of user specified regressors
%             name: - {1xk} cellstr of regressor names
%
%
%        SPM.Sess(s).Fc
%
%                i: - indices pertaining to each input
%             name: - names pertaining to each input
%                p: - grouping of regressors per parameter
%
%
%            4th level
%            --------------------------------------------------------------
%            SPM.Sess(s).U(i).P(p)
%
%                 name: - parameter name
%                    P: - (q x 1) parameter matrix
%                    h: - order of polynomial expansion (0 = none)
%                    i: - sub-indices of U(i).u for plotting
%
%
% saves SPM.mat if save_SPM==1 (this is the default)
%__________________________________________________________________________
%
% spm_fMRI_design allows you to build design matrices with separable
% session-specific partitions.  Each partition may be the same (in which
% case it is only necessary to specify it once) or different.  Responses
% can be either event- or epoch related, where the latter model prolonged
% and possibly time-varying responses to state-related changes in
% experimental conditions.  Event-related response are modelled in terms
% of responses to instantaneous events.  Mathematically they are both
% modelled by convolving a series of delta (stick) or box-car functions,
% encoding the input or stimulus function. with a set of hemodynamic
% basis functions.
%
% spm_fMRI_design allows you to combine both event- and epoch-related
% responses in the same model and/or regressor. You specify the number
% of trial (event or epoch) types.  Epoch and event-related
% responses are modeled in exactly the same way by first specifying their
% onsets [in terms of onset times] and then their durations.  Events are
% specified with a duration of 0.  If you enter a single number for the
% durations it will be assumed that all trials conform to this duration.
%
% Interactions or response modulations can enter at two levels.  Firstly
% the stick function itself can be modulated by some parametric variate
% (this can be time or some trial-specific variate like reaction time)
% modeling the interaction between the trial and the variate or, secondly
% interactions among the trials themselves can be modeled using a Volterra
% series formulation that accommodates interactions over time (and therefore
% within and between trial types).  The first sort of interaction is
% specified by extra (modulated) stick functions in Sess(s).u.  If
% a polynomial expansion of the specified variate is requested there will
% be more than one column.  The corresponding name of the explanatory
% variables in X.name is Sn(s) trial(u)xparam(p)^q*bf(i) for the qth
% order expansion of the parameter convolved with the ith basis function
% for the uth trial in the sth session.  If no parametric variate is
% specified the name is simply Sn(s) trial(u)*bf(i).  Interactions among
% and within trials enter as new trial types but do not have .pst or .ons
% fields.  These interactions can be characterized later, in results, in
% terms of the corresponding second order Volterra Kernels.
%
% The design matrix is assembled on a much finer time scale (xBF.dt) than the
% TR and is then sub-sampled at the acquisition times.  After down-sampling
% the regressors for each input are othogonalised.  This ensures that
% components due to the canonical hrf are not explained away by other basis
% functions or parametric modulators.
%
% Sess(s).ons(u) contains onset times in seconds or scans relative to the
% timing of the first scan
%
% Notes on spm_get_ons, spm_get_bf and spm_Volterra are included below
% for convenience.
%
%                           ----------------
%
% spm_get_ons contructs a struct array containing sparse input
% functions U(i).u specifying occurrence events or epochs (or both).
% These are convolved with a basis set at a later stage to give
% regressors that enter into the design matrix. Interactions of evoked
% responses with some parameter (time or a specified  variate P) enter at
% this stage as additional columns in U(u).u with each trial multiplied
% by the [expansion of the] trial-specific parameter. If parametric
% modulation is modeled, P(p).P contains the original variate and
% P(p).name is its name. The 0th order expansion of this is simply the main
% effect in the first column of U(u).u
%
%                           ----------------
%
% spm_get_bf prompts for basis functions to model hemodynamic
% responses.  The basis functions returned are orthogonalized
% and defined as a function of peri-stimulus time in time-bins.
%
%                           ----------------
%
% For first order expansions spm_Volterra simply convolves the causes
% (e.g. stick functions) in U(u).u by the basis functions in Sess(s).bf
% to create design matrix X.  For second order expansions new entries appear
% in the design matrix that correspond to the hemodynamic interaction among the
% orginal causes (if the events are sufficiently close in time).
% The basis functions for these are two dimensional and are used to
% assemble the second order kernel in spm_graph.m.  Second order effects
% are computed for only the first column of U(u).u.
%
%__________________________________________________________________________
% Copyright (C) 1999-2012 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_fMRI_design.m 5183 2013-01-10 15:30:20Z ged $


SVNid = '$Rev: 5183 $';

%-Say Hello
%--------------------------------------------------------------------------
spm('FnBanner',mfilename,SVNid);


%-Construct Design matrix {X}
%==========================================================================

%-Microtime onset and microtime resolution
%--------------------------------------------------------------------------
try
    fMRI_T     = SPM.xBF.T;
    fMRI_T0    = SPM.xBF.T0;
catch
    fMRI_T     = spm_get_defaults('stats.fmri.t');
    fMRI_T0    = spm_get_defaults('stats.fmri.t0');
    SPM.xBF.T  = fMRI_T;
    SPM.xBF.T0 = fMRI_T0;
end

%-Time units, dt = time bin {secs}
%--------------------------------------------------------------------------
SPM.xBF.dt     = SPM.xY.RT/SPM.xBF.T;

%-Get basis functions
%--------------------------------------------------------------------------
SPM.xBF        = spm_get_bf(SPM.xBF);
assignin('base','bf',SPM.xBF.bf);
assignin('base','volterra',SPM.xBF.Volterra);

%-Get session specific design parameters
%==========================================================================
Xx    = [];
Xb    = [];
Xname = {};
Bname = {};
for s = 1:length(SPM.nscan)
    
    %-Number of scans for this session
    %----------------------------------------------------------------------
    k = SPM.nscan(s);
    
    
    %-Create convolved stimulus functions or inputs
    %======================================================================
    
    %-Get inputs, neuronal causes or stimulus functions U
    %----------------------------------------------------------------------
    U = spm_get_ons(SPM,s);
    assignin('base','USPM',U); 


    %-Convolve stimulus functions with basis functions
    %----------------------------------------------------------------------
    [X,Xn,Fc] = spm_Volterra(U, SPM.xBF.bf, SPM.xBF.Volterra);
    
    %-Resample regressors at acquisition times (32 bin offset)
    %----------------------------------------------------------------------
    if ~isempty(X)
        X = X((0:(k - 1))*fMRI_T + fMRI_T0 + 32,:);
    end

    %-Orthogonalise (within trial type)
    %----------------------------------------------------------------------
    for i = 1:length(Fc)
        if i<= numel(U) && ... % for Volterra kernels
                (~isfield(U(i),'orth') || U(i).orth)
            p = ones(size(Fc(i).i));
        else
            p = Fc(i).p;
        end
        for j = 1:max(p)
            X(:,Fc(i).i(p==j)) = spm_orth(X(:,Fc(i).i(p==j)));
        end
    end
    
    % get user specified regressors
    %=======================================================
    units = SPM.xBF.UNITS;  % Units of time (typically 'secs')
    T = SPM.xBF.T;          % Number of time points in HRF
    T0 = SPM.xBF.T0;        % Reference time point (typically middle of HRF)
    dt = SPM.xBF.dt;        % Time resolution (sampling interval) of HRF
    Volterra = SPM.xBF.Volterra; % Indicator for Volterra expansion (typically 1)
    name = SPM.xBF.name;    % Name of the basis function (typically 'hrf')
    length_hrf = SPM.xBF.length; % Length of the HRF in seconds
    order = SPM.xBF.order;  % Order of basis functions (typically 1)
    bf = SPM.xBF.bf;        % The basis functions themselves (array of values)

    try 
          C     = SPM.Sess(s).C.C;
          Cname = SPM.Sess(s).C.name;
    catch
    
        % covariates - C
        %-----------------------------------------------        
          str   = sprintf('Session %d',s);
          spm_input('Other regressors',1,'d',str)
          C     = [];
          c     = spm_input('user specified','+1','w1',0);
          while size(C,2) < c
                   str = sprintf('regressor %i',size(C,2) + 1);
                   C  = [C spm_input(str,2,'e',[],[k Inf])];
          end
 
          % and their names - Cnames
          %-----------------------------------------------
          Cname = {};
          for i = 1:size(C,2)
             str      = sprintf('regressor %i',i);
          Cname{i} = spm_input('name of','+0','s',str);
        end
      end

    % convolve regressors and then append mean-corrected regressors (remove linear and non-linear trends) and names
    %-------------------------------------------------------
    assignin('base', 'C', C);
    detrended_C = spm_detrend(C);
    if size(detrended_C, 1) > size(X, 1)
       rows_to_remove = size(detrended_C, 1) - size(X, 1);
       detrended_C(end-rows_to_remove+1:end, :) = [];
    end
    X      = [X detrended_C];
    Xn     = {Xn{:}   Cname{:}};
    
    %-Confounds: Session effects
    %======================================================================
    B     = ones(k,1);
    Bn    = {'constant'};
   

    %-Session structure array
    %======================================================================
    assignin('base','UCHECK',U);

    for i = 1:numel(U)
        SPM.Sess(s).U(i).P = U(i).P;
    end

    SPM.Sess(s).U      = U;
    SPM.Sess(s).row    = size(Xx,1) + (1:k);
    SPM.Sess(s).col    = size(Xx,2) + (1:size(X,2));
    SPM.Sess(s).Fc     = Fc;
    
    %-Append into Xx and Xb
    %======================================================================
    assignin('base','X',X);
    assignin('base','B',B);
    Xx      = blkdiag(Xx,X);
    Xb      = blkdiag(Xb,B);
    
    %-Append names
    %----------------------------------------------------------------------
    for i = 1:length(Xn)
        Xname{end + 1} = [sprintf('Sn(%i) ',s) Xn{i}];
    end
    for i = 1:length(Bn)
        Bname{end + 1} = [sprintf('Sn(%i) ',s) Bn{i}];
    end
    
end


%-Place design matrix structure in xX
%==========================================================================
SPM.xX.X    = [Xx Xb];
SPM.xX.iH   = [];
SPM.xX.iC   = 1:size(Xx,2);
SPM.xX.iB   = (1:size(Xb,2)) + size(Xx,2);
SPM.xX.iG   = [];
SPM.xX.name = {Xname{:} Bname{:}};

if nargin < 2 || save_SPM
    %-Save SPM.mat
    %----------------------------------------------------------------------
    fprintf('%-40s: ','Saving fMRI design')                             %-#
    save('SPM.mat', 'SPM', spm_get_defaults('mat.format'));
    fprintf('%30s\n','...SPM.mat saved');
end
