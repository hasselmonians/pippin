function [ttgrid, Basis_orth, Basis, B_ctrs] = RaisedCosine(BasisPrs,zflag)
% [ttgrid, Basis_orth, Basis, Bcenters] = makeRaisedCosBasis(BasisPrs,zflag)
%
% Make basis of raised cosines with logarithmically stretched time axis
%
% INPUT:  
% ------
% BasisPrs - struct with fields:
%          .nh - number of basis vectors
%   .endpoints - [t1, tend] absolute temporal position of center of 1st and last cosine basis vector 
%           .b - offset for nonlinear stretching of x axis: y = log(x+b) 
%                (larger b -> more nearly linear stretching)
%          .dt - time bin size of bins representing basis
% 
%    zflag - flag that (if set to 1) sets first basis vector to 1 for all time
%            points prior to the 1st peak (useful basis for refractory effects in GLM)
%
% OUTPUT:
% -------
%     ttgrid [nt x 1]  - time lattice on which basis is defined
% Basis_orth [nt x nh] - orthogonalized basis (each column is a basis vector)
%      Basis [nt x nh] - original cosine basis vectors
%   Bcenters [nh x 1]  - centers of each cosine basis function
%
%  Example call:
%  -------------
% Bprs.nh = 8;  % number of basis vectors
% Bprs.endpoints = [0, 10]; % location of 1st and last cosines
% Bprs.b = 1.5;  % nonlinear stretch factor (larger => more linear)
% Bprs.dt = 0.1; % time bin size
% [tt, Borth, B] = makeRaisedCosBasis(Bprs); 

% Extract params from struct
nh = BasisPrs.nh; % number of basis functions
endpoints = BasisPrs.endpoints; % location of first and last basis func
b = BasisPrs.b; 
dt = BasisPrs.dt;

% Check for zflag
if nargin < 2
    zflag = 0;
end

% Check that b is positive
if b <= 0, error('b must be > 0');
end

% Define nonlinear time axis stretching function and its inverse
nlin = @(x)(log(x+1e-20)); 
invnl = @(x)(exp(x)-1e-20);

% Set time grid and cosine basis centers
yendpoints = nlin(endpoints+b);   % 1t and last endpoints in stretched coordinates
dctr = diff(yendpoints)/(nh-1);   % spacing between raised cosine peaks
ctrs = yendpoints(1):dctr:yendpoints(2);  % centers for cosine basis vectors
maxt = invnl(yendpoints(2)+2*dctr)-b; % maximum time bin (where last basis vector stops)
ttgrid = (0:dt:maxt)'; % time grid 
nt = length(ttgrid);   % number of time points in basis
B_ctrs = invnl(ctrs);  % vector of raised cosine centers

% Function for single raised cosine basis function
ff = @(x,c,dc)((cos(max(-pi,min(pi,(x-c)*pi/dc/2)))+1)/2);

% Make the basis
Basis = ff(repmat(nlin(ttgrid+b), 1, nh), repmat(ctrs, nt, 1), dctr);

% If necessary, set first basis vector to 1 before first peak 
if zflag == 1  
    ii = ttgrid<=endpoints(1);  % indices to set to 1
    Basis(ii,1) = 1; % set first basis vector to constant before peak
end

% Compute orthogonalized basis 
Basis_orth = orth(Basis);  