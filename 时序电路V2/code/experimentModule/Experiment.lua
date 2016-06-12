local Experiment = {}

function Experiment:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
    return o;  
end

Experiment.extend = Experiment.new

_G.Experiment = Experiment
