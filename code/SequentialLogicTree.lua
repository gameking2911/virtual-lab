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

function SequentialLogicTree:specialFeedback( )
	if( self.stack:getOffsetSameNode() == 4 ) then
-- 判定此节点为与非门中的节点
		-- local t_table = self.stack:find()
		-- local socket3 = self.slceboard.config.key.socket_3
		print("RS")
		return "RS"
	end	
end

------根据生成的组合逻辑树计算相应节点的显示值,采用多叉树的深度优先遍历，当值已经存在时，不再向下遍历（剪枝，提高效率）
------根据生成的组合逻辑树计算相应节点的显示值,采用多叉树的深度优先遍历，当值已经存在时，不再向下遍历（剪枝，提高效率）
function SequentialLogicTree:getNodeDisplay( IDtable,ifDetermine_risingEdge )
----
	-- local type_directConnection = 1
----遍历栈，看此点是否在栈中存在,若存在，即存在反馈环，无法计算，报错，否则将此点加入栈
	if self.stack:ifexist( IDtable ) then
		local s = self:specialFeedback()
		if s then
			return s
		end
		-- if(self.stack:getOffsetSameNode() == 4 ) then
		-- 	print("RS")
		-- 	return "RS"
		-- end
		print("电路存在反馈环，无法计算，请重新连接电路！")
		self.existFeedback()
		return
	end
	-- else
		self.stack:push( IDtable )
	-- end
		local display 
	if  self[IDtable].ifUnEvaluation then
		-- local display 
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

		self[IDtable].ifUnEvaluation = false

		if  ifDetermine_risingEdge and type(display)=="boolean" then
			local Q = self[IDtable].logic_num
			local newQ = display
			-- print("oldq,newq",Q,newQ,self[IDtable].subNodes.name,IDtable[2])
			if Q == false and newQ == true then
				print("上升沿")
				display = "↑"
				self[IDtable].logic_num = display
			elseif Q == true and newQ == false then
				print("下降沿")
				display = "↓"
				self[IDtable].logic_num = display
			-- else
			-- 	self[IDtable].logic_num = newQ
			end

		elseif type(display) == "boolean" then
			self[IDtable].logic_num = display
		else
			self[IDtable].ifUnEvaluation = true
		end

		print("display,logic_num",IDtable[1],IDtable[2],display,self[IDtable].logic_num)


		-- self[IDtable].logic_num = display
		-- self[IDtable].ifUnEvaluation = false

	else
		display = self[IDtable].logic_num
	end

----弹出栈顶点
	self.stack:pop( IDtable )

	-- return self[IDtable].logic_num
	return display

end

function SequentialLogicTree:getConnected_information( connected_relation )
	if connected_relation == 1 then
		return 		{ name = "directConnection" ,alg = 
					function (input_ports) return self:getNodeDisplay(input_ports[1]) end, 
					}

	elseif connected_relation == 2 then
		return 		{ name = "NOTgate" ,alg = 
					function (input_ports)  
						-- local s = self:getNodeDisplay(input_ports[1])
						-- print("q,notq",s,not s)
						return not self:getNodeDisplay(input_ports[1]) end, 
					}

	elseif connected_relation == 3 then
		return		{ name = "JKtrigger" , alg = 
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
		return 		{ name = "Dtrigger" , 
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

	elseif connected_relation == 5 then
		return 		{ name = "NANDgate"  , 
					alg = 
					function ( input_ports,node )
						local S;
						local R;
						local i1 = self:getNodeDisplay(input_ports[1])
						local i2 = self:getNodeDisplay(input_ports[2])
						if(i1 == "RS" and i2 ~= "RS") then
							return {i2,i1}
						elseif(i2 == "RS" and i1~="RS" ) then
							return {i1,i2}
						elseif(type(i1) == "table" and i1[2]=="RS" and type(i2)=="boolean") then
							S = i2
							R = i1[1]

						elseif(type(i2) == "table" and i2[2]=="RS" and type(i1)=="boolean") then
							S = i1
							R = i2[1]

						elseif(type(i1)=="boolean" and type(i2)=="boolean") then
							return not (i1 and i2)
						else
							print("连接错误！", type(i1), type(i2))
							return false
						end
						if(S == false and R == true) then 
													print("S=0,R=1")

							return true 
						elseif(S == true and R == false) then 
							return false
						elseif(S == false and R == false) then 
							print("不稳定态") 
							return false
						elseif(S == true and R == true) then 
							return node.logic_num
						end

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

----Q与Q非相当于连接了一个not电路
	if not self[IDtable] then
		-- self[IDtable] = nil
		self[IDtable] = {
--------ifUnEvaluation表示此点是否已经计算赋值	
--------逻辑初值为false
		logic_num = false,	
		ifUnEvaluation = true,

		 	}
	end
	if connected_relation and not self[IDtable].subNodes then
		self[IDtable].subNodes = self:getConnected_information( connected_relation )
	end
	return self[IDtable]
end

function SequentialLogicTree:creatConnection( connected_relation,from_table,to_table )
	local from = self:IDtable2Node(from_table,connected_relation) 
	local to = self:IDtable2Node(to_table) 
	from.subNodes[#from.subNodes+1] = to_table
	return self
end

function SequentialLogicTree:destroyConnection( IDtable )
	if self[IDtable] then
		self[IDtable].subNodes = nil
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
	end
end

--------回调函数，当组合逻辑电路拥有反馈环时调用
function SequentialLogicTree:existFeedback()
end



_G.SequentialLogicTree = SequentialLogicTree