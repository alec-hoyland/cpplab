

% generic method that adds something as a child to this object
function self = add(self,varargin)
switch length(varargin)
case 1
	assert(isa(varargin{1},'cpplab'),'Argument should be a cpplab object')
	name = varargin{1}.cpp_class_name;
	thing = varargin{1};
case 2
	if isa(varargin{2},'cpplab') && isa(varargin{1},'char')
		name = varargin{1};
		thing = varargin{2};
	elseif isa(varargin{1},'cpplab') && isa(varargin{2},'char')
		name = varargin{2};
		thing = varargin{1};
	elseif isa(varargin{1},'cpplab') && isa(varargin{2},'cpplab')
		error('cpplab::add "add one object at a time"')
	else
		error('cpplab::add "I dont know what you want me to do"')
	end
otherwise
	if iseven(length(varargin))
		name = varargin{1};
		hpp_path = varargin{2};
		varargin(1:2) = [];
	else
		hpp_path = varargin{1};
		varargin(1) = [];
	end

	thing = cpplab(hpp_path,varargin{:});
	if ~exist('name','var')
		name = thing.cpp_class_name;
	end
end
p = self.addprop(name);
p.NonCopyable = false;
self.(name) = thing;

v = evalin('base','whos');
hash_these = false(length(v));
for i = 1:length(v)
	if strcmp(v(i).class,'cpplab')
		hash_these(i) = true;
	end
	S = superclasses(v(i).class);
	if ~isempty(S)
		if any(strcmp(S,'cpplab'))
			hash_these(i) = true;
		end
	end
end
% ok, now ask these objects to hash
for i = 1:length(v)
	if hash_these(i)
		if strcmp(v(i).name,'ans')
			continue
		end
		evalin('base',[v(i).name '.sha1hash;']);
	end
end
