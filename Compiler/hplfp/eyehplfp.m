function eyehplfp(varargin)

%startup

    % get channel string
    [p1, chstr] = nptFileParts(pwd);
    % get array string
    [p2, arrstr] = nptFileParts(p1);
    % get session string
    [p3, sesstr] = nptFileParts(p2);
    % get day string
    [p4, daystr] = nptFileParts(p3);

disp(p1)
disp(p2)

if ~isdeployed
   addpath('~/matlab/DPV')
   addpath('~/matlab/newNpt')
   addpath('~/matlab/Hippocampus') 
   addpath('~/matlab/neuroshare')
   addpath('~/hmmsort')
end

% addPathCmd = '/nfs/app1/common/matlab/R2018a/bin/glnxa64';
% addpath(addPathCmd);
%disp(['added path: ',addPathCmd])
%system('ldd /nfs/app1/common/matlab/R2018a/bin/glnxa64/libmwxcp_dwarf.so')
%disp('Finished running ldd')
    
    % to read Args
    load([p2,'/rsData']);

    rh = rplhighpass('auto','SaveLevels',2,varargin{:});
	rl = rpllfp('auto','SaveLevels',2,varargin{:});

	if(~Args.SkipSort)
		display('Launching spike sorting ...')
		% check to see if we should sort this channel
		if(isempty(dir('skipsort.txt')))
	
			% make channel direcory on HPC, copy to HPC, cd to channel directory, and then run hmmsort
			display('Creating channel directory ...')
            if ~Args.UseHPC
                syscmd = ['ssh eleys@atlas7; cd ~/hpctmp/Data/' daystr '/' sesstr '/' arrstr '; mkdir ' chstr];
                display(syscmd)
                system(syscmd);
                display('Transferring rplhighpass file ...')
                syscmd = ['scp rplhighpass.mat eleys@atlas7:~/hpctmp/Data/' daystr '/' sesstr '/' arrstr '/' chstr];
                display(syscmd)
                rval=1;
                while(rval~=0)
                    rval=system(syscmd);
                end
                syscmd = ['cd ~/hpctmp/Data/' daystr '/' sesstr '/' arrstr '/' chstr];
            end
			display('Running spike sorting ...')
			syscmd = '~/hmmsort/hmmsort_pbs.py ~/hmmsort';
			display(syscmd)
			system(syscmd);
		end  % if(isempty(dir('skipsort.txt')))
	end  % if(Args.SkipSort)
