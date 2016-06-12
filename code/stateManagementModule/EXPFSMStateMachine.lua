local EXPFSMStateMachine = FSMStateMachine:new
{  
    NormalState = FSMState:new{name="NormalState"} , 
    ChoiceState = FSMState:new{name="ChoiceState"} ,
    SettingsState = FSMState:new{name="SettingsState"} ,

    transitions = {  
        NormalState = {},  
        ChoiceState = {},  
        SettingsState = {}, 
    },  
    curState = "NormalState",  

} 

-- EXPFSMStateMachine.NewChoiceState = EXPFSMStateMachine.ChoiceState:new{name="NewChoiceState"} 
-- EXPFSMStateMachine.transitions.NewChoiceState = {}

function EXPFSMStateMachine:LoadTransitions()
    self:addTransition("NormalState", "ClickC/Ibtn", "ChoiceState")  
    self:addTransition("ChoiceState", "ClickCancelChoice", "NormalState")  
    self:addTransition("NormalState", "ClickC/IModel", "SettingsState")  
    self:addTransition("SettingsState", "ClickCmplBtn", "NormalState") 
    self:addTransition("SettingsState", "ClickC/Ibtn", "ChoiceState")  
end

function EXPFSMStateMachine.NormalState:mouseMove(p)
    if exp.focus then
        exp.focus = nil
    end
    if p and p.node and p.node.mesh and p.node.mesh.parent and not p.node.mesh.parent.permit then
        exp.focus =  exp:isIntersected(p.node.mesh.parent.msh)
    end
end

function EXPFSMStateMachine.ChoiceState:mouseMove(p)
    if p then
        exp.choice.transform:setTranslation(p.x,p.y,p.z)
    end
    
    if exp.focus then
        exp.focus = nil
    end
    if p and p.node and p.node.mesh and p.node.mesh.parent and p.node.mesh.parent.permit then
        local obj = p.node.mesh.parent
        if exp.choice.class == obj.class then
            exp.focus =  exp:isIntersected(obj.msh) 
        end
        -- exp.focus =  exp:isIntersected(exp.choice.class,p.node.mesh.parent.msh) 
        if exp.focus then
            if exp.color ~= _Color.Green then
                exp.color = _Color.Green
                exp.twinkle:clear()
                exp.twinkle:fade(exp.color, 0, 1, 500)
                exp.choice:enumMesh( '', true, 
                function(m)
                    m.blender = exp.invisibility 
                end )
                exp.focus.msh:enumMesh( '', true, 
                function(m)
                    m.blender = exp.twinkle 
                end )
            end
            if exp.focus ~= exp.last_focus then
                if exp.last_focus and exp.last_focus.permit and exp.last_focus.class == exp.focus.class then
                    exp.last_focus.msh:enumMesh( '', true, 
                    function(m)
                        m.blender = exp.transparent 
                    end )
                end
                exp.focus.msh:enumMesh( '', true, 
                function(m)
                    m.blender = exp.twinkle 
                end )
                exp.last_focus = exp.focus                      
            end
        -- else
        --     exp.focus = nil
        end 

    else
        if exp.color ~= _Color.Red then
            exp.focus = nil
            exp.color = _Color.Red
            exp.twinkle:clear()
            exp.twinkle:fade(exp.color, 0, 1, 500)
            exp.choice:enumMesh( '', true, 
            function(m) 
                m.blender = exp.twinkle
             end )
            exp:placed(exp.choice.class)
        end         
    end 

end

function EXPFSMStateMachine.SettingsState:mouseMove(p)
    if exp.last_subfocus then
        exp.last_subfocus.blender = nil
        exp.last_subfocus = nil
    end     
    if p and p.node and p.node.mesh and p.node.mesh.parent == exp.set_one then

        exp.focus = exp.set_one:isIntersected(p.node.mesh) 

        if exp.focus then
            exp.focus.blender = exp.Grayshade
            exp.last_subfocus = exp.focus    
        end
    end
end

function EXPFSMStateMachine.NormalState:LeftMouseDown(o,x,y)
    if o.class ~= classID.Line then
        exp.sm:stateTransition("ClickC/IModel") 
        exp.set_one = o
        ui.finish.show = true
        o:settings()
    end
end

function EXPFSMStateMachine.NormalState:RightMouseDown(o,x,y)
    if o and _sys:isKeyDown(_System.KeyAlt) then
        o:unplace()
    end
end

function EXPFSMStateMachine.ChoiceState:LeftMouseDown(o,x,y)
    o:place()
    self:RightMouseDown()
end

function EXPFSMStateMachine.ChoiceState:RightMouseDown()
    exp.sm:stateTransition("ClickCancelChoice")     
    exp.choice = nil
    exp:place_init()
end

function EXPFSMStateMachine.SettingsState:enter()
    exp.focus = nil
end

function EXPFSMStateMachine.SettingsState:LeftMouseDown(o,x,y)
    -- if o.parent then
    exp.set_one:onClick(o.ID)
    -- end
end

function EXPFSMStateMachine.SettingsState:RightMouseDown(o,x,y)
    if exp.focus then
        exp.set_one:onClickRight(o.ID)
    end
end

function EXPFSMStateMachine:mouseMove(x,y)
    local p = exp.scene:pick(_rd:buildRay(x,y))
        self[self.curState]:mouseMove(p)
end

function EXPFSMStateMachine:LeftMouseDown(x,y)
    if exp.focus then
       self[self.curState]:LeftMouseDown(exp.focus,x,y)
    end
end

function EXPFSMStateMachine:RightMouseDown(x,y)
    -- if exp.focus then
        self[self.curState]:RightMouseDown(exp.focus,x,y)      
    -- end
end

-- local NewChoiceState = EXPFSMStateMachine.ChoiceState:new()

_G.EXPFSMStateMachine = EXPFSMStateMachine
