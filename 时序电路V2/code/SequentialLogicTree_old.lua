local SequentialLogicTree = {}

function SequentialLogicTree:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
----初始化，维护一个链栈
	o.stack = listStack:new()
    return o;  
end



--------IDTable 格式 {父meshID，子meshID}
function SequentialLogicTree:IDtable2Node( IDtable )
	-- if not IDtable then
	-- 	return
	-- end
----Q与Q非相当于连接了一个not电路
	if not self[IDtable] then
		self[IDtable] = {
--------ifUnEvaluation表示此点是否已经计算赋值	
--------逻辑初值为0
		logic_num = 0,	
		ifUnEvaluation = true,
		subNodes = {

		{ name = "directConnection" ,alg = 
		-- function (a,b) return (a or b) end, 
		function (input_ports) return input_ports[1] end, 
		},

		{ name = "NOTgate" ,alg = 
		-- function (a,b) return (a or b) end, 
		function (input_ports) return not input_ports[1] end, 
		},

		{ name = "JKtrigger" ,
		alg = 
		-- function (a,b) return (a or b) end, 
		function (S,R,CP,J,K) 




		end, 


		},
		{ name = "Dtrigger" , 
		-- Q = 0, 
		-- S = {},R = {},CP = {},D = {}

-- Q = 0为初始值,
		alg = 
		-- function (a,b) return (a and b) end,NOT = true,
		function (input_ports) 
		-- local s = self:getNodeDisplay(input_ports.S)
		-- local r = self:getNodeDisplay(input_ports.R)
		-- local cp = self:getNodeDisplay(input_ports.CP)
		-- local d = self:getNodeDisplay(input_ports.D)
			local Q = 0
			local s = self:getNodeDisplay(input_ports[1])
			local r = self:getNodeDisplay(input_ports[2])
			local cp = self:getNodeDisplay(input_ports[3],true)
			local d = self:getNodeDisplay(input_ports[4])

			if s == 0 and r == 1 then
				Q = 0
			elseif s == 1 and r == 0 then
				Q = 1			
			elseif s == 1 and r == 1 then
				print("不稳定态")
			elseif s == 0 and r == 0 then
				if cp == "↑" then
					Q = d
				end
			end
			return Q
		end, 



		 },

					},
		 	}
	end
	return self[IDtable]
end

-- function SequentialLogicTree:creatTree( isDirectConnection,from_Pid,from_Sid,to_Pid,to_Sid )
function SequentialLogicTree:creatConnection( connected_relation,from_table,to_table )
	local from = self:IDtable2Node(from_table) 
	local to = self:IDtable2Node(to_table) 
	from.subNodes[connected_relation][#from.subNodes[connected_relation]+1] = to_table
	return self
end

function SequentialLogicTree:destroyConnection( connected_relation,IDtable )
	if self[IDtable] then
		local t = self[IDtable].subNodes[connected_relation]
		for i=1,#t do
			t[i] = nil
		end
	end
end

function SequentialLogicTree:numInit( )
	for k,v in pairs(self) do
		-- if self[k].logic_num~=nil then
		-- 	self[k].logic_num = nil
		-- end
		self[k].logic_num = 0
	end
end

--------回调函数，当组合逻辑电路拥有反馈环时调用
function SequentialLogicTree:existFeedback()
end


------根据生成的组合逻辑树计算相应节点的显示值,采用多叉树的深度优先遍历，当值已经存在时，不再向下遍历（剪枝，提高效率）
function SequentialLogicTree:getNodeDisplay( IDtable,triger_type,ifDetermine_risingEdge )
----
	-- local type_directConnection = 1
----遍历栈，看此点是否在栈中存在,若存在，即存在反馈环，无法计算，报错，否则将此点加入栈
	if self.stack:ifexist( IDtable ) then
		print("电路存在反馈环，无法计算，请重新连接电路！")
		self.existFeedback()
		return
	end

	if  self[IDtable].ifUnEvaluation then
		local display 
		-- local length_connection = 0

		local input_ports = self[IDtable].subNodes[triger_type]

		display = self[IDtable].subNodes[triger_type].alg(input_ports)

		if display == nil then
			display = false	
		end

		if self[IDtable].ifUnEvaluation then

			if ifDetermine_risingEdge then
				local Q = self[IDtable].logic_num
				local newQ = display
				if Q == 0 and newQ == 1 then
					print("上升沿")
					self[IDtable].logic_num = "↑"
				elseif Q == 1 and newQ == 0 then
					print("下降沿")
					self[IDtable].logic_num = "↓"
				end
			else
				self[IDtable].logic_num = display
			end
			-- self[IDtable].logic_num = display
			self[IDtable].ifUnEvaluation = false

		end			
	end

----弹出栈顶点
	self.stack:pop( IDtable )
	print("self[IDtable].logic_num",IDtable[1],IDtable[2],self[IDtable].logic_num)

	return self[IDtable].logic_num
end

_G.SequentialLogicTree = SequentialLogicTree