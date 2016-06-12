local SLCE = Experiment:extend()

function  SLCE:init( ... )

	for i=1,#exp.o do
		if exp.o[i].class == classID.SLCEboard then
			self.slceboard = exp.o[i]
		elseif exp.o[i].class == classID.cc4011 then
			self.cc4011 = exp.o[i]
		elseif exp.o[i].class == classID.cc4012 then
			self.cc4012 = exp.o[i]
		elseif exp.o[i].class == classID.cc4013 then
			if self.cc4013 then
				self.cc4013_2 = exp.o[i]
			else 
				self.cc4013 = exp.o[i]
			end
		elseif exp.o[i].class == classID.cc4027 then
			if self.cc4027 then
				self.cc4027_2 = exp.o[i]
			else 
				self.cc4027 = exp.o[i]
			end

		elseif exp.o[i].class == classID.Vm then
			self.Vcc = exp.o[i]
		end
	end

	self.slceboard:place()

	-- self.portsnum = 14
	self.sl_tree = SequentialLogicTree:new()
	local logic_socket = self.slceboard.config.key.logic_switch_socket
	local pulse_socket = self.slceboard.config.key.single_pulse_socket

	local socket1 = self.slceboard.config.key.socket_1
	local socket2 = self.slceboard.config.key.socket_2
-- ----D触发器（14孔插座）
-- 	local socket3 = self.slceboard.config.key.socket_3
-- 	local socket4 = self.slceboard.config.key.socket_4
-- ----jk触发器（16孔插座）
	local socket4 = self.slceboard.config.key.socket_4
	local socket5 = self.slceboard.config.key.socket_5
	local light_socket = self.slceboard.config.key.output_socket
	local tmsh = self.slceboard.msh
----输出端口索引表，通过父mesh和子mesh进行索引
	self.outputIndex = {}
	-- print("~~~~~~~~~",self.slceboard,tmsh,logic_socket[1],tmsh:getSubMesh(logic_socket[1]))
	self.outputIndex[tmsh] = {

	[tmsh:getSubMesh(logic_socket[1])] = { IDtable={self.slceboard.ID,logic_socket[1]},  },
	[tmsh:getSubMesh(logic_socket[2])] = { IDtable={self.slceboard.ID,logic_socket[2]},  },
	[tmsh:getSubMesh(logic_socket[3])] = { IDtable={self.slceboard.ID,logic_socket[3]},  },
	[tmsh:getSubMesh(logic_socket[4])] = { IDtable={self.slceboard.ID,logic_socket[4]},  },
	[tmsh:getSubMesh(logic_socket[5])] = { IDtable={self.slceboard.ID,logic_socket[5]},  },
	[tmsh:getSubMesh(logic_socket[6])] = { IDtable={self.slceboard.ID,logic_socket[6]},  },
	[tmsh:getSubMesh(logic_socket[7])] = { IDtable={self.slceboard.ID,logic_socket[7]},  },
	[tmsh:getSubMesh(logic_socket[8])] = { IDtable={self.slceboard.ID,logic_socket[8]},  },

----单次脉冲源
	[tmsh:getSubMesh(pulse_socket[1])] = { IDtable={self.slceboard.ID,pulse_socket[1]},  },
	[tmsh:getSubMesh(pulse_socket[2])] = { IDtable={self.slceboard.ID,pulse_socket[2]},  },

----socket1
	[tmsh:getSubMesh(socket1[1])] = { IDtable={self.slceboard.ID,socket1[1]},  },
	[tmsh:getSubMesh(socket1[2])] = { IDtable={self.slceboard.ID,socket1[2]},  },
	[tmsh:getSubMesh(socket1[12])] = { IDtable={self.slceboard.ID,socket1[12]},  },
	[tmsh:getSubMesh(socket1[13])] = { IDtable={self.slceboard.ID,socket1[13]},  },
----socket2
	[tmsh:getSubMesh(socket2[1])] = { IDtable={self.slceboard.ID,socket2[1]},  },
	[tmsh:getSubMesh(socket2[2])] = { IDtable={self.slceboard.ID,socket2[2]},  },
	[tmsh:getSubMesh(socket2[12])] = { IDtable={self.slceboard.ID,socket2[12]},  },
	[tmsh:getSubMesh(socket2[13])] = { IDtable={self.slceboard.ID,socket2[13]},  },
----socket4
	[tmsh:getSubMesh(socket4[1])] = { IDtable={self.slceboard.ID,socket4[1]},  },
	[tmsh:getSubMesh(socket4[2])] = { IDtable={self.slceboard.ID,socket4[2]},  },
	[tmsh:getSubMesh(socket4[14])] = { IDtable={self.slceboard.ID,socket4[14]},  },
	[tmsh:getSubMesh(socket4[15])] = { IDtable={self.slceboard.ID,socket4[15]},  },
----socket5
	[tmsh:getSubMesh(socket5[1])] = { IDtable={self.slceboard.ID,socket5[1]},  },
	[tmsh:getSubMesh(socket5[2])] = { IDtable={self.slceboard.ID,socket5[2]},  },
	[tmsh:getSubMesh(socket5[14])] = { IDtable={self.slceboard.ID,socket5[14]},  },
	[tmsh:getSubMesh(socket5[15])] = { IDtable={self.slceboard.ID,socket5[15]},  },
									}

----输入端口索引表，通过父mesh和子mesh进行索引
	self.inputIndex = {}
	self.inputIndex[tmsh] = {

	[tmsh:getSubMesh(light_socket[1])] = { IDtable={self.slceboard.ID,light_socket[1]},  },
	[tmsh:getSubMesh(light_socket[2])] = { IDtable={self.slceboard.ID,light_socket[2]},  },
	[tmsh:getSubMesh(light_socket[3])] = { IDtable={self.slceboard.ID,light_socket[3]},  },
	[tmsh:getSubMesh(light_socket[4])] = { IDtable={self.slceboard.ID,light_socket[4]},  },
	[tmsh:getSubMesh(light_socket[5])] = { IDtable={self.slceboard.ID,light_socket[5]},  },
	[tmsh:getSubMesh(light_socket[6])] = { IDtable={self.slceboard.ID,light_socket[6]},  },
	[tmsh:getSubMesh(light_socket[7])] = { IDtable={self.slceboard.ID,light_socket[7]},  },
	[tmsh:getSubMesh(light_socket[8])] = { IDtable={self.slceboard.ID,light_socket[8]},  },
----socket1
	[tmsh:getSubMesh(socket1[3])] = { IDtable={self.slceboard.ID,socket1[3]},  },
	[tmsh:getSubMesh(socket1[4])] = { IDtable={self.slceboard.ID,socket1[4]},  },	
	[tmsh:getSubMesh(socket1[5])] = { IDtable={self.slceboard.ID,socket1[5]},  },
	[tmsh:getSubMesh(socket1[6])] = { IDtable={self.slceboard.ID,socket1[6]},  },	
	[tmsh:getSubMesh(socket1[8])] = { IDtable={self.slceboard.ID,socket1[8]},  },
	[tmsh:getSubMesh(socket1[9])] = { IDtable={self.slceboard.ID,socket1[9]},  },	
	[tmsh:getSubMesh(socket1[10])] = { IDtable={self.slceboard.ID,socket1[10]},  },
	[tmsh:getSubMesh(socket1[11])] = { IDtable={self.slceboard.ID,socket1[11]},  },

	-- [tmsh:getSubMesh(socket1[7])] = { IDtable={self.slceboard.ID,socket1[7]},  },
	-- [tmsh:getSubMesh(socket1[14])] = { IDtable={self.slceboard.ID,socket1[14]},  },
----socket2
	[tmsh:getSubMesh(socket2[3])] = { IDtable={self.slceboard.ID,socket2[3]},  },
	[tmsh:getSubMesh(socket2[4])] = { IDtable={self.slceboard.ID,socket2[4]},  },	
	[tmsh:getSubMesh(socket2[5])] = { IDtable={self.slceboard.ID,socket2[5]},  },
	[tmsh:getSubMesh(socket2[6])] = { IDtable={self.slceboard.ID,socket2[6]},  },	
	[tmsh:getSubMesh(socket2[8])] = { IDtable={self.slceboard.ID,socket2[8]},  },
	[tmsh:getSubMesh(socket2[9])] = { IDtable={self.slceboard.ID,socket2[9]},  },	
	[tmsh:getSubMesh(socket2[10])] = { IDtable={self.slceboard.ID,socket2[10]},  },
	[tmsh:getSubMesh(socket2[11])] = { IDtable={self.slceboard.ID,socket2[11]},  },

	-- [tmsh:getSubMesh(socket2[7])] = { IDtable={self.slceboard.ID,socket2[7]},  },
	-- [tmsh:getSubMesh(socket2[14])] = { IDtable={self.slceboard.ID,socket2[14]},  },

----socket4
	[tmsh:getSubMesh(socket4[3])] = { IDtable={self.slceboard.ID,socket4[3]},  },
	[tmsh:getSubMesh(socket4[4])] = { IDtable={self.slceboard.ID,socket4[4]},  },
	[tmsh:getSubMesh(socket4[5])] = { IDtable={self.slceboard.ID,socket4[5]},  },
	[tmsh:getSubMesh(socket4[6])] = { IDtable={self.slceboard.ID,socket4[6]},  },
	[tmsh:getSubMesh(socket4[7])] = { IDtable={self.slceboard.ID,socket4[7]},  },
	[tmsh:getSubMesh(socket4[9])] = { IDtable={self.slceboard.ID,socket4[9]},  },
	[tmsh:getSubMesh(socket4[10])] = { IDtable={self.slceboard.ID,socket4[10]},  },
	[tmsh:getSubMesh(socket4[11])] = { IDtable={self.slceboard.ID,socket4[11]},  },
	[tmsh:getSubMesh(socket4[12])] = { IDtable={self.slceboard.ID,socket4[12]},  },
	[tmsh:getSubMesh(socket4[13])] = { IDtable={self.slceboard.ID,socket4[13]},  },
	-- [tmsh:getSubMesh(socket4[14])] = { IDtable={self.slceboard.ID,socket4[14]},  },
	-- [tmsh:getSubMesh(socket4[15])] = { IDtable={self.slceboard.ID,socket4[15]},  },

	-- [tmsh:getSubMesh(socket4[8])] = { IDtable={self.slceboard.ID,socket4[8]},  },
	-- [tmsh:getSubMesh(socket4[16])] = { IDtable={self.slceboard.ID,socket4[16]},  },
----socket5
	[tmsh:getSubMesh(socket5[3])] = { IDtable={self.slceboard.ID,socket5[3]},  },
	[tmsh:getSubMesh(socket5[4])] = { IDtable={self.slceboard.ID,socket5[4]},  },
	[tmsh:getSubMesh(socket5[5])] = { IDtable={self.slceboard.ID,socket5[5]},  },
	[tmsh:getSubMesh(socket5[6])] = { IDtable={self.slceboard.ID,socket5[6]},  },
	[tmsh:getSubMesh(socket5[7])] = { IDtable={self.slceboard.ID,socket5[7]},  },
	[tmsh:getSubMesh(socket5[9])] = { IDtable={self.slceboard.ID,socket5[9]},  },
	[tmsh:getSubMesh(socket5[10])] = { IDtable={self.slceboard.ID,socket5[10]},  },
	[tmsh:getSubMesh(socket5[11])] = { IDtable={self.slceboard.ID,socket5[11]},  },
	[tmsh:getSubMesh(socket5[12])] = { IDtable={self.slceboard.ID,socket5[12]},  },
	[tmsh:getSubMesh(socket5[13])] = { IDtable={self.slceboard.ID,socket5[13]},  },
	-- [tmsh:getSubMesh(socket5[14])] = { IDtable={self.slceboard.ID,socket5[14]},  },
	-- [tmsh:getSubMesh(socket5[15])] = { IDtable={self.slceboard.ID,socket5[15]},  },

	-- [tmsh:getSubMesh(socket5[8])] = { IDtable={self.slceboard.ID,socket5[8]},  },
	-- [tmsh:getSubMesh(socket5[16])] = { IDtable={self.slceboard.ID,socket5[16]},  },


									}	

------初始化，将所用芯片的所有与非门的输入端口和输出端口连接起来，因为经过与非门，所以isDirectConnection置为false
	-- self.cc4011:loadConnection(self,self.slceboard,socket1)
	-- self.cc4012:loadConnection(self,self.slceboard,socket2)
	-- self.cc4011:place()
	-- self.cc4012:place()
	for i=1,#socket1 do
		if self.outputIndex[tmsh][tmsh:getSubMesh(socket1[i])] then
			self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(socket1[i])].IDtable )
		end
		if self.inputIndex[tmsh][tmsh:getSubMesh(socket1[i])] then
			self.sl_tree:IDtable2Node( self.inputIndex[tmsh][tmsh:getSubMesh(socket1[i])].IDtable )
		end
	end

	for i=1,#socket2 do
		if self.outputIndex[tmsh][tmsh:getSubMesh(socket2[i])] then
			self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(socket2[i])].IDtable )
		end
		if self.inputIndex[tmsh][tmsh:getSubMesh(socket2[i])] then 
			self.sl_tree:IDtable2Node( self.inputIndex[tmsh][tmsh:getSubMesh(socket2[i])].IDtable )		
		end
	end

	for i=1,#socket4 do
		if self.outputIndex[tmsh][tmsh:getSubMesh(socket4[i])] then
			self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(socket4[i])].IDtable )
		end
		if self.inputIndex[tmsh][tmsh:getSubMesh(socket4[i])] then 
			self.sl_tree:IDtable2Node( self.inputIndex[tmsh][tmsh:getSubMesh(socket4[i])].IDtable )		
		end
	end

	for i=1,#socket5 do
		if self.outputIndex[tmsh][tmsh:getSubMesh(socket5[i])] then
			self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(socket5[i])].IDtable )
		end
		if self.inputIndex[tmsh][tmsh:getSubMesh(socket5[i])] then 
			self.sl_tree:IDtable2Node( self.inputIndex[tmsh][tmsh:getSubMesh(socket5[i])].IDtable )		
		end
	end

	for i=1,#logic_socket do
		local table_index = self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[i])].IDtable
		self.sl_tree:IDtable2Node( table_index )
		self.sl_tree[table_index].logic_num = self.slceboard.output[i]
		self.sl_tree[table_index].ifUnEvaluation = false
	end

	for i=1,#pulse_socket do
		local table_index = self.outputIndex[tmsh][tmsh:getSubMesh(pulse_socket[i])].IDtable
		self.sl_tree:IDtable2Node( table_index )
		self.sl_tree[table_index].logic_num = self.slceboard.output_pulse[i]
		self.sl_tree[table_index].ifUnEvaluation = false
	end

	for i=1,#light_socket do
		self.sl_tree:IDtable2Node( self.inputIndex[tmsh][tmsh:getSubMesh(light_socket[i])].IDtable )
	end
	-- self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[1])].IDtable )
	-- self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[2])].IDtable )
	-- self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[3])].IDtable )
	-- self.sl_tree:IDtable2Node( self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[4])].IDtable )

	-- -------四个输入端
	-- local a = false
	-- local b = true
	-- local c = false
	-- local d = true

	------设置输入源初始值
	-- for i=1,#logic_socket do
	-- 	self.sl_tree[self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[i])].IDtable].logic_num = self.slceboard.output[i]
	-- end
	-- self.sl_tree[self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[1])].IDtable].logic_num = a
	-- self.sl_tree[self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[2])].IDtable].logic_num = b
	-- self.sl_tree[self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[3])].IDtable].logic_num = c
	-- self.sl_tree[self.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[4])].IDtable].logic_num = d
-- ------连接线数组
	self.linestate = 0
	self.linkedLines = {}
	self.temp_start_point =  _Vector3.new()
	self.temp_end_point = _Vector3.new()

end

SLCE:init( ... )

_G.SLCE = SLCE

-- when{}
-- function sendPortNum ( index , output )
-- 	local tmsh = slce.slceboard.msh
-- 	local logic_socket = slce.slceboard.config.key.logic_switch_socket
-- 	slce.sl_tree[slce.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[index])].IDtable].logic_num = output
-- 	print("self.output[i]",index,output)
-- end
-- function exp:linkPointsLighting()
-- print()
-- end

exp.sm.LinkState = FSMState:new{name="LinkState"} 
--lua table
exp.sm.transitions.LinkState={}
exp.sm:addTransition("NormalState", "ClickLinkbtn", "LinkState")
-- exp.smaddTransition(ChoiceState, ClickLinkbtn, LinkState)
exp.sm:addTransition("SettingsState", "ClickLinkbtn", "LinkState")
exp.sm:addTransition("LinkState", "linkFinished", "NormalState")
-- exp.sm:addTransition("LinkState", "ClickCIbtn", "ChoiceState")
-- exp.sm:addTransition("LinkState", "ClickCmplBtn", "NormalState")

function SLCE:ifLighting(output_light,input_light)
	-- for i=1,#self.input_ports in self.input_ports do
		-- local t = self.input_ports[i]
	for k1,v1 in pairs(self.inputIndex) do
		for k2,v2 in pairs(self.inputIndex[k1]) do
			local t = self.inputIndex[k1][k2]
------------输入只能一次
			if not t.unique then
				local msh = exp.o[t.IDtable[1]].msh:getSubMesh(t.IDtable[2])
				msh.blender = input_light and self:getCurrentColor() or nil
			end
		end
	end

	-- for i=1,#self.output_ports in self.output_ports do
	-- 	local k = self.output_ports[i]
	for k1,v1 in pairs(self.outputIndex) do
		for k2,v2 in pairs(self.outputIndex[k1]) do
			local t = self.outputIndex[k1][k2]
			local msh = exp.o[t.IDtable[1]].msh:getSubMesh(t.IDtable[2])
			msh.blender = output_light and self:getCurrentColor() or nil
		end
	end
end

function SLCE:ifPorts(input_or_output,Pmsh,Smsh)
	-- body
-----遍历数组，看是否在inputPorts中
	if input_or_output == 1 then
		if self.outputIndex[Pmsh] and self.outputIndex[Pmsh][Smsh] then
			return true
		end
-----遍历数组，看是否在outputPorts中
	elseif  input_or_output == 2 then 
		if self.inputIndex[Pmsh] and self.inputIndex[Pmsh][Smsh] and not self.inputIndex[Pmsh][Smsh].unique then
			return true
		end
	end
	return false
end

function SLCE:getCurrentColor( ... )
	if 	self.linestate == 0 then
		return exp.Blueshade
	elseif 	self.linestate == 1 then
		return exp.Blueshade
	elseif 	self.linestate == 2 then 
		return exp.Redshade
	end	
end
function exp.sm.LinkState:mouseMove(p)
	-- print(dd,exp.sm.curState)
    if exp.focus then
    	exp.focus.blender = SLCE:getCurrentColor()
        exp.focus = nil
    end
    if p and p.node and p.node.mesh and p.node.mesh.parent and not p.node.mesh.parent.permit then
        if SLCE:ifPorts(SLCE.linestate,p.node.mesh.parent.msh,p.node.mesh) then
        	-- print(p.node.mesh.parent.ID,p.node.mesh.ID)
        	exp.focus = p.node.mesh
        	exp.focus.blender = exp.Grayshade
        end
    end
end

-- function slce:turningPoint(start_point,end_point)
-- 	print(turningPoint)
-- 	return _Vector3.new(2,2,2)
-- end


--------更新端口数据(连接线构造二叉树，然后递归或循环计算Y1，Y2，Y3，Y4)
function SLCE:updateData()
	local light_socket = self.slceboard.config.key.output_socket
	local lights = self.slceboard.config.key.display.output_lighting

	for i=1,#light_socket do
		local t = self.inputIndex[self.slceboard.msh][self.slceboard.msh:getSubMesh(light_socket[i])]
--------如果输出的逻辑显示器没有连入成为树节点，就不用计算显示值
		-- print("self.sl_tree[t.IDtable]",self.sl_tree[t.IDtable])
		if self.sl_tree[t.IDtable] then
			print("display_",t.IDtable[2],self.sl_tree:getNodeDisplay (t.IDtable))
------------根据输出值确定是否开灯
			if self.sl_tree:getNodeDisplay (t.IDtable) then
				self.slceboard.msh:getSubMesh(lights[i]).blender = exp.Yellowshade
			else
				self.slceboard.msh:getSubMesh(lights[i]).blender = nil
			end
		end
	end
end

function exp.sm.LinkState:LeftMouseDown(o,x,y)
	local point = exp.scene:pick(_rd:buildRay(x,y))
--------点击后置需要把focus的mesh置为nil
	exp.focus.blender = nil
    exp.focus = nil
	if 	SLCE.linestate == 1 then
		SLCE.temp_start_point = _Vector3.new(point.x,point.y,point.z)
		SLCE.temp_start_mesh = o
		SLCE.linestate = 2
--------颜色变化，input_port灭，output_port亮
		SLCE:ifLighting(false,true)	

	elseif SLCE.linestate == 2 then 
		SLCE.temp_end_point = _Vector3.new(point.x,point.y,point.z)
		-- slce.temp_end_mesh = o
		SLCE.linkedLines[#SLCE.linkedLines+1] = {}

--------start_mesh 和 end_mesh 用于获得mesh对象的id，以便updatedata的时候遍历连接关系通过id索引进行数据更新
		-- slce.linkedLines[#slce.linkedLines].start_mesh = slce.temp_start_mesh
		-- slce.linkedLines[#slce.linkedLines].end_mesh = o
		SLCE.linkedLines[#SLCE.linkedLines].start_point = SLCE.temp_start_point
		SLCE.linkedLines[#SLCE.linkedLines].end_point = SLCE.temp_end_point

--------保证每个与非门输入端只能接入一个输入源
		if not SLCE.inputIndex[o.parent.msh][o].unique then
			SLCE.inputIndex[o.parent.msh][o].unique = true
		end
 	
		SLCE.sl_tree:creatConnection(1,SLCE.inputIndex[o.parent.msh][o].IDtable,SLCE.outputIndex[SLCE.temp_start_mesh.parent.msh][SLCE.temp_start_mesh].IDtable)	

-- ---------当芯片放置在场景中，与非门的输出端口和显示灯将被刷新数据

-- 		if slce.cc4011.state then
-- 			slce:updateData()
-- 		end

		SLCE.linestate = 1
		-- exp.smstateTransition(linkFinished) 
--------颜色变化，input_port灭，output_port灭
		SLCE:ifLighting(true,false)
		-- slceifLighting(false,false)

--------因为两点间不能连接直线，因此需要确定第三点，以折线方式连接
		-- link[#link+1] = {start_point,slceturningPoint(start_point,end_point),end_point}
	end
end
local function linkfinished( ... )
	exp.sm:stateTransition("linkFinished") 
----颜色变化，input_port灭，output_port灭
	SLCE:ifLighting(false,false)
	SLCE.lineState = 0 
end

function exp.sm.LinkState:RightMouseDown(o)
	if _sys:isKeyDown(_System.KeyAlt) then
		-- !!linkfinished()
		ui.finish.click(self)	
	end
end

function ui.model.simulation.click(self)
	print("开始仿真")
----仿真前，需将logic_num初始化，同时更新输出端口值
	local tmsh = SLCE.slceboard.msh
	local logic_socket = SLCE.slceboard.config.key.logic_switch_socket
	local pulse_socket = SLCE.slceboard.config.key.single_pulse_socket
	----更新之前，需将所有节点logic_num值释放
	SLCE.sl_tree:numInit()
----逻辑开关值重置
	for i=1,#logic_socket do
		local table_index = SLCE.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[i])].IDtable
		SLCE.sl_tree[table_index].logic_num = SLCE.slceboard.output[i]
		SLCE.sl_tree[table_index].ifUnEvaluation = false
		-- print("qqq",table_index[2],SLCE.sl_tree[table_index].logic_num)
	end
----脉冲开关值重置
	for i=1,#pulse_socket do
		local table_index = SLCE.outputIndex[tmsh][tmsh:getSubMesh(pulse_socket[i])].IDtable
		SLCE.sl_tree[table_index].logic_num = SLCE.slceboard.output_pulse[i]
		SLCE.sl_tree[table_index].ifUnEvaluation = false
	end
---------当芯片放置在场景中，与非门的输出端口和显示灯将被刷新数据
	-- if slce.cc4011.state then
	SLCE:updateData()
	ui.chart1.show = true
	ui.chart2.show = true
	ui.chart3.show = true
	ui.chart4.show = true
	ui.chart5.show = true
	-- end
end

function ui.model.deleteLink.click(self)
--------清除所有线路连接,灭灯,显示初始化
	SLCE:ifLighting(false,false)

	local lights = SLCE.slceboard.config.key.display.output_lighting
	for i =1,#lights do
		SLCE.slceboard.msh:getSubMesh(lights[i]).blender = nil
	end

	SLCE.linestate = 0
	SLCE.linkedLines = nil
	SLCE.linkedLines = { }
-- --------逻辑初始化
-- ----删除unique标示
	for k1,v1 in pairs(SLCE.inputIndex) do
		for k2,v2 in pairs(SLCE.inputIndex[k1]) do
			local t = SLCE.inputIndex[k1][k2]
			if t.unique then
				t.unique = nil
			end
		end
	end
----时序逻辑树的重置
	local logic_socket = SLCE.slceboard.config.key.logic_switch_socket
	local light_socket = SLCE.slceboard.config.key.output_socket
	local socket1 = SLCE.slceboard.config.key.socket_1
	local socket2 = SLCE.slceboard.config.key.socket_2
	local socket4 = SLCE.slceboard.config.key.socket_4
	local socket5 = SLCE.slceboard.config.key.socket_5
	local tmsh = SLCE.slceboard.msh

-- 	slce.sl_tree = nil
-- 	slce.sl_tree = SequentialLogicTree:new()
-- ------初始化，将所用芯片的所有与非门的输入端口和输出端口连接起来，因为经过与非门，所以isDirectConnection置为false
-- 	slce.cc4011:loadConnection(slce,slce.slceboard,socket1)
-- 	slce.cc4012:loadConnection(slce,slce.slceboard,socket2)

-- 	slce.sl_tree:IDtable2Node( slce.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[1])].IDtable )
-- 	slce.sl_tree:IDtable2Node( slce.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[2])].IDtable )
-- 	slce.sl_tree:IDtable2Node( slce.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[3])].IDtable )
-- 	slce.sl_tree:IDtable2Node( slce.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[4])].IDtable )

-- -- 	------设置输入源初始值
-- 	for i=1,#logic_socket do
-- 		slce.sl_tree[slce.outputIndex[tmsh][tmsh:getSubMesh(logic_socket[i])].IDtable].logic_num = slce.slceboard.output[i]
-- 	end

----逻辑值置为nil
	SLCE.sl_tree:numInit()

	for i=1,#socket1 do
		if SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket1[i])] then
			SLCE.sl_tree:destroyConnection( SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket1[i])].IDtable )
		end

		if SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket2[i])] then
			SLCE.sl_tree:destroyConnection( SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket2[i])].IDtable )
		end
	end

	for i=1,#socket4 do
		if SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket4[i])] then
			SLCE.sl_tree:destroyConnection( SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket4[i])].IDtable )
		end

		if SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket5[i])] then
			SLCE.sl_tree:destroyConnection( SLCE.inputIndex[tmsh][tmsh:getSubMesh(socket5[i])].IDtable )
		end
	end

	for i=1,#light_socket do
		if SLCE.inputIndex[tmsh][tmsh:getSubMesh(light_socket[i])] then
			SLCE.sl_tree:destroyConnection( SLCE.inputIndex[tmsh][tmsh:getSubMesh(light_socket[i])].IDtable )
		end
	end
end

function SLCE.cc4013:place()
	print("SLCE.cc4013:place")
	Object.place(self)
	local socket1 = SLCE.slceboard.config.key.socket_1
	ChipInit { chip = self, load_or_delete = true, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket1 }
end

function SLCE.cc4013:unplace()
	print("SLCE.cc4013:unplace")
	Object.unplace(self)
	local socket1 = SLCE.slceboard.config.key.socket_1
	ChipInit { chip = self, load_or_delete = false, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket1 }
end

function SLCE.cc4013_2:place()
	print("SLCE.cc4013_2:place")
	Object.place(self)
	local socket2 = SLCE.slceboard.config.key.socket_2
	ChipInit { chip = self, load_or_delete = true, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket2 }
end

function SLCE.cc4013_2:unplace()
	print("SLCE.cc4013_2:unplace")
	Object.unplace(self)
	local socket2 = SLCE.slceboard.config.key.socket_2
	ChipInit { chip = self, load_or_delete = false, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket2 }
end

function SLCE.cc4027:place()
	print("SLCE.cc4027:place")
	Object.place(self)
	local socket4 = SLCE.slceboard.config.key.socket_4
	ChipInit { chip = self, load_or_delete = true, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket4 }
end

function SLCE.cc4027:unplace()
	print("SLCE.cc4027:unplace")
	Object.unplace(self)
	local socket4 = SLCE.slceboard.config.key.socket_4
	ChipInit { chip = self, load_or_delete = false, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket4 }
end

function SLCE.cc4027_2:place()
	print("SLCE.cc4027_2:place")
	Object.place(self)
	local socket5 = SLCE.slceboard.config.key.socket_5
	ChipInit { chip = self, load_or_delete = true, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket5 }
end

function SLCE.cc4027_2:unplace()
	print("SLCE.cc4027_2:unplace")
	Object.unplace(self)
	local socket5 = SLCE.slceboard.config.key.socket_5
	ChipInit { chip = self, load_or_delete = false, experiment = SLCE,main_socket = SLCE.slceboard,sub_socket = socket5 }
end

function SequentialLogicTree:existFeedback()
	ui.model.deleteLink.click(self)
end
-------test
	-- slce.cc4011:place()
	-- slce.cc4012:place()


function ui.model.Line.but.click(self)
	linkfinished()
	exp.sm:stateTransition("ClickLinkbtn") 
	-- exp.choice.class = classID.Line
	SLCE.linestate = 1
	----颜色变化，input_port亮，output_port灭
	SLCE:ifLighting(true,false)
end

function ui.model.I.i1.click(self)
	linkfinished()
	exp.sm:stateTransition("ClickC/Ibtn") 
	exp.choice  = _Mesh.new('cc4013.skn')
	exp.choice.class = classID.cc4013
	exp.choice:enumMesh( '', true, function(m)  m.blender = twinkle end )
	exp:placed(exp.choice.class)
end

function ui.model.u.u1.click(self)
	linkfinished()
	exp.sm:stateTransition("ClickC/Ibtn") 
	exp.choice  = _Mesh.new('cc4027.skn')
	exp.choice.class = classID.cc4027
	exp.choice:enumMesh( '', true, function(m) m.blender = twinkle end )
	exp:placed(exp.choice.class)
end

function ui.model.R.r1.click(self)
	linkfinished()
	exp.sm:stateTransition("ClickC/Ibtn") 
	exp.choice  = _Mesh.new('cc4012.skn')
	exp.choice.class = classID.cc4012
	exp.choice:enumMesh( '', true, function(m)  m.blender = twinkle end )
	exp:placed(exp.choice.class)
end

local function visualAngleInit()
	_rd.camera.eye = _Vector3.new(0,-5,35)
	_rd.camera.look = _Vector3.new(0,0,10)
	_rd.camera.up = _Vector3.new(0,0,1)
	_rd.camera.radiusMax = 45
	_rd.camera.radiusMin = 10
end

function ui.finish.click(self)
------视角限制复位
	visualAngleInit()
	linkfinished()
	exp.sm:stateTransition("ClickCmplBtn") 
	ui.finish.show = false
	exp.set_one = nil 
	-- _G.CamFlag = true
	-- ui.setR.show = false
end
function ui.Model.modelClose.click(self)
	ui.modelOpen.show = true
	ui.Model.show = false
end

function ui.modelOpen.click(self)
	ui.modelOpen.show = false
	ui.Model.show = true

end

local Flag = true
function ui.dl.click(self)
	if ui.mapjk.show then
		ui.moveDiff(ui.Map.JK,0,150)
		ui.Map.RS.show = true
		ui.Map.D.show = true

	elseif ui.mapd.show then
		ui.moveDiff(ui.Map.D,0,110)
		ui.Map.RS.show = true
		ui.Map.JK.show = true
	elseif ui.maprs.show then
		ui.moveDiff(ui.Map.RS,0,70)
		ui.moveDiff(ui.dl,-150,0)
		ui.Map.D.show = true
		ui.Map.JK.show = true
	end
	ui.mapjk.show = false
	ui.mapd.show = false
	ui.maprs.show = false
	ui.dl.show = false
	Flag = true

end

function ui.Map.JK.click(self)
	ui.mapjk.show = true
	ui.dl.show = true
	if Flag then
		ui.moveDiff(ui.Map.JK,0,-150)
	end
	ui.Map.RS.show = false
	ui.Map.D.show = false
	Flag = false
end
function ui.Map.D.click(self)
	ui.mapd.show = true
	ui.dl.show = true
	if Flag then
		ui.moveDiff(ui.Map.D,0,-110)
	end
	ui.Map.RS.show = false
	ui.Map.JK.show = false
	Flag = false
end
function ui.Map.RS.click(self)
	ui.maprs.show = true
	ui.dl.show = true
	if Flag then
		ui.moveDiff(ui.Map.RS,0,-70)
		ui.moveDiff(ui.dl,-150,0)
	end
	ui.Map.D.show = false
	ui.Map.JK.show = false
	Flag = false
end

function ui.chart1.click(self)
	ui.submit1.show = true
	ui.chart1.show = false
	ui.moveDiff(ui.chart5,0,-130)
	ui.moveDiff(ui.submit5,0,-130)
	ui.moveDiff(ui.chart2,0,-130)
	ui.moveDiff(ui.submit2,0,-130)
	ui.moveDiff(ui.chart3,0,-130)
	ui.moveDiff(ui.submit3,0,-130)
	ui.moveDiff(ui.chart4,0,-130)
	ui.moveDiff(ui.submit4,0,-130)
	ui.Model.show = false
	ui.modelOpen.show = true
end
function ui.submit1.close.click(self)
	ui.submit1.show =false
	ui.chart1.show = true
	ui.moveDiff(ui.chart5,0,130)
	ui.moveDiff(ui.submit5,0,130)
	ui.moveDiff(ui.chart2,0,130)
	ui.moveDiff(ui.submit2,0,130)
	ui.moveDiff(ui.chart3,0,130)
	ui.moveDiff(ui.submit3,0,130)
	ui.moveDiff(ui.chart4,0,130)
	ui.moveDiff(ui.submit4,0,130)
end
function ui.chart5.click(self)
	ui.submit5.show = true
	ui.chart5.show = false
	ui.moveDiff(ui.chart2,0,-130)
	ui.moveDiff(ui.submit2,0,-130)
	ui.moveDiff(ui.chart3,0,-130)
	ui.moveDiff(ui.submit3,0,-130)
	ui.moveDiff(ui.chart4,0,-130)
	ui.moveDiff(ui.submit4,0,-130)
	ui.Model.show = false
	ui.modelOpen.show = true
end
function ui.submit5.close.click(self)
	ui.submit5.show =false
	ui.chart5.show = true
	ui.moveDiff(ui.chart2,0,130)
	ui.moveDiff(ui.submit2,0,130)
	ui.moveDiff(ui.chart3,0,130)
	ui.moveDiff(ui.submit3,0,130)
	ui.moveDiff(ui.chart4,0,130)
	ui.moveDiff(ui.submit4,0,130)
end
function ui.chart2.click(self)
	ui.submit2.show = true
	ui.chart2.show = false
	ui.moveDiff(ui.chart3,0,-130)
	ui.moveDiff(ui.submit3,0,-130)
	ui.moveDiff(ui.chart4,0,-130)
	ui.moveDiff(ui.submit4,0,-130)
	ui.Model.show = false
	ui.modelOpen.show = true
end
function ui.submit2.close.click(self)
	ui.submit2.show =false
	ui.chart2.show = true
	ui.moveDiff(ui.chart3,0,130)
	ui.moveDiff(ui.submit3,0,130)
	ui.moveDiff(ui.chart4,0,130)
	ui.moveDiff(ui.submit4,0,130)
end
function ui.chart3.click(self)
	ui.submit3.show = true
	ui.chart3.show = false
	ui.moveDiff(ui.chart4,0,-230)
	ui.moveDiff(ui.submit4,0,-230)
	ui.Model.show = false
	ui.modelOpen.show = true
end
function ui.submit3.close.click(self)
	ui.submit3.show =false
	ui.chart3.show = true
	ui.moveDiff(ui.chart4,0,230)
	ui.moveDiff(ui.submit4,0,230)
end
function ui.chart4.click(self)
	ui.submit4.show = true
	ui.chart4.show = false

	ui.Model.show = false
	ui.modelOpen.show = true
end
function ui.submit4.close.click(self)
	ui.submit4.show =false
	ui.chart4.show = true

end

---------画出波形
when{}
function render(e)
	for i=1,#SLCE.linkedLines do
		if SLCE.linkedLines[i] and SLCE.linkedLines[i].start_point and SLCE.linkedLines[i].end_point then
			local s = SLCE.linkedLines[i].start_point
			local e = SLCE.linkedLines[i].end_point 
			_rd:draw3DLine(s.x, s.y, s.z, e.x, e.y, e.z, _Color.Red)
		end
	end
end
