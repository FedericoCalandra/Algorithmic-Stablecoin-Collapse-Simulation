classdef Token
    %TOKEN class modelling a token
    
    properties
        Name            string
        IsStablecoin    logical
    end
    
    methods
        function token = Token(name, isStablecoin)
            %Token() Construct an instance of this class
            token.Name = name;
            token.IsStablecoin = isStablecoin;
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

