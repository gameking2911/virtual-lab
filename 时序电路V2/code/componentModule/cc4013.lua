local config = {


			key={

				} ,

			Dtriger={
			[1]={input={3,4,5,6,},output={1,2,},},
			[2]={input={8,9,10,11,},output={12,13,},},
					},
			msh=
				{
				[1]='cc4013.skn'
				}
			}

local cc4013 = Chip:extend()

function cc4013:init( ... )
	Equip.init(self)
	self.WorkinglinkedNum = 0
	self.portsnum = 14
	self.config = config
	self.ports_state = {}
	for i=1,self.portsnum do
		self.ports_state[i] = false
	end
end

-- when{}
-- function ChipInit ( load_or_delete,experiment ,main_socket ,sub_socket )
-- 	if load_or_delete then
-- 		cc4013:loadNodes ( experiment,main_socket,sub_socket )
-- 	else
-- 		cc4013:deleteNodes ( experiment,main_socket,sub_socket )
-- 	end
-- end

-----将芯片电路节点和连接关系加载到对应试验中
function cc4013:loadConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh
----注意端口加载顺序，S,R,CP,D
	experiment.sl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[2])].IDtable,
								  experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable )	


	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[6])].IDtable )	
	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[4])].IDtable )	
	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[3])].IDtable )	
	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[5])].IDtable )	

	experiment.sl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[12])].IDtable,
								  experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable )	

	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[8])].IDtable )	
	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[10])].IDtable )	
	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[11])].IDtable )	
	experiment.sl_tree:creatConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[9])].IDtable )	
end

function cc4013:deleteConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh
	for i=1,self.portsnum do
		-- experiment.sl_tree:destroyConnection( 2,experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		if experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])] then
			-- experiment.sl_tree:destroyConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
			-- experiment.sl_tree:destroyConnection( 4,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
			experiment.sl_tree:destroyConnection( experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		end
	end
end

_G.cc4013 = cc4013
