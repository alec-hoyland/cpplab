%                    _       _     
%   ___  _     _    | | __ _| |__  
%  / __|| |_ _| |_  | |/ _` | '_ \ 
% | (_|_   _|_   _| | | (_| | |_) |
%  \___||_|   |_|   |_|\__,_|_.__/ 
%
%
% readCPPClass.m
% reads a C++ file and finds the members of that class by
% figuring out the constructor for that class

function [class_members, input_types] = readCPPClass(self,cppfilename)

% check that it exists 
assert(exist(cppfilename,'file') == 2,'C++ file not found.')

class_name = pathEnd(cppfilename);
lc = length(class_name);
lines = lineRead(cppfilename);

% find the lines where the class is declared
constructor_lines = [];
for i = 1:length(lines)
	if length(lines{i}) < lc
		continue
	end
	if strcmp(lines{i}(1:lc),class_name)
		constructor_lines = [constructor_lines; i];
	end
end

if length(constructor_lines) > 1
	error('This C++ class has more than one constructor; not supported.')
end

constructor_line = lines{constructor_lines};

classdef_line = lines{lineFind(lines,['class ' class_name])};
if ~isempty(strfind(classdef_line,'public'))
	self.cpp_class_parent = strtrim(strrep(classdef_line(strfind(classdef_line,'public')+6:end),'{',''));
else
	self.cpp_class_parent = 'N/A';
end


% figure out the input variables to the constructor 
input_variables = {};
input_types = {};

a = strfind(constructor_line,'(');
z = strfind(constructor_line(a:end),',');

while length(z) > 0
	z = z(1);
	this_input = strtrim(constructor_line(a+1:a+z-2));
	space_loc = strfind(this_input,' ');
	assert(length(space_loc)==1,'Expected exactly one space in this input')
	input_types = [input_types; strtrim(this_input(1:space_loc))];
	input_variables = [input_variables; strtrim(this_input(space_loc:end))];
	a = a+z;
	z = strfind(constructor_line(a:end),','); 
end

% get the last one too
z = strfind(constructor_line(a:end),')'); z = z(1);
this_input = strtrim(constructor_line(a+1:a+z-2));
space_loc = strfind(this_input,' ');
assert(length(space_loc)==1,'Expected exactly one space in this input')
input_types = [input_types; strtrim(this_input(1:space_loc))];
input_variables = [input_variables; strtrim(this_input(space_loc:end))];


% read the actual constructor and figure out the mapping from the input variables to something
% that something is assumed to be members of this class. 
constructor_start = [];
constructor_stop = [];
idx = constructor_lines;

for i = idx:length(lines)
	this_line = strtrim(lines{i});
	if strcmp(this_line(1),'{')
		constructor_start = i;
		break
	end
end

for i = constructor_start:length(lines)
	this_line = strtrim(lines{i});
	if strcmp(this_line(1),'}')
		constructor_stop = i;
		break
	end
end

% find every one of the input variables in the constructor code
member_variables = cell(length(input_variables),1);

for i = 1:length(member_variables)
	for j = constructor_start:constructor_stop
		this_line = strtrim(lines{j});
		this_line = strrep(this_line,' ','');

		if any(strfind(this_line,['=' input_variables{i} ';']))
			this_member = this_line(1:strfind(this_line,'=')-1);
			member_variables{i} = this_member;
		else
	end
end

class_members = member_variables;


end

