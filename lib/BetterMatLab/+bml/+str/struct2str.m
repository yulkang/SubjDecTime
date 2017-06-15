function str = struct2str(S, varargin)
% See also: bml.str.Serializer.convert

str = bml.str.Serializer.convert(S, varargin{:});

% opt = varargin2S(varargin, {
%     'fields', []
%     'include_fields', true
%     'sep_fields', ';' % '___'
%     'sep_field_val', '=' % '__'
%     'sep_val', ',' % '_'
%     'skip_fields_with_error', true
%     'skip_empty', true
%     });
% 
% if isequal(opt.fields, [])
%     opt.fields = fieldnames(S);
% end
% if ~opt.include_fields
%     opt.fields = setdiff(fieldnames(S), opt.fields, 'stable');
% end
% 
% str = '';
% nf = numel(opt.fields);
% for ii = 1:nf
%     f = opt.fields{ii};
%     v = S.(f);
%     
%     if isempty(v) && opt.skip_empty
%         continue;
%     end
%     
%     str_f = '';
%     
%     if ii > 1
%         str_f = [str_f, opt.sep_fields];
%     end
%     
%     str_f = [str_f, f];
%     try
%         if ischar(v)
%             str_f = [str_f, opt.sep_field_val, v];
%         else
%             assert(isnumeric(v) || islogical(v));
%             if ~isempty(v)
%                 str_f = [str_f opt.sep_field_val, sprintf('%g', v(1))];
% 
%                 if ~isscalar(v)
%                     str_f = [str_f, sprintf([opt.sep_val, '%g'], v(2:end))];
%                 end
%             end
%         end
%         str = [str, str_f];
%     catch err
%         if ~opt.skip_fields_with_error
%             rethrow(err);
%         end
%     end
end