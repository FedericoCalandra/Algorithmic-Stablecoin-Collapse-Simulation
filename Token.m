classdef Token
    %TOKEN class modelling a token
    
    properties
        Name            string
        IsStablecoin    logical = false
        IsCollateral    logical = false
        PEG             double = 1
    end
    
    methods
        function token = Token(varargin)
            %Token() Construct an instance of this class
            token.Name = varargin{1};
            if nargin > 1
                token.IsStablecoin = varargin{2};
                if nargin > 2
                    token.IsCollateral = varargin{3};
                    token.PEG = varargin{4};
                end
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

