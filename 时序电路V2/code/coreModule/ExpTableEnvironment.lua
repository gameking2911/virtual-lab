------------实验台环境类，主要进行场景和环境变量的初始化，为其他类提供支持
local ExpTableEnvironment ={}
_G.ExpTableEnvironment = ExpTableEnvironment

function ExpTableEnvironment:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
    return o;  
end

function ExpTableEnvironment:ObjLoad(t)
	local o = {}
	-- local lineIndex = 0
	for k,v in pairs(t) do
		for i=1,#v.position do 
			
			if(k==classID.Am) then
				o[#o+1] = Am:new{ID=#o+1,class=classID.Am}	
			elseif(k==classID.Vm) then
				o[#o+1] = Vm:new{ID=#o+1,class=classID.Vm}
			elseif(k==classID.Rb)	then			
				o[#o+1] = Rb:new{ID=#o+1,class=classID.Rb}
			elseif(k==classID.KCLboard)	then	
				o[#o+1] = KCLboard:new{ID=#o+1,class=classID.KCLboard}
			elseif(k==classID.cc4011)	then	
				o[#o+1] = cc4011:new{ID=#o+1,class=classID.cc4011}
			elseif(k==classID.cc4012)	then	
				o[#o+1] = cc4012:new{ID=#o+1,class=classID.cc4012}
			elseif(k==classID.CLCEboard)	then	
				o[#o+1] = CLCEboard:new{ID=#o+1,class=classID.CLCEboard}
			elseif(k==classID.cc4013)	then	
				o[#o+1] = cc4013:new{ID=#o+1,class=classID.cc4013}
			elseif(k==classID.cc4027)	then	
				o[#o+1] = cc4027:new{ID=#o+1,class=classID.cc4027}
			elseif(k==classID.SLCEboard)	then	
				o[#o+1] = SLCEboard:new{ID=#o+1,class=classID.SLCEboard}
			end


			o[#o]:setPosition(t[k].position[i])
			o[#o]:setRotation(t[k].rotation[i])
			o[#o]:init()
-------------可以通过索引号选取不同品牌的元器件/设备，此处默认索引号都为1
			o[#o]:load(self,t[k].style[i])

			--------------根据每个设备对应连接线的ID设置设备/元器件连接线索引
			if t[k].line then
				local m = {}
				local lineNum = 0
				for j=1,#t[k].line.position[i] do
					-- m[#m+1] = o[t[k].line[i][j]]
					-- lineIndex = lineIndex + 1
					lineNum = lineNum + 1
					o[#o+1] = Line:new{ID=#o+1,class=classID.Line}
					o[#o]:setPosition(t[k].line.position[i][j])
					o[#o]:setRotation(t[k].line.rotation[i][j])
					o[#o]:init()
					o[#o]:load(self,t[k].line.style[i][j])
					m[#m+1] = o[#o]
				end

				o[#o-lineNum]:setLine(m)
			end

			-- self.o = o
			-- end
		end
		-- end
	end
	self.o = o

end

--------可修改，变长参数输入，可加载不同模型
function ExpTableEnvironment:EnvironmentLayout( expID )
	----------加载场景基础模型
	-- _G.scene = _Scene.new('lab.sen')
	self.scene = _Scene.new('lab.sen')
	local desk = _Mesh.new ('desk.msh')
	desk.transform:mulScalingLeft(1.5,1.5,1)
	self.scene:add(desk)

	self.wall = _mf:createCube()
	_mf:transformShape(self.wall, _Matrix3D.new():setScaling(5, 65, 65))
	self.wall:setTexture(_Image.new('wall.jpg'))
------------属性值加载
----------灰色渐变
	self.Grayshade = _Blender.new()
	self.Grayshade:fade(_Color.Gray, 0.3, 0.8, 1500)
----------蓝色渐变
	self.Blueshade = _Blender.new()
	self.Blueshade:fade(_Color.Blue, 0.3, 0.8, 1500)
----------红色渐变
	self.Redshade = _Blender.new()
	self.Redshade:fade(_Color.Red, 0.3, 0.8, 1500)
----------黄色渐变
	self.Yellowshade = _Blender.new()
	self.Yellowshade:fade(_Color.Yellow, 0.3, 0.8, 1500)
	------------透明/隐形效果
	self.transparent = _Blender.new()
	self.transparent:blend(0x80ffffff)
	self.invisibility = _Blender.new()
	self.invisibility:blend(0x00ffffff)
	------------闪烁效果
	-- local twinkle_time = 500
	self.twinkle = _Blender.new()
	self.color = _Color.Black
	self.twinkle:fade(self.color, 0, 1, 500)
	self.twinkle.playMode = _Blender.PlayPingPong

	----------判定偏移量
	-- local m = 1
	self.choice = nil
	exp.set_one = nil 
	self.focus = nil
	self.subfocus = nil

	---------根据选择不同的实验板UI取得不同的实验序号
	-- _G.expID = 1

	self.last_focus = nil
	self.last_subfocus = nil


		----------加载所有设备/元器件的classID
	_dofile('classID.lua')
	----------加载实验配置文件与设备类型ID
	_dofile('expConfig.lua')
	----------加载设备/元器件与状态机类
	_dofile('equFile.lua')

	self:ObjLoad(exp_config[expID].obj)


--------加载实验流程控制状态机,添加状态转移关系
	self.sm = EXPFSMStateMachine:new{obj=self}  
	self.sm:LoadTransitions()

	-------加载实验算法和对应UI
	_dofile(exp_config[expID].name)

end

function ExpTableEnvironment:place_init()
	for i=1,#self.o do
		if self.o[i].permit then
		self.o[i].msh:enumMesh( '@[^]', true, 
			function(m)
				m.blender = self.invisibility
			end )
		end
	end
end

function ExpTableEnvironment:placed(i)
	for j=1,#self.o do
		if self.o[j].permit then
			if(self.o[j].class == i) then
				self.o[j].msh:enumMesh( '@[^]', true, 
				function(m)
					m.blender = self.transparent
				end )
			else
				self.o[j].msh:enumMesh( '@[^]', true, 
				function(m)
					m.blender = self.invisibility
				end)
			end
		end
	end
	-- end
end

function ExpTableEnvironment:isIntersected(msh)
	for i=1,#self.o do
		if(msh == self.o[i].msh ) then
			-- focus = i
			return self.o[i]
		end
	end
	-- end
end

when{}
function render(e)
	-- time_count = time_count + e
	exp.scene:render()
	
-----------画墙
	local mat = _Matrix3D.new()
	mat:setTranslation(70, 0, 0)
	mat:mulRotationZRight(math.pi * 0.5)
	_rd:pushMatrix3D(mat)
	exp.wall:drawMesh()
	_rd:popMatrix3D()

	mat:setTranslation(70, 0, 0)
	mat:mulRotationZRight(math.pi)
	_rd:pushMatrix3D(mat)
	exp.wall:drawMesh()
	_rd:popMatrix3D()

	mat:setTranslation(70, 0, 0)
	mat:mulRotationZRight(math.pi * 1.5)
	_rd:pushMatrix3D(mat)
	exp.wall:drawMesh()
	_rd:popMatrix3D()

	mat:setTranslation(70, 0, 0)
	mat:mulRotationZRight(math.pi * 2)
	_rd:pushMatrix3D(mat)
	exp.wall:drawMesh()
	_rd:popMatrix3D()
-----------
	if exp.choice then
		exp.choice:drawMesh()
	end
end

-- function  setScene( ... )
-------可将操作方法封装起来，实现野外等其他操作方式的实验的并入...
