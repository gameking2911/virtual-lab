---------根据选择不同的实验板UI取得不同的实验序号
_G.expID = 4
_G.exp = ExpTableEnvironment:new()
exp:EnvironmentLayout(expID)

local cx=0
local cy=0
when{}
function mouseMove(x,y)	
	if cx ~= x and cy ~= y then
		exp.sm:mouseMove(x,y)
		cx = x
		cy = y
	end
end


when{ a=1 }
function mouseDown(a,x,y)
	exp.sm:RightMouseDown(x,y)
end

when{ a=0 }
function mouseDown(a,x,y)
	-- print("x,y",x,y)
	exp.sm:LeftMouseDown(x,y)
end

