os.info = {}
os.info.uiedit = true
os.info.uieditpath = 'uieditor/'
os.info.uiconfpath = 'confui/'
os.info.uibasepath = 'code/'
os.info.uirespath = './'
os.info.uilangpre = '_lang' -- 多语言文本前缀函数名，若非空，则需要定义同名函数如下
function _lang(s) return s end

-------------------------------------------------------------------
_sys.downloadLog = false
_sys.showStat = false
_sys.showVersion = false

_sys:enumFolder(os.info.uirespath, true, function(folder)
	_sys:addPath(folder)
end)

local Dofile = dofile
function dofile(f)
	print('dofile', f)
	return Dofile(f)
end

dofile (os.info.uibasepath..'uibase.lua')
dofile (os.info.uibasepath..'ui.lua')

ui.loadConfig()

dofile (os.info.uieditpath..'uiedit.lua')
_app:onIdle(ui.appIdle)
_app:onMouseMove(ui.appMouseMove)
_app:onMouseDown(ui.appMouseDown)
_app:onMouseUp(ui.appMouseUp)
_app:onMouseWheel(ui.appMouseWheel)
_app:onTouchBegin(ui.appTouchBegin)
_app:onTouchMove(ui.appTouchMove)
_app:onTouchEnd(ui.appTouchEnd)
_app:onKeyDown(function(keycode)
	uieditKeyDown(keycode)
	ui.appKeyDown(keycode)
	end
)
_app:onChar(ui.appChar)
_app:onIMEString(ui.appIMEString)

ui.onNew()
ui.enableEdit(ui)
