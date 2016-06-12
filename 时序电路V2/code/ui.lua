local mat = _Matrix2D.new()
local ble = _Blender.new()

function ui.loadConfig()

if _sys.os == 'android' then
	local uifont = ui.font
	ui.font = function(name, ...)
		if type(name) == 'string' then
			return uifont('Arial', ...)
		end
		return uifont(name, ...)
	end
end

ui.sound = _SoundGroup.new()
ui.fonts = {
	s9 = ui.font(os.info.defaultfont, 9, ''),
	s9be = ui.font(os.info.defaultfont, 9, 'be'),
	s9e = ui.font(os.info.defaultfont, 9, 'e'),
	s9u = ui.font(os.info.defaultfont, 9, 'u'),
	s9s = ui.font(os.info.defaultfont, 9, 's'),
	s11be = ui.font(os.info.defaultfont, 11, 'be'),
	s16be = ui.font(os.info.defaultfont, 16, 'be'),

	yh8 = ui.font('微软雅黑', 8, ''),
	yh8b = ui.font('微软雅黑', 8, 'b'),
	yh8e = ui.font('微软雅黑', 8, 'e'),
	yh8u= ui.font('微软雅黑', 8, 'u'),
	yh10 = ui.font('微软雅黑', 10, ''),
	yh10b = ui.font('微软雅黑', 10, 'b'),
	yh10e = ui.font('微软雅黑', 10, 'e'),
	yh12 = ui.font('微软雅黑', 12, ''),
	yh12b = ui.font('微软雅黑', 12, 'b'),
	yh12e = ui.font('微软雅黑', 12, 'e'),
	h12 = ui.font('黑体', 12, ''),
	h16 = ui.font('黑体', 16, ''),
}
ui.fonts.default = ui.fonts.s9e
for key, font in next, ui.fonts do
	font.key = 'ui.fonts.'..key
end

os.info.uiconfpath = os.info.uiconfpath or '../cconf/'
os.info.configStr = os.info.configStr or ''
if not os.info.uiedit and _sys:fileExist(os.info.uiconfpath..'conf_uirects.lua') then _dofile (os.info.uiconfpath..'conf_uirects.lua') end
local t = os.now()
_dofile (os.info.uiconfpath..'conf_ui0.lua')
_dofile (os.info.uiconfpath..'conf_ui1.lua')
print('INFO conf_ui takes', os.now() - t, 'msec')

local function uchar(u)
	if u <= 127 then return string.char(u) end
	if u <= 0x7ff then return string.char(0xc0+toint(u/64), 0x80+u%64) end
	return string.char(0xe0+toint(u/4096), 0x80+toint(u/64%64), 0x80+u%64)
end
local function copyTable(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = copyTable(v)
        end
    end
    return tab
end
function ui.cliped(u)
	if not _rd.cx1 then return false end
	local x, y = ui.pos(u)
	return x + u.w < _rd.cx1 or x >= _rd.cx2 or y + u.h < _rd.cy1 or y >= _rd.cy2
end

--------------------- pick -----------------------
function ui.pass:onPick()
	ui.child(false)
end
function ui.passc:onPick(full)
	ui.pick'nochild' ui.super() ui.child()
end
function ui.passp:onPick(full)
	ui.super() if ui.child()==self then ui.child'passp' end
end
function ui.pickc:onPick(full)
	ui.pick'allchild' ui.super() ui.child()
end
function ui.pickcp:onPick(full)
	ui.super() if ui.child() then ui.child(self) end
end

--------------------- ui.select ------------------
function ui.onSelect(u, owner)
	if owner==nil then owner = u.owner end
	for k, v in next, owner do
		if v == u then owner.select = k break end
	end
end
function ui.select(u)
	local o = u and u.owner
	return o~= nil and o[o.select]==u
end
---------------------- longhover ---------------------
local function hoverClock(u)
	u.hovert = u.hovert or os.now()
	if os.now() - u.hovert > 2000 then 
		if (u.longHover or u.onLongHover) and not u.longHovering then
			u.longHovering = true
			if u.longHover then u:longHover() end
			if u.onLongHover then u:onLongHover() end
		end
	end
end

local function stopHoverClock(u)
	if u.longHovering then 
		u.hovert = nil
		u.longHovering = false
		if u.onUnLongHover then u:onUnLongHover() end
		if u.unLongHover then u:unLongHover() end		
	end
end
---------------------------------------------------

local function byteCount(text, i)
	local curByte = string.byte(text, 1)
	if curByte>0 and curByte<=127 then
        return 1
    elseif curByte>=192 and curByte<223 then
        return 2
    elseif curByte>=224 and curByte<239 then
        return 3
    elseif curByte>=240 and curByte<=247 then
        return 4
    end
    return 0
end

local function startRoll(u)
	if not u.text and not u.font or u.font:stringWidth(u.text) < u.w then return end
	u.tempRollText= u.text
	u.rollTimer = _Timer.new()
	u.rollTimer.name = 'timer'
	u.text = string.sub(u.text, byteCount(u.text, 1) + 1)
	u.rollTimer:start('timer', 300, function()
		u.text = string.sub(u.text, byteCount(u.text, 1) + 1)
		if u.text == '' then 
			u.text = u.tempRollText
		end
	end)
end
local function endRoll(u)
	if not u.rollTimer then return end
	u.rollTimer:stop('timer')
	u.text = u.tempRollText
	u.rollTimer = nil
	u.tempRollText = nil
end

--------------------- position --------------------
local function position(u)
	local p = ui.parent(u)
	while p and p~= ui do 
		local pp = ui.parent(p)
		ui.position(p, pp)
		p = pp
	end
	ui.position(u)
end

--------------------- ui.label --------------------
function ui.label:onUpdate() 
	if ui.hover() == self then hoverClock(self) 
	else
		stopHoverClock(self)
	end
	if self.autosize and self.text ~= self.lasttext then
		self.lasttext = self.text
		ui.sizeTo(self, self.font:stringWidth(self.text), self.font:stringHeight(self.text))
	end
end
function ui.label:onRender()
	_rd:useClip(_rd.x, _rd.y, _rd.x+self.w, _rd.y+self.h)
		if self.text and self.text ~= '' then
			self.font:drawText(0, 0, self.w, self.h, self.text)
		end
	_rd:popClip()
end

function ui.label:onClick()
	if self.click then
		self:click()
	end
end
function ui.label:onLongHover()
	if not self.banRollText then startRoll(self)end
end
function ui.label:onUnLongHover()
	endRoll(self)
end

---------------------- ui.button ---------------------
function ui.button:onRender(full)
	if self.disable then _rd:useBlender(ble:gray()) end
	ui.super()
	local push = not self.disable and ui.push(self)
	if push then _rd:pushMul2DMatrixLeft(mat:setTranslation(0, self.pushy)) end
	if self.bg then
		local bg = not self.disable and (push and self.bgpush or
			ui.hover(self) and self.bghover or self.select and self.bgselect) or self.bgidle
		if bg then ui.drawImg(self, bg) end
	end
	local fg = not self.disable and (push and 'fgpush' or
		ui.hover(self) and 'fghover' or self.select and 'fgselect') or 'fgidle'
	fg = self[fg]
	if fg then
		if getmetatable(fg)==_Image then fg = self.fg==1 and fg else fg = fg[self.fg] end
	end
	if not fg then
		fg = self.fgidle if fg then
			if getmetatable(fg)==_Image then fg = self.fg==1 and fg else fg = fg[self.fg] end
		end
	end
	if fg then ui.drawImg(self, fg) end
	if self.text and self.text ~= '' then
		local x, y = ui.pos(self)
		_rd:useClip(x, y, x+self.w, y+self.h)
		self.font:drawText(0, 0, self.w, self.h, self.text)
		_rd:popClip()
	end
	ui.child()
	if push then _rd:pop2DMatrix() end
	if self.disable then _rd:popBlender() end
end

function ui.button:onUpdate()
	if ui.hover() == self then hoverClock(self) 
	else
		stopHoverClock(self)
	end
end

function ui.button:onClick()
	if self.disable then return end
	self.audioplay = 'uibutton'
	if  os.now() - (self.clickt or 0) > 300  then
		if self.audio ~= '' then
			ui.sound:stop()
			ui.sound.volume = self.volume
			ui.sound:play(self.audio)
		end
		self.clickt = os.now()
		if self.radio then
			for k, v in next, self.owner do
				if k ~= 'owner' then
					if ui.is(ui.button, v) then v.select = false end
				end
			end
			self.select = true
		end
		if self.click then --click
			self:click()
		end
	else
		--doubleClick
		self.clickt = 0
		if self.doubleClick then
			self:doubleClick()
		end
	end
end
function ui.button:onLongHover()
	if not self.banRollText then startRoll(self)end
end
function ui.button:onUnhover()
	endRoll(self)
end
------------------- ui.checkbox --------------
function ui.checkbox:onClick()
	if not self.disable then 
		self.select = not self.select
		if self.click then --checkstate change 
			self:click()
		end
	end
end
local blender = _Blender.new()
function ui.checkbox:onRender()
	if self.disable then  _rd:useBlender(blender:blend(_Color.Gray))end
	local i = self.select and self.bgselect or self.bgidle
	if i then ui.drawImg(self, i) end
	if self.disable then _rd:popBlender() end
end
function ui.checkbox:onUpdate()
	if ui.hover() == self then hoverClock(self) 
	else
		stopHoverClock(self)
	end
end
function ui.checkbox:onDraging(dx, dy, full)
	ui.child(false)
end
------------------- ui.radiobox --------------
function ui.radiobox:onClick()
	for k, v in next, self.owner do if k ~= 'owner' then
		if ui.is(ui.radiobox, v) then v.select = false end
	end end
	self.select = true
end
function ui.radiobox:onRender()
	local i = self.select and self.bgselect or self.bgidle
	if i then ui.drawImg(self, i) end
end
function ui.radiobox:onClick()
	if self.click then 
		self.click()
	end
end
function ui.radiobox:onDraging(dx, dy, full)
	ui.child(false)
end
------------------- ui.input ----------------
if _sys.os == 'win32' or _sys.os == 'win64' then 

local inputmat = _Matrix2D.new()
ui.input.onRender = function(self)
	local x, y = _rd.x, _rd.y
	local img = (ui.focus(self) and not self.disable) and self.bgfocus or self.bgidle
	if img then ui.drawImg(self, img) end
	_rd:useClip(x+self.pad.l, y+self.pad.t,
		x+self.pad.l+self.w-self.pad.r, y+self.pad.t+self.h-self.pad.b)
	_rd:pushMul2DMatrixLeft(inputmat:setTranslation(self.left, self.top))
	local selstart = -1 local selend = -1
	if self.selend then
		selstart, selend = self.selstart, self.selend
		if self.selstart > self.selend then selstart, selend = self.selend, self.selstart end
	end
	for i, v in ipairs(self.ts) do
		if v.y+v.h >= self.pad.t-self.top and v.y < self.h-self.pad.b-self.top then
			if i > selstart and i <= selend then v:drawSel() end
			v:draw(v)
		end
	end
	if self.readonly ~= true then
		if self==ui.focus() and (os.now()+self.tagtime)%1000 > 500 then
			self.tag:drawImage(self.tagx-self.tag.W, self.tagy, self.tag.W*2, self.tagh)
		end
	end
	if ui.ime and ui.focus()==self then
		_rd:popClip()
		_rd:fillRect(self.tagx, self.tagy, self.font:stringWidth(ui.ime), self.tagh, 0xff0000ff)
		self.font:drawText(self.tagx, self.tagy, self.font:stringWidth(ui.ime), self.tagy+self.tagh, ui.ime, 'cm')
		_rd:useClip(x+self.pad.l, y+self.pad.t, x+self.pad.l+self.w-self.pad.r, y+self.pad.t+self.h-self.pad.b)
	end
	_rd:pop2DMatrix()
	_rd:popClip()
end
ui.input.onUpdate = function(self)
	if ui.hover() == self then hoverClock(self) 
	else
		stopHoverClock(self)
	end
	self.readonly = self.disable
	self.tag = self.fgcaret
	self.curr = self.curr or 0
	local v = self.ts[self.curr]
	if v == nil and self.curr > 1 then self.curr = self.curr - 1 end
	self.tagx = v and (v.x + v.w) or self.pad.r
	self.tagy = v and v.y or self.pad.t
	self.tagh = v and v.h or self.font:stringHeight('h')
	local w = self.w - self.pad.l - self.pad.r
	self.textalign = self.font.align
	if self.textalign:lead("l") then
		self.left = math.min(0, math.max(w-self.font:stringWidth(self.text),
			math.max(w/4, math.min(self.tagx+self.left, w*3/4))-self.tagx))
	elseif self.textalign:lead("c") then
		self.left = (self.w-self.pad.r-self.pad.l-self.font:stringWidth(self.text))/2
	elseif self.textalign:lead("r") then
		self.left = math.min(w, math.max(w-self.font:stringWidth(self.text),
			math.min(w/4, math.min(self.tagx+self.left, w*3/4))-self.tagx))
	end
	if self.lasttext ~= self.text then 
		local cur = self.curr
		self:setText(self.text) 
		self.curr = cur
		self.lasttext = self.text 
	end
end
ui.input.onUnfocus = function(self)
	self.selend = nil
	_sys.enableIME = false
	self.pushtimes = nil
	stopHoverClock(self)
	endRoll(self)
	if self.unFocus then self:unFocus() end
end
ui.input.onFocus = function(self)
	_sys.enableIME = true
	if self.focus then self:focus() end
end
ui.input.onKey = function(self, k, c)
	if k==27 then return end
	local seltext, selstart, selend = self:getSel()
	if selstart then selstart = selstart + 1 end
	local clearsel = false
	self.curr = self.curr or 0
	if _sys:isKeyDown(_System.KeyCtrl) then
		if k==_System.KeyV then
			self:cut(selstart, selend)
			local s = _String.replace(_sys.clipboard, '[\\u0000-\\u001f]', '')
			self:insert(s)
			clearsel = true
		elseif k == _System.KeyC then _sys.clipboard = seltext
		elseif k == _System.KeyX then
			_sys.clipboard = seltext self:cut(selstart, selend) clearsel = true
			if self.readonly then return end
		elseif k == _System.KeyA then self.selstart = 0 self.selend = #self.ts
		end
	elseif k==_System.KeyReturn then
		if not self.onEnter then return end
		self:onEnter()
		clearsel = true
	elseif k==_System.KeyBack and (self.curr > 0 or selstart) then
		if self.readonly then  self.curr = math.max(0, self.curr - 1) return end
		if selstart then self:cut(selstart, selend)
		else table.remove(self.ts, self.curr) self.curr = self.curr - 1 end
		self:requeue()
		clearsel = true
	elseif k==_System.KeyDel then
		if self.readonly then return end
		if selstart then self:cut(selstart, selend)
		else table.remove(self.ts, self.curr+1) end
		self:requeue()
		clearsel = true
	elseif k==_System.KeyLeft then
		if _sys:isKeyDown(_System.KeyShift) then
			if self.curr > 0 then
				self.selstart = self.selstart or self.curr
				self.selend = self.curr - 1
			end
		else clearsel = true end
		if self.curr > 0 then self.curr = self.curr - 1 end
	elseif k==_System.KeyRight then
		if _sys:isKeyDown(_System.KeyShift) then
			if self.curr < #self.ts then
				self.selstart = self.selstart or self.curr
				self.selend = self.curr + 1
			end
		else clearsel = true end
		if self.curr < #self.ts then self.curr = self.curr + 1 end
	elseif k==_System.KeyEnd then
		if _sys:isKeyDown(_System.KeyShift) then
			self.selstart = self.selstart or self.curr
			self.selend = #self.ts
		else clearsel = true end
		self.curr = #self.ts
	elseif k==_System.KeyHome then
		if _sys:isKeyDown(_System.KeyShift) then
			self.selstart = self.selstart or self.curr
			self.selend = 0
		else clearsel = true end
		self.curr = 0
	elseif c then
		if self.readonly then return end
		self:cut(selstart, selend)
		self:insert(uchar(c))
		clearsel = true
	end
	if clearsel then self.selend = nil self.selstart=self.curr end
	ui.child(false)
end
ui.input.currformx = function(self, x, y)
	local curr
	local last
	if x < self.pad.l then x = self.pad.l end
	for i, v in ipairs(self.ts) do
		last = self.ts[i+1] == nil or self.ts[i+1].row ~= v.row
		if x >= v.x and x <= v.w/2 + v.x and y >= v.y and y < v.y + v.h then curr = i - 1
		elseif x > v.w/2 and x < v.x + v.w and y >= v.y and y < v.y + v.h then curr = i end
		if curr == nil and y >= v.y and y < v.y + v.h and last then curr = i end
		if curr then break end
	end
	if curr == nil and y < self.pad.t and x < self.pad.l then curr = 0 end
	if curr == nil and y > self.h and x > 0 then curr = #self.ts end
	return curr
end
ui.input.onPush = function(self)
	local x, y = ui.pos('mouse', self)
	x = x - self.left y = y - self.top
	self.curr = self:currformx(x, y) or self.curr
	if _sys:isKeyDown(_System.KeyShift) then
		if self.selstart ~= self.curr then self.selend = self.curr end
	else
		self.selstart = self.curr
		self.selend = nil
	end
	self.tagtime = - os.now()%1000 + 500
	if (not self.pushtimes or self.pushtimes == 0) and not self.disable then self:selectAll() end
	self.pushtimes = self.pushtimes and self.pushtimes + 1 or 1
end
ui.input.onDraging = function(self, x, y)
	local x, y = ui.pos('mouse', self)
	x = x - self.left y = y - self.top
	self.curr = self:currformx(x,y) or self.curr
	self.selend = self.curr ~= self.selstart and self.curr or nil
	ui.child(false)
end
local drawText = function(self)
	self.font:drawText(self.x, self.y, self.w, self.h, self.text, self.align)
end
local drawImage = function(self)
	self.img:drawImage(self.x, self.y, self.x + self.w, self.y + self.h)
end
local drawPass = function(self)
	self.font:drawText(self.x, self.y, self.w, self.h, self.password, self.align)
end
local drawSel = function(self)
	_rd:fillRect(self.x, self.y, self.w, self.h, 0xff3a6ba3)
end
ui.input.requeue = function(self)
	local oldtext = tostring(self.text)
	self.text = ""
	local x = self.pad.l
	local y = self.pad.t
	local ts = self.ts
	self.ts = {}
	for i, v in ipairs(ts) do if v.text ~= "" then
		local usable = true
		table.copy(v, { w=self.font:stringWidth(v.text), img=nil, x=x, y=y, draw=drawText,
			font=self.font, h=self.font:stringHeight(v.text), align=self.font.align, drawSel=drawSel })
		if self.password then
			v.w = self.font:stringWidth(self.password)
			v.password = self.password
			v.draw = drawPass
		end
		if usable then
			x = v.w + x
			table.push(self.ts, v)
			self.text = self.text .. v.text
		end
	end end
	if self.onChange and oldtext ~= self.text and self.nochange == nil then
		self:onChange(oldtext) self.nochange = nil
	end
end
ui.input.setText = function(self, t)
	self.ts = {}
	self.curr = 0	
	self:insert(type(t)=='number' and ('%.16g'):format(t) or tostring(t))
end
ui.input.insert = function(self, tt, curr)
	tt = tostring(tt)
	curr = curr or self.curr
	if curr < 0 then curr = 0
	elseif curr > #self.ts then curr = #self.ts
	end
	self.curr = curr
	for i = 1, tt:ulen() do
		if #self.ts < self.w then
			table.insert(self.ts, self.curr + 1, { text=_String.sub(tt, i, i) })
			self.curr = self.curr + 1
		end
	end
	self:requeue()
end

ui.input.cut = function(self, selstart, selend)
	if selstart == nil then return end
	if selstart > selend then selstart, selend = selend, selstart end
	for i = selstart, selend do
		table.remove(self.ts, selstart)
	end
	self.curr = selstart - 1
end
ui.input.getSel = function(self)
	local r = ""
	if self.selend == nil then return r end
	local selstart, selend = self.selstart, self.selend
	if self.selstart > self.selend then selstart, selend = self.selend, self.selstart end
	for i = selstart+1 , selend do
		r = r .. self.ts[i].text
	end
	return r, selstart, selend
end
ui.input.clear = function(self)
	self:setText("")
end
ui.input.onNew = function(self)
	self.selstart, self.ts, self.tagtime = self.left or 0, {}, 0
	self.pad = {
		b = 0,
		l = 6,
		r = 6,
	}
	self.pad.t = 0
	self.left = 0
	self.tag = self.fgcaret
	self.top = self.h/2 - self.font:stringHeight('t')/2
	self.curr = 0
end
ui.input.onClick = function(self)
	if os.now() - (self.clickt or 0) > 300 then 
		self.clickt = os.now()
		if self.click then 
			self:click()
		end
	else
		self.clickt = 0
		self:selectAll()
		 if self.doubleClick then self:doubleClick() end
	end
end
ui.input.selectAll = function(self)
	self.selstart = 0
	self.selend = self.text:ulen()
end
ui.input.onLongHover = function(self)
	-- if not self.banRollText and ui.focus() ~= self then 
	-- 	startRoll(self) 
	-- end
end
ui.input.onUnhover = function(self)
	-- stopHoverClock(self)
	-- endRoll(self)
end

else

--for mobile
ui.input.onRender = function(self)
	local cx, cy, cw, ch = ui.position(self.fgcaret, self)
	local left, right, top, bottom = cx, cx, cy, self.h-ch-cy
	local img = (ui.focus(self) and not self.disable) and self.bgfocus or self.bgidle
	if img then ui.drawImg(self, img) end
	_rd:useClip(_rd.x+left, _rd.y+top, _rd.x+self.w-right, _rd.y+self.h-bottom)
	self.font:drawText(left-self.textx, top, math.max(self.textw, self.w),
		self.h-top-bottom, self.passt or self.text)
	_rd:popClip()
	if ui.focus(self) and os.now()%1000 > 500 then
		local x = left-self.textx+self.caretx-cw/2
		if self.textw < self.w then
			if self.font.align:byte(1)==99 then
				x = x + (self.w - self.textw) / 2
			elseif self.font.align:byte(1)==114 then
				x = x + self.w - self.textw
			end
		end
		if not self.disable then
			self.fgcaret:drawImage(x, cy, cw, ch)
		end
	end
end
ui.input.onUpdate = function(self)
	local textx = not os.info.uiedit
	if self.lasttext ~= self.text then
		self.lasttext, self.textw, textx = self.text
	end
	if self.lastcaret ~= self.caret then
		self.lastcaret, self.textw, textx = self.caret
	end
	if self.lastpass ~= self.pass then
		self.lastpass, self.textw, textx = self.pass
	end
	if not self.textw then
		local n = self.text:ulen()
		if self.caret > n then self.caret = n end
		self.textw, self.caretx = 0, 0
		local s = self.pass ~= '' and self.font:stringWidth(self.pass)
			or { self.text:ucs(1, -1, 'c') }
		for i = 1, n do
			self.textw = self.textw + (self.pass ~= '' and s
				or self.font:stringWidth(uchar(s[i])))
			if i <= self.caret then self.caretx = self.textw end
		end
		self.passt = self.pass ~= '' and self.pass:rep(n) or nil
	end
	if not textx then
		if not self.textx then self.textx = 0 end
		local cx = ui.position(self.fgcaret, self)
		local lr = cx * 2
		local x, pad = self.caretx-self.textx, (self.w-lr)/5
		if x < pad then
			self.textx = math.max(self.textx + x-pad, 0)
		elseif x > self.w-lr-pad then
			self.textx = math.min(self.textx + x-self.w+lr+pad, math.max(self.textw-self.w+lr, 0))
		end
	end
end

ui.input.onPush = function(self)
	local x = ui.pos('mouse', self) + self.textx - ui.position(self.fgcaret, self)
	self.caret = self.text:ulen()
	local b, n = 1
	for i = 1, self.caret do
		local u = self.text:byte(b)
		n = u<128 and 1 or u<0xE0 and 2 or 3
		local w = self.font:stringWidth(self.text:sub(b, b+n-1))
		if x < w/2 then self.caret = i-1 return end
		b, x = b + n, x - w
	end
end
ui.input.onUnfocus = function(self)
	self.caret = self.text:ulen()
	_sys.enableIME = false
	if _sys.os ~= 'win32' then
		_sys:hideKeyboard()
	end
end
ui.input.onFocus = function(self)
	if  self.disable then return end
	_sys.enableIME = true
end
ui.input.onClick = function(self)
	if _sys.os ~= 'win32' then
		_sys:showKeyboard(self.text)
	end
end
ui.input.onKey = function(self, k, c)
	if self.disable then return end
	if k == _System.KeyESC then return end
	if k == _System.KeyBack then
		if self.caret > 0 then
			local b = 0
			for i = 1, self.caret-1 do
				local u = self.text:byte(b+1)
				b = b + (u<128 and 1 or u<0xE0 and 2 or 3)
			end
			local u = self.text:byte(b+1)
			self.text = self.text:sub(1, b)..self.text:sub(b+(u<128 and 1 or u<0xE0 and 2 or 3)+1)
			self.caret = self.caret-1
		end
	elseif k == _System.KeyLeft then
		self.caret = math.max(self.caret-1, 0)
	elseif k == _System.KeyRight then
		self.caret = math.min(self.caret+1, self.text:ulen())
	elseif c then
		local b = 0
		for i = 1, self.caret do
			local u = self.text:byte(b+1)
			b = b + (u<128 and 1 or u<0xE0 and 2 or 3)
		end
		self.text = self.text:sub(1, b)..uchar(c)..self.text:sub(b+1)
		self.caret = self.caret+1
	end
	ui.child(false)
end
ui.input.onKeys = function(self, s)
	self.text = s
	self.caret = #self.text
end
ui.input.onClick = function(self)
	if self.click then 
		self:click()
	end
end
end
------------------- ui.progress --------------
local matrix0 = _Matrix2D.new()
function ui.progress:goTo(pos, t, endcallback)
	t = t or 0
	if t <=0  or not tonumber(t) then 
		self.anima = false 
		self.now1 = pos
	else 
		self.anima = true
	end
	self.speed = t
	self.now = pos
	self.last = nil
	if endcallback then 
		self.endcallback = endcallback 
	end
end
function ui.progress:onRender()
	self.lorientation = self.lorientation or false
	if self.lorientation ~= self.orien  then
		self.w ,self.h = self.h, self.w
		self.lorientation = self.orien
	end
	local fg = 'fgidle'
	fg = self[fg]
	if fg then
		if getmetatable(fg)==_Image then fg = self.fgid==1 and fg else fg = fg[self.fgid] end
	end
	if not fg then
		fg = self.fgidle if fg then
		if getmetatable(fg)== _Image then fg = self.fgid==1 and fg else fg = fg[self.fgid] end
		end
	end
	if self.fg and not fg then
		fg = self.fg
	else
		fg = fg
	end
	local x1, y1 = ui.pos(self)
	if not fg or self.max < 1 then return end
	if self.now1 > 0 then
		local x, y, w, h = ui.position(fg, self)
		local n = math.min(self.now1, self.max)
		local length
		if not self.orien then
			length = w/self.max >= fg.W and n/self.max * w or fg.W + (n-1)/(self.max-1)*(w - fg.W)
			x = self.style==1 and (self.w - length) - x + 1 or x
			w = length
		else
			length = h / self.max >= fg.W and n / self.max * h or fg.W + (n-1)/(self.max-1)*(h - fg.W)
			y = self.style == 1 and (self.h - length) - y + 1 or y
			h = length
		end
		fg:drawImage(x, y, w, h)
	end
	matrix0:setTranslation(x1, y1 )
	if self.orien then
		matrix0:setTranslation(x1 + self.w, y1 )
		matrix0:mulRotationLeft(math.pi / 2)
	end
	_rd:push2DMatrix(matrix0)
	if self.format and self.format ~= '' then
		self.font:drawText(0, 0, self.orien and self.h or self.w, self.orien and self.w or self.h, self.format:format(self.now1, self.max))
	end
	_rd:pop2DMatrix()
end
function ui.progress:onUpdate()
	if self.now1 == self.now then 
		if self.endcallback then 
			local callback = self.endcallback
			self.endcallback = nil
			callback()
		end
		self.last=nil  
		return 
	end
	if not self.anima or not self.speed or self.speed<=0 then self.now1=self.now return end
	self.now1 = self.now1 or self.now
	if not self.last then self.d=(self.now-self.now1)/self.speed self.last=os.now() return end
	self.now1 = self.now1+self.d*(os.now()-self.last)
	self.now1 = math.min(self.now1,self.now)
	self.last = os.now()

end
------------------- ui.progexpr --------------
function ui.progexpr:onUpdate()
	if self.lv1==self.lv and self.now1==self.now then self.last=nil return end
	self.lv = self.lv>#self.conf and #self.conf or self.lv
	if not self.anima or not self.speed or self.speed<=0 then -- no anima
		self.now1=self.now
		self.lv1=self.lv
		return
	end
	self.now1 = self.now1 or 0
	self.lv1 = self.lv1 or 1

	local max = self.conf[self.lv1][self.confkey] or 0
	if not self.last then	-- start anima
		self.delta = self.lv1<self.lv and max - self.now1 or self.now-self.now1
		self.delta = self.delta/self.speed
		self.last=os.now()
		return
	end

	if self.lv1>=self.lv and self.now1>=self.now then -- stop anima
		self.now1=self.now
		self.lv1=self.lv
		return
	end

	local pass = os.now()-self.last
	if pass==0 then return end
	self.last = os.now()
	local d = self.delta*pass
	self.now1 = self.now1+d
	if self.now1>=max and self.lv1<self.lv then -- carry
		self.lv1 = self.lv1+1
		self.now1 = 0
		self.delta = self.lv1<self.lv and max - self.now1 or self.now-self.now1
		self.delta = self.delta/self.speed
	end
end

local matrix0 = _Matrix2D.new()
function ui.progexpr:onRender()
	local fg = 'fgidle'
	fg = self[fg]
	if fg then
		if getmetatable(fg)==_Image then fg = self.fgid==1 and fg else fg = fg[self.fgid] end
	end
	if not fg then
		fg = self.fgidle if fg then
		if getmetatable(fg)==_Image then fg = self.fgid==1 and fg else fg = fg[self.fgid] end
		end
	end
	if self.fg and not fg then
		fg = self.fg
	else
		fg = fg
	end

	self.lorientation = self.lorientation or false
	if self.lorientation ~= self.orien  then
		self.w, self.h = self.h, self.w
		self.lorientation = self.orien
	end
	if not fg or not self.lv1 or not self.conf[self.lv1] or not self.now1 then return end
	local x1 ,y1 = ui.pos(self)
	local max1 = self.conf[self.lv1][self.confkey]
	if self.now1 > 0 then
		local x, y, w, h = ui.position(fg, self)
		local length
		if not self.orien then
			length = fg.W + math.min(self.now1/max1, 1)*(w - fg.W)
			x = self.style==1 and (self.w - length) - x + 1 or x
			w = length
		else
			length = fg.W + math.min(self.now1/max1, 1)*(h - fg.W)
			y = self.style==1 and (self.h - length) - y + 1 or y
			h = length
		end
		fg:drawImage(x, y, w, h)
	end

	matrix0:setTranslation(x1, y1 )
	if self.orien then
		matrix0:setTranslation(x1 + self.w, y1 )
		matrix0:mulRotationLeft(math.pi / 2)
	end

	_rd:push2DMatrix(matrix0)
	if self.format and self.format ~= '' then
		if self.format=='LV%d' then
			self.font:drawText(0, 0, self.orien and self.h or self.w, self.orien and self.w or self.h, self.format:format(self.lv1))
		else
			self.font:drawText(0, 0, self.orien and self.h or self.w, self.orien and self.w or self.h, self.format:format(self.now1, max1))
		end
	end
	_rd:pop2DMatrix()
end


------------------- ui.listnode --------------
function ui.listnode:onNew()
	self.selectArea = self.owner
	local lo, o = self.owner, self.owner
	while o ~= ui do 
		if ui.is(ui.list, o) then lo = o end
		o = o.owner
	end
	self.clipo = lo
end

function ui.listnode:onUpdate(full)
	local x, y = ui.pos(self, self.clipo)
	if x > self.clipo.w or x + self.w < 0 or y > self.clipo.h or y + self.h < 0 then 
		self.cliped = true
		return
	else
		self.cliped = false
		ui.child()
	end  
	local o, dragd = self.owner, self.dragd
	self.dragd = o.dragd
	if not o.autoalign then return end
	if o.dragd or not dragd then return end
	local b = ui.back(o)
	while b and not b.show do b = ui.high(b) end
	if not b then return end
	local hv = b.align and b.align[11]
	local p99 = math.min((hv and o.w or o.h) - o.Z, 0)
	local p0, p9 = o.offset or 0, (o.offset or 0) - p99
	if p0 > 0 and p9 < 0 then return end
	if hv then
		if x >= -self.w/2 and x <= self.w/2 then
			o.moved = -x
		end
	else
		if y >= -self.h/2 and y <= self.h/2 then
			o.moved = -y
		end
	end

end
function ui.listnode:onRender(full)
	if self.cliped then return end
	local bg = (self.select and self.bgselect or ui.push(self) and self.bgpush or
		 ui.hover(self) and self.bghover ) or self.bgidle
	if bg then ui.drawImg(self, bg) end
	ui.drawImg(self, self.backgs)
	ui.child()
end

local function dps(u, selectu)
	local b = ui.back(u)
	while b and not b.show do 
		b = ui.high(b)
	end
	if not b then return end
	while b do 
		if ui.is(ui.listnode, b) and b.show then
			if b.select and b.onUnselect and b ~= selectu then 
				b:onUnselect(selectu) 
			end
			b.select = false 
		end
		dps(b, selectu)
		b = ui.high(b)
	end
end

function ui.listnode:onSelect()
	dps(self.selectArea, self)
	self.select = true
end

function ui.listnode:unSelect()
	if self.select and self.onUnselect then 
		self:onUnselect()
	end
	self.select = false
end

function ui.listnode:setSelectArea(u)
	self.selectArea = u
end

function ui.listnode:onClick()
	if os.now() - (self.clickt or 0) >300 then
		self.clickt = os.now()
		self:onSelect()
		if self.click then self:click() end
	else
		self.clickt = 0
		if self.doubleClick then self:doubleClick() end
	end
end

function ui.listnode:onHotkey(k)
	if self.hotKey then self:hotKey(k) end
end

function ui.listnode:onFocus(full)
	self.focused = true
	ui.child()
end

function ui.listnode:onUnfocus(full)
	ui.child()
	self.focused = false
end

------------------- ui.list --------------

do
local qa = {}

function ui.list:resetPos()
	local  u  = ui.back(self)
	if not u then return end
	while u and not u.show do    u = ui.high(u) end
	if not u then return end
	local dx = u.align[11] and u.align[11] or u.x
	local dy = u.align[12] and u.align[12] or u.y
	ui.moveTo(u,dx,dy)
	self.dragingd =0
	self.dragd, self.drag0, self.drag9, self.dragt, self.outd ,self.moved= nil
	self.offset =0
end

function ui.list:moveWithoutRebound(dis)
	local b = ui.back(self)
	while b and not b.show do b = ui.high(b) end
	if not b then return end
	local hv = b.align and b.align[11]
	local offset = hv and b.x or b.y
	local f = ui.front(self)
	while f and not f.show do f = ui.low(f) end
	local Z = 0
	if f then
		Z = (hv and f.x + f.w or f.y + f.h) - (offset or 0)
	end
	--解决移动太多回弹问题，解决办法是：若需要回弹 则将边界移动到正好不用回弹的位置
	local wh = hv and self.w or self.h
	local p99 = math.min(wh - Z, 0)
	local dxy = hv or b.align[12] or 0
	local p0, p9 = offset or 0, (offset or 0) - p99
	dis = dis + p0 > dxy and -p0 or dis + p9 < -dxy and -p9 or dis
	ui.moveDiff(b, hv and dis, hv or dis)
end

function ui.list:onWheel(e ,full)
	local b = ui.back(self)
	while b and not b.show do b = ui.high(b )end
	if not b then return end
	local hv = b.align and b.align[11]
	local dis = hv and b.w or b.h
	local dx , dy = b.align[11] or 0 ,b.align[12] or 0
	local wh = hv and self.w or self.h
	if dis >= wh/5 then 
		dis = b.H or wh/5
	end 
	self:moveWithoutRebound(e*dis)
end

function ui.list:ToBottom(u, isui)
	--bottom show node
	local b = ui.front(self)
	while b and not b.show do 
		b = ui.low(b)
	end
	--calculate number of nodes
	local shownodes = 0
	local topShowNode
	while b  do
		if b.show then shownodes = shownodes + 1 topShowNode = b end
		b = ui.low(b)
	end
	if shownodes * u.h > self.h then 
		--calculate u's pos in list
		local seq = 0
		if isui then 
			local tempu = u
			while tempu do 
				if tempu.show then seq = seq + 1 end
				tempu = ui.low(tempu)
			end
		else
			seq = u
		end
		if shownodes * u.h > self.h then
			local hv = topShowNode.align and topShowNode.align[11]
			ui.moveTo(topShowNode , hv and - (seq*u.w - self.w ) or 0 , hv and 0 or - (seq * u.h -self.h))
			self.dragingd ,self.dragd, self.drag0, self.drag9, self.dragt, self.outd = 0 
			self.moved= nil
			self.offset = hv and - (seq * u.w - self.w ) or - (seq * u.h -self.h)
		end
	end
end

--@param u-node of list, cb - callback, through - true/false
function ui.list:slideToMiddle(u, cb ,through)
	local b = ui.back(self)
	while b and not b.show do b = ui.high(b) end
	if not b then return end
	self.slideTo = function ( )
		local hv = b.align and b.align[11]
		local x, y = ui.pos(self)
		local x1, y1 = ui.pos(u)
		local dxy = (hv and self.w - u.w or self.h - u.h)/2 - (hv and x1-x or y1-y)
		if through then 
			local b = ui.back(self)
			while b and not b.show do b = ui.high(b) end
			ui.moveDiff(b ,hv and dxy, not hv and dxy)
			if cb then cb() end
		else
			self.moved = dxy
			self.slidecb = cb
		end
	end
end

function ui.list:stepTo(a)
	local u1, u0 = ui.back(self), ui.front(self)
	while u1 and not u1.show do u1 = ui.high(u1) end
	if not u1 then return end
	local hv = u1.align and u1.align[11]
	if a == 1 then
		while not ((hv and u1.x or u1.y) >= 0) do
			u1 = ui.high(u1)
		end
		if (hv and u1.x or u1.y) > 0 then
			self.moved = hv and -u1.x or -u1.y
		else
			local u2 = ui.high(u1)
			self.moved = hv and -u2.x or -u2.y
		end
	elseif a == -1 then
		while not ( (hv and u0.x+u0.w or u0.y+u0.h) <= (hv and self.w or self.h) ) do
			u0 = ui.low(u0)
		end
		if (hv and u0.x+u0.w or u0.y+u0.h) > (hv and self.w or self.h) then
			self.moved = hv and (self.w-u0.x-u0.w) or self.h-u0.y-u0.h
		else
			local u3 = ui.low(u0)
			self.moved = hv and self.w-u3.x-u3.w or self.h-u3.y-u3.h
		end
	end
end

function ui.list:onNew()
	self.offset = 0
	self.Z = 0
end

function ui.list:onRender(full)
	ui.super()
	_rd:useClip(_rd.x, _rd.y, _rd.x+self.w, _rd.y+self.h)
	ui.child()
	_rd:popClip()
end

function ui.list:onUpdate(full)
	ui.super()
	local b = ui.back(self)
	while b and not b.show do  b = ui.high(b) end
	if not b then return end

	if self.forceq then
		local ba, u = b.align, b
		if not ba then ba = ui.alignLTQ(0,0,nil,0) b.align = ba
		elseif ba[13] ~= qa then ba[12], ba[13] = ba[12] or not ba[11] and 0, qa
		end
		while u do
			local a = u.align
			if not a then u.align = ui.align(unpack(b.align))
			elseif a[13] ~= qa then a[11], a[12], a[13] = a[11] or ba[11], a[12] or ba[12], qa
			end
			u = ui.high(u)
		end
	end
	local dragd = self.dragd
	if b and (not self.dragingd or self.dragingd==0) then
		local hv = b.align and b.align[11]
		local wh = hv and self.w or self.h
		local p99 = math.min(wh - self.Z, 0)
		local p0, p9 = self.offset or 0, (self.offset or 0) - p99
		local dxy = (b.align[12] and b.align[12] ) or (b.align[11] and b.align[11]) or  0
		if dragd then
			dragd = p0 > 0 and dragd * .8 * (1 - p0 / wh)
				or p9 < 0 and dragd * .8 * (1 + p9 / wh)
				or dragd * (os.now() - self.dragt < 200 and 1 or .92)
			if math.abs(dragd) <= (p0 <= 0 and p9 >= 0 and 1.5 or 5) then
				dragd = nil
				local xy = toint(hv and b.x or b.y)
				ui.moveTo(b, hv and xy, not hv and xy)
			else
				self.offset = p0 + dragd
				ui.moveDiff(b, hv and dragd, not hv and dragd)
				ui.position(b)
			end
		elseif p0 > dxy or p9 < -dxy then
			if not self.outd or (self.outd > 0) ~= (p0 > 0) then
				self.outd, self.dragt = (p0 > 0 and p0 or p9) * .6, os.now()	 
			else
				local t = (os.now()-self.dragt)/2000
				local p = toint(self.outd - self.outd * math.cos(math.max(1-t, 0)^10*2.3))
				if p0 <= 0 then p = p + p99 end
				if self.moved then self.moved = self.moved + (hv and (p  - p0 ) or (p  - p0  ) )end
				ui.moveTo(b, hv and p + b.x - p0, not hv and p + b.y - p0)
			end
		elseif self.moved then
			local eplase = 1000 / _sys.fps
			local d = self.moved>0 and (eplase/3) or (-eplase/3) --0.5px/ms
			self.offset = self.offset or 0
			local bd = hv and b.x+d or b.y+d
			local p = hv and self.w-self.Z or self.h-self.Z
			if bd > dxy   then
				ui.moveTo(b, hv and dxy or b.x, hv and b.y or dxy)
				self.moved = nil
				if self.slidecb then self.slidecb() self.slidecb=nil end
				return
			elseif bd < p - dxy  then
				ui.moveTo(b, hv and self.w-self.Z -dxy  or b.x, hv and b.y or self.h-self.Z-dxy )
				self.moved = nil
				if self.slidecb then self.slidecb() self.slidecb=nil end
				return
			end
			if self.moved > -15 and self.moved < 15 then
				ui.moveDiff(b, hv and self.moved, not hv and self.moved)
				self.moved = nil
				if self.slidecb then self.slidecb() self.slidecb=nil end
				return
			end
			ui.moveDiff(b, hv and d, not hv and d)
			self.moved = self.moved - d
		end
	end
	ui.child()
	if self.slideTo then
		ui.position(self)
		local slideTo = self.slideTo
		self.slideTo = nil
		slideTo()
	end
	self.dragd = dragd
	self.offset = b.align and b.align[11] and b.x  or b.y
	local f = ui.front(self)
	while f and not f.show do f = ui.low(f) end
	if f then
		self.Z = (b.align and b.align[11] and f.x + f.w or f.y + f.h) - (self.offset or 0)
	end
	if self.autosize then 
		self.w = hv and self.Z or self.w
		self.h = hv and self.h or self.Z
	end
end

function ui.list:updateZ()
	local b = ui.back(self)
	while b and not b.show do  b = ui.high(b) end
	if not b then  
	 	if self.autosize then 
			self.w = hv and 0 or self.w
			self.h = hv and self.h or 0
		end
		return 
	end
	self.Z = 0
	local u = ui.back(self)
	while u do 
		position(u)
		u = ui.high(u)
	end
	self.offset = b.align and b.align[11] and b.x or b.y
	local f = ui.front(self)
	while f and not f.show do f = ui.low(f) end
	if f then
		self.Z = (b.align and b.align[11] and f.x + f.w or f.y + f.h) - (self.offset or 0)
	end
	if self.autosize then 
		self.w = hv and self.Z or self.w
		self.h = hv and self.h or self.Z
	end
	local hv = b.align and b.align[11]
	local wh = hv and self.w or self.h
	local p99 = math.min(wh - self.Z, 0)
	local p0, p9 = self.offset or 0, (self.offset or 0) - p99	
	local dxy = (b.align[12] and b.align[12] ) or (b.align[11] and b.align[11]) or  0
	if p0 > dxy then 
		ui.moveTo(b, hv and dxy, not hv and dxy)
	elseif p9 < -dxy then 
		local dis = wh > self.Z and dxy or wh - self.Z 
		ui.moveTo(b, hv and dis, not hv and dis)
	end
	self.offset = b.align and b.align[11] and b.x or b.y
	return self.Z
end

function ui.list:onPush(full)
	self.dragingd, self.dragd, self.drag0, self.drag9, self.dragt, self.outd = 0
	self.push = {}
	self.push[1] = ui.push()	self.dragxx ,self.dragyy = ui.mousex , ui.mousey
	if self.Push then self:Push() end
	ui.child()
	if type(ui.child()) ~= 'number' then ui.child(4) end
end
function ui.list:onDraging(dx, dy, full)
	if self.banDraging then return end
	ui.super()
	if not ui.child() then return end
	if not self.Z then return end
	local b = ui.back(self)
	while b and not b.show do b = ui.high(b) end
	if not b then return end
	local hv = b.align and b.align[11]
	local p99 = math.min((hv and self.w or self.h) - self.Z, 0)
	local p0, p9 ,d= self.offset or 0, (self.offset or 0)- p99 ,hv and dx or dy
	self.drag0 = p0 > 0 and math.min(p0, self.drag0 or 1/0) or 0
	self.drag9 = p9 < 0 and math.max(p9, self.drag9 or -1/0) or 0
	p0, p9 = p0-self.drag0, p9-self.drag9
	if p0 < 0 and p9 > 0 then 
		if self.push and self.push[1] == self then --drag  self
		local tdx ,tdy  = 0 ,0
		if hv then
			tdx = self.dragx and dx - self.dragx or dx
		else
			tdy = self.dragy and dy - self.dragy or dy
		end
		self.dragx = dx
		self.dragy = dy 
		dx = tdx
		dy = tdy
		end
	else 
		if self.push and self.push[1] == self then  
			dx = ui.mousex - self.dragxx -(self.dragx or 0)
			dy = ui.mousey - self.dragyy - (self.dragy or 0)
		end
	end
	local d = hv and dx or dy
	d = d + p0 > 0 and toint(d * .4 - p0 * .6) or d + p9 < 0 and toint(d * .4 - p9 * .6) or d
	self.dragingd = (d+(self.dragingd or d))/2
	ui.moveDiff(b, hv and d, not hv and d)
	ui.child(false)
end
function ui.list:onDrag(full)
	ui.super() ui.child()
	self.push = nil
	self.dragd, self.dragt, self.dragingd, self.drag0, self.drag9 = self.dragingd * .9, os.now()
end
function ui.list:onDrop(full)
	ui.super() ui.child()
	self.push = nil
	self.dragx , self.dragy ,self.dragxx ,self.dragyy = nil
end

function ui.list:banDrag(t)
	self.banDraging = t
end

function ui.list:setFocus(u)
	local owner = u.owner
	while owner and owner ~= ui do 
		if owner ==  self then break end
		owner = owner.owner
	end
	if not owner and owner == ui then return end
	local b = ui.back(self)
	while b and not b.show do 
		b = ui.high(b)
	end
	if not b then return end
	-- Update position.
	local bb = ui.back(self)
	while bb do 
		if bb.show then ui.position(bb) end
		bb = ui.high(bb)
	end
	local hv = b.align and b.align[11]
	local x, y = ui.pos(self)
	local x1, y1 = ui.pos(u)
	self:moveWithoutRebound((hv and self.w - u.w or self.h - u.h)/2 - (hv and x1-x or y1-y))
end

function ui.list:selectAll()
	local b = ui.back(self)
	while b do 
		if b.show and ui.is(ui.listnode, b)then
			b.select = true
		end
		b = ui.high(b)
	end
end
function ui.list:unSelectAll()
	local b = ui.back(self)
	while b do 
		if b.show and ui.is(ui.listnode, b) and b.select then
			b.select = false
			-- if b.onUnselect then b:onUnselect() end
		end
		b = ui.high(b)
	end
	if self.onUnselectAll then self:onUnselectAll() end
end

end

------------------- ui.scrollv --------------
function ui.scrollv:onWheel(e, full)
	local list = self.list
	if list then list:onWheel(e, full)end
end

function ui.scrollv.tbtn:onClick(full)
	local p  = ui.parent(self)
	local list = p.list
	list:onWheel(1,full)
end

function ui.scrollv.bbtn:onClick(full)
	local p  = ui.parent(self)
	p:onWheel(-1 , full)
end
function ui.scrollv:onNew()
	self.lstyle = self.lstyle or 0
	self.slider.pt = self.style==0 and self.tbtn.h or self.tbtn.w
	self.slider.pb = self.style==0 and self.h-self.bbtn.h or self.w-self.bbtn.w
	self.list = ui.low(self)
	if self.list and ui.is(ui.list, self.list) then
		if self.style == 0 then
			self.slider.show = (self.list.Z and self.list.Z > self.list.h) and true or false
			self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.h / self.list.Z
		elseif self.style == 1 then
			self.slider.w = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.w / self.list.Z
			self.slider.show = (self.list.Z and self.list.Z > self.list.w) and true or false
		end
	end
	self.bgres = self.backgs.resname
end
function ui.scrollv:onUpdate()
	if not self.slider.show then self.backgs.resname = ''
	else
		self.backgs.resname = self.bgres
	end
	self.lstyle = self.lstyle or 0
	if self.lstyle ~= self.style then
		self.w, self.h = self.h, self.w
		self.slider.w, self.slider.h = self.slider.h, self.slider.w
		if self.style == 0 then
			self.tbtn.align = ui.alignCT()
			self.slider.align = ui.alignCT(0,self.tbtn.h)
			self.bbtn.align = ui.alignCB()
		elseif self.style == 1 then
			self.tbtn.align = ui.alignLM()
			self.slider.align = ui.alignLM(self.tbtn.w, 0)
			self.bbtn.align = ui.alignRM()
		end
		self.lstyle = self.style
	end
	self.slider.pt = self.style==0 and self.tbtn.h or self.tbtn.w
	self.slider.pb = self.style==0 and self.h-self.bbtn.h or self.w-self.bbtn.w
	self.list = ui.low(self)
	if self.list and ui.is(ui.list, self.list) then
	if self.style == 0 then
			self.slider.show = (self.list.Z and self.list.Z > self.list.h) and true or false
			if self.list.offset > 0 then 
				self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.h / (self.list.Z + self.list.offset)
			elseif  - self.list.offset + self.list.h > self.list.Z then
				 self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.h / (- self.list.offset + self.list.h)
			else 
				self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.h / self.list.Z
			end	
		elseif self.style == 1 then
		self.slider.show = (self.list.Z and self.list.Z > self.list.w) and true or false
			if self.list.offset > 0 then 
				self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.w / (self.list.Z + self.list.offset)
			elseif  - self.list.offset + self.list.w > self.list.Z then
				 self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.w / (- self.list.offset + self.list.w)
			else 
				self.slider.h = self.list.Z and (self.slider.pb-self.slider.pt) * self.list.w / self.list.Z
			end
		end
	end
	if self.slider.show and ui.is(ui.list, self.list) then 
		local slider = self.slider
		if self.style == 0 then 
			local y = self.list.offset / (self.list.h - self.list.Z) * (slider.pb - slider.pt - slider.h ) + slider.pt
			if y < slider.pt then
				ui.moveTo(slider, slider.x, slider.pt)
			elseif y+slider.h > slider.pb then
				ui.moveTo(slider, slider.x, slider.pb-slider.h)
			else
				ui.moveTo(slider, slider.x, y)
			end
		elseif self.style ==1 then 
			local x = self.list.offset / (self.list.w - self.list.Z) * (slider.pb - slider.pt - slider.h) + self.pt
			if x < slider.pt then 
				ui.moveTo(slider, slider.pt, slider.y)
			elseif x + slider.w > slider.pb then 
				ui.moveTo(slider, slider.pb - slider.w, slider.y)
			else
				ui.moveTo(slider, x, slider.y)
			end
		end
	end
end
function ui.scrollv.slider:onDraging(dx, dy, full)
	local p = ui.parent(self)
	local list = p.list
	if not list then return end
	local d = 0
	if p.style == 0 then
		if self.y + dy < self.pt  then 
			dy = self.pt - self.y 
		elseif self.y + dy  + self.h > self.pb then 
			dy = self.pb - self.y - self.h
		end
		d = - (list.Z - list.h) / (self.pb - self.pt - self.h) * dy
		list:onDraging(dx, d, full)
	elseif p.style == 1 then
		if not self.last then self.last = 0 end
		if self.x + dx < self.pt then 
			dx = self.pt - self.x
		elseif self.x + dx +  self.w < self.pb then 
			dx = self.pb - self.x - self.w
		end
		self.last = self.x
		d = - (list.Z - list.w) / (self.pb - self.pt - self.w) * dx
		list:onDraging(d, dy, full)
	end 
end

------------------- ui.tab --------------
function ui.tab:onUpdate()
	for k, v in next, self do
		if ui.is(ui.button, v) then
			local p = ui.high(v)
			if p and ui.is(ui.tpage, p) then
				p.show = v.select
			end
		end
	end
end

------------------- ui.richtext --------------
local function endLine(self, line, left, y)
	self.linenum = self.linenum + 1
	local x = 0
	for i, v in ipairs(line) do 
		x = x + self.font:stringWidth(v.text)
	end
	local falign = self.font.align
	x =  falign:find('l') and 0 or falign:find('c') and (self.w-x)*0.5 or falign:find('r') and self.w-x	
	for i, v in ipairs(line) do
		ui.moveDiff(v, x, (line.h - (v.H or v.h))/2)
		v.linenum = self.linenum
	end
	return left, y+line.h, { h=0 }
end
local function addUi(self, u, left, x, y, line, file)
	if _Image==getmetatable(u) then
		self[1][#self[1]+1] = u
	end
	local w, h = u.W or u.w, u.H or u.h
	if x+w > self.w then
		x, y, line = endLine(self, line, left, y)
	end
	line[#line+1] = u
	line.h = math.max(h, line.h)
	ui.moveTo(u, x, y, self)
	return x+(file and self.w or w), y, line
end
local function setNode(self, str, data, left, x, y, line)
	if not str or str == '' then return x, y, line end
	local t, u, c, m, f, ln, func
	if not str:lead('`') then
	else
		t, m, f, c, ln = str:match('^`([^`]*)`([%%!%@]*)([%+%a]*)([#%w]*)(|?)')
	end
	if not t or t=='' then
		if ln=='|' then
			x, y, line = endLine(self, line, left, y)
		end
		return x, y, line
	end
	if m=='%' then
		u = ui.img(t)
		if func then
			u = ui^{ w=u.W, h=u.H, backgs=u}
		end
		x, y, line = addUi(self, u, left, x, y, line)
	elseif t then
		local font, style, color, falign = self.font, self.font.style, self.font.textColor, self.font.align
		if #f>0 then style = style..f:sub(2) end
		if #c>0 then
			color = toint(c:gsub('#', '0x'))
		end
		font = ui.font(font.resname, font.size, style, color)
		local s = font:cutLines(t, self.w, x<self.w and x or left)
		for i, v in ipairs(s) do
			u = ui.img(font, font.textColor, ui.alignLT(), v)
			if #v>0 then
				x, y, line = addUi(self, u, left,  x,  y, line, v:byte(-1)==13)
			end
		end
	end
	if func then
		function u:onClick()
			func()
		end
	end
	return x, y, line
end
function ui.richtext:setText(str, data, top, left)
	if not str or str == '' then return end
	position(self)
	self.linenum = 0
	self.movediffx = {}
	self:clear()
	self[1] = {}
	local x, y = left, top or self.top
	local line = { h=0 }
	for t, n in str:gmatch('([^{]*){([^}]*)}') do
		if t~= '' then x, y, line = setNode(self, '`'..t..'`', data, left, x, y, line) end
		if n ~= '' then x, y, line = setNode(self, n, data, left, x, y, line) end
	end
	local left, h = endLine(self, line, left, y)
	if self.autosize then
		ui.sizeTo(self, self.w, h)
	end
	ui.position(self)
	local movediffy = self.linenum*self.font.height
	local falign = self.font.align
	movediffy = falign:find('t') and 0 or falign:find('m') and (self.h-movediffy)*0.5 or falign:find('b') and self.h-movediffy	
	for i, v in ipairs(self[1]) do 
		ui.moveDiff(v, 0, movediffy)
	end
	if str:lead('{`') then
		local s = str:sub(3,-3)
		self.text,self.ltext = s,s
	end
	--避免onupate重复settext
	return h
end

function ui.richtext:clear()
	for i = 2, #self do ui.remove(i, self[i]) end
	self[1] = nil
end

function ui.richtext:onRender()
	if self[1] then ui.drawImg(self, self[1]) end
end
function ui.richtext:onUpdate()
	if (self.text ~= '' and self.text ~= self.ltext ) then
		local h = self:setText('{`' .. self.text .. '`}', '', 0, 0)
		self.ltext = self.text
	end
end
-------------------ui.htmlLabel-----------
local TextTag={}
TextTag.__index=TextTag
function TextTag.new(self, text, defaults)
	local instance=setmetatable({}, TextTag)
	instance.text=text
	instance.textColor=0xffffffff
	instance.font=defaults.font
	instance.w=instance.font:stringWidth(instance.text);
	instance.h=instance.font:stringHeight(instance.text);
	return instance
end

function TextTag.clone(self, text)
	local instance=setmetatable({}, TextTag)
	instance.text=text
	instance.textColor=0xffffffff
	instance.font=self.font
	instance.w=instance.font:stringWidth(instance.text)
	instance.h=instance.font:stringHeight(instance.text)
	return instance
end

function TextTag.size(self)
	return self.w, self.h
end

function TextTag.isEmpty(self)
	return self.text==""
end

function TextTag.onRender(self,h,num)
	self.font.textColor=self.textColor
	if num then
		local len=_String.len(self.text)
		if num>=len then
			self.font:drawText(0, h-self.h, sefl.w, self.h, self.text)
		else
			self.font:drawText(0, h-self.h, sefl.w, self.h,  _String.sub(self.text, 1, num))
		end
		return len-num
	else
		self.font:drawText(0, h-self.h, self.w, self.h, self.text)
	end
end

function TextTag.multiline(self, space, maxw)
	local txts=self.font:cutLines(self.text, maxw, space)
	local len=#txts
	if len<=1 then
		return 0, space+self.font:stringWidth(txts[#txts])
	end
	local tags={}
	for ii=1, #txts do
		tags[ii]=self:clone(txts[1])
	end
	return len-1, self.font:stringWidth(txts[len]), tags
end


local FontTag=table.copy({}, TextTag)
FontTag.__index=FontTag
function FontTag.new(self, attrs, text, defaults)
	local instance=setmetatable({}, FontTag)
	instance.fontsize=attrs.size or 10
	instance.textColor=attrs.color and toint(attrs.color:gsub("#", "0x")) or 0xffffffff
	instance.font=attrs.face and getFont(attrs.face, instance.fontsize) or defaults.font
	instance.text=text
	instance.w=instance.font:stringWidth(instance.text)
	instance.h=instance.font:stringHeight(instance.text)
	return instance
end

function FontTag.clone(self, text)
	local instance=setmetatable({}, FontTag);
	instance.text=text
	instance.textColor=self.textColor
	instance.font=self.font
	instance.w=instance.font:stringWidth(instance.text)
	instance.h=instance.font:stringHeight(instance.text)
	return instance
end

local ImageTag={};
function ImageTag.new(self, attrs)
	local instance=setmetatable({}, ImageTag)
	if attrs.src then
		instance.img=_Image.new(attrs.src)
	end
	return instance
end

function ImageTag.size(self)
	if not self.img then return 0, 0 end
	return self.img.w, self.img.h
end

function ImageTag.onRender(self, h, num)
	if not self.img then return end
	self.img:drawImage(0, h-self.img.h, self.img.w, self.img.h)
	return num-1
end

function ImageTag.multiline(self, space, maxw)
	if space+self.img.w>maxw then
		return 1, self.img.w
	end
	return 0, self.img.w+space
end

_G.HtmlText={};
HtmlText.__index=HtmlText
function HtmlText.new(self, str, defaults, fullstr)
	local instance = setmetatable({}, HtmlText)
	self.fullstr = fullstr
	instance:set(str, defaults)
	return instance
end

function HtmlText:subset(str)
	self.str = str
	self.indexs = {} -- {开始位置，}
	self.objs = {}
	self.tags={}
	local start = 1
	self.len = 0
	while true do
		local pos1, pos2, head, text, tail = string.find(str, "(<[^>]*>)([^<]*)(</[^>]*>)", start)
		if not pos1 then --没有找到，纯文本
			local len = string.len(self.str)
			if start <= len then
				table.insert(self.indexs, {self.len+1, len-start+self.len+1})
--				table.insert(self.indexs, {start, len})
				local txt=string.sub(self.str, start, len)
				table.insert(self.objs, {text = txt})
				self.len = len-start+self.len+1
			end
			break;
		end
		if start ~= pos1 then --有纯文本
			table.insert(self.indexs, {self.len+1, pos1-start+self.len})
--			table.insert(self.indexs, {start, pos1-1});
			local txt=string.sub(self.str, start, pos1-1)
			table.insert(self.objs, {text = txt})
			self.len = pos1-start+self.len
		end
		local len1, len2 = string.len(head), string.len(tail)
		table.insert(self.indexs, {self.len+1, pos2-pos1-len2-len1+self.len+1, len1, len2})
--		table.insert(self.indexs, {pos1-len1, pos2-len1-len2, len1, len2})
		table.insert(self.objs, {head = head, text = text, tail = tail})
		start = pos2 + 1
		self.len = pos2-pos1-len2-len1+self.len+1
	end
	self.len = 0;
	for ii = 1, #self.objs do
		local index = self.indexs[ii]
		local obj = self.objs[ii]
		index[2] = self.len+_String.len(obj.text)
		index[1] = self.len+1
		self.len = index[2]
	end
	return self.objs
end

function HtmlText.set(self, str, defaults )
	if self.str == str then  return end

	if str:ulen() < 2 then --in order to caluculate htmllabel's w and h  for once
		self.Fullobjs = copyTable(self:subset(self.fullstr))
	end
	self.objs = self:subset(str)
end


HtmlText.htmltags={
	font=FontTag,
	img=ImageTag
};
function HtmlText.register(name, tag)
	HtmlText.htmltags[name]=tag
end
HtmlText.textTag=TextTag
function HtmlText.setTextTag(tag)
	HtmlText.textTag=tag
end

function HtmlText:decodeTag(head, text, defaults)
	if not head then
		return self.textTag:new(text, defaults)
	end
	local _, _, tagname, attrs=string.find(head, "<([^ ]*)([^>]*)")
	local pos=1
	local nattrs={}
	while true do
		local _, nextpos, k, v=string.find(attrs, "([^=^ ]*)=([^ ^,]*)", pos)
		if not nextpos then
			break
		else
			pos=nextpos
			if v:lead("'") then
				nattrs[k]=string.sub(v, 2, -2)
			else
				nattrs[k]=toint(v)
			end
		end
	end
	return self.htmltags[tagname]:new(nattrs, text, defaults)
end

function HtmlText.buildTags(self, defaults)
	self.tags={}
	self.lines=nil
	local multiline=defaults.multiline
	local w=0
	local maxh=0
	local maxw=defaults.w
	if self.Fullobjs and self.str:ulen() < 2 then --in order to calculate w and h of htmllabel
		for ii=1, #self.Fullobjs do
			local o=self.Fullobjs[ii]
			local tag=self:decodeTag(o.head, o.text, defaults)
			if multiline then
				self.lines=self.linesor{}
				local _, neww, tags=tag:multiline(w, maxw)
				if not tags then
					table.insert(self.tags, tag)
				else
					for kk=1, #tags do
						local ntag=tags[kk]
						if ntag:isEmpty() then
						else
							local tagw, tagh=tag:size()
							maxh=math.max(maxh, tagh)
							table.insert(self.tags, ntag)
						end
						table.push(self.lines, #self.tags, maxh)
					end
				end
				w=neww
			else
				local tagw, tagh=tag:size()
				w=w+tagw
				maxh=math.max(maxh, tagh)
				table.insert(self.tags, tag)
			end
		end
		defaults.w ,defaults.h =  w, maxh
	end
	self.tags={}
	self.lines=nil
	local multiline=defaults.multiline
	local w=0
	local maxh=0
	local maxw=defaults.w
	for ii=1, #self.objs do
		local o=self.objs[ii]
		local tag=self:decodeTag(o.head, o.text, defaults)
		if multiline then
			self.lines=self.linesor{}
			local _, neww, tags=tag:multiline(w, maxw)
			if not tags then
				table.insert(self.tags, tag)
			else
				for kk=1, #tags do
					local ntag=tags[kk]
					if ntag:isEmpty() then
					else
						local tagw, tagh=tag:size()
						maxh=math.max(maxh, tagh)
						table.insert(self.tags, ntag)
					end
					table.push(self.lines, #self.tags, maxh)
				end
			end
			w=neww
		else
			local tagw, tagh=tag:size()
			w=w+tagw
			maxh=math.max(maxh, tagh)
			table.insert(self.tags, tag)
		end
	end
	return w, maxh
end

function HtmlText.showNum(self, num)
	self.num=num
end

local mat=_Matrix2D.new()
function HtmlText.onRender(self, h)
	local num=self.num
	local lineindex=1
	local x, y=0, 0
	if self.lines then
		for ii=1, #self.tags do
			local tag=self.tags[ii]
			mat:setTranslation(x,y)
			_rd:pushMulMatrix2DLeft(mat)
			local maxh=self.lines[lineindex+1]
			if num then
				num=self.tags[ii]:onRender(h, num)
				if num<=0 then
					break
				end
			else
				tag:onRender(maxh);
			end
			local tagx, tagy=self.tags[ii]:size()
			x=x+tagx
			_rd:popMatrix2D();
			if ii==self.lines[lineindex] then
				x=0 y=y+self.lines[lineindex+1]
				linenindex=lineindex+2
			end
		end
		return;
	end
	for ii=1, #self.tags do
		local tag=self.tags[ii]
		mat:setTranslation(x,y)
		_rd:pushMulMatrix2DLeft(mat)
		if num then
			num=tag:onRender(h, num)
			_rd:popMatrix2D()
			if num<=0 then
				break
			end
		else
			tag:onRender(h)
			_rd:popMatrix2D()
		end
		local tagx=self.tags[ii]:size()
		x=x+tagx
	end
end

local function section(r1, r2)
	if r1[1] > r2[2] then return end
	if r1[2] < r2[1] then return end
	return r1[1] > r2[1] and r1[1] or r2[1], r1[2] > r2[2] and r2[2] or r1[2]
end

function HtmlText.sub(self, i, j)
	j = j or math.huge
	local r = {i, j}
	local pos = i
	local str = ""
	for ii = 1, #self.indexs do
		local index = self.indexs[ii]
		local pos1, pos2 = section(index, r)
		if pos1 then
			local obj = self.objs[ii]
			if pos1 == index[1] and pos2 == index[2] then
				if obj.head then
					str = str..obj.head
				end
				str = str..obj.text
				if obj.tail then
					str = str..obj.tail
				end
			else
				if obj.head then
					str = str..obj.head
				end
				str = str.._String.sub(obj.text, pos1-index[1]+1, pos2-pos1+1)
				if obj.tail then
					str = str..obj.tail
				end
			end
		end
	end
	return str;
end

function HtmlText.playEffect(self)
	if self.tags then
		local tag=self.tags[#self.tags]
		if tag.playEffect then
			tag:playEffect()
		end
	end
end

function HtmlText.full(self)
	return self.str
end

function ui.htmlLabel:onNew()
	self:genTags()
end

function ui.htmlLabel:genTags(fullstr)
	if self.text and self.text~="" then
		self.htmltext=HtmlText:new(self.text, self ,self.fullstr )
		if self.multiline then
			local _, h=self.htmltext:buildTags(self)
			self.h = h
		else
			local _, h=self.htmltext:buildTags(self)
		end
	else
		self.htmltext=nil
	end
end


function ui.htmlLabel:setText(txt)
	self.text=txt
	self:genTags(self.fullstr)
end

function ui.htmlLabel.playEffect(self)
	self.htmltext:playEffect()
end

function ui.htmlLabel:onRender()
	if not self.htmltext then return; end
	self.htmltext:onRender(self.h)
end

function ui.htmlLabel:sub(num)
	if not self.htmltext then return 0; end
	self.htmltext:setNum(num)
end

function ui.htmlLabel:getLen()
	if not self.htmltext then return 0; end
	return self.htmltext.len
end
------------------- ui.pfx --------------
function ui.pfx:onNew()
	self.pfx = _ParticlePlayer.new()
	self:onShow()
end
local matrix0 = _Matrix2D.new()
function ui.pfx:onRender()
	if self.pfxplay and not ui.cliped(self) then
		local x, y = _rd.x, _rd.y
		_rd:push2DMatrix(matrix0)
			self.pfx:draw2D(x, y)
		_rd:pop2DMatrix()
	end
end

if  os.info.uiedit then 
	ui.pfx.onUpdate = function(self)
		if (self.res ~= '' and self.lres ~= self.res) or (tonumber(self.scale) and self.lscale ~= self.scale) or (tonumber(self.speed) and self.lspeed ~= self.speed) or (tonumber(self.loop) and self.lloop ~= self.loop )  then
			self:onShow()
		elseif self.reset then
			self:resetpfx()
			self.reset = false
		elseif self.etime and  self.etime<=os.now() then
			if self.pfx then
				self.pfx:stop()
				self.etime = nil
			end
		end
	end
end

function ui.pfx:resetpfx()
	if self.pfxplay and self.pfxplay.typeid and self.pfxplay.typeid == _Particle.typeid then
		self.pfx:reset()
		self:onShow()
	end
end

function ui.pfx:onShow()
	if not self.res or self.res == '' then return end
	self.pfx:stop()
	self.pfxplay = self.pfx:play2D(self.res , 0, 0 , self.scale)
	self.pfxplay.bind = self.bind
	self.lres = self.res
	self.lscale = self.scale
	self.lspeed = self.speed
	self.lloop = self.loop
	if tonumber(self.speed) and self.speed > 0 and tonumber(self.loop) and self.loop > 0 then
		self.etime = os.now() + self.speed * (self.loop + 1 )
	end
end

------------------- ui.swf --------------
function ui.swf:onShow()
	if not self.swf then
		if not self.res or self.res=='' then return end
		local ok, swf = pcall(_SWFManager.new, self.res)
		if not ok then print('WARN ui.swf:onShow', swf) return end
		self.swf = swf
		if self.swfsize and self.width and swf.height then
			ui.sizeTo(self, swf.width, swf.height)
		end
		self.swf.show = true
		self.swf:reset()
		self.swf.hitTestDisable = false
	end
end

function ui.swf:onHide()
	if self.swf then self.swf.show = false end
end

function ui.swf:onUpdate()
	if not self.swf then return end
	if self.res ~= '' and self.res ~= self.lres then
		self:onShow()
	end
	self.swf._x, self.swf._y = ui.pos(self)
	if self.swf.width then self.swf._xscale = 100 * self.w/self.swf.width end
	if self.swf.height then self.swf._yscale = 100 * self.h/self.swf.height end
end

function ui.swf:done()
	if self.swf then self.show, self.swf.show = false, false end
end

------------------- ui.slider --------------
function ui.slider:onNew()
	self.value = self.value < self.min and self.min or self.value
	self.value = self.value > self.max and self.max or self.value
end

function ui.slider:onUpdate()
	self.lstyle = self.lstyle or 0
	if self.style ~= self.lstyle then
		self.w, self.h = self.h, self.w
		self.bar.w, self.bar.h = self.bar.h, self.bar.w
		self.bar.align = ui.alignCM()
		self.btn.w, self.btn.h = self.btn.h, self.btn.w
		self.btn.align = ui.alignCM()
		self.lstyle = self.style
	end
	self.value = self.value < self.min and self.min or self.value
	self.value = self.value > self.max and self.max or self.value
	self.snapInterval = (self.snapInterval > (self.max - self.min) / 2 or self.snapInterval <= 0 )and (self.max - self.min) / 2 or self.snapInterval
	local len = self.max - self.min
	if self.style==0 then
		ui.moveTo(self.btn, (self.value-self.min)/len*(self.w-self.btn.w), self.btn.y)
	elseif self.style==1 then
		ui.moveTo(self.btn, self.btn.x, (self.value-self.min)/len*(self.h-self.btn.h))
	end
end

function ui.slider:setValue(value)
	if value ~= self.value then 
		self.value = value
		if self.change then self:change() end
	end
end

function ui.slider:throwEvent()
	if self.lvalue ~= self.value and self.realChange then 
		self:realChange(self.lvalue)
	end
end

function ui.slider.btn:onPush()
	if self.owner.disable then return end
	self.owner.lvalue = self.owner.value
end

function ui.slider.btn:onDrag()
	if self.owner.disable then return end
	self.owner:throwEvent()
end

function ui.slider.btn:onDraging(dx, dy)
	if self.owner.disable then return end
	local p = ui.parent(self)
	if p.style==0 then
		if self.x+dx < 0 then
			ui.moveTo(self, 0, self.y)
		elseif self.x+self.w+dx > p.w then
			ui.moveTo(self, p.w-self.w, self.y)
		else
			ui.moveTo(self, self.x+dx, self.y)
		end
	elseif p.style==1 then
		if self.y+dy < 0 then
			ui.moveTo(self, self.x, 0)
		elseif self.y+self.h+dy > p.h then
			ui.moveTo(self, self.x, p.h-self.h)
		else
			ui.moveTo(self, self.x, self.y+dy)
		end
	end
	local len = p.max - p.min
	local plen
	if p.style==0 then
		plen = p.btn.x/(p.w-p.btn.w)*len
	elseif p.style==1 then
		plen = p.btn.y/(p.h-p.btn.h)*len
	end
	if plen then 
		if p.snapping then 
			p:setValue(p.min + math.floor(plen/p.snapInterval)*p.snapInterval)
		else
			p:setValue(p.min + plen)		
		end		
	end
end

function ui.slider.bar:onPush()
	if self.owner.disable then return end
	self.owner.lvalue = self.owner.value
	local p = ui.parent(self)
	local x, y = ui.mousex, ui.mousey
	local ux, uy = ui.pos(self)
	p.getPushX, p.getPushY = x, y
	local plen
	if p.style==0 then
		plen = (x-ux)/(p.w-p.btn.w)*(p.max-p.min)
	elseif p.style==1 then
		plen = (y-uy)/(p.h-p.btn.h)*(p.max-p.min)
	end
	if plen then 
		if p.snapping then 
			p:setValue(p.min + math.floor(plen/p.snapInterval)*p.snapInterval)
		else
			p:setValue(p.min + plen)	
		end
	end
	if self.push then self:push() end
end

function ui.slider.bar:onClick()
	if self.owner.disable then return end
	self.owner:throwEvent()
end

function ui.slider.bar:onDrag()
	if self.owner.disable then return end
	self.owner:throwEvent()	
end

function ui.slider.bar:onDraging(dx, dy)
	if self.owner.disable then return end
	local p = ui.parent(self)
	p.btn:onDraging(ui.mousex - p.getPushX, ui.mousey - p.getPushY, full)
	p.getPushX, p.getPushY = ui.mousex, ui.mousey
end

------------------- ui.drag --------------
function ui.drag:onDraging(dx , dy ,full )
	if not self.disable then
		local p = ui.parent(self)
		p.align = ui.alignLT(p.x+dx , p.y+dy)
	end
end

------------------- ui.dropDownList -----
function ui.dropDownList:showList(isshow)
	local add_h = 0
	if isshow  then
		add_h = self.list.h
	end
	ui.show(self.list,isshow)
	ui.sizeTo(self , self.w, self.inputtext.h + add_h)
end

function ui.dropDownList.btn_dropdown:click()
	local p = ui.parent(self)
	p:showList(not p.list.show)

end

function ui.dropDownList.inputtext:click()
	local p = ui.parent(self)
	p.btn_dropdown:onClick()
end

function ui.dropDownList.list:onClick(full)
	ui.child()
	local p = ui.parent(self)
	p.btn_dropdown:onClick()
end

function ui.dropDownList:onUpdate()
	local focus = ui.focus()
	if focus ~= self and focus ~= self.list and focus ~= self.inputtext and focus ~= self.btn_dropdown then 
		local flag = false
		local b = ui.back(self.list)
		while b do 
			if focus == b then flag = true end
			b = ui.high(b)
		end
		if not flag then 
			self:showList(false)
		end
	end
end

----------------------ui.mesh-------------

function ui.mesh:onNew()
	self.role = self.role or _Mesh.new()
	if #self.mesh >0 then
		local subMeshes = self.role:getSubMeshs()
		local meshadd = false
		if #self.mesh ~= #subMeshes then
			meshadd = true
		else
			for i,v in ipairs(subMeshes) do
				if _sys:getFileName(self.mesh[i].res) ~= _sys:getFileName(v.resname) then
					meshadd = true
				break
				end
			end
		end
			if meshadd then
				self.role:clearSubMeshs()
				for i ,v in ipairs(self.mesh) do
					if _sys:getExtention(v.res) == 'skn' then
						local msh = _Mesh.new(_sys:getFileName(self.mesh[i].res))
						self.role:addSubMesh(msh)
					end
				end
			end
	else
		self.role:clearSubMeshs()
	end

	if self.skeleton and _sys:getExtention(self.skeleton)=='skl' then
		if self.role.skeleton == nil or _sys:getFileName(self.skeleton) ~= _sys:getFileName(self.role.skeleton.resname) then
			self.role.skeleton = _Skeleton.new(_sys:getFileName(self.skeleton))
			self.SklInfName =  _sys:getFileName(self.skeleton,false ,true)
			self.role.skeleton:loadInf(self.SklInfName..'.inf')
			self.infs = self.role.skeleton:getInfluences()
		end
	end

	if #self.animation > 0  and self.skeleton and _sys:getExtention(self.skeleton)=='skl' then
		if self.role.skeleton then
			local sans = self.role.skeleton:getAnimas()
			local flag= false
			local animas_num = self:AnimasCount()
			if #sans ~=animas_num then
				flag = true
			else
				local tempi = 1
				for i,v in ipairs(self.animation) do
					if _sys:getExtention(v.res) =='san' then
						if _sys:getFileName(v.res) ~= _sys:getFileName(sans[tempi].resname) then
							flag =true
							break
						else
							tempi = tempi + 1
						end
					end
				end
			end
			if flag then
				self.role.skeleton:clearAnimas()
				for i ,v in ipairs(self.animation) do
					if _sys:getExtention(v.res) =='san' then
						local san = self.role.skeleton:addAnima(_sys:getFileName(v.res))
						if i ==1  then
							san:play()
						end
					end
				end
			end
		end
	else
		if self.role.skeleton then
			self.role.skeleton:clearAnimas()
		end
	end
	if self.role.skeleton and #self.role.skeleton:getAnimas() > 0  then
		local sans = self.role.skeleton:getAnimas()
		if not sans[1].isPlaying then
			sans[1].loop = self.loop
			if self.loop then sans[1]:play()end
		else
			sans[1].loop = self.loop
		end
	end
	self.role.transform:setScaling(self.scale , self.scale , self.scale)
	self.tempscale = self.scale
	if self.mirror then self.role.transform:mulScalingLeft(1, -1, 1)end
	self.tempmirror = self.mirror
	self.tranx ,self.trany ,self.tranz = self.translation.x , self.translation.y ,self.translation.z
	self.role.transform:mulTranslationRight(self.tranx ,self.trany ,self.tranz)
end

function ui.mesh:AnimasCount()
	local count = 0
	if #self.animation > 0 then
		for i ,v in ipairs(self.animation) do
			if _sys:getExtention(v.res) == 'san' then
				count = count + 1
			end
		end
	end
	return count
end

function ui.mesh:setAni(loop, res)
	if _sys:getExtention(res) =='san' then
		local sans = self.role.skeleton:getAnimas()
		local  IsExist = false
		for i ,v in next , sans  do
			if v.name == res then
				IsExist = true
				local s = self.role.skeleton:getAnima(res)
				s:play()
				s.loop = loop
			end
		end
		if not IsExist then
			local san = self.role.skeleton:addAnima(_sys:getFileName(res))
			san.name = res
			san.loop = loop
			san:play()
		end
	end
end

function ui.mesh:setSkl(res, useinf)
	if _sys:getExtention(res) == 'skl' then
		self.skeleton = res
		if self.role.skeleton == nil or _sys:getFileName(self.skeleton) ~= _sys:getFileName(self.role.skeleton.resname) then
			self.role.skeleton = _Skeleton.new(_sys:getFileName(self.skeleton))
			self.SklInfName =  _sys:getFileName(self.skeleton,false ,true)
			self.role.skeleton:loadInf(self.SklInfName..'.inf')
			self.infs = self.role.skeleton:getInfluences()
			self.role.skeleton:stopAnimas()
			self.role.skeleton:clearAnimas()
		end
	end
	if useinf == '' then
		self.role.skeleton:resetInfluence()
	else
		for i,v in next , self.infs do
			if v == useinf then
				self.role.skeleton:useInfluence(i)
				break
			end
		end
	end
end

function ui.mesh:setMesh(res)
	if #self.mesh > 0 then
		self.mesh[1].res = res
		local subMeshes = self.role:getSubMeshs()
		local meshadd = false
		if #self.mesh ~= #subMeshes then
			meshadd = true
		else
			for i,v in ipairs(subMeshes) do
				if _sys:getFileName(self.mesh[i].res) ~= _sys:getFileName(v.resname) then
					meshadd = true
					break
				end
			end
		end
		if meshadd then
			self.role:clearSubMeshs()
			for i ,v in ipairs(self.mesh) do
				if _sys:getExtention(v.res) == 'skn' then
					local msh = _Mesh.new(_sys:getFileName(self.mesh[i].res))
					self.role:addSubMesh(msh)
				end
			end
		end
	else
	end
end


local faceVector = _Vector3.new()
function ui.mesh:onUpdate()
	self.role = self.role or _Mesh.new()
	if self.tempsklinf ~= self.setinf  and self.role.skeleton and #self.infs > 0 then
		if self.setinf == '' then
			self.role.skeleton:resetInfluence()
		else
			for i ,v in next , self.infs do
				if v == self.setinf then
					self.role.skeleton:useInfluence(i)
					self.tempsklinf = self.setinf
					break
				end
			end
		end

	end

	if #self.mesh >0 then
		local subMeshes = self.role:getSubMeshs()
		local meshadd = false
		if #self.mesh ~= #subMeshes then
			meshadd = true
		else
			for i,v in ipairs(subMeshes) do
				if _sys:getFileName(self.mesh[i].res) ~= _sys:getFileName(v.resname) then
					meshadd = true
				break
				end
			end
		end
			if meshadd then
				self.role:clearSubMeshs()
				for i ,v in ipairs(self.mesh) do
					if _sys:getExtention(v.res) == 'skn' and _sys:fileExist(self.mesh[i].res) then
						local msh = _Mesh.new(_sys:getFileName(self.mesh[i].res))
						self.role:addSubMesh(msh)
					end
				end
			end
	else
		self.role:clearSubMeshs()
	end

	if self.skeleton and _sys:getExtention(self.skeleton)=='skl' then
		if (self.role.skeleton == nil or _sys:getFileName(self.skeleton) ~= _sys:getFileName(self.role.skeleton.resname) ) and _sys:fileExist(self.skeleton) then
			self.role.skeleton = _Skeleton.new(_sys:getFileName(self.skeleton))
			self.SklInfName =  _sys:getFileName(self.skeleton,false ,true)
			self.role.skeleton:loadInf(self.SklInfName..'.inf')
			self.infs = self.role.skeleton:getInfluences()
		end
	end

	if #self.animation > 0  and self.skeleton and _sys:getExtention(self.skeleton)=='skl' then
		if self.role.skeleton then
			local sans = self.role.skeleton:getAnimas()
			local flag= false
			local animas_num = self:AnimasCount()
			if #sans ~=animas_num then
				flag = true
			else
				local tempi = 1
				for i,v in ipairs(self.animation) do
					if _sys:getExtention(v.res) =='san' then
						if _sys:getFileName(v.res) ~= _sys:getFileName(sans[tempi].resname) then
							flag =true
							break
						else
							tempi = tempi + 1
						end
					end
				end
			end
			if flag then
				self.role.skeleton:clearAnimas()
				for i ,v in ipairs(self.animation) do
					if _sys:getExtention(v.res) =='san' and _sys:fileExist(v.res) then
						local san = self.role.skeleton:addAnima(_sys:getFileName(v.res))
						if i ==1  then
							san:play()
						end
					end
				end
			end
		end
	else
		if self.role.skeleton then
			self.role.skeleton:clearAnimas()
		end
	end
	if self.role.skeleton and #self.role.skeleton:getAnimas() > 0 then
		local sans = self.role.skeleton:getAnimas()
		if not sans[1].isPlaying then
			sans[1].loop = self.loop
			if self.loop then sans[1]:play()end
		else
			sans[1].loop = self.loop
		end
	end
	if self.tempscale ~= self.scale then
		local mulscale = self.scale/self.tempscale
		self.tempscale = self.scale
		self.role.transform:mulScalingLeft(mulscale , mulscale , mulscale)
	end
	if self.tempmirror ~= self.mirror then
		self.tempmirror = self.mirror
		self.role.transform:mulScalingLeft(1, -1, 1)
	end
	if self.tranx ~= self.translation.x or self.trany ~= self.translation.y or self.tranz ~= self.translation.z then 
		self.role.transform:mulTranslationRight( self.translation.x - self.tranx,self.translation.y - self.trany ,self.translation.z - self.tranz)
		self.tranx ,self.trany ,self.tranz = self.translation.x , self.translation.y ,self.translation.z
	end
end

local matrix0 = _Matrix2D.new()

function ui.mesh:onRender()
	if not ui.cliped(self) then
		local x, y = _rd.x, _rd.y
		faceVector.x = self.vector.x
		faceVector.y  = self.mirror and -1 * self.vector.y or self.vector.y
		faceVector.z = self.vector.z
		_rd:push2DMatrix(matrix0)
		self.role:draw2D(faceVector , x, y)
		_rd:pop2DMatrix()
	end
end

--------------ui.imglabel-------------
local function letterMatch(u, char)
	for i , v  in next , u.imgtb do 
		if char == v.letter then 
			return i 
		end
	end
	return false
end

function ui.imglabel:Ischange()
	if self.oldtext ~= self.text or self.oldw ~= self.w or self.oldh ~= self.h or (self.res ~= self.oldRes and _sys:getExtention(self.res) == 'png' ) then return true end
	if self.oldpngw ~= self.pngw or self.oldpngh ~=  self.pngh then return true end
	for i ,v in ipairs(self.imgtb) do 
		if self.oldimgtb[i].i ~= v.i or self.oldimgtb[i].j ~= v.j or self.oldimgtb[i].shrink ~= v.shrink or self.oldimgtb[i].letter ~= v.letter then
			return true
		end
	end 
	return false
end
function ui.imglabel:onNew()
	self.row = self.h / self.pngh
	self.col = self.w / self.pngh
	self.hscale = self.hscale or self.h/self.pngh
	self.oldtext = self.text
	self.oldRes = self.res
	self.oldw  ,self.oldh = self.w , self.h
	self.oldpngw = self.pngw
	self.oldpngh = self.pngh
	self.oldimgtb = {}
	self.oldimgtb = copyTable(self.imgtb)
	self.resStr = {}
	if _sys:getExtention(self.res) == 'png' then 
		local b , n =1
		self.resStr = {}
		local tempx2 = 0
		local caret = self.text:ulen()
		for i = 1 ,caret do 
			local u = self.text:byte(b)
			n = u <128 and 1 or u<0xE0 and 2  or 3
			local char = self.text:sub(b ,b +n -1)
			local str = {}
			local img = _Image.new(self.res)
			local index = letterMatch(self,char)
			if index  then 
				local imgtbindex = self.imgtb[index]
				if imgtbindex then 
					local rect = _Rect.new((imgtbindex.j -1) * self.pngw + imgtbindex.shrink/2,(imgtbindex.i -1) * self.pngh, imgtbindex.j  * self.pngw - imgtbindex.shrink/2 , imgtbindex.i  * self.pngh)
					img.rect = rect
					str[1] = img
					str[3] = 0 --y
					str[2] = tempx2 
					tempx2 = tempx2 + self.pngw - imgtbindex.shrink
					str[4] = tempx2
					table.insert(self.resStr,str)
				end
			end
			b = b + n
		end
		if caret > 0  and self.w < self.resStr[#self.resStr][4]*self.hscale then self.w = self.resStr[#self.resStr][4]*self.hscale end
	end
end

function ui.imglabel:onUpdate()
	if  self:Ischange() and _sys:getExtention(self.res) == 'png' then
		local b , n =1
		self.resStr = {}
		local caret = self.text:ulen()
		local tempx2 = 0
		if self.oldh ~= self.h or self.oldpngh ~= self.pngh  then 
		self.hscale = self.h / self.pngh
		self.w = self.w * self.h / self.oldh
		end
		for i = 1 ,caret do 
			local u = self.text:byte(b)
			n = u <128 and 1 or u<0xE0 and 2  or 3
			local char = self.text:sub(b ,b +n -1)
			local str = {}
			local img = _Image.new(self.res)
			local index = letterMatch(self,char)
			if index  then 
				local imgtbindex = self.imgtb[index]
				if imgtbindex then 
					local rect = _Rect.new((imgtbindex.j -1) * self.pngw + imgtbindex.shrink/2,(imgtbindex.i -1) * self.pngh, imgtbindex.j  * self.pngw - imgtbindex.shrink/2 , imgtbindex.i  * self.pngh)
					img.rect = rect
					str[1] = img
					str[3] = 0 --y
					str[2] = tempx2 
					tempx2 = tempx2 + self.pngw - imgtbindex.shrink
					str[4] = tempx2
					table.insert(self.resStr,str)
				end
			end
			b = b + n
		end
		if caret > 0 and self.w < self.resStr[#self.resStr][4]*self.hscale then self.w = self.resStr[#self.resStr][4]*self.hscale end
		self.oldtext = self.text
		self.oldRes = self.res
		self.oldpngw , self.oldpngh = self.pngw , self.pngh
		self.oldw  ,self.oldh = self.w , self.h
	end
end
function ui.imglabel:onRender()
	if #self.resStr > 0 then
		local font = self.font 
		local x = 0
		if font.align == 'lt' or font.align =='lm' or font.align =='lb' then 
			x = 0
		elseif font.align == 'ct' or font.align =='cm' or font.align =='cb' then 
			x = (self.w - self.resStr[#self.resStr][4]*self.hscale)/2
		else
			x = self.w - self.resStr[#self.resStr][4]*self.hscale
		end
		for i , v in next , self.resStr do 
			v[1]:drawImage(x + self.hscale *v[2] ,self.hscale* v[3] ,x + self.hscale*v[4] ,self.hscale*(v[3] + self.pngh))
		end
	end
end

------------------ui.clipper----------------

function ui.clipper:onRender(full)
	_rd:useClip(_rd.x, _rd.y, _rd.x + self.w, _rd.y + self.h)
	ui.child()
	_rd:popClip()
end

function ui.clipper:onDraging(dx, dy, full)
	if not self.dragEnable then  return end
	local child = ui.back(self)
	if not child then return end
	local x_add  = self.dragx and dx - self.dragx or dx
	local y_add = self.dragy and dy - self.dragy or dy
	self.dragx = dx - x_add
	self.dragy = dy - y_add
	local x , y = ui.pos(self)
	local x1 , y1 = ui.pos(child)
	local x1, y1 = x1 - x , y1 -y
	local x2, y2 = x1 + child.w, y1 + child.h
	if  x1 + x_add > 0  then 
		x_add =  -x1
	end
	if x2 + x_add < self.w then
		x_add = self.w - x2
	end

	if y1 + y_add > 0 then
		y_add = - y1
	end
	if y2 + y_add < self.h then
		y_add = self.h - y2
	end
	self.dragx = dx-x_add
	self.dragy = dy-y_add
	ui.moveDiff(child, x_add, y_add)
end 

function ui.clipper:onDrop(full)
	self.dragx, self.dragy = nil
end

----------------------ui.color---------------------
local function changeColor(self)
	local color = (tonumber(self.rgb, 16))%0x1000000
		+ 0x1000000*toint(255/100*math.max(0, math.min(100,toint(self.alpha))), 0.5)
		self.rgb = ('%06x'):format(color%0x1000000)
		self.alpha = toint(color/0x1000000/255*100, 0.5)
	return color
end

function ui.color:onNew()
	--init
	self.alpha = self.alpha or 100
	self.rgb = self.rgb or string.format('%06x', 0xffffff)
	self.color = self.color or changeColor(self)
	self.lalpha = self.alpha
	self.lrgb = self.rgb
end

function ui.color:onClick()
	self.color = _sys:selectColor(self.color) -- alpha is 100
	self.rgb = string.format('%06x', self.color%0x1000000)
	self.color = changeColor(self)
	if self.click then 
		self:click()
	end
end

function ui.color:onUpdate()
	if self.lalpha ~= self.alpha or self.lrgb ~= self.rgb then 
		self.color = changeColor(self)
		self.lalpha = self.alpha 
		self.lrgb = self.rgb
		self.lcolor = self.color
	end
	if self.lcolor ~= self.color then
		self.rgb = string.format('%06x', self.color%0x1000000)
		self.alpha = toint(self.color%0x100000000/0x1000000/255*100, .5)
		self.color = changeColor(self)
		self.lalpha = self.alpha 
		self.lrgb = self.rgb
		self.lcolor = self.color
	end
end

function ui.color:getColor()
	return '0x'..string.format('%x', self.color)
end

function ui.color:setColor(color)
	local c = self.color
	if type(color) == 'string' then 
		self.color = tonumber(color, 16)
	elseif type(color) == 'number' then 
		self.color = color
	end	
	if c ~= self.color and self.change then 
		self:change()
	end
end

function ui.color:onRender() 
	if ui.focus() == self then 
		_rd:fillRect(0, 0, self.w, self.h/11, 0xff08769B)
		_rd:fillRect(0, self.h-self.h/11 ,self.w ,self.h/11, 0xff08769B)
		_rd:fillRect(0, self.h/11, self.w/11, self.h-self.h/11 ,0xff08769B)
		_rd:fillRect(self.w-self.w/11, self.h/11, self.w/11, self.h-self.h/11, 0xff08769B)
	end
	_rd:fillRect(self.w/11, self.h/11, self.w-self.w/5.5, self.h-self.h/5.5, self.color)
end

----------------ui.window---------------
local function appcursor(self) --changecursor
	local x ,y = ui.pos(self)
	local mousex ,mousey = ui.mousex, ui.mousey
	self.dragl ,self.dragr, self.dragt, self.dragb = false, false, false, false
	if mousex <= x + 3 then 
		self.dragl = true
		_app.cursor = 'sizewe'
		return
	end
	if mousex >= x + self.w - 3 then 
		self.dragr = true
		_app.cursor = 'sizewe'
		return
	end
	if mousey <= y + 3 then 
		self.dragt = true
		_app.cursor = 'sizens'
		return 
	end
	if mousey >= y + self.h - 3 then 
		self.dragb = true
		_app.cursor = 'sizens'
		return
	end 
	self.dragl ,self.dragr, self.dragt, self.dragb = false, false, false, false
	_app.cursor = 'arrow'
end

local function windowStretch(self)--stretch window
	local x, y = ui.pos(self)
	local mousex, mousey = ui.mousex, ui.mousey
	local resizew, resizeh = self.w, self.h
	local movex,movey = x, y
	if self.dragl then 
		resizew = self.w + x - mousex
		movex = mousex
	elseif self.dragr then 
		resizew =  mousex - x 
		movex = x 
	elseif self.dragt then 
		resizeh = self.h + y - mousey
		movey = mousey
	elseif self.dragb then 
		resizeh = mousey - y
		movey = y
	end
	if resizew > self.maxweight then 
		resizew = self.maxweight
	elseif resizew < self.minweight then 
		resizew = self.minweight
	end
	if resizeh > self.maxheight then
		resizeh = self.maxheight 
	elseif resizeh < self.minheight then
		resizeh = self.minheight
	end
	if (resizew == self.maxweight or resizew == self.minweight) and self.enablemove then 
		if self.dragl then 
			movex = mousex
		elseif self.dragr then
			movex = mousex - resizew
		end
	end
	if (resizeh == self.maxheight or resizeh == self.minheight) and self.enablemove then 
		if self.dragt then 
			movey = mousey
		elseif self.dragb then 
			movey = mousey - resizeh
		end
	end
	ui.sizeTo(self, resizew, resizeh)
	ui.moveTo(self, movex, movey)
	ui.position(self)
end

local function windowMove(self) --movewindow backup
	local x ,y = ui.pos(self)
	local mousex, mousey = ui.mousex, ui.mousey
	if self.dragl then 
		ui.moveTo(self, mousex, y)
	elseif self.dragr then 
		ui.moveTo(self, mousex - self.w, y)
	elseif self.dragt then 
		ui.moveTo(self, x, mousey)
	elseif self.dragb then
		ui.moveTo(self, x, mousey - self.h)
	end
end


function ui.window:onUpdate()
	if self.onHovering then 
		if not self.dragging then appcursor(self) end
	end
	if self.dragging then 
		windowStretch(self)
	end
end

function ui.window:onHover(full)
	self.onHovering = true
	ui.child()
end

function ui.window:onPush(full)
	if self.dragl or self.dragr or self.dragt or self.dragb then 
		self.dragging = true
	end
	ui.child()
end
function ui.window:onDraging(full)
	ui.child()
end

function ui.window:onUnhover(full)
	self.onHovering = false
	_app.cursor = 'arrow'
	ui.child()
end

function ui.window:onDrag(full)
	_app.cursor = 'arrow'
	self.dragging = false
	self.dragl ,self.dragr, self.dragt, self.dragb = false, false, false, false
end

-------------------------ui.obliqueList---------------------for mobile
local qa = {}

function ui.obliqueList:onNew()
	self.Z = 0
	self.offset = 0
end

function ui.obliqueList:onUpdate(full)
	ui.super()
	local b = ui.back(self)
	while b and not b.show do b = ui.high(b) end
	if not b then return end
	if self.forceq then 
		local ba, u = b.align, b
		if not ba then 
			ba = ui.alignLTQ(0,0,nil,0) b.align = ba
		elseif ba[13] ~= qa then 
			ba[12], ba[13] = ba[12] or not ba[11] and 0, qa
		end
		while u do 
			local a = u.align
			if not a then 
				u.align = ui.align(unpack(b.align))
			elseif a[13] ~= qa then 
				a[11], a[12], a[13] = a[11] or ba[11], a[12] or ba[12], qa
			end
			u = ui.high(u)
		end
	end
	local dragd, hv = self.dragd, self.lateral 
	if b and (not self.dragingd or self.dragingd == 0) and self.Z then 
		local wh = hv and self.w or self.h
		local p99 = math.min(wh - self.Z, 0)
		local p0, p9 = self.offset or 0, (self.offset or 0) - p99
		local dxy = hv and (b.align[12] and b.align[12] or 0) or (b.align[11] and b.align[11] or 0) 
		local dxy = 0
		if dragd then 
			dragd = p0 > 0 and dragd*0.8*(1-p0/wh) or p9 < 0 and dragd*0.8*(1+p9/wh) or dragd*(os.now() - self.dragt < 200 and 1 or 0.92)
			if math.abs(dragd) <= (p0 <= 0 and p9 >= 0 and 1.5 or 5) then 
				dragd = nil
				local xy = toint(hv and b.x or b.y)
				self.offset = p0 + toint(xy) - (hv and b.x or b.y)
				if b.align and b.align[11] and b.align[12] then 
					ui.moveDiff(b, not hv and (b.w + b.align[11])*(xy-b.y)/(b.h + b.align[12]), hv and (b.h + b.align[12])*(xy-b.y)/( b.w + b.align[11]))
				end
				ui.moveTo(b, hv and xy, not hv and xy)

			else
				self.offset = p0 + dragd
				ui.moveDiff(b, hv and dragd , not hv and dragd)
				--oblique 
				if dragd ~= 0 and b.align and b.align[11] and b.align[12] then 
					ui.moveDiff(b, not hv and (b.w + b.align[11])*dragd/(b.h + b.align[12]), hv and (b.h + b.align[12])*dragd/( b.w + b.align[11]))
				end
				ui.position(b)
			end
		elseif p0 > dxy or p9 < -dxy then 
			if not self.outd or (self.outd > 0) ~= (p0 > 0)then 
				self.outd, self.dragt = (p0 > 0 and p0 or p9)*0.6, os.now()
			else
				local t = (os.now()-self.dragt)/2000
				local p = toint(self.outd - self.outd*math.cos(math.max(1-t, 0)^10*2.3))
				if p0 <= 0 then p = p + p99 end
				self.offset = p
				ui.moveTo(b, hv and p + b.x - p0, not hv and p + b.y - p0)
				if b.align and b.align[11] and b.align[12] then 
					ui.moveDiff(b, not hv and (b.w + b.align[11])*(p-p0)/(b.h + b.align[12]), hv and (b.h + b.align[12])*(p-p0)/( b.w + b.align[11]))
				end
			end
		end
	end
	ui.child()
	self.dragd = dragd
	local f = ui.front(self)
	while f and not f.show do f = ui.low(f) end
	if f then 
		self.Z = (hv and f.x + f.w or f.y + f.h) - (self.offset or 0)
	end
end
 
function ui.obliqueList:onRender(full)
	ui.super()
	_rd:useClip(_rd.x, _rd.y, _rd.x + self.w, _rd.y + self.h)
	ui.child()
	_rd:popClip()
end

function ui.obliqueList:onPush(full)
	self.dragingd, self.dragd,  self.drag0, self.drag9, self.dragt, self.outd = 0 
	self.push = ui.push() 
	self.dragxx, self.dragyy = ui.mousex, ui.mousey
	self.dragx, self.dragy = nil
	if self.Push then self:Push() end
	ui.child()
	if type(ui.child()) ~= 'number' then ui.child(4) end
end

function ui.obliqueList:onDraging(dx, dy, full)
	if self.banDraging then return end
	ui.super()
	if not ui.child() then return end
	if not self.Z then return end
	local b = ui.back(self)
	while b and not b.show do b = ui.high(b) end
	if not b then return end
	local hv = self.lateral 
	local p99 = math.min((hv and self.w or self.h) - self.Z, 0)
	local p0, p9, d = self.offset or 0, (self.offset or 0) - p99, hv and dx or dy
	self.drag0 = p0 > 0 and math.min(p0, self.drag0 or 1/0) or 0
	self.drag9 = p9 < 0 and math.max(p9, self.drag9 or -1/0) or 0
	p0, p9 = p0 - self.drag0, p9 - self.drag9
	if p0 < 0 and p9 > 0 then
		if self.push == self then 
			local tdx, tdy = 0, 0
			if hv then 
				tdx = self.dragx and dx - self.dragx or dx 
			else 
				tdy = self.dragy and dy - self.dragy or dy
			end
			self.dragx = dx
			self.dragy = dy
			dx, dy = tdx, tdy
		end
	else 
		if self.push == self then 
			dx = ui.mousex - self.dragxx - (self.dragx or 0)
			dy = ui.mousey - self.dragyy - (self.dragy or 0)
		end
	end
	d =  hv and dx or dy 
	d = d + p0 > 0 and toint(d*0.4 - p0*0.6) or d + p9 < 0 and toint(d*0.4 - p9*0.6) or d
	self.dragingd = (d+(self.dragingd or d))/2
	self.offset = (self.offset or 0) + d
	ui.moveDiff(b, hv and d, not hv and d)
	--oblique
	if d ~= 0 and b.align and b.align[11] and b.align[12] then 
		ui.moveDiff(b, not hv and (b.w + b.align[11])*d/(b.h + b.align[12]), hv and (b.h + b.align[12])*d/( b.w + b.align[11]))
	end
	ui.child(false)
end

function ui.obliqueList:onDrag(full)
	ui.super() ui.child()
	self.push = nil
	self.dragd, self.dragt, self.dragingd, self.drag0, self.drag9 = self.dragingd*0.9, os.now()
end

function ui.obliqueList:onDrop(full)
	ui.child()
	self.push = nil
	self.dragx, self.dragy, self.dragxx, self.dragyy = nil
end

function ui.obliqueList:banDrag(t)
	self.banDraging = t
end

-------------------ui.accordin----------------------

function ui.accordin:onNew()
	local lo, o = self.owner, self.owner
	while o ~= ui do 
		if ui.is(ui.list, o) then lo = o end
		o = o.owner
	end
	self.clipo = lo
end

function ui.accordin:onRender(full)
	_rd:useClip(_rd.x, _rd.y, _rd.x + self.w, _rd.y + self.h)
	if not self.cliped then 
		ui.drawImg(self, self.backgs)
		ui.child() 
	end
	_rd:popClip()
end

function ui.accordin:onUpdate(full)
	local x, y = ui.pos(self, self.clipo)
	if x > self.clipo.w or x + self.w < 0 or y > self.clipo.h or y + self.h < 0 then 
		self.cliped = true
	else
		self.cliped =false
		ui.child()
	end  
end

function ui.accordin:collapse(u)
	self.h = u.y + u.h
	self.folding = true
end

function ui.accordin:expand()
	local b = ui.back(self)
	local min = 0
	while b do 
		if b.show then 
			min = min > b.y + b.h and min or b.y + b.h
		end
		b = ui.high(b)
	end
	self.h = min
	self.folding = false
end

---------------------ui.treenode-----------------------------

function ui.treenode:getNodeNum()
	return self.nodenum or 0
end

function ui.treenode:onNew()
	if ui.is(ui.treenode, self.owner) then 
		self.tree = self.owner.tree	
	else 
		self.tree = self
	end
end

function ui.treenode:addNode(o, key, after)
	self.nodenum = self.nodenum and self.nodenum+1 or 1
	local panel = self.panel
	if not o then o = self^{} end
	self.new[key == nil and #self + 1 or key] = o
	if after then assert(ui.parent(after) == panel) ui.low(o, after)
	else ui.front(panel, o)
	end
	if not o.align then o.align = ui.alignLT() end
	o.align[11], o.align[12], o.align[13] = false, o.align[12] or 0, self
	o.tree = self.tree
	o.show = self.expanded
	if self.expanded then self:updateSize() end
	return o
end

function ui.treenode:removeNode(o)
	if o.owner == self then self.nodenum = self.nodenum - 1 ui.remove(nil, o)end
	if self.expanded then self:updateSize() end
end

function ui.treenode:clear()
	while ui.front(self.panel) do 
		ui.remove(nil, ui.front(self.panel))
		self.nodenum = self.nodenum - 1
	end
	if self.expanded then self:updateSize() end
end

function ui.treenode:updateSize()
	self.panel.show = self.expanded
	if self.expanded then 
		ui.position(self.panel)
		local o = ui.back(self.panel)
		while o do ui.position(o) o = ui.high(o) end
		o = ui.front(self.panel)
		ui.sizeTo(self.panel, nil, o and o.y + o.h or 0)
		ui.sizeTo(self, nil, self.panel.y + self.panel.h)
	else
		ui.sizeTo(self.panel, nil, 0)
		ui.sizeTo(self, nil, self.panel.y + self.panel.h)
	end
	if ui.is(ui.treenode, self.owner) then 
		self.owner:updateSize() 
	end
end

function ui.treenode:onClick()
	if os.now() - (self.clickt or 0) > 300 then
		self.clickt = os.now()
		if self.click then self:click() end
	else
		self.clickt = 0
		if self.doubleClick then self:doubleClick() end
	end
end

function ui.treenode:onPush()
	if self.tree.selectNode then self.tree.selectNode.selected = false end
	self.tree.selectNode = self
	self.selected = true
	-- self.focus = true
end

function ui.treenode:expand(expanded)
	if expanded == nil then expand = not self.expanded
	else expanded = not not expanded
	end
	self.expanded = expanded
	local u  = ui.back(self.panel)
	while u do u.show = expanded u = ui.high(u) end
	self:updateSize()
end

function ui.treenode:onRender(full)
	ui.super()
	local bg = (self.selected and self.bgselect or ui.push(self) and self.bgpush or
	 ui.hover() and (ui.hover() == self or ui.parent(ui.hover()) == self) and self.bghover) or self.bgidle
	if bg then bg:drawImage(0, 0, self.w, self.panel.y-2) end
	ui.child()
end

----------------------ui.affector----------------------

function ui.affector:onNew()
	self.points = {}
	self.selectP = nil
	self.PointHoverColor = 0xff68b2f2
	self.PointSelectColor = _Color.Green
end

function ui.affector:onClick()
	if self.click then self:click() end
end

local function cmp(a, b)
	return a.x < b.x or (a.x == b.x and a.index < b.index)
end

function ui.affector:insertPoint(point)
	local tx, ty = point.x, point.y
	table.insert(self.points, point)
	table.sort(self.points, cmp)
	for i, v in ipairs(self.points) do 
		if v.x == tx and v.y == ty then 
			return i
		end
	end
end

function ui.affector:onPush()
	if self.disable then return end
	local selected = false
	self.selectP = nil
	if self.points and #self.points > 0 then 
		for i, v in ipairs(self.points) do 
			if v.hover then 
				self.selectP = i
				selected = true
			end
		end
	end
	if not selected then 
		local x, y = ui.pos(self)
		self.selectP = self:insertPoint{x = ui.mousex - x, y = ui.mousey - y, index = os.now()}
		if self.onChange then self:onChange() end
	end

end

function ui.affector:onKey(k, c)
	if self.disable then return end
	if k == _System.KeyDel then
		if self.selectP then
			table.remove(self.points, self.selectP)
			table.sort(self.points, cmp)
			if self.onChange then self:onChange() end
			self.selectP = #self.points
			if self.onDelEvent then self.onDelEvent() end
		end
	end
end

function ui.affector:onDraging(dx, dy,full)
	if not self.selectP then return end
	local x, y = ui.pos(self)
	local mx, my = ui.mousex - x, ui.mousey - y
	local edge = {x1 = 0, y1 = 0, x2 = self.w, y2 = self.h }
	for i, v in ipairs(self.points) do 
		if i == self.selectP -1 then 
			edge.x1 = v.x
		elseif i == self.selectP + 1 then
			edge.x2= v.x
		end
	end
	if mx >= edge.x1 and mx <= edge.x2  then 
		self.points[self.selectP].x = mx      
	elseif dx and dx < 0 then 
	     self.points[self.selectP].x =  edge.x1   
	elseif dx and dx > 0 then 
		self.points[self.selectP].x =  edge.x2       
	end
	if my >= edge.y1 and my <= edge.y2 then 
		self.points[self.selectP].y = my
	elseif dy and dy < 0 then 
		self.points[self.selectP].y = edge.y1
	elseif dy and dy > 0 then 
		self.points[self.selectP].y = edge.y2
	end
	if self.onChange then self:onChange() end
end

function ui.affector:onHovering()
	if self.disable then return end
	if not self.points or #self.points == 0 then return end
	local x, y = ui.pos(self)
	local mx, my = ui.mousex - x, ui.mousey - y
	for i, v in ipairs(self.points) do 
		if mx >= v.x -3 and mx <= v.x + 3 and my >= v.y -3 and my <= v.y + 3 then 
			v.hover = true
		else 
			v.hover = false
		end  
	end
end

function ui.affector:onUpdate()
	if self.hovering then self:onHovering() end
end

function ui.affector:onRender()
	local lpoint = nil
	for i, v in ipairs(self.points) do 
		if lpoint then 
			_rd:drawLine(lpoint.x ,lpoint.y, v.x, v.y, _Color.White, true)
		end
		if v.hover then 
			_rd:drawRect(v.x - 3, v.y - 3, 6, 6, self.PointHoverColor)
		elseif self.selectP == i then 
			_rd:drawRect(v.x - 2, v.y - 2, 4, 4, self.PointSelectColor)
		else
			_rd:drawRect(v.x - 1, v.y - 1, 2, 2, _Color.White)
		end
		lpoint = v
	end
end

function ui.affector:onHover()
	self.hovering = true
end

function ui.affector:onUnhover()
	self.hovering = false
end

function ui.affector:getData()
	local data = {}
	for i, v in ipairs(self.points) do 
		table.insert(data, {x = v.x / self.w, y = (self.h - v.y) / self.h})
	end
	return data
end

function ui.affector:setData(data)
	self.points = {}
	local t = os.now()
	for i, v in ipairs(data) do 
		table.insert(self.points, {x = math.floor(v.x * self.w), y = math.floor( (1 - v.y) * self.h), index = t})
		t = t + 1
	end
	if self.onChange then self:onChange() end
end

function ui.affector:getValue(p)
	if not p or not self.points[p] then return end
	local point = self.points[p]
	return {x = point.x / self.w, y = (self.h - point.y) / self.h} 
end

--------------ui.checkbox1-----------------------Checkbox with hover
local blender = _Blender.new()
function ui.checkbox1:onRender()
	if self.disable then  _rd:useBlender(blender:blend(_Color.Gray))end
	local i = self.select and self.bgselect or self.bgidle
	if i then ui.drawImg(self, i) end
	if not self.disable then 
		local hover = ui.hover(self) and (self.select and self.hoverselect or self.hoveridle)
		if hover then ui.drawImg(self, hover) end
	end
	if self.disable then _rd:popBlender() end
end

------------ui.size -------------------------------
function ui.size:onUpdate()
	local p = ui.parent(self)
	if p == ui then return end
	if ui.hover() == self then 
		if self.corner == 'lt' or self.corner == 'rb' then 
			if p.w == self.minw or p.w == self.maxw then
				_app.cursor = 'sizens'
			elseif p.h == self.minh or p.h == self.maxh then 
				_app.cursor = 'sizewe'
			else
		    	_app.cursor = 'sizenwse'
		    end
		elseif self.corner == 'lb' or self.corner == 'rb' then 
			if p.w == self.minw or p.w == self.maxw then 
				_app.cursor = 'sizens'
			elseif p.h == self.minh or p.h == self.maxh then 
				_app.cursor = 'sizewe'
			else
		    	_app.cursor = 'sizenesw'
		    end
		end
		if bghover then 
			bghover:drawImage(0, 0, self.w, self.h)
		end
	end
end
function ui.size:onDraging(dx, dy, full)
	local p = ui.parent(self)
	if p == ui then return end
	local mousex, mousey = ui.mousex, ui.mousey
	local x, y = ui.pos(p)
	local resizew, resizeh = p.w, p.h
	local movex, movey = x, y
	if self.corner == 'lt' then 
		resizew = p.w + x - mousex
		resizeh = p.h + y - mousey
	elseif self.corner == 'rt' then 
		resizew =  mousex - x 
		resizeh = p.h + y - mousey			
	elseif self.corner == 'lb' then 
		resizew = p.w + x - mousex
		resizeh = mousey - y	
	elseif self.corner == 'rb' then 
		resizew = mousex - x
		resizeh = mousey - y		
	end
	if resizew > self.maxw or resizew < self.minw or resizeh > self.maxh or resizeh < self.minh  then 
		if resizew > self.maxw then 
			resizew = self.maxw
		elseif resizew < self.minw then 
			resizew = self.minw
		end
		if resizeh > self.maxh then 
			resizeh = self.maxh
		elseif resizeh < self.minh then 
			resizeh = self.minh
		end
	else 	
		if self.corner == 'lt' then 
			movex = mousex		
			movey = mousey
		elseif self.corner == 'rt' then 
			movey = mousey
		elseif self.corner == 'lb' then 
			movex = mousex
		elseif self.corner == 'rb' then 
		end
	end	
	ui.sizeTo(p, resizew, resizeh)
	ui.moveTo(p, movex, movey)
end

function ui.size:onDrag(b)
	_app.cursor = 'arrow'
end

function ui.size:onUnhover()
	_app.cursor = 'arrow'
end

-------------------------ui.size1----------------------------

function ui.size1:onUpdate()
	local p = ui.parent(self)
	if p == ui then return end
	if ui.hover() == self then 
		if self.corner == 'l' or self.corner == 'r' then 
			_app.cursor = 'sizewe'
		elseif self.corner == 't' or self.corner == 'b' then 
			_app.cursor = 'sizens'
		end
		if bghover then 
			bghover:drawImage(0, 0, self.w, self.h)
		end
	end
end

function ui.size1:onDraging(dx, dy, full)
	local p = ui.parent(self)
	if p == ui then return end
	local mousex, mousey = ui.mousex, ui.mousey
	local x, y = ui.pos(p)
	local resizew, resizeh = p.w, p.h
	local movex, movey = x, y
	if self.corner == 'l' then 
		resizew = p.w + x - mousex
	elseif self.corner == 't' then 
		resizeh = p.h + y - mousey			
	elseif self.corner == 'b' then 
		resizeh = mousey - y	
	elseif self.corner == 'r' then 
		resizew = mousex - x
	end
	if resizew > self.maxw or resizew < self.minw or resizeh > self.maxh or resizeh < self.minh  then 
		if resizew > self.maxw then 
			resizew = self.maxw
		elseif resizew < self.minw then 
			resizew = self.minw
		end
		if resizeh > self.maxh then 
			resizeh = self.maxh
		elseif resizeh < self.minh then 
			resizeh = self.minh
		end
	else 	
		if self.corner == 'l' then 
			movex = mousex		
		elseif self.corner == 't' then 
			movey = mousey
		elseif self.corner == 'b' then 
		elseif self.corner == 'r' then 
		end
	end	
	ui.sizeTo(p, resizew, resizeh)
	ui.moveTo(p, movex, movey)
end

function ui.size1:onDrag(b)
	_app.cursor = 'arrow'
end

function ui.size1:onUnhover()
	_app.cursor = 'arrow'
end

------------------------------ ui.button1 --------------------- select > push > hover > idle
function ui.button1:onRender(full)
	if self.disable then _rd:useBlender(ble:gray()) end
	ui.super()
	local push = not self.disable and ui.push(self)
	if push then _rd:pushMul2DMatrixLeft(mat:setTranslation(0, self.pushy)) end
	if self.bg then
		local bg = not self.disable and  (self.select and self.bgselect or ui.push(self) and self.bgpush or
		 ui.hover(self) and self.bghover ) or self.bgidle
		if bg then ui.drawImg(self, bg) end
	end
	local fg = not self.disable and (self.select and 'fgselect' or
		ui.push(self) and 'fgpush' or ui.hover(self) and 'fghover') or 'fgidle'
	fg = self[fg]
	if fg then
		if getmetatable(fg)==_Image then fg = self.fg==1 and fg else fg = fg[self.fg] end
	end
	if not fg then
		fg = self.fgidle if fg then
			if getmetatable(fg)==_Image then fg = self.fg==1 and fg else fg = fg[self.fg] end
		end
	end
	if fg then ui.drawImg(self, fg) end
	if self.text and self.text ~= '' then
		local x, y = ui.pos(self)
		_rd:useClip(x, y, x+self.w, y+self.h)
		self.font:drawText(0, 0, self.w, self.h, self.text)
		_rd:popClip()
	end
	ui.child()
	if push then _rd:pop2DMatrix() end
	if self.disable then _rd:popBlender() end
end

function ui.button1:onUpdate()
	if ui.hover() == self then hoverClock(self) 
	else
		stopHoverClock(self)
	end
end

function ui.button1:onClick()
	if self.disable then return end
	if  os.now() - (self.clickt or 0) > 300  then
		self.clickt = os.now()
		if self.radio then
			for k, v in next, self.owner do
				if k ~= 'owner' then
					if ui.is(ui.button1, v) then v.select = false end
				end
			end
			self.select = true
		end
		if self.click then --click
			self:click()
		end
	else
		--doubleClick
		self.clickt = 0
		if self.doubleClick then
			self:doubleClick()
		end
	end
end
function ui.button1:onLongHover()
	if not self.banRollText then startRoll(self)end
end
function ui.button1:onUnhover()
	endRoll(self)
end

------------------- ui.color1 ----------------------- alpha render independently
function ui.color1:onNew()
	self.alpha = self.alpha or 100
	self.rgb = self.rgb or string.format('%06x', 0xffffff)
	self.color = self.color or changeColor(self)
	self.lalpha = self.alpha
	self.lrgb = self.rgb
end

function ui.color1:onUpdate()
	if self.lalpha ~= self.alpha or self.lrgb ~= self.rgb then 
		self.color = changeColor(self)
		self.lalpha = self.alpha 
		self.lrgb = self.rgb
		self.lcolor = self.color
	end
	if self.lcolor ~= self.color then
		self.rgb = string.format('%06x', self.color%0x1000000)
		self.alpha = toint(self.color%0x100000000/0x1000000/255*100, .5)
		self.color = changeColor(self)
		self.lalpha = self.alpha 
		self.lrgb = self.rgb
		self.lcolor = self.color
	end
end

function ui.color1:onRender()
	-- Render RGB
	_rd:fillRect(1, 1, self.w -2, self.h * 0.8, tonumber('0xff'..self.rgb))
	-- Redner Alpha
	_rd:fillRect(1, self.h * 0.8 + 1, (self.w -2) * self.alpha / 100, self.h * 0.2 - 2 ,_Color.White)
	_rd:fillRect((self.w -2) * self.alpha / 100 + 1, self.h * 0.8 + 1, (self.w -2) * (1 - self.alpha / 100), self.h * 0.2 - 2, _Color.Black)	
end

function ui.color1:getColor()
	return '0x'..string.format('%x', self.color)
end

function ui.color1:setColor(color)
	if type(color) == 'string' then 
		self.color = tonumber(color, 16)
	elseif type(color) == 'number' then 
		self.color = color
	end
end

------------------------ ui.colorPicker ----------------------
local function modeFocusOne(r, g, b, mode)
	local c1, c2, c3, c4
	c1 = 0xff000000 + (mode==0 and r or mode==1 and 0xff or 0)*0x10000 + (mode==1 and g or 0xff)*0x100 + (mode==2 and b or 0)
	c2 = 0xff000000 + (mode==0 and r or 0xff )*0x10000 + (mode==1 and g or 0xff)*0x100 + (mode==2 and b or 0xff) 
	c3 = 0xff000000 + (mode==0 and r or 0)*0x10000 + (mode==1 and g or 0)*0x100 + (mode==2 and b or 0)
	c4 = 0xff000000 + (mode==0 and r or mode==1 and 0 or 0xff)*0x10000 + (mode==1 and g or 0)*0x100 + (mode==2 and b or 0xff)
	return c1, c2, c3, c4
end

local function modeFocusTwo(r, g, b, mode)
	return 0xff000000 + (mode==0 and 0xff or r)*0x10000 + (mode==1 and 0xff or g)*0x100 + (mode==2 and 0xff or b), 0xff000000 + (mode==0 and 0 or r)*0x10000 + (mode==1 and 0 or g)*0x100 + (mode==2 and 0 or b)
end

local function convertRGBtoHSV(r, g, b)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	if max == min then 
		return 0, 0, max
	else
		if g >= b then 
			return toint((max-r+g-min+b-min)/(max-min)*60, 0.5), toint((1-min/max)*255, 0.5), max
		else
			return toint(360-(max-r+g-min+b-min)/(max-min)*60, 0.5), toint((1-min/max)*255, 0.5), max
		end
	end
end

local function convertHSVtoRGB(h, s, v)
	h, s, v = toint(h, 0.5), toint(s, 0.5), toint(v, 0.5)
	if s == 0 then return v, v, v end
	s = s/255
	h = h/60
	local h1 = math.floor(h)
	local f = h - h1
	local p = v*(1-s)
	local q = v*(1-f*s)
	local t = v*(1-(1-f)*s)
	f = toint(f, 0.5)
	p = toint(p, 0.5)
	q = toint(q, 0.5)
	t = toint(t, 0.5)
	if h1 == 0 then 
		return v, t, p
	elseif h1 == 1 then 
		return q, v, p
	elseif h1 == 2 then 
		return p, v, t
	elseif h1 == 3 then 
		return p, q, v
	elseif h1 == 4 then 
		return t, p, v
	elseif h1 == 5 then 
		return v, p, q
	else
		return v, p, q
	end
end

function ui.colorPicker:getColor() 
	return '0x'..string.format('%08x', self.color)
end

function ui.colorPicker:setColor(color)
	if type(color) == 'string' then 
		self.color = tonumber(color, 16)
	elseif type(color) == 'number' then 
		self.color = color
	end
	self.a, self.r, self.g, self.b = toint(self.color%0x100000000/0x1000000), toint((self.color%0x1000000)/0x10000), toint((self.color%0x10000)/0x100), toint(self.color%0x100)
	self.H, self.S, self.V = convertRGBtoHSV(self.r, self.g, self.b) 
end

function ui.colorPicker:onNew()
	self.mode = self.mode or 0
	self.colorModel = self.colorModel or 0
	self.H, self.S, self.V = convertRGBtoHSV(self.r, self.g, self.b)
	self.img1 = _Image.new('image\\uiimg\\circle.png')
	self.img2 = _Image.new('image\\uiimg\\triangle.png')
	self.img3 = _Image.new('image\\uiimg\\triangle1.png')
	self.img4 = _Image.new('image\\uiimg\\transparent.png')
	self.img5 = _Image.new('image\\uiimg\\transparent1.png')
	self.precision = 4
	self.presetColors = {}
	self:readConfig()
end

function ui.colorPicker:throwEvent()
	if self.lcolor ~= self.color and self.realChange then 
		self:realChange(self.lcolor)
	end
end

function ui.colorPicker.modeBtn:onClick()
	self.owner.mode = (self.owner.mode +  1)%6
end

function ui.colorPicker.colorModelBtn:onClick()
	self.owner.colorModel = (self.owner.colorModel+1)%2 
	self.owner.label1.text = self.owner.colorModel==0 and 'R' or 'H'
	self.owner.label2.text = self.owner.colorModel==0 and 'G' or 'S'
	self.owner.label3.text = self.owner.colorModel==0 and 'B' or 'V'
end

function ui.colorPicker:onUpdate(full)
	self.color = self.a*0x1000000 + self.r*0x10000 + self.g*0x100 + self.b
	self.rgb = 0xff000000 + self.r*0x10000 + self.g*0x100 + self.b
	ui.child()
	if self.linkUI and self.linkUI.color and self.linkUI.setColor then 
		self.linkUI:setColor(self.color)
	end
end

function ui.colorPicker:selectColor(u)
	self.linkUI = nil
	local o = self.owner
	while o and o ~= ui do 
		o.show = true
		o = o.owner
		if o.owner == ui then 
			ui.focusTo(o)
		end
	end
	if type(u) == 'number' then 
	elseif type(u) == 'table' then
		self.linkUI = u
		if u.color then
			self:setColor(u.color)
		end 
	end
end

function ui.colorPicker:writeConfig()
	local configStr = os.info.configStr
	configStr = configStr..'ui.colorPicker.presetColors = {\n'
	for i, v in ipairs(self.presetColors) do 
		configStr = configStr..'['..i..'] = '..v.color..',\n'
	end
	configStr = configStr..'}\n'
	_sys:writeConfig(_sys.userProfile..'\\fancy\\UIEditor\\config.lua', configStr)
end

function ui.colorPicker:readConfig()
	local config = _sys:readConfig(_sys.userProfile..'\\fancy\\UIEditor\\config.lua')
	assert(loadstring(config))()
	self.presetColors = ui.colorPicker.presetColors
	for i, v in ipairs(self.presetColors) do 
		local tcolor = v
		local nu = self.presetColorUI^{show = true}
		self.new[#self+1] = nu
		nu.color = v
		nu.mode = 0
		self.presetColors[i] = {u = nu, color = tcolor}
 		if not self.presetColorUI.flagPos then 
 			local tx, ty = ui.position(self.presetColorUI)
 			self.presetColorUI.flagPos = {x = tx, y = ty}
 		end
 		local x, y = self.presetColorUI.flagPos.x, self.presetColorUI.flagPos.y
		local index = i
		ui.moveTo(nu, x+(index-1)%13*14, y+math.floor((index-1)/13)*14)
		ui.moveTo(self.presetColorUI, x+(index)%13*14, y+math.floor(index/13)*14)
		ui.position(self)
		if  y+math.floor(index/13)*14 +self.presetColorUI.h*1.5 > self.h then 
			self.h = y + math.floor(index/13)*14 + self.presetColorUI.h*1.5
		end
	end
end

-- alpha Color
function ui.colorPicker.colorA:onRender()
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
	-- Render RGB
	_rd:fillRect(1, 1, self.w-2, self.h*0.8, self.owner.rgb)
	-- Redner Alpha
	_rd:fillRect(1, self.h * 0.8 + 1, (self.w-2)*self.owner.a/255, self.h*0.2-2 ,_Color.White)
	_rd:fillRect((self.w-2)*self.owner.a/255+1, self.h*0.8+1, (self.w -2)*(1-self.owner.a/255), self.h * 0.2 - 2, _Color.Black)	
end
-- Area1
function ui.colorPicker.area1:onNew()
	self.img1 = self.owner.img1
end

function ui.colorPicker.area1:onPush()
	self.owner.lcolor = self.owner.color
	self:onDraging(0, 0, full)
end 

function ui.colorPicker.area1:onClick()
	self.owner:throwEvent()
end

function ui.colorPicker.area1:onDrag()
	self.owner:throwEvent()
end

function ui.colorPicker.area1:getPushX(t, max)
	return self.img1.w/2 + t/max*(self.w-self.img1.w)
end

function ui.colorPicker.area1:getPushY(t, max)
	return self.img1.h/2 + (1-t/max)*(self.h-self.img1.h)
end

function ui.colorPicker.area1:getColorX(max)
	return toint((self.pushx-self.img1.w/2)*max/(self.w- self.img1.w), 0.5)
end

function ui.colorPicker.area1:getColorY(max)
	return toint((1 - (self.pushy-self.img1.h/2)/(self.h- self.img1.h))*max, 0.5)
end

function ui.colorPicker.area1:onDraging(dx, dy, full)
	self.pushx, self.pushy = ui.pos('mouse', self)
	self.pushx = self.pushx < 5 and 5 or self.pushx > self.w - 5 and self.w -5 or self.pushx
	self.pushy = self.pushy < 5 and 5 or self.pushy > self.h -5 and self.h -5 or self.pushy
	if self.owner.mode < 3 then 
		if self.owner.mode == 0 then 
			self.owner.b = self:getColorX(0xff)
			self.owner.g = self:getColorY(0xff)
		elseif self.owner.mode == 1 then
			self.owner.b = self:getColorX(0xff)
			self.owner.r = self:getColorY(0xff)
		elseif self.owner.mode == 2 then 
			self.owner.r = self:getColorX(0xff)
			self.owner.g = self:getColorY(0xff)
		end
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		if self.owner.mode == 3 then 
			self.owner.S = self:getColorX(0xff)
			self.owner.V = self:getColorY(0xff)
		elseif self.owner.mode == 4 then 
			self.owner.H = self:getColorX(359)
			self.owner.V = self:getColorY(0xff)
		elseif self.owner.mode == 5 then 
			self.owner.H = self:getColorX(359)
			self.owner.S = self:getColorY(0xff)
		end
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)	
	end
end

function ui.colorPicker.area1:onUpdate()
	if self.owner.mode < 3 then 
		local c1, c2, c3, c4 = modeFocusOne(self.owner.r, self.owner.g, self.owner.b, self.owner.mode)
		self.lcolor = {}
		self.rcolor = {}
		local dh = 1/(self.h-1)
		for i = 0, self.h-1 do 
			table.insert(self.lcolor, _Color.lerp(c1, c3, i*dh))
			table.insert(self.rcolor, _Color.lerp(c2, c4, i*dh))
		end
	end
	if self.owner.mode == 0 then 
		self.pushx = self:getPushX(self.owner.b, 0xff)
		self.pushy = self:getPushY(self.owner.g, 0xff)
	elseif self.owner.mode == 1 then 
		self.pushx = self:getPushX(self.owner.b, 0xff)
		self.pushy = self:getPushY(self.owner.r, 0xff)
	elseif self.owner.mode == 2 then 
		self.pushx = self:getPushX(self.owner.r, 0xff)
		self.pushy = self:getPushY(self.owner.g, 0xff)
	elseif self.owner.mode == 3 then 
		self.pushx = self:getPushX(self.owner.S, 0xff)
		self.pushy = self:getPushY(self.owner.V, 0xff)	
	elseif self.owner.mode == 4	then 
		self.pushx = self:getPushX(self.owner.H, 359)
		self.pushy = self:getPushY(self.owner.V, 0xff)	
	elseif self.owner.mode == 5 then
		self.pushx = self:getPushX(self.owner.H, 359)
		self.pushy = self:getPushY(self.owner.S, 0xff)
	end
end

function ui.colorPicker.area1:onRender()
	local pcs = self.owner.precision
	if self.owner.mode < 3 then 
		local dw = 1/(self.w-1)
		local i, j = 0, 0
		while i < self.h-1 do 
			j = 0
			while j < self.w-1 do 
				_rd:fillRect(j, i, pcs, pcs, _Color.lerp(self.lcolor[i+1], self.rcolor[i+1], j*dw))
				j = j + pcs - 1
			end
			i = i + pcs - 1
		end
	else
		if self.owner.mode == 3 then 
			-- focus H
			local dw, dh = 0xff/(self.w-1), 0xff/(self.h-1)
			local i, j = 0, 0
			while i < self.h-1 do 
				j = 0
				while j < self.w-1 do 
					local r, g, b = convertHSVtoRGB(self.owner.H ,j*dw, 255-i*dh)
					_rd:fillRect(j, i, pcs, pcs, 0xff000000+r*0x10000+g*0x100+b)
					j = j + pcs - 1
				end
				i = i + pcs - 1
			end
		elseif self.owner.mode == 4 then 
			-- fouse S
			local dw, dh = 359/(self.w-1), 0xff/(self.h-1)
			local i, j = 0, 0
			while i < self.h-1 do 
				j = 0
				while j < self.w-1 do 
					local r, g, b = convertHSVtoRGB(j*dw, self.owner.S, 255-i*dh)
					_rd:fillRect(j, i, pcs, pcs, 0xff000000+r*0x10000+g*0x100+b)
					j = j + pcs - 1
				end
				i = i + pcs - 1
			end
		else
		-- fouse V
			local dw, dh =359/(self.w-1), 0xff/(self.h-1)
			local i, j = 0, 0
			while i < self.h-1 do 
				j = 0
				while j < self.w-1 do 
					local r, g, b = convertHSVtoRGB(j*dw, 255-i*dh, self.owner.V)
					_rd:fillRect(j, i, pcs, pcs, 0xff000000+r*0x10000+g*0x100+b)
					j = j + pcs - 1
				end
				i = i + pcs - 1
			end
		end
	end
	self.img1:drawImage(self.pushx -5, self.pushy -5, self.pushx -5 + self.img1.w, self.pushy -5 + self.img1.h)
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
end
-- Area2
function ui.colorPicker.area2:onNew()
	self.img = self.owner.img2
end

function ui.colorPicker.area2:onPush()
	self.owner.lcolor = self.owner.color
	self:onDraging(0, 0, full)
end

function ui.colorPicker.area2:onClick()
	self.owner:throwEvent()
end

function ui.colorPicker.area2:onDrag()
	self.owner:throwEvent()
end


function ui.colorPicker.area2:getPushY(t, max) --getgetPushY
	return toint((1-t/max)*self.h, 0.5)
end

function ui.colorPicker.area2:getColorY(max)
	return toint((1-self.pushy/self.h)*max, 0.5)
end

function ui.colorPicker.area2:onDraging(dx, dy, full)
	local t
	t, self.pushy = ui.pos('mouse', self)
	self.pushy = self.pushy < 0 and 0 or self.pushy > self.h and self.h or self.pushy
	if self.owner.mode == 0 then 
		self.owner.r = self:getColorY(0xff)
	elseif self.owner.mode == 1 then 
		self.owner.g = self:getColorY(0xff)
	elseif self.owner.mode == 2 then 
		self.owner.b = self:getColorY(0xff)
	elseif self.owner.mode == 3 then 
		self.owner.H = self:getColorY(359)
	elseif self.owner.mode == 4 then 
		self.owner.S = self:getColorY(0xff)
	elseif self.owner.mode == 5 then 
		self.owner.V = self:getColorY(0xff)
	end
	if self.owner.mode < 3 then 
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else 
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
end

function ui.colorPicker.area2:onUpdate()
	if self.owner.mode == 0 then 
		self.pushy = self:getPushY(self.owner.r, 0xff)
	elseif self.owner.mode == 1 then 
		self.pushy = self:getPushY(self.owner.g, 0xff)
	elseif self.owner.mode == 2 then 
		self.pushy = self:getPushY(self.owner.b, 0xff)
	elseif self.owner.mode == 3 then 
		self.pushy = self:getPushY(self.owner.H, 359)	
	elseif self.owner.mode == 4	then 
		self.pushy = self:getPushY(self.owner.S, 0xff)	
	elseif self.owner.mode == 5 then
		self.pushy = self:getPushY(self.owner.V, 0xff)
	end
end

function ui.colorPicker.area2:onRender()
	if self.owner.mode < 3 then 
		local c1, c2 = modeFocusTwo(self.owner.r, self.owner.g, self.owner.b,  self.owner.mode)
		local color
		for i = 0, self.h-1 do
			_rd:fillRect(0, i, self.w, 1, _Color.lerp(c1, c2, i/(self.h-1)))
		end
	else
		if self.owner.mode == 3 then 
			local dh = 359/(self.h-1)
			for i = 0, self.h-1 do 
				local r, g, b = convertHSVtoRGB(toint(359-dh*i, 0.5), 255, 255)
				_rd:fillRect(0, i, self.w, 1, 0xff000000+r*0x10000+g*0x100+b)
			end
		elseif self.owner.mode == 4 then 
			local dh = 0xff/(self.h-1)
			for i = 0, self.h-1 do 
				local r, g, b = convertHSVtoRGB(self.owner.H, 255-dh*i, self.owner.V)
				_rd:fillRect(0, i, self.w, 1, 0xff000000+r*0x10000+g*0x100+b)
			end
		elseif self.owner.mode == 5 then 
			local dh = 0xff/(self.h-1)
			for i = 0, self.h-1 do 
				local r, g, b = convertHSVtoRGB(self.owner.H, self.owner.S, 255-dh*i)
				_rd:fillRect(0, i, self.w, 1, 0xff000000+r*0x10000+g*0x100+b)
			end
		end
	end
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
	self.img.flip = 0
	self.img:drawImage(-self.img.w, self.pushy-self.img.h/2 , 0, self.pushy+self.img.h/2)
	self.img.flip = 1
	self.img:drawImage(self.w, self.pushy-self.img.h/2, self.w+self.img.w, self.pushy+self.img.h/2)
end

--slider1 for r or h
function ui.colorPicker.slider1:onNew()
	self.img = self.owner.img3
end

function ui.colorPicker.slider1:onPush()
	self.owner.lcolor = self.owner.color
	self:onDraging(0, 0, full)
end

function ui.colorPicker.slider1:onClick()
	self.owner:throwEvent()
end

function ui.colorPicker.slider1:onDrag()
	self.owner:throwEvent()
end

function ui.colorPicker.slider1:onDraging(dx, dy, full)
	local t
	self.pushx, t = ui.pos('mouse', self)
	self.pushx = self.pushx<0 and 0 or self.pushx>self.w and self.w or self.pushx
	if self.owner.colorModel == 0 then 
		self.owner.r = self:getColorX(0xff)
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		self.owner.H = self:getColorX(359)
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
end

function ui.colorPicker.slider1:getPushX(t, max)
	return toint(t/max*self.w, 0.5)
end

function ui.colorPicker.slider1:getColorX(max)
	return toint(self.pushx/self.w*max, 0.5)
end

function ui.colorPicker.slider1:onUpdate()
 	if self.owner.colorModel == 0  then 
		self.pushx = self:getPushX(self.owner.r, 0xff)
		self.owner.input1.text = self.owner.r
	else
		self.pushx = self:getPushX(self.owner.H, 359)
		self.owner.input1.text = self.owner.H
	end
end

function ui.colorPicker.slider1:onRender()
	if self.owner.colorModel == 0  then 
		local c1, c2 = modeFocusTwo(self.owner.r, self.owner.g, self.owner.b,  0)
		local dw = 1/(self.w-1)
		for i = 1, self.w-1 do
			_rd:fillRect(i, 0, 1, self.h, _Color.lerp(c2, c1, dw*i))
		end
	else
		local dw = 359/(self.w-1)
		for i = 0, self.w-1 do 
			local r, g, b = convertHSVtoRGB(dw*i,255 ,255)
			_rd:fillRect(i, 0, 1, self.h, 0xff000000+r*0x10000+g*0x100+b)
		end		
	end
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
	self.img.flip = 0
	self.img:drawImage(self.pushx-self.img.w/2, -self.img.h, self.pushx+self.img.h/2, 0)
	self.img.flip = 2
	self.img:drawImage(self.pushx-self.img.w/2, self.h, self.pushx+self.img.h/2, self.h+ self.img.h)
end

function ui.colorPicker.input1:onChange()
	self.text = tonumber(self.text) and self.text or 0
	local n = tonumber(self.text)
	n = n<0 and 0 or n>(self.owner.colorModel==0 and 0xff or 359) and (self.owner.colorModel==0 and 0xff or 359) or n
	if self.owner.colorModel == 0 then
		self.owner.r = n
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		self.owner.H = n
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
	self.text = n
end
--slider2 for g or s
function ui.colorPicker.slider2:onNew()
	self.img = self.owner.img3
end

function ui.colorPicker.slider2:onPush()
	self.owner.lcolor = self.owner.color
	self:onDraging(0, 0, full)
end

function ui.colorPicker.slider2:onClick()
	self.owner:throwEvent()
end

function ui.colorPicker.slider2:onDrag()
	self.owner:throwEvent()
end

function ui.colorPicker.slider2:onDraging(dx, dy, full)
	local t
	self.pushx, t = ui.pos('mouse', self)
	self.pushx = self.pushx<0 and 0 or self.pushx>self.w and self.w or self.pushx
	if self.owner.colorModel == 0 then 
		self.owner.g = self:getColorX(0xff)
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		self.owner.S = self:getColorX(0xff)
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
end

function ui.colorPicker.slider2:getPushX(t, max)
	return toint(t/max*self.w, 0.5)
end

function ui.colorPicker.slider2:getColorX(max)
	return toint(self.pushx/self.w*max, 0.5)
end

function ui.colorPicker.slider2:onUpdate()
 	if self.owner.colorModel == 0  then 
		self.pushx = self:getPushX(self.owner.g, 0xff)
		self.owner.input2.text = self.owner.g
	else
		self.pushx = self:getPushX(self.owner.S, 0xff)
		self.owner.input2.text = self.owner.S
	end
end

function ui.colorPicker.slider2:onRender()
	if self.owner.colorModel == 0 then 
		local c1, c2 = modeFocusTwo(self.owner.r, self.owner.g, self.owner.b, 1)
		local dw = 1/(self.w-1)
		for i = 1, self.w-1 do 
			_rd:fillRect(i, 0, 1, self.h, _Color.lerp(c2, c1, dw*i))
		end
	else
		local dw = 0xff/(self.w-1)
		for i = 0, self.w-1 do 
			local r, g, b = convertHSVtoRGB(self.owner.H, dw*i, self.owner.V)
			_rd:fillRect(i, 0, 1, self.h, 0xff000000+r*0x10000+g*0x100+b)
		end
	end
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
	self.img.flip = 0
	self.img:drawImage(self.pushx-self.img.w/2, -self.img.h, self.pushx+self.img.h/2, 0)
	self.img.flip = 2
	self.img:drawImage(self.pushx-self.img.w/2, self.h, self.pushx+self.img.h/2, self.h+ self.img.h)
end

function ui.colorPicker.input2:onChange()
	self.text = tonumber(self.text) and self.text or 0
	local n = tonumber(self.text)
	n = n<0 and 0 or n>0xff and 0xff or n
	if self.owner.colorModel == 0 then
		self.owner.g = n
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		self.owner.S = n
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
	self.text = n
end

--slider3 for b or v
function ui.colorPicker.slider3:onNew()
	self.img = self.owner.img3
end

function ui.colorPicker.slider3:onPush()
	self.owner.lcolor = self.owner.color
	self:onDraging(0, 0, full)
end

function ui.colorPicker.slider3:onClick()
	self.owner:throwEvent()
end

function ui.colorPicker.slider3:onDrag()
	self.owner:throwEvent()
end
function ui.colorPicker.slider3:onDraging(dx, dy, full)
	local t
	self.pushx, t = ui.pos('mouse', self)
	self.pushx = self.pushx<0 and 0 or self.pushx>self.w and self.w or self.pushx
	if self.owner.colorModel == 0 then 
		self.owner.b = self:getColorX(0xff)
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		self.owner.V = self:getColorX(0xff)
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
end

function ui.colorPicker.slider3:getPushX(t, max)
	return toint(t/max*self.w, 0.5)
end

function ui.colorPicker.slider3:getColorX(max)
	return toint(self.pushx/self.w*max, 0.5)
end

function ui.colorPicker.slider3:onUpdate()
 	if self.owner.colorModel == 0  then 
		self.pushx = self:getPushX(self.owner.b, 0xff)
		self.owner.input3.text = self.owner.b
	else
		self.pushx = self:getPushX(self.owner.V, 0xff)
		self.owner.input3.text = self.owner.V
	end
end

function ui.colorPicker.slider3:onRender()
	if self.owner.colorModel == 0 then 
		local c1, c2 = modeFocusTwo(self.owner.r, self.owner.g, self.owner.b, 2)
		local dw = 1/(self.w-1)
		for i = 1, self.w-1 do 
			_rd:fillRect(i, 0, 1, self.h, _Color.lerp(c2, c1, dw*i))
		end
	else 
		local dw = 0xff/(self.w-1)
		for i = 0, self.w-1 do 
			local r, g, b = convertHSVtoRGB(self.owner.H, self.owner.S, dw*i)
			_rd:fillRect(i, 0, 1, self.h, 0xff000000+r*0x10000+g*0x100+b)
		end	
	end
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
	self.img.flip = 0
	self.img:drawImage(self.pushx-self.img.w/2, -self.img.h, self.pushx+self.img.h/2, 0)
	self.img.flip = 2
	self.img:drawImage(self.pushx-self.img.w/2, self.h, self.pushx+self.img.h/2, self.h+ self.img.h)
end

function ui.colorPicker.input3:onChange()
	self.text = tonumber(self.text) and self.text or 0
	local n = tonumber(self.text)
	n = n<0 and 0 or n>0xff and 0xff or n
	if self.owner.colorModel == 0 then
		self.owner.b = n
		self.owner.H, self.owner.S, self.owner.V = convertRGBtoHSV(self.owner.r, self.owner.g, self.owner.b)
	else
		self.owner.V = n
		self.owner.r, self.owner.g, self.owner.b = convertHSVtoRGB(self.owner.H, self.owner.S, self.owner.V)
	end
	self.text = n
end

--slider4 for a
function ui.colorPicker.slider4:onNew()
	self.img = self.owner.img3
end

function ui.colorPicker.slider4:onPush()
	self.owner.lcolor = self.owner.color
	self:onDraging(0, 0, full)
end

function ui.colorPicker.slider4:onClick()
	self.owner:throwEvent()
end

function ui.colorPicker.slider4:onDrag()
	self.owner:throwEvent()
end

function ui.colorPicker.slider4:onDraging(dx, dy, full)
	local t
	self.pushx, t = ui.pos('mouse', self)
	self.pushx = self.pushx<0 and 0 or self.pushx>self.w and self.w or self.pushx
	self.owner.a = self:getColorX(0xff)
end

function ui.colorPicker.slider4:getPushX(t, max)
	return toint(t/max*self.w, 0.5)
end

function ui.colorPicker.slider4:getColorX(max)
	return toint(self.pushx/self.w*max, 0.5)
end

function ui.colorPicker.slider4:onUpdate()
	self.pushx = self:getPushX(self.owner.a, 0xff)
	self.owner.input4.text = self.owner.a
end

function ui.colorPicker.slider4:onRender()
	local dw = 1/(self.w-1)
	for i = 0, self.w-1 do 
		_rd:fillRect(i, 0, 1, self.h, _Color.lerp(_Color.Black, _Color.White, dw*i))
	end
	_rd:drawRect(0, -1, self.w+1, self.h+1, 0xff000000)
	self.img.flip = 0
	self.img:drawImage(self.pushx-self.img.w/2, -self.img.h, self.pushx+self.img.h/2, 0)
	self.img.flip = 2
	self.img:drawImage(self.pushx-self.img.w/2, self.h, self.pushx+self.img.h/2, self.h+ self.img.h)
end

function ui.colorPicker.input4:onChange()
	self.text = tonumber(self.text) and self.text or 0
	local n = tonumber(self.text)
	n = n<0 and 0 or n>0xff and 0xff or n
	self.owner.a = n
	self.text = n
end

-- presets Colors
function ui.colorPicker.presetColorUI:onNew()
	self.mode = 0.2
	self.color = self.owner.color
	self.img4 = self.owner.img4
end

function ui.colorPicker.presetColorUI:onUpdate()
	self.color = self.mode == 0.2 and self.owner.color or self.color
end

function ui.colorPicker.presetColorUI:onRender()
	local x, y, w, h = self.mode*self.w, self.mode*self.h, (1-self.mode*2)*self.w, (1-self.mode*2)*self.h
	if ui.focus() == self then 
		_rd:drawRect(x-1, y-1, w+2, h+2, 0x88000000)		
	end
	if self.mode == 0.2 then 
		self.img4:drawImage(x, y, x+w, y+h)	
	else 
		self.img4:drawImage(x, y, w, h)			
	end
	_rd:fillRect(x, y, w, h, self.color)
	_rd:drawRect(x, y, w, h, 0xff000000)
end

function ui.colorPicker.presetColorUI:onKey(k, c)
	if k == _System.KeyDel and self.mode == 0 then 
		for i, v in ipairs(ui.parent(self).presetColors) do 
			if v.u == self then 
				for p = i, #self.owner.presetColors-1 do 
					self.owner.presetColors[p].u.color = self.owner.presetColors[p+1].u.color 
					self.owner.presetColors[p].color = self.owner.presetColors[p+1].color 
				end 
				local index = #self.owner.presetColors
				local t = self.owner.presetColors[index]
				ui.remove(nil, t.u)
				table.remove(self.owner.presetColors, index)
				ui.focusTo(#self.owner.presetColors>0 and (i==index and self.owner.presetColors[i-1].u or self.owner.presetColors[i].u) or self.owner)
				ui.moveTo(self.owner.presetColorUI, self.owner.presetColorUI.flagPos.x+(index-1)%13*14, self.owner.presetColorUI.flagPos.y+math.floor((index-1)/13)*14)
				break
			end
		end
	end
end

function ui.colorPicker.presetColorUI:onClick()
	if self.mode == 0 then
		ui.parent(self):setColor(self.color)
	else
		local nu = self.owner.presetColorUI^{show = true}
		self.owner.new[#self.owner+1] = nu
		table.insert(ui.parent(self).presetColors, {u = nu, color = self.color})
		nu.mode = 0
 		if not self.flagPos then 
 			local tx, ty = ui.position(self)
 			self.flagPos = {x = tx, y = ty}
 		end
 		local x, y = self.flagPos.x, self.flagPos.y
		local index = #self.owner.presetColors
		ui.moveTo(nu, x+(index-1)%13*14, y+math.floor((index-1)/13)*14)
		ui.moveTo(self, x+(index)%13*14, y+math.floor(index/13)*14)
		ui.position(self)
		if  y+math.floor(index/13)*14 +self.h*1.5 > ui.parent(self).h then 
			ui.parent(self).h = y + math.floor(index/13)*14 + self.h*1.5
		end
	end
end

end
-- ui.loadConfig()









