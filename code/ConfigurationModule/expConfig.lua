local exp_config =
	{
		[3]={
			name="CLCE.lua",
			obj={
				["3"]={name = "Vm.lua", style = {1,} , position = {_Vector3.new(10.85,0,7.5),} , rotation = {-0.5*math.pi,},
				line = {
						style =
						{
						{7,8,},
						},

						position =
						{
						{_Vector3.new(5.724,-1.068,7.757),_Vector3.new(5.724,1.111,7.757),},
						},

						rotation = 
						{
						{0,0},
						},

								},
							},
				["11"] = {name = "CC4011.lua", style = {1,} , position = {_Vector3.new(4.65,6.2,7.5),} , rotation = {0,},
						},
				["12"] = {name = "CC4012.lua", style = {1,} , position = {_Vector3.new(-1.65,6.2,7.5),} , rotation = {0,},
						} ,
				["13"] = {name = "clceboard.lua", style = {1,} , position = {_Vector3.new(0,0,7.45),} , rotation = {0,},
						} ,				
				},


			} ,

------
		[4]={
			name="SLCE.lua",
			obj={
				["11"] = {name = "CC4011.lua", style = {1,} , position = {_Vector3.new(9.65,0,7.5),} , rotation = {0,},
						},

				["14"] = {name = "CC4013.lua", style = {1,1} , position = {_Vector3.new(5.65,0,7.5),_Vector3.new(0,0,7.5),} , rotation = {0,0},
						},
				["15"] = {name = "SLCEboard.lua", style = {1,} , position = {_Vector3.new(0,0,7.45),} , rotation = {0,},
						} ,
				["16"] = {name = "cc4027.lua", style = {1,1} , position = {_Vector3.new(5,0,7.45),_Vector3.new(0,0,7.45),} , rotation = {0,0},
						} ,			
				},


			} ,

	}

_G.exp_config = exp_config
