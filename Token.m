classdef Token
    %TOKEN class modelling a token
    
    properties
        Name    string
    end
    
    methods
        function token = Token(name)
            %Token() Construct an instance of this class
            token.Name = name;
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

