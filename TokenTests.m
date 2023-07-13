classdef TokenTests < matlab.unittest.TestCase
    
    methods (Test)
        function testTokenName(TestCase)
            token = Token("MyToken");
            actName = token.Name;
            expName = "MyToken";
            TestCase.verifyEqual(actName, expName);
        end
    end
    
end

