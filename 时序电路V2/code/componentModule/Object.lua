local Object = {}

function Object:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
    return o;  
end

Object.extend = Object.new
-- Object.permit=false
-- Object.state = "0"
function Object:init( ... )
	self.state = "0"
	self.permit = true
end

-------在envir环境中加载object，选择索引为index的模型
function Object:load( envir,index )
    self.msh = _Mesh.new(self.config.msh[index])
    local i = 0
    self.msh:enumMesh( '@[^]', true, 
    function(m)
        i = i + 1
        m.transform:setTranslation(self.position)
        m.transform:mulRotationZLeft(self.rotation)

--------初始模型自动隐藏!
        m.blender = envir.invisibility
        m.ID = i
        m.parent = self
        envir.scene:add(m) 
    end)
end

function Object:setPosition(n)
	self.position = n
end

function Object:setRotation(n)
	self.rotation = n
end

function Object:place()
----------是否使用状态机？
	-- self.sm
   
    self.msh:enumMesh( '', true, function(m) m.blender=nil end )
	self.permit = false
end

function Object:unplace()
    self.msh:enumMesh( '', true, function(m) m.blender=exp.invisibility end )
    self.permit = true
end

_G.Object = Object