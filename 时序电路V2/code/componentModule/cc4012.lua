local config = {


			key={

				} ,

			NANDgates={
			[1]={input={2,3,4,5,},output={1},},
			[2]={input={9,10,11,12,},output={13},},
					},
			msh=
				{
				[1]='cc4012.skn'
				}
			}

local cc4012 = Chip:extend()

function cc4012:init( ... )
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
-- 		cc4012:loadNodes ( experiment,main_socket,sub_socket )
-- 	else
-- 		cc4012:deleteNodes ( experiment,main_socket,sub_socket )
-- 	end
-- end

-----将芯片电路节点和连接关系加载到对应试验中
function cc4012:loadConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh

	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[2])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[3])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[4])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[5])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[9])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[10])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[11])].IDtable )	
	experiment.cl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[12])].IDtable )	
end

function cc4012:deleteConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh
	for i=1,self.portsnum do
		-- experiment.cl_tree:destroyConnection( 2,experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		if experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])] then
			experiment.cl_tree:destroyConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		end
	end
end

_G.cc4012 = cc4012
