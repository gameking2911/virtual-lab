local config = {


			key={

				} ,

			-- Dtriger={
			-- [1]={input={3,4,5,6,},output={1,2,},},
			-- [2]={input={8,9,10,11,},output={12,13,},},
			-- 		},
			msh=
				{
				[1]='cc4027.skn'
				}
			}

local cc4027 = Chip:extend()

function cc4027:init( ... )
	Equip.init(self)
	self.WorkinglinkedNum = 0
	self.portsnum = 16
	self.config = config
	self.ports_state = {}
	for i=1,self.portsnum do
		self.ports_state[i] = false
	end
end

-----将芯片电路节点和连接关系加载到对应试验中
function cc4027:loadConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh
----注意端口加载顺序，S,R,CP,J,K
	experiment.sl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[2])].IDtable,
								  experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable )	


	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[7])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[4])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[3])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[6])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[1])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[5])].IDtable )	

	experiment.sl_tree:creatConnection( 2,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[14])].IDtable,
								  experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[15])].IDtable )	

	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[15])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[9])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[15])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[12])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[15])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[13])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[15])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[10])].IDtable )	
	experiment.sl_tree:creatConnection( 3,experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[15])].IDtable,
								  experiment.inputIndex[tmsh][tmsh:getSubMesh(sub_socket[11])].IDtable )	
end

function cc4027:deleteConnection ( experiment,main_socket,sub_socket )
	local tmsh = main_socket.msh
	for i=1,self.portsnum do
		if experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])] then
			experiment.sl_tree:destroyConnection( experiment.outputIndex[tmsh][tmsh:getSubMesh(sub_socket[i])].IDtable )
		end
	end
end

_G.cc4027 = cc4027
