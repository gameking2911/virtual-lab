local config = {


			key={

				} ,

			NANDgates={
			[1]={input={1,2},output={3},},
			[2]={input={5,6},output={4},},
			[3]={input={8,9},output={10},},
			[4]={input={12,13},output={11},},
				},
			msh=
				{
				[1]='cc4011.skn'
				}
			}

local cc4011 = Chip:extend()

function cc4011:init( ... )
	Equip.init(self)
	self.portsnum = 14
	self.config = config
	self.WorkinglinkedNum = 0
	self.ports_state = {}
	for i=1,self.portsnum do
		self.ports_state[i] = false
	end
end

---写在clce，使用事件驱动来做
-- function cc4011:place( experiment,main_socket,sub_socket )
-- 	Object.place(self)
-- 	self:loadNodes ( experiment,main_socket,sub_socket )
-- end

-- when{}
-- function ChipInit ( load_or_delete,experiment ,main_socket ,sub_socket )
-- 	if load_or_delete then
-- 		cc4011:loadNodes ( experiment,main_socket,sub_socket )
-- 	else
-- 		cc4011:deleteNodes ( experiment,main_socket,sub_socket )
-- 	end
-- end

-----将芯片电路节点和连接关系加载到对应试验中
function cc4011:loadConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh

	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[3])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[3])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[2])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[4])].IDtable,
							  	  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[5])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[4])].IDtable,
							      experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[6])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[10])].IDtable,
							      experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[8])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[10])].IDtable,
							      experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[9])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[11])].IDtable,
							      experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[12])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[11])].IDtable,
							      experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable )	
end

function cc4011:deleteConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh
	for i=1,self.portsnum do
		-- experiment.cl_tree:destroyConnection( 2,experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		if experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])] then
			experiment.cl_tree:destroyConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		end
	end
end

_G.cc4011 = cc4011
