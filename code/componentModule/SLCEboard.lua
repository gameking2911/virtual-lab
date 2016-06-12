local config = {

			key={
				control=
				{
				-- logic_switch = {8,41,45,49,},
				-- single_pulse = {8,9},
				-- logic_switch = {8,41,},
				-- single_pulse = {45,49,},
				logic_switch = {8,100,104,108,112,116,120,124,},
				single_pulse = {165,},
				-- single_pulse = 180,
-- --------------代表孔11,10,3,4
-- 				output_level = {
-- 				[1] = {73,74,67,68,},
-- 				[2] = {73,74,67,68,},
-- 				},

				},

				-- logic_switch_socket = {39,42,46,50,},
				-- single_pulse_socket = {8,9},
				-- logic_switch_socket = {39,42,},
				-- single_pulse_socket = {46,50,},
				logic_switch_socket = {9,101,105,109,113,117,121,125},
				single_pulse_socket = {166,167,},
----------------14孔插座3个
				-- socket_1 = {65,66,67,68,69,70,71,78,75,74,73,72,76,77},
				-- socket_2 = {79,80,81,82,83,84,85,86,87,88,89,90,91,92},
				socket_1 = {13,14,15,16,17,18,19,26,23,22,21,20,24,25,},
				socket_2 = {42,43,44,45,46,47,48,50,69,66,67,68,70,49},	
				socket_3 = {71,72,73,74,75,76,77,79,98,95,96,97,99,78},	
----------------16孔插座2个
				socket_4 = {201,202,203,204,205,206,207,208,210,214,216,215,211,212,213,209},	
				socket_5 = {185,186,187,188,189,190,191,192,200,193,194,195,196,197,198,199},			
				-- socket_3 = {65,66,67,68,69,70,71,78,75,74,73,72,76,77},
				-- socket_4 = {79,80,81,82,83,84,85,86,87,88,89,90,91,92},
				-- socket_5 = {65,66,67,68,69,70,71,78,75,74,73,72,76,77},
----------------输出端口插座
				-- output_socket = {64,61,58,54,},
				output_socket = {12,129,132,135,138,141,144,147},
				display=
				{
				switch_lighting = {10,102,106,110,114,118,122,126},
				output_lighting = {217,130,133,136,139,142,145,148},

				},

				} ,

			msh=
				{
				[1]='SLCEboard.skn'
				}
			}

local SLCEboard = Equip:extend()

function SLCEboard:init( ... )
	Equip.init(self)
	self.state = "1"
----单次脉冲,一个高电平跳变，一个低电平跳变
	self.output_pulse = {}
	self.output_pulse[1] = false
	self.output_pulse[2] = true

----4个输出端口
	self.output = {}
	self.output[1] = false
	self.output[2] = false
	-- self.output[3] = false
	-- self.output[4] = false
----定时器
	self.timer = _Timer.new()
	-- self.timer:start('↑trigger', 3000, hop)
	-- self.timer:start('↓trigger', 3000, hop)
	-- self.timer:pause('↑trigger')
	-- self.timer:pause('↓trigger')

	self.config = config
end

function SLCEboard:isIntersected(msh)
		-- print("msh.id",msh.ID)
	local t1 = self.config.key.control.logic_switch
	local t2 = self.config.key.control.single_pulse
	for i=1,#t1 do
		if( msh == self.msh:getSubMesh(t1[i]) ) then
			return msh
		end
 	end
 	for i=1,#t2 do
		if( msh == self.msh:getSubMesh(t2[i]) ) then
			return msh
		end
 	end
end

function SLCEboard:onClick(subMeshID)
	local t1 = self.config.key.control.logic_switch
	local t2 = self.config.key.control.single_pulse
	local t3 = self.config.key.display.switch_lighting

	for i=1,#t2 do
		if(subMeshID == t2[1]) then
			self.output_pulse[1] = "↑"
------------注意，一段时间后将返回原状态
			local function hop1()
				print("pause1")
				self.timer:pause('↑trigger')
				self.output_pulse[1] = false
			end
			self.timer:start('↑trigger', 1000, hop1)

			self.output_pulse[2] = "↓"	
------------注意，一段时间后将返回原状态
			local function hop2()
				print("pause2")
				self.timer:pause('↓trigger')
				self.output_pulse[2] = true
			end
			self.timer:start('↓trigger', 1000, hop2)
			break
-- 		elseif(subMeshID == t2[2]) then
-- 			self.output_pulse[2] = "↓"	
-- ------------注意，一段时间后将返回原状态
-- 			local function hop()
-- 				self.timer:pause('↓trigger')
-- 				self.output_pulse[2] = true
-- 			end
-- 			self.timer:start('↓trigger', 1000, hop)
-- 			break
		end
	end

	for i=1,#t1 do
		if( subMeshID == t1[i] ) then
			self.output[i] = not self.output[i]
------------根据输出值确定是否开灯
			if self.output[i] then
				self.msh:getSubMesh(t3[i]).blender = exp.Yellowshade
			else
				self.msh:getSubMesh(t3[i]).blender = nil
			end

			print(subMeshID,self.output[i])
			break
		end
	end

end

function SLCEboard:settings()
------设置状态限制视角				
-- _rd.camera.radiusMax = 10
-- _rd.camera.radiusMin = 5
	local up = _Vector3.new(0,1,0)			
	_rd.camera.look:set(self.position) 
	local mz = 8			
	_rd.camera.up = up
	 _Vector3.add( _rd.camera.look , _Vector3.new( 0 , 0 , mz ) , _rd.camera.eye )
end

function SLCEboard:unplace()
	print("电路板不能取下!")
end

function SLCEboard:load(envir,index)
	Equip.load(self,envir,index)
end

_G.SLCEboard = SLCEboard

