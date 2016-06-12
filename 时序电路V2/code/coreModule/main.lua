_sys:addPath('code')
_sys:addPath('code\\coreModule')
_sys:addPath('code\\cameraModule')
_sys:addPath('code\\componentModule')
_sys:addPath('code\\ConfigurationModule')
_sys:addPath('code\\experimentModule')
_sys:addPath('code\\stateManagementModule')
_sys:addPath('image')
_sys:addPath('confui')
_sys:addPath('env')
_sys:addPath('env\\mesh')
_sys:addPath('env\\terrain')
_sys:addPath('env\\textures')
_sys:addPath('env\\animation')

_dofile('uibase.lua')
_dofile ('ui.lua')

_sys.showStat = false
_sys.showVersion = false
_sys.showMemory = false

function _G._lang(s) return s end   --- 多语言函数支持

--ui的配置路径
os.info = {} 
os.info.uiconfpath = 'confui/'
os.info.uibasepath = 'code/'
os.info.uirespath = './'
os.info.uilangpre = '_lang'

_define()
define.render{ e = 0 }
define.keyDown{key = 0}
define.mouseMove{x = 0, y= 0}
define.mouseWheel{delta = 0}
define.touchBegin{x = 0, y=0}
define.touchEnd{x = 0, y=0}
define.pick{x = 0,y = 0}
define.mouseDown{a = 0, x = 0, y = 0}
define.SendMsg{obj = {},msg = "None"}
define.MessageReturn{data = ""}
define.ChipInit{ chip = {}, load_or_delete = true,experiment = {},main_socket = {},sub_socket = {} }
-- define.sendPortNum{ index = 0 , output = false }
--- Lua UI Event.
_app:onTouchBegin(function(x,y)
	ui.appTouchBegin(x, y)
	touchBegin{x = x,y = y}
	mouseDown{a = 0,x = x, y = y}
	-- mouseDown{a = 2,x = x, y = y}
end)
_app:onTouchMove(function(x, y)
	ui.appTouchMove(x, y)
	mouseMove{x = x,y = y}
end)
_app:onTouchEnd(function(x,y)
	ui.appTouchEnd(x, y)
	touchEnd{x = x, y = y}
end)


_app:onChar(ui.appChar)
_app:onIMEString(ui.appIMEString)



_app:onIdle(function(e)
	ui.appIdle(e)
    render{e = e}
end)

_app:onMouseMove(function(x, y)
	ui.appMouseMove(x, y)
	mouseMove{x=x,y=y}
end)

_app:onMouseWheel(function(delta)
	ui.appMouseWheel(delta) 
	mouseWheel{delta=delta}
end)

_app:onMouseDown(function(btn, x, y)
	ui.appMouseDown(btn, x, y)
	mouseDown{a = btn, x = x, y = y}
	
end)

_app:onKeyDown(function(keycode)
	ui.appKeyDown(keycode)
	keyDown{key = keycode}
end)

_app:onKeyUp(function(keycode)
	-- hotKey = false
end)

_app:onMouseUp(function(btn, x, y)
	ui.appMouseUp(btn, x, y)
end)


_app:onTouchZoom(function(x)
	print('zoom')
	mouseWheel{delta = x*5}
end)



ui.loadConfig() --load模版UI。

ui.onNew()  --真正地创建UI。这时候UI会显示出来。




function string:split(sep)
 local sep, fields = sep or "\t", {}
 local pattern = string.format("([^%s]+)", sep)
 self:gsub(pattern, function(c) fields[#fields+1] = c end)
 return fields
end

_dofile('ExpTableEnvironment.lua')
_dofile('cameraControl.lua')
_dofile('client.lua')

_rd.w = 1500
_rd.h = 640
if _sys.os ~= 'win32' then
	_sys:setLogicalResolution(800, 600)  --设置逻辑宽高
end
