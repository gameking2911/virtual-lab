local FSMStateMachine = {}  
  
function FSMStateMachine:new(o)  
    o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
    return o; 
end  
  
function FSMStateMachine:addTransition(before, event, after)  
    if self.transitions[before] then  
        if self.transitions[before][event] then print("event already be added",before,event)  
        else  
            self.transitions[before][event] = after  
        end  
    end  
end  
  
function FSMStateMachine:stateTransition(event)  
    -- assert(self.curState) 
    -- print("curState",self.curState) 
    local out = self.transitions[self.curState][event] 
    print("curState","event","out",self.curState,event,out) 
    if out then  
        print(string.format("reponse to event:%s", event))  
    --     -- respond to this event  
        -- 将对象传入exit/enter可改变对象属性
        self[self.curState]:exit(self.obj)  
        self.curState = out 
        self[self.curState]:enter(self.obj)  
    else  
    --     -- no related event  
        print(string.format("no reponse to event:%s", event))  
    end  
end  

_G.FSMStateMachine = FSMStateMachine
