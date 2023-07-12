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
    end
end

