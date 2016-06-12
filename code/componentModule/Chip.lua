local Chip = Equip:extend()

function Chip:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
    return o;  
end

Chip.extend = Chip.new

function Chip:init( ... )

end

when{}
function ChipInit ( chip,load_or_delete,experiment ,main_socket ,sub_socket )
    print("ChipInit")
    if load_or_delete then
        chip:loadConnection ( experiment,main_socket,sub_socket )
    else
        chip:deleteConnection ( experiment,main_socket,sub_socket )
    end
end

_G.Chip = Chip