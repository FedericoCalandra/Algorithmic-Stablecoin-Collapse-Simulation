classdef Token
    %TOKEN class modelling a token
    
    properties
        Name            string
        IsStablecoin    logical = false
    end
    
    methods
        function token = Token(varargin)
            %Token() Construct an instance of this class
            token.Name = varargin{1};
            if nargin > 1
                token.IsStablecoin = varargin{2};
            end
        end
        
        function is_eq = is_equal(self, other)
            if self.Name == other.Name
                is_eq = true;
            else
                is_eq = false;
            end
        end
    end
end

