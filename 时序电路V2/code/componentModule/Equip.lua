local Equip = Object:extend()
---------
-- EquipCommand.line = nil
--------表示设备能正常工作的最小接线数
-- Equip.WorkinglinkedNum = 2

function Equip:init( ... )
--------表示设备能正常工作的最小接线数
	Object.init(self)
	self.WorkinglinkedNum = 2
	self.linked = 0
end

function Equip:onClick(subMeshID)
end

function Equip:onClickRight(subMeshID)
end

function Equip:setLine(line)
	line = line or {}
	self.line = line
	-- self.linkedMax = 2
	for i=1,#line do
		line[i].owner = self
	end
end

function Equip:isIntersected(msh)
	-- print("msh.id",msh.ID)
	if self.config.key.control then

		for k,v in pairs(self.config.key.control) do
			-- if(subMeshID == v) then
			if( msh == self.msh:getSubMesh(v) ) then
				-- self.msh:getSubMesh(subMeshID).blender = t_blender
				-- self.msh:getSubMesh(subMeshID).blender:fade(_Color.Gray, 0.3, 0.8, 1500)
				return msh
				-- break
			end
	 	end

	end
end

function Equip:settings()
------设置状态限制视角				
-- _rd.camera.radiusMax = 10
-- _rd.camera.radiusMin = 5
	local up = _Vector3.new(0,0,1)			
	_rd.camera.look:set(_Vector3.add( self.position , _Vector3.new(0, 0, 1) ) ) 
	local mx = {-6,0,6,0} 
	local my = {0,-6,0,6}
	local mz = 0			
	_rd.camera.up = up
	local index = 2 + self.rotation/(0.5*math.pi) 									
	 _Vector3.add( _rd.camera.look , _Vector3.new( mx[index] , my[index] , mz ) , _rd.camera.eye )
end

function Equip:place()
	Object.place(self)
    self.msh:enumMesh( '', true, function(m) m.blender=nil end )
    if not self.line then return end

	for i=1,#self.line do
    	-- exp.o[self.line[i]].msh:enumMesh( '', true, function(m) m.blender=transparent end )
		self.line[i].permit=true

	end
end

function Equip:unplace()
	Object.unplace(self)
	self:isNotJoined()
	self.ready = false
	self.msh:enumMesh( '', true, function(m) m.blender=exp.invisibility end )
    if not self.line then return end
	for i=1,#self.line do
    	self.line[i].msh:enumMesh( '', true, function(m) m.blender=exp.invisibility end )
       	-- self.line[i].msh.blender = exp.invisibility 
		self.line[i].permit=false
		-- self.line[i].unplace(self)
	end
end

function Equip:link()
	self.linked = self.linked + 1
	print("self.linked",self.linked)
	if(self.linked>=self.WorkinglinkedNum) then
		self:isJoined()
		self.ready = true
	else
		self:isNotJoined()
	end
end

function Equip:unlink()
	self.linked = self.linked - 1
	if(self.linked<self.WorkinglinkedNum) then
		self:isNotJoined()
		self.ready = false
	else
		self:isJoined()
	end
end

function Equip:isJoined()
	self.state = "1"
	SendMsg{obj = self,msg = "ImReady"}
end

function Equip:isNotJoined()
	self.state = "0"
	SendMsg{obj = self,msg = "ImQuiteReady"}
end

_G.Equip = Equip

