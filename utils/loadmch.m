function [data, headerstruct]=loadmch(fname,format)
%    [data, header]=loadmch(fname,format)
%
%    author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
%    input:
%        fname: the file name to the output .mch file
%        format:a string to indicate the format used to save
%               the .mch file; if omitted, it is set to 'float'
%
%    output:
%        data:  the output MCX detected photon data array
%        hd:    file header info, a structure has the following fields
% [version,medianum,detnum,recordnum,totalphoton,detectedphoton,savedphoton,lengthunit]
%        (note: totalphoton is currently not available)
%
%    this file is part of Monte Carlo eXtreme (MCX)
%    License: GPLv3, see http://mcx.sf.net for details


if(nargin==1)
   format='float';
end

fid=fopen(fname,'rb');

data=[];
header=[];
while(~feof(fid))
	magicheader=fread(fid,4,'char');
	if(strcmp(char(magicheader(:))','MCXH')~=1)
		if(isempty(header))
			fclose(fid);
			error('can not find a MCX history data block');
		end
		break;
	end
	hd=fread(fid,7,'uint');
	if(hd(1)~=1) error('version higher than 1 is not supported'); end
	unitmm=fread(fid,1,'float32');
	junk=fread(fid,7,'uint');
	
	dat=fread(fid,hd(7)*hd(4),format);
	dat=unitmm*reshape(dat,[hd(4),hd(7)])';
	data=[data;dat];
	if(isempty(header))
		header=[hd;unitmm]';
	else
		if(any(header(1:5)~=hd(1:5)'))
			error('loadmch can only load data generated from a single session');
		else
			header(6)=header(6)+hd(6);
			header(7)=header(7)+hd(7);
		end
	end
end

fclose(fid);

if(nargout>=2)
   headerstruct=struct('version',header(1),'medianum',header(2),'detnum',header(3),...
                       'recordnum',header(4),'totalphoton',header(5),...
                       'detectedphoton',header(6),'savedphoton',header(7),'lengthunit',header(8));
end
