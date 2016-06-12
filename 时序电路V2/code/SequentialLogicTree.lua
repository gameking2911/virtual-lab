local SequentialLogicTree = {}

function SequentialLogicTree:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self;  
----初始化，维护一个链栈
	o.stack = listStack:new()

	-- o.directConnection = 1
	-- o.NOTgate = 2
	-- o.JKtrigger = 3
	-- o.Dtrigger = 4

    return o;  
end


------根据生成的组合逻辑树计算相应节点的显示值,采用多叉树的深度优先遍历，当值已经存在时，不再向下遍历（剪枝，提高效率）
function SequentialLogicTree:getNodeDisplay( IDtable,ifDetermine_risingEdge )
----
	-- local type_directConnection = 1
----遍历栈，看此点是否在栈中存在,若存在，即存在反馈环，无法计算，报错，否则将此点加入栈
	if self.stack:ifexist( IDtable ) then
		print("电路存在反馈环，无法计算，请重新连接电路！")
		self.existFeedback()
		return
	else
		self.stack:push( IDtable )
	end

	if  self[IDtable].ifUnEvaluation then
		local display 
		-- local length_connection = 0

		local input_ports = self[IDtable].subNodes
		if self[IDtable].subNodes then
			display = self[IDtable].subNodes.alg(input_ports,self[IDtable])
			-- print("IDtable[2]",self[IDtable].subNodes.name,IDtable[2])
			-- print("display",IDtable[2],self[IDtable].subNodes.name,display,#input_ports)
		end
		if display == nil then
			display = false	
		end

		-- print("type(display)",type(display))
		-- if ifDetermine_risingEdge then
		if  ifDetermine_risingEdge and type(display)=="boolean" then
			local Q = self[IDtable].logic_num
			local newQ = display
			-- print("oldq,newq",Q,newQ,self[IDtable].subNodes.name,IDtable[2])
			if Q == false and newQ == true then
				print("上升沿")
				self[IDtable].logic_num = "↑"
			elseif Q == true and newQ == false then
				print("下降沿")
				self[IDtable].logic_num = "↓"
			-- else
			-- 	self[IDtable].logic_num = newQ
			end
		else
			self[IDtable].logic_num = display
		end
		-- self[IDtable].logic_num = display
		self[IDtable].ifUnEvaluation = false


	end

----弹出栈顶点
	self.stack:pop( IDtable )
	-- print("logic_num",IDtable[1],IDtable[2],self[IDtable].logic_num)

	return self[IDtable].logic_num
end

function SequentialLogicTree:getConnected_information( connected_relation )
	if connected_relation == 1 then
		return 		{ name = "directConnection" ,id = 1,alg = 
					function (input_ports) return self:getNodeDisplay(input_ports[1]) end, 
					}

	elseif connected_relation == 2 then
		return 		{ name = "NOTgate" ,type = "sequential" ,id = 2,alg = 
					function (input_ports)  
						-- local s = self:getNodeDisplay(input_ports[1])
						-- print("q,notq",s,not s)
						return not self:getNodeDisplay(input_ports[1]) end, 
					}

	elseif connected_relation == 3 then
		return		{ name = "JKtrigger" ,type = "sequential" ,id = 3,alg = 
--S,R,CP,J,K
					function (input_ports,node) 
						-- print("old_num",node.logic_num)
						local Q = false
						local s = self:getNodeDisplay(input_ports[1])
						local r = self:getNodeDisplay(input_ports[2])
						local cp = self:getNodeDisplay(input_ports[3],true)
						local j = self:getNodeDisplay(input_ports[4])
						local k = self:getNodeDisplay(input_ports[5])

						-- if type(s)~="boolean" or type(r)~="boolean" or type(j)~="boolean" or type(k)~="boolean" then
						-- 	print("单次脉冲不要接入非cp端")
						-- end

						if s==false and r == true then
							Q = false
						elseif s == true and r == false then
							Q = true			
						elseif s == true and r == true then
							print("不稳定态")
						elseif s == false and r == false then
							if cp == "↑" then
-- j,k接单次脉冲情况		
							print(cp,node.logic_num,Q)
								-- if node.logic_num == "↑" then
								-- 	node.logic_num = true
								-- elseif node.logic_num == "↓" then
								-- 	node.logic_num = false
								-- end
								Q = (j and (not node.logic_num) ) or ( (not k) and node.logic_num )
							else
								Q = node.logic_num
							end
						end
						print("Q,s,r,cp,j,k",Q,s,r,cp,j,k)
						return Q
					end, 
					}

	elseif connected_relation == 4 then
		return 		{ name = "Dtrigger" ,type = "sequential" , id = 4,
-- Q = 0为初始值,input_ports顺序s，r，cp，d
					alg = 
					function (input_ports,node) 
						print("old_num",node.logic_num)
						local Q = false
						local s = self:getNodeDisplay(input_ports[1])
						local r = self:getNodeDisplay(input_ports[2])
						local cp = self:getNodeDisplay(input_ports[3],true)
						local d = self:getNodeDisplay(input_ports[4])

						if s==false and r == true then
							Q = false
						elseif s == true and r == false then
							Q = true			
						elseif s == true and r == true then
							print("不稳定态")
						elseif s == false and r == false then
							if cp == "↑" then
------d接单次脉冲情况
								-- if d == "↑" then
								-- 	d = true
								-- elseif d == "↓" then
								-- 	d = false
								-- end

								Q = d
							else
								Q = node.logic_num
							end
						end
						print("Q,s,r,cp,d",Q,s,r,cp,d)
						return Q
					end, 

					 }
	else
		return {name = "unConnection", id = -1, alg = function ( input_ports )
				return false
				end,}
	end
end

--------IDTable 格式 {父meshID，子meshID}
function SequentialLogicTree:IDtable2Node( IDtable,connected_relation )

	-- if not IDtable then
	-- 	return
	-- end
----Q与Q非相当于连接了一个not电路
	if not self[IDtable] then
		-- self[IDtable] = nil
		self[IDtable] = {
--------ifUnEvaluation表示此点是否已经计算赋值	
--------逻辑初值为false
		logic_num = false,	
		ifUnEvaluation = true,

		-- subNodes = self:getConnected_information( connected_relation )
		 	}
	end
	-- self[IDtable].subNodes = nil
	-- if self[IDtable].subNodes and self[IDtable].subNodes.id == connected_relation then
	if connected_relation and not self[IDtable].subNodes then
	-- else
		self[IDtable].subNodes = self:getConnected_information( connected_relation )
		-- print("connected_relation",IDtable[2],connected_relation)
	end
	return self[IDtable]
end

-- function SequentialLogicTree:creatTree( isDirectConnection,from_Pid,from_Sid,to_Pid,to_Sid )
function SequentialLogicTree:creatConnection( connected_relation,from_table,to_table )
	-- print("connected_relation",connected_relation)
	local from = self:IDtable2Node(from_table,connected_relation) 
	local to = self:IDtable2Node(to_table) 
	-- from.subNodes[connected_relation][#from.subNodes[connected_relation]+1] = to_table
	from.subNodes[#from.subNodes+1] = to_table
	-- print("~~~~~~~~~~~",from_table[2],connected_relation,from.subNodes,#from.subNodes)

	return self
end

-- function SequentialLogicTree:destroyConnection( connected_relation,IDtable )
function SequentialLogicTree:destroyConnection( IDtable )
	if self[IDtable] then
		-- local t = self[IDtable].subNodes[connected_relation]
		-- self[IDtable].subNodes = self:getConnected_information( -1 )
		self[IDtable].subNodes = nil
		-- local t = self[IDtable].subNodes
		-- for i=1,#t do
		-- 	t[i] = nil
		-- end
	end
end

function SequentialLogicTree:numInit( )
	for k,v in pairs(self) do
--------注意，除非芯片取下来，具备记忆功能的输出的节点值都要保留下来（时序电路芯片具备储存值的功能）
		self[k].ifUnEvaluation = true

		if self[k].logic_num == "↑" then
			self[k].logic_num = true
		elseif self[k].logic_num == "↓" then
			self[k].logic_num = false
		end

		-- if self[k].subNodes and self[k].subNodes.type ~= "sequential"  then
		-- 	self[k].logic_num = false
		-- end
	end
end

--------回调函数，当组合逻辑电路拥有反馈环时调用
function SequentialLogicTree:existFeedback()
end



_G.SequentialLogicTree = SequentialLogicTree