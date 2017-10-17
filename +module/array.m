classdef array < handle
	properties
		data		% cell array
	end
	
	properties(SetAccess = private, Dependent)
		length
		vector		% converts to array and reshapes
		stream		% converts to array (no reshaping)
	end
	
	methods
		function obj=array(varargin)
			if(nargin == 1)
				if(iscell(varargin{1}))
					obj.data = varargin{1};
% 				elseif(isstruct(varargin{1}))
% 					list = fieldnames(varargin{1});
% 					for ii=1:numel(list)
% 						obj.data{ii} = varargin{1}.(list{ii});
% 					end
				else
					obj.data = mat2cell(...
						varargin{1}(:),...
						ones(numel(varargin{1}),1)...
					);
				end
			else
				obj.data = varargin;
			end
		end
		
		% information
		function n=get.length(obj)
			n = numel(obj.data);
		end
		
		function data=get.vector(obj)
			data = reshape([obj.data{:}],size(obj.data));
		end
		
		function data=get.stream(obj)
			data = [obj.data{:}];
		end
		
		
		% intrinsic array manipulation
		function obj=push(obj,elm)
			obj.data{end+1} = elm;
		end
		
		function obj=append(obj,arr)
			arr.forEach(@(elm) obj.push(elm));
        end
        
        function obj=assign(obj,f)
            fWrap = obj.get_fWrap(f);
            
            for ii=1:obj.length
				elm = obj.data{ii};
                obj.data{ii} = lib.struct.merge(elm,fWrap(elm));
            end
        end
		
		function obj=sort(obj,f)
			arr = obj.map(f);
			[~,sx] = sort(arr.vector);
			
			obj.data = obj.data(sx);
		end
		
		function obj=reverse(obj)
			obj.data = obj.data(end:-1:1);
		end
		
		% element extraction
		function id=indexOf(obj,f)
			id = [];
			switch class(f)
				case 'char'
					for ii=1:numel(obj.data);
						if strcmp(f,obj.data{ii})
							id = ii;
							break
						end
					end
					
				case 'double'
					for ii=1:numel(obj.data);
						if f == obj.data{ii}
							id = ii;
							break
						end
					end
					
				case 'function_handle'
					for ii=1:numel(obj.data);
						if(f(obj.data{ii}))
							id = ii;
							break
						end
					end
			end
		end
		
		function elm=find(obj,f)
			elm = [];
			fWrap = obj.get_fWrap(f);
			
			for ii=1:numel(obj.data);
				if(fWrap(obj.data{ii}))
					elm = obj.data{ii};
					break
				end
			end
		end
		
		function elm=min(obj,f)
			arr = obj.accumulate(f);
			kk = arr == min(arr);
			elm = obj.data{kk};
		end
		
		% validation
		function b=every(obj,f)
			fWrap = obj.get_fWrap(f);
			
			b = true;
			for ii=1:obj.length
				if ~fWrap(obj.data{ii})
					b = false;
					break;
				end
			end
		end
		
		function b=some(obj,f)
			fWrap = obj.get_fWrap(f);
			
			b = false;
			for ii=1:obj.length
				if fWrap(obj.data{ii})
					b = true;
					break;
				end
			end
		end
		
		% extrinsic manipulation
		function arr=slice(obj,iStart,varargin)
			if nargin == 2
				iEnd = obj.length;
			else
				iEnd = varargin{1};
			end
			
			ch = str2func(class(obj));
			arr = ch(obj.data{iStart:iEnd});
		end
		
		
		function arr = pick(obj,varargin)
			ch = str2func(class(obj));
			arr = ch(obj.data{varargin{:}});
		end
		
		
		
		function arr=filter(obj,f)
			ch = str2func(class(obj));
			arr = ch();
			fWrap = obj.get_fWrap(f);
			
			for ii=1:numel(obj.data)
				if fWrap(obj.data{ii})
					arr.push(obj.data{ii});
				end
			end
		end
		
		function arr=exclude(obj,f)
			ch = str2func(class(obj));
			arr = ch();
			fWrap = obj.get_fWrap(f);
			
			for ii=1:numel(obj.data)
				if ~fWrap(obj.data{ii})
					arr.push(obj.data{ii});
				end
			end
		end
		
		function arr=map(obj,f)
			ch = str2func(class(obj));
			fWrap = obj.get_fWrap(f);

			arr = ch(...
				cellfun(fWrap, obj.data, 'UniformOutput', false)...
			);
		end
		
		% other
		function obj=forEach(obj,f)
			fWrap = obj.get_fWrap_forEach(f);
% 			fWrap = obj.get_fWrap(f);
			
			for ii=1:obj.length
				fWrap(obj.data{ii});
			end
		end
		
		function s=join(obj,delimiter)
			s = strjoin(obj.data,delimiter);
		end
		
		function s=reduce(obj,f,varargin)
			% set inital values
			if(nargin == 3 && ~lib.isfunc(varargin{1}))
				s = varargin{1};
				i0 = 1;
			else
				s = obj.data{1};
				i0 = 2;
			end
			
			% reduce array
			for ii=i0:numel(obj.data);
				s = f(s,obj.data{ii});
			end
			
			% furnish
			if(nargin == 3 && lib.isfunc(varargin{1}))
				s = varargin{1}(s);
			end
		end
		
		function acc = accumulate(obj,f,varargin)
% 			fWrap = obj.get_fWrap_forEach(f);
			fWrap = obj.get_fWrap(f);
			
			acc = obj.reduce(@(acc,elm) [acc;fWrap(elm)],[]);
			acc = reshape(acc,size(obj.data));
		end
	end
	
	methods (Access = protected)
		function fWrap=get_fWrap(obj,f)
			ii = 1;
			
			function varargout=fWrap2(elm)
				varargout{:} = f(elm,ii);
				ii = ii + 1;
			end
			
			function varargout=fWrap3(elm)
				varargout{:} = f(elm,ii,obj);
				ii = ii + 1;
			end
			
			switch(nargin(f))
				case 0
					fWrap = @(elm) f();
				case 1
					fWrap = f;
				case 2
					fWrap = @fWrap2;
				case 3
					fWrap = @fWrap3;
			end
		end
		
		% without any output
		function fWrap=get_fWrap_forEach(obj,f)
			ii = 1;
			
			function fWrap2(elm)
				f(elm,ii);
				ii = ii + 1;
			end
			
			function fWrap3(elm)
				f(elm,ii,obj);
				ii = ii + 1;
			end
			
			switch(nargin(f))
				case 0
					fWrap = @(elm) f();
				case 1
					fWrap = f;
				case 2
					fWrap = @fWrap2;
				case 3
					fWrap = @fWrap3;
			end
		end
	end
end