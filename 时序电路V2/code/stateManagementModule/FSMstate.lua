local FSMState = {}  
  
function FSMState:new(super)  
    local obj = super or {}  
    obj.super = self  
    return setmetatable(obj, {__index = self})  
end  
  
  
function FSMState:enter()  
    print(string.format("%s enter", self.name))  
end  
  
  
function FSMState:exit()  
    print(string.format("%s exit", self.name))  
end  

_G.FSMState = FSMState