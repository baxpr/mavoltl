function mavoltl(varargin)

% We know:
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

% Parse inputs and report
P = inputParser;
addOptional(P,'assr_label','Unknown_assessor');
addOptional(P,'seg_niigz','/INPUTS/T1_seg.nii.gz');
addOptional(P,'vol_txt','/INPUTS/T1_label_volumes.txt');
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

assr_label = P.Results.assr_label;
seg_niigz = P.Results.seg_niigz;
vol_txt = P.Results.vol_txt;
out_dir = P.Results.out_dir;

fprintf('assr_label: %s\n',assr_label);
fprintf('seg_niigz: %s\n',seg_niigz);
fprintf('vol_txt: %s\n',vol_txt);
fprintf('out_dir: %s\n',out_dir);

% Copy SEG/TICV file to output location and unzip
copyfile(seg_niigz,fullfile(out_dir,'seg.nii.gz'));
system(['gunzip -f ' fullfile(out_dir,'seg.nii.gz')]);
seg_nii = fullfile(out_dir,'seg.nii');

% Get pixdim with NIfTI_20140122
n_affected = load_nii(seg_nii,[],[],[],[],[],1);
pixdim_affected = n_affected.hdr.dime.pixdim(2:4);
voxvol_affected = prod(pixdim_affected);

% Get pixdim with niftiread
n_true = niftiinfo(seg_nii);
pixdim_true = n_true.PixelDimensions;
voxvol_true = prod(pixdim_true);

% Compute the possible error due to bug in load_nii
vol_pcterror = 100 * (voxvol_affected-voxvol_true) / voxvol_true;

% Load the erroneous vol_txt to get ROI list
rois = readtable(vol_txt,'Delimiter','comma','Format','%s%s%f');

% Fix the format of labels to be machine readable and numeric
rois.label = cellfun( ...
	@str2num, rois.Number, 'UniformOutput',false);

% Fix the region names too
rois.name = cellfun(@(x) strrep(x,' ','_'),rois.Name, ...
	'UniformOutput',false);
rois.name = cellfun(@lower,rois.name,'UniformOutput',false);
rois.name = cellfun(@matlab.lang.makeValidName,rois.name,'UniformOutput',false);

% Load the SEG image
seg = niftiread(seg_nii);

% Compute volumes and write to output file. Compute the error we actually
% observed in the data by estimating it.
results = table(vol_pcterror,nan, ...
	'VariableNames',{'load_nii_possible_pcterror','load_nii_observed_pcterror'});
for r = 1:height(rois)
	voxels = sum( ismember(seg(:),rois.label{r}) );
	results.([rois.name{r} '_mm3']) = voxels * voxvol_true;
end
hip_true = results.right_anterior_hippocampus_mm3;
hip_observed = rois.Volume_mm_3_( ...
	strcmp(rois.name,'right_anterior_hippocampus'));
results.load_nii_observed_pcterror(1) = 100 * (hip_observed-hip_true) / hip_true;
writetable(results,fullfile(out_dir,'stats.csv'));

% Make PDF
pdf_figure = openfig('mavoltl_pdf.fig','new');
figH = guihandles(pdf_figure);
set(figH.assr_info, 'String', assr_label);
set(figH.date,'String',['Report date: ' date]);
set(figH.version,'String',['Matlab version: ' version]);
info = table(results{:,3:end}.', ...
	'RowNames',results.Properties.VariableNames(3:end), ...
	'VariableNames',{'Volume_mm3'});
istr = evalc('disp(info)');
istr = strrep(istr,'<strong>','');
istr = strrep(istr,'</strong>','');
istr = [ ...
	sprintf(['Possible error for this image geometry: %0.4f%%\n' ...
	'Actual error in the analyzed Temporal_Lobe: %0.4f%%\n\n' ...
	'First few corrected volumes:\n\n'],vol_pcterror, ...
	results.load_nii_observed_pcterror) ...
	istr ];
set(figH.results_text, 'String', istr)
print(pdf_figure,'-dpdf',fullfile(out_dir,'mavoltl.pdf'))
close(pdf_figure)

% Exit if we're compiled
if isdeployed
	exit(0)
end

