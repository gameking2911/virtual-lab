os.info.uiconfpath = os.info.uiconfpath or '../cconf/'
os.info.uieditwh = os.info.uieditwh or { 960, 640, 1000, 600, 1024, 768, 1280, 720, 1136, 640  }
os.info.uilang = os.info.uilang or function (s) return s end
os.info.uilangpre = os.info.uilangpre or ''
os.info.uilangpost = os.info.uilangpost or ''
if not ui.fonts then ui.fonts = {} end
ui.fonts.s9e = ui.font(os.info.defaultfont, 9, 'e')
ui.fonts.s11be = ui.font(os.info.defaultfont, 11, 'be')

for key, font in next, ui.fonts do
	font.key = 'ui.fonts.'..key
end

if _sys:folderExist(os.info.uiconfpath) then 
	_sys:enumFile(os.info.uiconfpath, true,function ( filename )
		if _sys:getExtention(filename) =='lua' then 
			if not (filename == 'conf_ui0.lua' or filename == 'conf_ui1.lua')   then 
				dofile(os.info.uiconfpath..filename)
			end
		end
	end) 
end

local function hotkeySize() return _sys:isKeyDown(16) end -- shift
local function hotkeyRev() return _sys:isKeyDown(16) end -- shift
local function hotkeyHide() return _sys:isKeyDown(27) end -- esc
local function hotkeyHori() return _sys:isKeyDown(16) end -- shift
local function hotkeyBig() return _sys:isKeyDown(9) end -- tab
local function hotkeyTest() return _sys:isKeyDown(32) end -- space
local function hotkeyIn() return _sys:isKeyDown(17) and _sys:isKeyDown(187) end -- ctrl +
local function hotkeyOut() return _sys:isKeyDown(17) and _sys:isKeyDown(189) end -- ctrl -
local function hotkeyFront() return _sys:isKeyDown(16) end -- shift
local function hotkeyImgt() return _sys:isKeyDown(16) end -- shift
local function hotkeySub() return _sys:isKeyDown(16) end -- shift
local function hotkeyDup() return _sys:isKeyDown(16) end -- shift

local function uchar(u)
	if u <= 127 then return string.char(u) end
	if u <= 0x7ff then return string.char(0xc0+toint(u/64), 0x80+u%64) end
	return string.char(0xe0+toint(u/4096), 0x80+toint(u/64%64), 0x80+u%64)
end
local function tablekeys(s)
	local ss = {}
	for k, v in next, s do ss[#ss+1] = k end
	return ss
end

function ui.editpass:onPick()
	ui.child(false)
end
if ui.pass then
	function ui.pass:onPick()
		if not _sys:isKeyDown(_System.KeyCtrl) then ui.child(false) end
	end
end
function ui.editpassc:onPick(full)
	ui.pick'nochild' ui.super() ui.child()
end
function ui.editpassp:onPick(full)
	ui.super() if ui.child()==self then ui.child'passp' end
end
function ui.editpickc:onPick(full)
	ui.pick'allchild' ui.super() ui.child()
end
function ui.editpickcp:onPick(full)
	ui.super() if ui.child() then ui.child(self) end
end
function ui.editcursor:onHover()
	_app.cursor = self.cursor
end
function ui.editcursor:onUnhover()
	_app.cursor = ''
end

local function onSelect(u, owner)
	if owner==nil then owner = u.owner end
	local k0 = owner.select
	local u0 = k0 ~= nil and owner[owner.select] or nil
	owner.select = nil
	for k, v in next, owner do
		if v == u then owner.select = k break end
	end
	local on = owner.onSelect if on then on(owner, owner.select, u, k0, u0) end
end

function ui.edithotkey:onHotkey(k)
	local key = self.hotkey
	if k==(type(key)=='string' and key:byte(1) or toint(key))
		and not _sys:isKeyDown(17) then
		if self.onClick then self:onClick() end
		ui.child(false)
	end
end
if ui.hotkey then function ui.hotkey:onHotkey() end end

function ui.editlabel:onUpdate()
	if self.autow and self.text ~= self.autow then
		self.autow = self.text
		ui.sizeTo(self, self.font:stringWidth(self.text)+self.left*2)
	end
end
function ui.editlabel:onRender()
	if (type(self.text)=='string' and #self.text>0)
		or type(self.text)=='number' then
		self.font:drawText(self.left, self.top, self.w+self.left, self.h, self.text)
	end
end

function ui.editcheckbox:onClick()
	if not self.enable then return end
	self.checked = not self.checked
	if self.onChange then self:onChange() end
end
function ui.editcheckbox:onRender()
	if self.checked then ui.drawImg(self, self.fg) end
end

------------------------------------------------------------------
local inputmat = _Matrix2D.new()
function ui.editinput:onRender()
	local x, y = _rd.x, _rd.y
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
			if i > selstart and i <= selend then v:drawSel(v) 	 end
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
function ui.editinput:onUpdate()
	self.curr = self.curr or 0
	local v = self.ts[self.curr]
	if v == nil and self.curr > 1 then self.curr = self.curr - 1 end
	self.tagx = v and (v.x + v.w) or self.pad.r
	self.tagy = v and v.y or self.pad.t
	self.tagh = v and v.h or self.lineH
	local w = self.w - self.pad.l - self.pad.r
	if self.textalign:lead("l") then
		self.left = math.min(0, math.max(w-self.font:stringWidth(self.text),
			math.max(w/4, math.min(self.tagx+self.left, w*3/4))-self.tagx))
	elseif self.textalign:lead("c") then
		self.left = (self.w-self.pad.r-self.pad.l-self.font:stringWidth(self.text))/2
	elseif self.textalign:lead("r") then
		self.left = math.min(w, math.max(w-self.font:stringWidth(self.text),
			math.min(w/4, math.min(self.tagx+self.left, w*3/4))-self.tagx))
	end
end
function ui.editinput:onUnfocus()
	_sys.enableIME = false
end
function ui.editinput:onFocus()
	_sys.enableIME = true
end
function ui.editinput:onClick( )
	if os.now()  - (self.clickt or 0 ) > 300 then
		if self.Click then 
			self:Click()
		end
		self.clickt = os.now()
	else 
		self.clickt = 0 
		self:selectAll()
		if self.DoubleClick then 
			self:DoubleClick()
		end
	end
end


function ui.editinput:selectAll(  )
	self.selstart = 0 self.selend = #self.ts
end
function ui.editinput:onKey(k, c)
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
		elseif k == _System.KeyA then self:selectAll()
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
function ui.editinput:currformx(x, y)
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
function ui.editinput:onPush()
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
end
function ui.editinput:onDraging(x, y)
	local x, y = ui.pos('mouse', self)
	x = x - self.left y = y - self.top
	self.curr = self:currformx(x,y) or self.curr
	self.selend = self.curr ~= self.selstart and self.curr or nil
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
	_rd:fillRect(self.x, self.y, self.w, self.h, 0xff0000ff)
end
function ui.editinput:onShow(  )
	if self.text then 
		self:setText(self.text)
	end
end
function ui.editinput:requeue()
	local oldtext = tostring(self.text)
	self.text = ""
	local x = self.pad.l
	local y = self.pad.t
	local ts = self.ts
	self.ts = {}
	for i, v in ipairs(ts) do if v.text ~= "" then
		local usable = true
		table.copy(v, { w=self.font:stringWidth(v.text), img=nil, x=x, y=y, draw=drawText,
			font=self.font, h=self.lineH, align=self.textalign, drawSel=drawSel })
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
function ui.editinput:setText(t)
	self.ts = {}
	self.curr = 0
	self:insert(type(t)=='number' and ('%.16g'):format(t) or tostring(t))
end
function ui.editinput:insert(tt, curr)
	tt = tostring(tt)
	curr = curr or self.curr
	if curr < 0 then curr = 0
	elseif curr > #self.ts then curr = #self.ts
	end
	self.curr = curr
	for i = 1, tt:ulen() do
		if #self.ts < self.maxlength then
			table.insert(self.ts, self.curr + 1, { text=_String.sub(tt, i, i) })
			self.curr = self.curr + 1
		end
	end
	self:requeue()
end
function ui.editinput:cut(selstart, selend)
	if selstart == nil then return end
	if selstart > selend then selstart, selend = selend, selstart end
	for i = selstart, selend do
		table.remove(self.ts, selstart)
	end
	self.curr = selstart - 1
	self:requeue()
end
function ui.editinput:getSel()
	local r = ""
	if self.selend == nil then return r end
	local selstart, selend = self.selstart, self.selend
	if self.selstart > self.selend then selstart, selend = self.selend, self.selstart end
	for i = selstart+1 , selend do
		r = r .. self.ts[i].text
	end
	return r, selstart, selend
end
function ui.editinput:clear()
	self:setText("")
end
function ui.editinput:onNew()
	self.selstart, self.ts, self.tagtime = self.left or 0, {}, 0
end
_app:onIMEPosition(function()
	local pos = { x=0, y=0 }
	local input = ui.focus()
	if ui.is(ui.editinput, input) then
		pos.x, pos.y = ui.pos(input)
		pos.x, pos.y = pos.x + input.tagx, pos.y+input.tagy
		return pos
	end
	return pos
end)
------------------------------------------------------------------
function ui.editmenu:onNew()
	if not ui.is(ui.editmenu.node, self.owner) then ui.parent(self, ui.modaltop) end
	ui.back(self, self.node)
	self.node.show = false
	self.node.align = ui.sizeLT(0, self.top) ui.position(self.node)
	for k, v in next, self do if k ~= 'owner' and ui.is(ui, v) then
		if not v.align then v.align = ui.alignLT() end
		v.align[11], v.align[12], v.align[13] = false, v.align[12] or 0, self
	end end
	self.nodesnum = 0
	self.changed = true
end
function ui.editmenu:addNode(u, key)
	if type(u)=='string' then u = self.node^{ text=u } end
	self.new[key==nil and #self+1 or key] = u
	u.align[11], u.align[12], u.align[13] = false, u.align[12] or 0, self
	self.changed = true
	self.nodesnum = self.nodesnum + 1
	return u
end
function ui.editmenu:clear()
	self.nodesnum = 0
	if ui.focus(self) then ui.focusTo(self) end
	onSelect(nil, self)
	for k, v in next, self do
		if v ~= self.owner and v ~= self.node and ui.is(ui.editmenu.node, v) then ui.remove(k, v) end
	end
	self.changed = true
end
function ui.editmenu:onShow()
	if ui.parent(self)==ui.modaltop then
		ui.front(nil, self)
		ui.focusTo(self)
		ui.moveTo(self, ui.mousex, ui.mousey)
		self.changed = true
	end
end
function ui.editmenu:onHide()
	onSelect(nil, self)
end
function ui.editmenu:onUpdate(full)
	if not ui.focus(self) and ui.parents(self, ui.modaltop) then
		ui.show(self, false)
		return
	end
	if ui.is(ui.editmenu.node, self.owner) then
		ui.moveTo(self, self.owner.w-4, -self.top)
	end
	ui.back(self, self.node)
	ui.super() ui.child()
	if not self.changed then return end
	local u, w = ui.back(self), 0
	while u do
		w = math.max(w, u.W)
		u = ui.high(u)
	 end
	ui.sizeTo(self, w, ui.front(self).y+ui.front(self).h+self.node.h)
	self.changed = false
	if ui.parent(self)==ui.modaltop then
		ui.moveTo(self, math.max(0, math.min(self.x, _rd.w-self.w)),
			math.max(0, math.min(self.y, _rd.h-self.h)))
	end
end
function ui.editmenu.node:onUpdate()
	if self.owner.changed then
		self.W = self.text and self.fonts.idle:stringWidth(self.text) + self.left*2 or 70
	end
	if not self.enable and self.sub and self.sub.show then
		ui.focusTo(self.owner)
		ui.show(self.sub, false)
	end
end
function ui.editmenu.node:onRender(full)
	local bg, fs = self.backgs, self.fonts
	if not self.enable then
		_rd:useBlender(blend:blend(0xffbbbbbb))
		if self.text then
			fs.idle:drawText(self.left, 0, self.w, self.h, self.text)
		elseif self.color then
			_rd:fillRect(self.left, 0, self.w-1, self.h-1, self.color, true)
		end
		ui.child()
		_rd:popBlender()
		return
	end
	local font
	if ui.push()==self then
		ui.drawImg(self, bg.select or EMPTY)
		if self.text then font = fs.select or fs.idle end
	elseif ui.hover(self) then
		ui.drawImg(self, bg.hover or EMPTY)
		if self.text then font = fs.hover or fs.idle end
	elseif self.owner[self.owner.select]==self then
		ui.drawImg(self, bg.select or EMPTY)
		if self.text then font = fs.select or fs.idle end
	else
		if self.text then font = fs.idle end
	end
	if font then font:drawText(self.left, self.top, self.w, self.h, self.text)
	else _rd:fillRect(self.left, self.top, self.w-self.left-1, self.h-self.top-1, self.color, true)
	end
	ui.child()
end
function ui.editmenu.node:onPick()
	if not self.enable then ui.child(false) end
end
function ui.editmenu.node:onHover(fromchild)
	if self.enable and self.sub and not fromchild then
		ui.show(self.sub, true)
		ui.focusTo(self.sub)
	end
end
function ui.editmenu.node:onUnhover(tochild, full)
	ui.super() ui.child()
	if self.sub and not tochild then
		ui.show(self.sub, false)
		ui.focusTo(self)
	end
end
function ui.editmenu.node:onPush()
	onSelect(self)
	local u = self.owner.owner
	while ui.is(ui.editmenu.node, u) do
		onSelect(nil, u.owner)
		u = u.owner.owner
	end
end
function ui.editmenu.node:onClick()
	local u = self.owner
	while ui.is(ui.editmenu.node, u.owner) do
		u = u.owner.owner
	end
	u.show = false
end
----------------------------------------------------------
function ui.editscroll:setInfo(total, view, lineh)
	self.totalH = total
	self.viewH = view
	self.lineH = lineh or 20
	if self.offset == nil then self.offset = 0 end
	self:fixOffset()
end
function ui.editscroll:setOffset(s)
	self.offset = s
	self:fixOffset()
end
function ui.editscroll:onUpdate()
	self:barSize()
end
function ui.editscroll:onWheel(n, full)
	self:scrollContent(-n * self.lineH)
end
function ui.editscroll:scrollContent(y0, absolute)
	if absolute then self.offset = y0
	else self.offset = self.offset + y0 end
	self:fixOffset()
end
function ui.editscroll:_scroll(y0, absolute)  -- 参数为滚动的单位
	local r = self.bar
	if not absolute then
		self.offset = self.offset + y0 * (self.totalH - self.viewH) / (self.h - self.ty - self.by - r.h)
	else
		self.offset = y0 * (self.totalH - self.viewH) / (self.h - self.ty - self.by - r.h)
	end
	self:fixOffset()
end
function ui.editscroll:toDown()
	self:scrollContent(1 * self.lineH)
end
function ui.editscroll:toUp()
	self:scrollContent(-1 * self.lineH)
end
function ui.editscroll:toEnd()
	self:scrollContent(self.totalH)
end
function ui.editscroll:toStart()
	self:scrollContent(0, true)
end
function ui.editscroll:onScroll(v)
end
function ui.editscroll.bar:onDraging(x, y)
	self.owner:_scroll(y)
end
function ui.editscroll.bar:onDrag(a, b)
	if self.lineScroll then
		self.owner.offset = self.owner.lastoffset or 0
	end
end
function ui.editscroll:fixOffset()
	if self.offset < 0 then self.offset = 0 end
	if self.offset > self.totalH - self.viewH and self.totalH > self.viewH then self.offset = self.totalH - self.viewH end
	if self.totalH <= self.viewH then self.offset = 0 end
	local offset = self.offset
	if self.lineScroll then offset = toint(((self.offset + self.lineH/2)/self.lineH)) * self.lineH end
	if offset ~= self.lastoffset then
		self.lastoffset = offset
		self:onScroll(offset)
	end
end
function ui.editscroll:onPush(x, y)
	local r, x, y = self.bar, ui.pos('mouse', self)
	if y > r.y + r.h and y <= self.h - self.by then
		self.offset = self.offset +  (y - r.y - r.h /2) * self.totalH / (self.h - self.ty - self.by)
		self:fixOffset()
	elseif y < r.y and y >= self.ty then
		self.offset = self.offset - (r.y - y + r.h/2)* self.totalH / (self.h - self.ty - self.by)
		self:fixOffset()
	end
end
function ui.editscroll:barSize()
	self.bar.show = self.totalH > self.viewH
	if self.totalH <= self.viewH then
		ui.moveTo(self.bar, 0, self.ty)
		return
	end
	ui.moveTo(self.bar, 0, self.ty + self.offset * (self.h - self.ty - self.by - self.bar.h) / (self.totalH - self.viewH))
end
function ui.editscroll:onNew()
	self:setInfo(99, 100)  -- totalHeight, viewHeight
	self:setOffset(0)
end
function ui.editscroll.up:onClick()
	self.owner:toUp()
end
function ui.editscroll.down:onClick()
	self.owner:toDown()
end
function ui.editlist:addNode(o, key, high)
	if not o.owner then self.new[key==nil and #self+1 or key] = o end
	if not o.align then o.align = ui.alignLT() end
	o.align[11], o.align[12], o.align[13] = false, o.align[12] or 0, self
	self.lineh = o.h
	ui.parent(o, self.panel)
	if high then ui.low(high, o) end
	self:updateSize()
	return o
end
function ui.editlist:findNode(subkey, value)
	local r = {}
	for k, v in next, self do
		if ui.is(ui, v) and v[subkey] == value then r[#r+1] = v end
	end
	return unpack(r)
end
function ui.editlist:removeNode(o)
	if o.owner == self then ui.remove(nil, o)
	else ui.parent(o, o.owner) end
	self:updateSize()
end
function ui.editlist:noden()
	local n, vs = 0, {}
	for k, v in next, self do if ui.is(ui, v) and ui.parent(v)==self.panel then
		n, vs[#vs+1] = n + 1, v
	end end
	return n, vs
end
function ui.editlist:clear()
	local o = ui.front(self.panel)
	while o do
		if o.owner==self then ui.remove(nil, o)
		else ui.parent(o, o.owner) end
		o = ui.front(self.panel)
	end
	self:updateSize()
end
function ui.editlist:onSize()
	if self.scroll then
		ui.position(self)
		self.scroll:setInfo(self.panel.h, self.h, self.lineh)
		ui.position(self.scroll)
	end
end
function ui.editlist:updateSize()
	ui.position(self.panel)
	local o = ui.back(self.panel)
	while o do ui.position(o) o = ui.high(o) end
	o = ui.front(self.panel)
	ui.sizeTo(self.panel, nil, o and o.y+o.h or 0)
	self:onSize()
end
function ui.editlist.panel:onWheel(n, full)
	if self.owner.scroll then self.owner.scroll:onWheel(n) end
end
function ui.editlist.scroll:onScroll(v)
	ui.moveTo(self.owner.panel, nil, -v)
end
function ui.editlist:onRender(full)
	_rd:useClip(_rd.x, _rd.y, _rd.x + self.w, _rd.y + self.h)
	ui.super()
	ui.child()
	_rd:popClip()
	if self.border then ui.drawImg(self, self.border) end
end
-----------------------------------------------------------------
function ui.edittree:addNode(o, ...)
	ui.editlist.addNode(self, o, ...)
	o.tree = self
	return o
end
function ui.edittreenode:noden()
	return self.nodelen or 0
end
function ui.edittreenode:addNode(o, key, after)
	self.nodelen = self.nodelen and self.nodelen+1 or 1
	local panel = self.panel
	if not o then o = self^{} end
	self.new[key==nil and #self+1 or key] = o
	if after then assert(ui.parent(after)==panel) ui.low(o, after)
	else ui.front(panel, o)
	end
	if not o.align then o.align = ui.alignLT() end
	o.align[11], o.align[12], o.align[13] = false, o.align[12] or 0, self
	o.tree = self.tree
	o.show = self.expanded
	if self.expanded then self:updateSize() end
	return o
end
function ui.edittreenode:findNode(subkey, value)
	local r = {}
	for k, v in next, self do
		if ui.is(ui, v) and v[subkey] == value then r[#r+1] = v end
	end
	return unpack(r)
end
function ui.edittreenode:removeNode(o)
	if o.owner == self then ui.remove(nil, o) end
	if self.expanded then self:updateSize() end
end
function ui.edittreenode:clear()
	while ui.front(self.panel) do
		ui.remove(nil, ui.front(self.panel))
	end
	if self.expanded then self:updateSize() end
end
function ui.edittreenode:updateSize()
	self.panel.show = self.expanded
	if self.expanded then
		ui.position(self.panel)
		local o = ui.back(self.panel)
		while o do ui.position(o) o = ui.high(o) end
		o = ui.front(self.panel)
		ui.sizeTo(self.panel, nil, o and o.y+o.h or 0)
		ui.sizeTo(self, nil, self.panel.y+self.panel.h)
	else
		ui.sizeTo(self, nil, self.panel.y)
	end
	self.owner:updateSize()
end
function ui.edittreenode:onClick()
	if os.now() - (self.clickt or 0) > 300 then
		self.clickt = os.now()
	else
		self:onDoubleClick() self.clickt = 0
	end
end
function ui.edittreenode:onUnhover()
	self.clickt = 0
end
function ui.edittreenode:onDoubleClick()
	self.exicon:onClick()
end
function ui.edittreenode:expand(expand)
	if expand==nil then expand = not self.expanded
	else expand = not not expand
	end
	self.expanded = expand
	local u = ui.back(self.panel)
	while u do u.show = expand u = ui.high(u) end
	self:updateSize()
end
function ui.edittreenode.exicon:onUpdate()
	self.fg = self.owner.expanded and 1 or 2
end
function ui.edittreenode.exicon:onRender()
	local stat = self==ui.push() and 'fgpush' or self==ui.hover() and 'fghover' or 'fgidle'
	local s, t = self[stat]
	if s then
		if getmetatable(s)==_Image then t = self.fg==1 and s else t = s[self.fg] end
	end
	s = not t and self.fgidle
	if s then
		if getmetatable(s)==_Image then t = self.fg==1 and s else t = s[self.fg] end
	end
	if t then ui.drawImg(self, t) end
end
function ui.edittreenode.exicon:onClick()
	self.owner:expand()
end

--==========================================================--

local Keys = { w=1, h=2, align=3, backgs=4, show=5 }
local getmeta, floor, abs = getmetatable, math.floor, math.abs
local fun, genUI = {}
local editwin, ungos, ungo, undos, undo = nil, {}, 0, {}, 0
local curr, belonged, currps, curra, currq, currcopy
local currfront, pickfront, pickgfront
local belongs, frontls = {}, {}
local dels, delalls, queues = {}, {}, {}

local noticing, noticet
local function notice(t)
	noticing, noticet = t, os.now()+1500
end

local function sortKeys(s)
	table.sort(s, function(a, b)
		a = tostring(a) b = tostring(b)
		if Keys[a] then return Keys[a] < (Keys[b] or 99) end
		return not Keys[b] and a < b
	end)
	return s
end
local function belongOffer(u)
	while u ~= ui do
		for k, v in next, getmeta(u.owner).o do
			if v == u then return u end
		end
		u = u.owner
	end
	return u
end

local editmain, editprop, editzone = ui.editmain, ui.editprop, ui.editzone
local uilist, olist = editmain.uilist, editmain.olist
local uinode, onode = uilist.node, olist.onode
local setCurr

function editmain:onNew()
	ui.parent(uilist, editmain.lists)
	ui.parent(olist, editmain.lists)
	ui.front(ui.modaltop, editmain)
	ui.low(editmain, editprop)
	ui.low(editprop, editzone)
	ui.marginr, ui.marginb = ui.editmain.w, ui.editprop.h
	editmain.show = true
	ui.buildSeq()
end

function ui.moveTip(w, h)
	local mx, my, W, H, d, x, y = ui.mousex, ui.mousey, _rd.w, _rd.h, 27, 0, 0
	if not hotkeyTest() then mx, my = 5, 5 end
	local hf, vf = mx+d+w > W, my+d+h > H
	x = hf and math.max(0, mx-w) or mx+d
	y = vf and math.max(0, my-h) or my+d
	return x, y, hf, vf
end

local function changeAttr(attr, v)
	if attr.uk then
		local sup, u = attr.owner.sup, attr.owner.u
		if attr.uk=='align' and ui.is(ui.align, v) then
			local m = getmeta(u)
			if v[1] >= 0 then
				for i = #m, 1, -1 do
					if m[i].u==sup then ui.setOffer(sup, 'w', u.w) break end
					if m[i].o.w or i==1 then ui.setOffer(u, 'w', u.w) break end
				end
			end
			if v[3] >= 0 then
				for i = #m, 1, -1 do
					if m[i].u==sup then ui.setOffer(sup, 'h', u.h) break end
					if m[i].o.h or i==1 then ui.setOffer(u, 'h', u.h) break end
				end
			end
		end
		ui.setOffer(attr.owner.sup, attr.uk, v)
	else
		attr.owner.o[attr.k] = v
	end
end

local function belongNew(u)
	if u == ui or u.owner==ui then return u end
	for k, v in next, getmeta(u.owner).o do
		if v == u then return u end
	end
	local o, m = belongNew(u.owner), getmeta(u)
	ui.setOffer(o, m.key, 0^m[m.min].u^{})
	return o[m.key]
end
function onode.edit:onClick()
	ui.enableEdit(self.owner.sup)
end

function ui.editattrroot:onUpdate()
	self:checkEnable()
end
function ui.editattrroot:checkEnable()
	if not self.owner.sub then
		self.over.checked = true
		local m = getmeta(self.owner.u)
		for i = #m, 1, -1 do
			if m[i].u == self.owner.sup then break end
			if m[i].o[self.uk] ~= nil then self.over.checked = false break end
		end
		if curra==self and not self.over.checked then self:unselect() end
	else
		self.over.checked = getmeta(self.owner.u).o[self.uk] ~= nil
	end
	self.reset.show = self.over.show and not self.over.checked
	return self.over.checked
end
function ui.editattrroot.reset:onClick()
	self.reseting = true
end
function ui.editattrroot:onPick(full)
	ui.pick'allchild' ui.super() local c = ui.child()
	if c ~= self and c ~= self.over and c ~= self.reset
		and not ui.is(ui.edittreenode.exicon, c) and not self:checkEnable()
		then ui.child(false) end
end
function ui.editattrroot:onRender(full)
	ui.super() ui.child()
	if not self.owner.sub and not self.over.checked then
		if self.h < 30 then
			_rd:drawLine(0, self.h/2, self.w, 1, 0x77ffffff)
		else
			_rd:drawLine(0, 0, self.w, self.h, 0x77ffffff)
			_rd:drawLine(0, self.h-1, self.w, 0, 0x77ffffff, true)
		end
	end
end

function ui.editattrroot.over:onChange()
	if not self.show then return end
	if self.checked then
		self.owner:onChange()
		self.owner:select()
	else
		self.owner:unselect()
		changeAttr(self.owner, nil)
		if self.owner.sub and self.owner.align==nil then
			self.owner.align = ui.alignLT()
		end
	end
end
function ui.editattr:onChange()
	print'!! no onChange'
end

function ui.editcurra:select()
	if curra then curra:unselect() end
	if self.over and not self.over.checked then return false end
	curra = self
	local u = self.owner
	while ui.is(ui.edittreenode, u) do u:expand(true) u = u.owner end
	return true
end
function ui.editcurra:unselect()
	if curra ~= self then return false end
	curra = nil
	return true
end
function ui.editcurra:onRender()
	if curra==self then _rd:fillRect(0, 0, self.w, ui.editattr.h, 0x3300ffff) end
end
function ui.editcurra:onFocus(full)
	ui.super() ui.child()
	local u = ui.focus()
	while not ui.is(ui.editcurra, u) and not ui.is(ui.edittreenode.exicon, u)
		and not ui.is(olist.attrtable.add, u) and not ui.is(olist.attrtable.del, u)
		and not ui.is(olist.attrtable.up, u) and not ui.is(olist.attrtable.down, u)
		do u = ui.parent(u) end
	if u==self then self:select() end
end

local function updateOffer(self)
	if curra==self then return end
	if not self.uk then return self.owner.o[self.k] end
	if self.over.checked then return self.owner.sup[self.uk] end
	if not self.reset.reseting then return end
	self.reset.reseting = false
	return self.owner.sup[self.uk]
end
function ui.editattrinput:onEnter()
	self.owner:onChange()
end
function olist.attrtext:onUpdate()
	local v = updateOffer(self)
	if type(v)=='string' and v ~= self.value.text then self.value:setText(v) end
end
function olist.attrtext:onChange()
	changeAttr(self, self.value.text)
end
function olist.attrnum:onUpdate()
	local v = updateOffer(self)
	if type(v)=='number' and v ~= tonumber(self.value.text) then self.value:setText(v) end
end
function olist.attrnum:onChange()
	local v = tonumber(self.value.text) or 0
	self.value:setText(v)
	changeAttr(self, v)
end
function olist.attrbool:set(b)
	if self.now ~= nil then self.last = now else self.last = b end
	self.now, self.value.checked = b, b
end
function olist.attrbool:onUpdate()
	local v = updateOffer(self)
	if type(v)=='boolean' and v ~= self.value.checked then self.value.checked = v end
end
function olist.attrbool:onChange()
	-- local last, now = self.last, self.now
	-- self.last, self.now = self.now, self.value.checked
	-- addDo(function ()
		-- changeAttr(self, last)
		-- self.value.checked = last
	-- end, function ()
		-- changeAttr(self, now)
		-- self.value.checked = now
	-- end, '属性'..(self.uk or self.k))
	changeAttr(self, self.value.checked)
end
function olist.attrbool.value:onChange()
	self.owner:onChange()
end

function olist.attralign:set(a)
	self.a = a
	self.value.text = tostring(a)
end
function olist.attralign:onUpdate()
	local v, a = updateOffer(self), self.a
	if ui.is(ui.align, v) and tostring(v) ~= tostring(a) then
		self:set(v)
	end
end
function olist.attralign:select()
	if not ui.editattr.select(self) then return false end
	if self.uk ~= 'align' then
		self.root.owner.u.align, self.old = self.a, self.root.owner.u.align or false
		ui.position(self.root.owner.u)
	end
	editprop.aligns:set(self, self.root.owner.u)
	return true
end
function olist.attralign:unselect()
	if not ui.editattr.unselect(self) then return false end
	editprop.aligns:set()
	if self.old ~= nil then self.root.owner.u.align, self.old = self.old or nil end
	ui.position(self.root.owner.u)
	return true
end
function olist.attralign:onChange(a)
	if a then self:set(a) end
	changeAttr(self, self.a)
	if self.old ~= nil then self.root.owner.u.align = self.a end
end

function ui.editattrfont:set(f)
	local res = f.font or f
	self.font.text = res.resname ..' '..res.size..' '..res.style
	self.color:setText(('%06x'):format(f.textColor%0x1000000))
	self.alpha:setText(toint(f.textColor%0x100000000/0x1000000/255*100, .5))
	self.f = f
end
function ui.editattrfont:onUpdate()
	local v, f = updateOffer(self), self.f
	if _Font==getmetatable(v) and v ~= f and
		(v.resname ~= f.resname or v.textColor ~= f.textColor or v.align ~= f.align) then
		self:set(v)
	end
end
function ui.editattrfont.font:onClick()
	local menu = uilist.font
	menu.show = true
	menu:clear()
	local attr = self.owner
	local node = menu.node
	local function click(self)
		attr:onChange(ui.font(self.f, attr.f.textColor, attr.f.align))
	end
	local function hover(self)
		attr:onChange(ui.font(self.f, attr.f.textColor, attr.f.align), true)
	end
	local function unhover(self)
		attr:onChange()
	end
	local ks = tablekeys(ui.fonts)
	table.sort(ks)
	for i, k in ipairs(ks) do
		local f = ui.fonts[k]
		local n = node^{ f=f, text=('%s%3d %s'):format(f.resname, f.size, f.style),
			onClick=click, onHover=hover, onUnhover=unhover }
		node.owner:addNode(n)
	end
end
function ui.editattrfont.color:onNew()
	self.font = ui.font(self.font, self.font.textColor, self.font.align)
end
function ui.editattrfont.color:onUpdate()
	self.font.resname = self.owner.f.resname
	self.font.textColor = self.owner.f.textColor%0x1000000+0xff000000
end
local function changeColor(self)
	local attr = self.owner
	local color = (tonumber(attr.color.text, 16) or attr.f.textColor)%0x1000000
		+ 0x1000000*toint(255/100*math.max(0, math.min(100,
		toint(attr.alpha.text) or toint(attr.f.textColor%0x100000000/0x1000000/255*100, .5))))
	attr:onChange(ui.font(attr.f, color, attr.f.align))
	attr.color:setText(('%06x'):format(color%0x1000000))
	attr.alpha:setText(toint(color/0x1000000/255*100, .5))
	return color
end
ui.editattrfont.color.onEnter = changeColor
ui.editattrfont.alpha.onEnter = changeColor
function ui.editattrfont.color:onRightClick()
	local c = _sys:selectColor(changeColor(self))
	self.owner.color:setText(('%06x'):format(c%0x1000000))
	changeColor(self)
end

function olist.attrfont.Align:onRender()
	local x,y
	if self.owner.f.align then  x, y = self.owner.f.align:byte(1, 2)end

	x, y = x==99 and 1 or x==114 and 2 or 0, y==109 and 1 or y==98 and 2 or 0
	_rd:fillRect(0, 0, 20, 20, 0xffa9a0a2)
	_rd:fillRect(x*6, y*6, 8, 8, 0xff217b05)
end
function olist.attrfont.Align:onClick()

	local a = olist.fontalign
	a.attr = self.owner
	if a.attr.f.align then 
		a.s = 'align'..a.attr.f.align:upper()
	else
		a.s =  'align'..'LT'
	end
	ui.front(ui.modaltop, a)
	ui.show(a, true)
	ui.focusTo(a)
	ui.moveTo(a, ui.mousex - a.w/2, ui.mousey - a.h + 5)
end
function olist.fontalign:onUnfocus(tochild, full)
	ui.super() ui.child()
	if not tochild then
		self.show = false
	end
end
function olist.fontalign:onSelect(s)
	local attr = self.attr
	attr:onChange(ui.font(attr.f, attr.f.textColor, s:sub(6, 7):lower()))
	self.show, self.attr = false
end
function olist.attrfont:onChange(f, preview)
	if not f then f = self.f
	elseif not preview then self:set(f) f = self.f
	end
	changeAttr(self, f)
end

function olist.attrimgt:set(img)
	ui.editattrfont.set(self, img.font)
	self.value:setText(img.text)
	self.img = img
end
function olist.attrimgt:onUpdate()
	self.toarray.show = true
	local v, img, f = updateOffer(self), self.img, self.f
	if _Image==getmetatable(v) and v.font and v ~= img and
		(v.font.resname ~= f.resname or v.font.textColor ~= f.textColor
		or tostring(v.align) ~= tostring(img.align) or v.text ~= img.text) then
		self:set(v)
	end
end
function olist.attrimgt:select()
	if not ui.editattr.select(self) then return false end
	editprop.aligns:set(self, self.root.owner.u)
	return true
end
function olist.attrimgt:unselect()
	if not ui.editattr.unselect(self) then return false end
	editprop.aligns:set()
	return true
end
function olist.attrimgt.copy:onRender(full)
	if getmeta(currcopy)==_Image and currcopy.font then self.backgs.font.textColor = 0xffffaa00 end
	ui.super() ui.child()
	self.backgs.font.textColor = 0xffaaff00
end
function olist.attrimgt.copy:onClick()
	if not currcopy then
		currcopy = self.owner.img
	elseif getmeta(currcopy)==_Image and currcopy.font then
		local i = ui.img(currcopy.font, currcopy.font.textColor,
			ui.align(unpack(currcopy.align)), currcopy.text)
		self.owner:set(i)
		changeAttr(self.owner, i)
		currcopy = nil
		if curra==self.owner then self.owner:unselect() self.owner:select() end
	end
end
function olist.attrimgt:onChange(fa, preview)
	local i
	if not fa then
		i = self.img
	else
		local f = _Font==getmetatable(fa) and fa or self.f
		local a = ui.is(ui.align, fa) and fa or self.img.align
		i = ui.img(f, f.textColor, a, self.value.text)
		if not preview then self:set(i) end
	end
	changeAttr(self, i)
end
function olist.attrimgt.value:onEnter(full)
	self.owner:onChange(true)
end

function olist.attrimg:set(img)
	self.value:setText(img.res or img.resname)
	self.img = img
end
function olist.attrimg:onUpdate()
	self.toarray.show = true
	local v, img = updateOffer(self), self.img
	if _Image==getmetatable(v) and not v.font and v ~= img then
		self:set(v)
	end
end
function olist.attrimg:select()
	if not ui.editattr.select(self) then return false end
	editprop.pic:set(self)
	editprop.aligns:set(self, self.root.owner.u)
	return true
end
function olist.attrimg:unselect()
	if not ui.editattr.unselect(self) then return false end
	editprop.pic:set()
	editprop.aligns:set()
end
function olist.attrimg.copy:onRender(full)
	if getmeta(currcopy)==_Image and not currcopy.font then self.backgs.font.textColor = 0xffffaa00 end
	ui.super() ui.child()
	self.backgs.font.textColor = 0xffaaff00
end
function olist.attrimg.copy:onClick()
	if not currcopy then
		currcopy = self.owner.img
	elseif getmeta(currcopy)==_Image and not currcopy.font then
		local i = ui.img(currcopy, currcopy.align)
		self.owner:set(i)
		changeAttr(self.owner, i)
		currcopy = nil
		if curra==self.owner then self.owner:unselect() self.owner:select() end
	end
end
function olist.attrimg:onChange(pa, preview)
	local i
	if not pa then
		i = self.img
	else
		local p = _Image==getmetatable(pa) and pa or self.img
		local a = ui.is(ui.align, pa) and pa or self.img.align
		i = ui.img(p, a)
		if not preview then self:set(i) end
	end
	changeAttr(self, i)
end

function olist.attrtable:onUpdate()
	local v, o = updateOffer(self), self.o
	if type(v)=='table' and v ~= o then
		self.o, self.inited = v
		self:clear()
		self:init()
	end
	self.noarray.backgs = self.noarray.backgsno
	self.noarray.show = next(self.o)==1 and next(self.o, 1)==nil
	local ok = curra==self or curra and curra.owner==self and type(curra.k)=='number'
	self.add.show = ok
	ok = ok and curra ~= self
	self.del.show = ok
	self.up.show = ok and type(curra.k)=='number' and curra.k > 1
	self.down.show = ok and type(curra.k)=='number' and curra.k < #self.o
end
function olist.attrtable:onChange()
	changeAttr(self, self.o)
end

local function refreshCurra(img)
	local c = curr curr = nil setCurr(c)
	img = olist:search(img)
	if img then img:select() end
end
local function copyDeep(a, s)
	if a.uk then
		s = s or table.copy({}, a.owner.sup[a.uk])
	else
		a.owner.o = copyDeep(a.owner)
		s = s or table.copy({}, a.owner.o[a.k])
	end
	changeAttr(a, s)
	return s
end
function ui.edittoarray:onClick()
	local img = self.owner.img
	copyDeep(self.owner, { img })
	refreshCurra(img)
end
function olist.attrtable.noarray:onClick(full)
	local img = self.owner.o[1]
	copyDeep(self.owner, img)
	refreshCurra(img)
end
function olist.attrtable.add:onRender(full)
	self.backgs = hotkeyImgt() and self.backgs2 or self.backgs1
	ui.super() ui.child()
end
function olist.attrtable.add:onClick()
	if curra==self.owner then
		local s = copyDeep(curra)
		local img = hotkeyImgt() and ui.img(ui.fonts.s9e, 0xffffffff, nil, '') or ui.img'dummy'
		table.insert(s, 1, img)
		refreshCurra(img)
	elseif curra and curra.owner==self.owner and type(curra.k)=='number' then
		local s = copyDeep(curra.owner)
		local img = hotkeyImgt() and ui.img(ui.fonts.s9e, 0xffffffff, nil, '') or ui.img'dummy'
		table.insert(s, curra.k+1, img)
		refreshCurra(img)
	end
end
function olist.attrtable.del:onClick()
	if curra and curra.owner==self.owner then
		local s = copyDeep(curra.owner)
		table.remove(s, curra.k)
		local img = s[curra.k] or type(curra.k)=='number' and s[curra.k-1]
		if img then refreshCurra(img) else local c = curr curr = nil setCurr(c) end
	end
end
function olist.attrtable.up:onClick()
	if curra and curra.owner==self.owner
		and type(curra.k=='number') and curra.k > 1 then
		local s, img = copyDeep(curra.owner), curra.img
		s[curra.k-1], s[curra.k] = s[curra.k], s[curra.k-1]
		refreshCurra(img)
	end
end
function olist.attrtable.down:onClick()
	if curra and curra.owner==self.owner
		and type(curra.k=='number') and curra.k < #curra.owner.o then
		local s, img = copyDeep(curra.owner), curra.img
		s[curra.k+1], s[curra.k] = s[curra.k], s[curra.k+1]
		refreshCurra(img)
	end
end

function onode:onNew()
	self.font = ui.font(self.font, self.font.textColor, self.font.align)
end
function onode:onRender(full)
	if delalls[self.sup] then _rd:drawLine(0, 10, self.w, 1, 0xffffff00) end
	if dels[self.sup] then _rd:drawLine(0, 11, self.w, 1, 0xffffff00) end
	ui.super() ui.child()
end
function onode:init()
	if self.inited then return end
	self.inited = true
	local root = ui.is(onode, self) and ui.editattrroot or ui
	local m, ks, Ks = getmeta(self.sup)
	if m then
		ks, Ks = {}, {}
		if self.sub then
			ks[1], Ks.w = 'w', true
			ks[2], Ks.h = 'h', true
			ks[3], Ks.align = 'align', true
			ks[4], Ks.backgs = 'backgs', true
			ks[5], Ks.show = 'show', true
		end
		for i = #m, self.sub and 1 or #m, -1 do
			for k in next, m[i].o do
				if not Ks[k] then Ks[k], ks[#ks+1] = true, k end
			end
		end
	else
		ks = tablekeys(self.o)
	end
	sortKeys(ks)
	for i, k in ipairs(ks) do
		local v, sup, node
		if m then
			for i = #m, self.sub and 1 or #m, -1 do
				v, sup = m[i].o[k], m[i] if v ~= nil then break end
			end
			if self.sub and v==nil then
				if k=='w' then v = 0
				elseif k=='h' then v = 0
				elseif k=='align' then v = ui.alignLT() self.u.align = v
				elseif k=='backgs' then v = ui.img'dummy'
				elseif k=='show' then v = true
				end
			end
		else
			v = self.o[k]
		end
		if type(v) == 'string' then
			node = olist.attrtext^root^{}
			self:addNode(node)
			node.value:setText(v)
		elseif type(v) == 'number' then
			node = olist.attrnum^root^{}
			self:addNode(node)
			node.value:setText(v)
		elseif type(v) == 'boolean' then
			node = olist.attrbool^root^{}
			self:addNode(node)
			node:set(v)
		elseif ui.is(ui.align, v) then
			node = olist.attralign^root^{}
			self:addNode(node)
			node:set(v)
		elseif _Font==getmetatable(v) then
			node = olist.attrfont^root^{}
			self:addNode(node)
			node:set(v)
		elseif _Image==getmetatable(v) and v.font then
			node = olist.attrimgt^root^{}
			self:addNode(node)
			node:set(v)
		elseif _Image==getmetatable(v) and not v.font then
			node = olist.attrimg^root^{}
			self:addNode(node)
			node:set(v)
		elseif ui.is(ui, v) then
		elseif type(v) == 'table' then
			node = root^olist.attrtable^{ expanded=false }
			self:addNode(node)
			node.o, node.text = v, ''
			if root ~= ui then
				node.over.align[7] = node.over.align[7] + node.align[2]
				node.align[2] = node.align[2] + root.align[2]
				node.align[7] = node.align[7] - root.align[2]/2
			end
		end
		if node then
			if root ~= ui then
				node.root, node.uk = node, k
				if sup == m then node.over.checked = true end
				node.over.show = self.sub
			else
				node.root, node.k = self.root, k
			end
			node.offer, node.name.text = (sup or m or self).o, k
			if ui.is(olist.attrtable, node) then node:init() end
		end
	end
end
function onode:expand(b)
	self:init()
	ui.edittreenode.expand(self, b)
end
olist.attrtable.init, olist.attrtable.expand = onode.init, onode.expand

function olist:init()
	self:clear()
	if not curr then return end
	local m, ii, node = getmeta(curr)
	for i = #m, 1, -1 do
		if m[i].u == belongOffer(m[i].u) then
			ii = i break
		end
	end
	if not ii then error('edit sub '..curr) end
	for i = 1, #m do
		node = onode^{ text=m[i].name, show=true }
		self:addNode(node)
		node.o, node.sup, node.u, node.sub = m[i].o, m[i].u, curr, false
		node.sub = i==#m
		node:expand(true)
		node:expand(i==ii)
		node.show = i <= ii
		if i==ii and editwin ~= ui and not curra then
			for k, v in next, node do
				if ui.is(olist.attralign, v) and v.uk=='align' then
					v:select()
				end
			end
		end
	end
end
function olist:onPick(full)
	ui.super()
	local c = ui.child()
	if editwin==ui and not ui.is(ui.edittreenode.exicon, c) and not ui.is(onode.edit, c) then
		ui.child(c and self.scroll.bar)
	end
end

function olist:search(img)
	assert(_Image==getmetatable(img))
	local last, node = ui.front(self.panel)
	while last do
		node, last = last
		if not node.over or node.over.checked then
			if node.img==img then return node end
			last = node.panel and ui.front(node.panel)
		end
		while not last and node ~= self do last, node = ui.low(node), node.owner end
	end
end

function uinode:onNew()
	self.font = ui.font(self.font, self.font.textColor, self.font.align)
end
function uinode:set(u)
	self.u = u
	local name = self.k or ui.name(self.u)
	self.text = getmeta(u).title and getmeta(u).title..' '..name or name
	if self.u ~= ui then
		local fu = self.u
		while fu.owner ~= ui do fu = fu.owner end
		self.file.text = getmeta(fu).file or ''
	end
	self.exicon.show = not not ui.front(self.u)
	self.Show.show = self.u ~= ui
	self.seq.show = not belongs[self.u] and self.Show.show
	self.add.show = not belongs[self.u] and self.u ~= ui.top and self.u ~= ui.modal
		and self.u ~= ui.modaltop and self.u ~= ui.forcename
	self.del.show = not belongs[self.u] and self.Show.show and not getmeta(self.u).newedit
		and self.u ~= ui.top and self.u ~= ui.modal and self.u ~= ui.forcename
	self.queue.show = editwin ~= ui and not belongs[self.u] and self.u ~= editwin
	self.queue:setText(queues[self.u] and #queues[self.u]+1 or '')
end

function uinode:expand(b)
	if not self.initexpand then
		self.initexpand = true
		local u = ui.front(self.u)
		local uis = {}
		for k, v in next, self.u do
			if ui.is(ui, v) and v.owner == self.u then
				assert(uis[v]==nil, os.info.uilang'没处理情况')
				uis[v] = k
			end
		end
		while u do
			if u ~= ui.modaltop and queues[u] ~= true
				and (self.u~=ui or u.owner~=ui or not uis[u]:lead'edit') then
				local node = uinode^{ text='', show=true, expanded=false }
				self:addNode(node)
				if u.owner==self.u and uis[u] then
					node.k = uis[u]
				end
				node:set(u)
			end
			u = ui.low(u)
		end
	end
	ui.edittreenode.expand(self, b)
end

function uinode:onClick()
	local u = self.u
	if belongs[u] then
		if u ~= belonged then
			belonged, u = u, belongs[u]
		elseif hotkeySub() then
			u = belongNew(u)
			ui.cancelEdit(true) ungo = ungo-1 ui.enableEdit(ungos[ungo+1], true)
		end
	end
	setCurr(u)
end

function uinode:onRender(full)
	local x, y = ui.pos(self, uilist)
	if y + self.h < -10 or y > uilist.h + 10 then return end
	if delalls[self.u] then _rd:drawLine(0, 10, self.w, 1, 0xffffff00) end
	if dels[self.u] then _rd:drawLine(0, 11, self.w, 1, 0xffffff00) end
	if belongs[self.u] then self.font.textColor = 0xffbbdd00 end
	ui.super()
	self.font.textColor = 0xff00ff00
	if self.owner[self.owner.select] == self then
		_rd:fillRect(0, 0, self.w, self.panel.y-2, 0x66dddddd)
		_rd:drawRect(0, 0, self.w, self.panel.y-2, 0xffffff00)
	end
	if editwin then
		if curr == self.u then
			_rd:fillRect(0, 0, self.w, self.panel.y-2, 0x7700ffff)
		elseif belonged == self.u then
			_rd:drawRect(0, 0, self.w, self.panel.y-2, 0xffbbdd00)
		elseif currps and currps[self.u] then
			_rd:fillRect(0, 0, self.w, self.panel.y-2, 0x3300ffff)
		end
	end
	if editmain.search.search and tostring(self.text):find(editmain.search.search) then
		_rd:drawRect(0, 0, self.w, self.panel.y-2, 0xffeeeeee)
	end
	if currq then self.seq.backgs.font.textColor = hotkeyFront() and 0xff00aaff or 0xffffaa00 end
	ui.child()
	self.seq.backgs.font.textColor = 0xffaaff00
end

function uinode:onRightClick()
	if self.u==ui or self.u==ui.top or self.u==ui.modal or self.u==ui.forcename then return end
	ui.parent(uilist.title, self)
	uilist.title:setText(getmeta(self.u).title or '')
	ui.show(uilist.title, true)
	ui.focusTo(uilist.title)
end
function uilist.title:onUnfocus()
	ui.show(self, false)
	ui.parent(self, uilist)
end
function uilist.title:onEnter()
	local node = ui.parent(self)
	getmeta(node.u).title = self.text:gsub('^%s*(.-)%s*$', '%1')
	ui.focusTo(node)
	node:set(node.u)
end

function uinode.Show:onUpdate()
	if self.owner.u then self.checked = self.owner.u.show end
end
function uinode.Show:onChange()
	self.owner.u.show = self.checked
	local q = queues[self.owner.u]
	if q then for i = 1, #q do q[i].show = self.checked end end
end

function editmain.search:onChange()
	self.search = self.text and #self.text > 0
		and pcall(string.find, '', self.text) and self.text
end
function editmain.search:onEnter()
	if not self.search then return end
	local rev = hotkeyRev()
	local last, node, from, lastfrom = (rev and ui.front or ui.back)(uilist.panel)
	if not last then return end
	while last do
		node = last
		if not from then
			if node.u == curr then from = node end
		elseif node == from then
			break
		elseif tostring(node.text):find(self.search) and setCurr(node.u) then
			ui.focusTo(self)
			local r, x, y = uilist.scroll, ui.pos(node, uilist)
			if y <= node.h then r:scrollContent(y-node.h)
			elseif y+node.h >= r.viewH then r:scrollContent(y+node.h*2-r.viewH)
			end
			break
		end
		if not ui.back(node.panel) then
			local last, u = ui.back(node.u)
			while last do
				u = last
				local name = tostring(u.owner==ui.parent(u) and getmeta(u).key or ui.name(u))
				if (getmeta(u).title and getmeta(u).title..' '..name or name):find(self.search)
					and u ~= ui.modaltop and not ui.name(u):lead'ui.edit' then
					node:expand(true)
					break
				end
				last = ui.back(u)
				while not last and u ~= node.u do last, u = ui.high(u), ui.parent(u) end
			end
		end
		lastfrom, last = node, (rev and ui.front or ui.back)(node.panel)
		while not last and node ~= uilist do
			last, node = (rev and ui.low or ui.high)(node), node.owner
		end
		if not last then
			last, from = (rev and ui.front or ui.back)(uilist.panel), from or lastfrom
		end
	end
end

function editmain:onUpdate()
	editmain.seqing.show = not not currq
	editmain.seqing.text = currq and ui.name(currq) or ''
	editmain.copying.show = not not currcopy
	editmain.copying.text = getmeta(currcopy)==_Image and fun.image(nil, currcopy) or ''
end

function uinode.seq:onClick()
	local u = self.owner.u
	if not currq then
		if getmeta(u).parent.seq ~= ui.seqParent(u) then
			return notice(os.info.uilang'此ui由代码控制')
		end
		currq = u
	else
		local x, y = ui.pos(currq)
		ui.setSeq(currq, hotkeyFront() and u or ui.parent(u), not hotkeyFront() and u)
		if hotkeyFront() then
			local p = currq
			while p ~= ui do
				ui.position(p)
				p = ui.parent(p)
			end
			local xx, yy = ui.pos(currq)
			ui.moveDiff(currq, x-xx, y-yy)
			ui.setOffer(currq, 'align', currq.align)
		end
		if queues[u] then for i = 1, #queues[u] do
			ui.high(i==1 and u or queues[u][i-1], queues[u][i])
		end end
		if queues[currq] then for i = 1, #queues[currq] do
			ui.high(i==1 and currq or queues[currq][i-1], queues[currq][i])
		end end
		currq = nil
		ui.cancelEdit(true) ungo = ungo-1 ui.enableEdit(ungos[ungo+1], true)
	end
end
function editmain.seqing.no:onClick()
	currq = nil
end
function editmain.copying.no:onClick()
	currcopy = nil
end
local function addUi(owner, u, file, parent, low ,loadname ,key)
	if not key then 
		local key = 'new'..(ui.maxnewkey+1) 
	end
	if not loadname then 
		local loadname = 'other'
	end
	if owner==ui then
		if file ~= ui then while file.owner ~= ui do file = file.owner end end
		local fs = { math.max(999, getmeta(file).file or 0) }
		for k, v in next, getmeta(ui).o do if getmeta(v).file > fs[1] then
			fs[#fs+1] = getmeta(v).file
		end end
		fs[#fs+1] = 9950
		table.sort(fs)
		local f9, f = 0
		for i = 2, #fs do
			if fs[i]-fs[i-1] > f9 then f9, f = fs[i]-fs[i-1], i-1 end
		end
		if f9 <= 1 then notice(os.info.uilang'ui文件已满') return end
		f = fs[f]+(f9 > 40 and 20 or toint(f9/2))
		ui.load(loadname, f)
		ui.new[key] = u
		assert(getmeta(u).file == f)
	else
		ui.setOffer(owner, key, u)
	end
	if parent then
		ui.setSeq(owner[key], parent, low)
	end
	ui.cancelEdit(true) 
	ungo = ungo-1 
	ui.enableEdit(ungos[ungo+1], true)
	setCurr(owner[key])
end


function uinode.add:onClick()
if hotkeyDup() then
		if  getmeta(self.owner.u).newedit then print(self.owner , self.owner.u ,getmeta(self.owner.u).newedit) notice('模板不能直接复制') return end
		local u = 'return '..genUI(self.owner.u, nil, nil, true)..'nil'
		local u = assert(loadstring(u))()
		uilist.newui.addui = {}
		uilist.newui.addui = {owner =self.owner.u.owner , u = u , file = self.owner.u , parent = ui.parent(self.owner.u) , low = self.owner.u }
		uilist.newui.show = true
		return
	end

	uilist.menu:clear()
	local s = {}
	for k, v in next, ui do if ui.is(ui, v) and getmeta(v).newedit then
		s[#s+1] = getmeta(v)
	end end
	table.sort(s, function (a, b) return a.file < b.file end)
	table.insert(s, 1, getmeta(ui))
	uilist.menu.nodes = s 
	local menupage = uilist.menu.page
	menupage.currpage = 1
	menupage.searchedNode = {}
	local menupage = uilist.menu.page
	local addi = 0
	for i, m in next, s do
		if  string.find(ui.name(m.u),uilist.menu.search.text) then
			addi = addi + 1
			if addi <=menupage.pageNodeNum then
				uilist.menu:addNode(uilist.menu.node^{ text=ui.name(m.u) })
			end
			table.insert(menupage.searchedNode , ui.name(m.u))
		end
	end
	menupage.totalpagenum = math.ceil(#uilist.menu.page.searchedNode/menupage.pageNodeNum)
	menupage.totalpagenum = menupage.totalpagenum <= 0 and 1 or menupage.totalpagenum
	menupage.pagenum.text = menupage.currpage..'/'..menupage.totalpagenum
	uilist.menu.Owner = self.owner.u
	ui.show(uilist.menu, true)
end
function uilist.menu.node:onHover()
	local u = ui.byName(self.text)^{}
	ui.new[#ui+1], self.preview = u, u
	ui.show(u, true)
	ui.position(u)
	if u.w <= 0 or u.h <= 0 then ui.sizeTo(u, 50, 50) end
	if u.x < 0 or u.y < 0 then ui.moveTo(u, 0, 0) end
	ui.focusTo(self)
end
function uilist.menu.node:onUnhover()
	if self.preview then
		ui.remove(nil, self.preview)
		self.preview = nil
	end
end

function uilist.menu.node:onClick()
	self:onUnhover()
	local sup = ui.byName(self.text)
	uilist.newui.show = true
	if self.owner.Owner == ui then 
		uilist.newui.loadname.show = true
	else
		uilist.newui.loadname.show = false
	end
	uilist.newui.addui = {}
	uilist.newui.addui = {owner =self.owner.Owner , u = sup^{} , file = sup }
	local test = sup^{}
end
function uilist.menu.search:onEnter()
	local u = ui.byName(self.text)
	if not u then notice(os.info.uilang'找不到%s':format(self.text)) return end
	for k, v in next, self.owner do
		if ui.is(self.owner.node, v) and v.text == self.text then
			v:onClick() return
		end
	end
	notice(os.info.uilang'此模板由程序处理')
end
function uilist.newui:onShow(  )
	local key = 'new'..(ui.maxnewkey+1) 
	local loadname = getmeta(uilist.newui.addui.owner).load and getmeta(uilist.newui.addui.owner).load.name or 'other'
	self.loadname:setText(loadname)
	self.name:setText(key)
	if uilist.newui.loadname.show then 
		ui.focusTo(uilist.newui.loadname)
		uilist.newui.loadname:selectAll()
	else
		ui.focusTo(uilist.newui.name)
		uilist.newui.name:selectAll()
	end
end

function uilist.newui.loadname:onEnter(  )
	ui.focusTo(uilist.newui.name)
	uilist.newui.name:selectAll()
end

function uilist.newui.name:onEnter(  )
	ui.focusTo(uilist.newui.btn_ok)
end

function uilist.newui.btn_ok:onKey(k ,c)
	if k == 13 then self:onClick() return end
	if k == 27 then uilist.newui.show = false return end
end

function uilist.newui.btn_ok:onClick( )
	local newui = uilist.newui	
	if newui.name.text == '' then
		notice(os.info.uilang'UI不能为空')
		return
	end
	local flag =  false
	if newui.addui.owner == ui then 
		if ui[newui.name.text] then flag = true end
	else
		local b = ui.back(newui.addui.owner)
		while b do 
			if newui.name.text == getmeta(b).key then 
				flag = true
			end
			b = ui.high(b)
		end
	end
	if not flag then
		addUi(newui.addui.owner ,newui.addui.u , newui.addui.file , newui.addui.parent , newui.addui.low ,newui.loadname.text,newui.name.text )
		uilist.newui.show = false
	else 
		notice(os.info.uilang'UI名字重复')
	end
end

function uilist.newui.btn_cancel:onClick( )
	uilist.newui.show = false
end
local function pageSwitch( pageSwitched )
	local menupage = uilist.menu.page
	if menupage.currpage == pageSwitched then
		return 
	end
	uilist.menu:clear()
	menupage.currpage = pageSwitched
	local start = (menupage.currpage - 1) * menupage.pageNodeNum + 1
	local stop = start + menupage.pageNodeNum - 1 <= #menupage.searchedNode and start + menupage.pageNodeNum - 1 or #menupage.searchedNode
	menupage.pagenum.text = menupage.currpage..'/'..menupage.totalpagenum
	for i = start , stop do 
		uilist.menu:addNode(uilist.menu.node^{ text=menupage.searchedNode[i] })
	end
end

function uilist.menu.page.home_page:onClick(  )
	pageSwitch(1)
end

function uilist.menu.page.pre_page:onClick(  )
	if uilist.menu.page.currpage > 1 then
		pageSwitch(uilist.menu.page.currpage -1 )
	end
end

function uilist.menu.page.next_page:onClick(  )
	if uilist.menu.page.currpage < uilist.menu.page.totalpagenum then
		pageSwitch(uilist.menu.page.currpage + 1 )
	end
end

function uilist.menu.page.end_page:onClick(  )
	pageSwitch(uilist.menu.page.totalpagenum)
end

function uilist.menu.search:onChange()
	local nodesnum = uilist.menu.nodesnum
	local menuList = uilist.menu
	local clearFlag = false
	for i ,v in next , menuList.nodes do 
		if string.find(ui.name(v.u),self.text) then
			clearFlag = true
			break
		end
	end
	if clearFlag then 
		menuList:clear()
	else 
		return 
	end
	local menupage = uilist.menu.page
	local resultnum= 0
	menupage.currpage = 1
	menupage.searchedNode = {}

	for i ,v in next , menuList.nodes do 
		if string.find(ui.name(v.u),self.text) then
			resultnum = resultnum +1
			table.insert(menupage.searchedNode , ui.name(v.u))
		end
	end
	menupage.totalpagenum = math.ceil(resultnum/menupage.pageNodeNum)
	menupage.pagenum.text = menupage.currpage..'/'..menupage.totalpagenum
	
	local addi = 0
	for i ,v in next , menuList.nodes do 
		if string.find(ui.name(v.u),self.text) then
			uilist.menu:addNode(uilist.menu.node^{ text=ui.name(v.u) }) 
			ui.focusTo(self)
			addi = addi + 1
			if addi >= menupage.pageNodeNum then 
				 break
			end
		end
	end 
end


local function setQueue(u, n)
	n = math.max(n-1, 0)
	local q, p = queues[u], ui.parent(u)
	if q==true then return end
	if not q then
		if n==0 then return end
		q = {} queues[u] = q
	end
	for i = n+1, #q do ui.remove(nil, q[i]) queues[q[i]], q[i] = nil end
	for i = #q+1, n do q[i] = u^{} p.new[#p+1], queues[q[i]] = q[i], true end
	for i = 1, n do ui.high(i==1 and u or q[i-1], q[i]) end
	if n==0 then queues[u] = nil end
end
function uinode.del:onClick()
	local subs = {}
	local last, node = ui.back(ui)
	while last do
		node = last
		local m = getmeta(node)
		for i = 1, #m-1 do
			local s = subs[m[i].u]
			if not s then s = {} subs[m[i].u] = s end
			s[#s+1] = node
		end
		last = ui.back(node)
		while not last and node ~= ui do last, node = ui.high(node), ui.parent(node) end
	end
	dels[self.owner.u], delalls = not dels[self.owner.u] or nil, {}
	for v in next, dels do
		delalls[v], delalls[#delalls+1] = true, v
	end
	local i = 1
	while i <= #delalls do
		local u = delalls[i]
		for k, v in next, u do
			if not delalls[v] and ui.is(ui, v) and v.owner == u then
				delalls[v], delalls[#delalls+1] = true, v
			end
		end
		if subs[u] then
			for i, v in next, subs[u] do if not delalls[v] then
				delalls[v], delalls[#delalls+1] = true, v
			end end
		end
		i = i+1
	end
	for i = 1, #delalls do delalls[i] = nil end
	for v in next, delalls do
		setQueue(v, 1)
		v.show = false
	end
	ui.cancelEdit(true) ungo = ungo-1 ui.enableEdit(ungos[ungo+1], true)
	setCurr(self.owner.u)
end

function uinode.queue:onEnter()
	local u = self.owner.u
	local n = self.text == '' and 1 or tonumber(self.text) or ''
	if delalls[u] then n = 1 end
	if toint(n) ~= n or n > 100 then self:setText'' return end
	self:setText(n > 1 and n or '')
	if not u.align[13] then
		u.align[11], u.align[12], u.align[13] = 0, false, {}
		ui.setOffer(u, 'align', u.align)
	end
	setQueue(u, n)
end

local function hideAll()
	ui.front(nil, ui.top) ui.front(nil, ui.modal) ui.front(nil, ui.modaltop)
	local u = ui.front(ui.modal)
	while u do u.show = false u = ui.low(u) end
	local u = ui.front(ui.top)
	while u do u.show = false u = ui.low(u) end
	local u = ui.low(ui.top)
	while u do u.show = false u = ui.low(u) end
end

function ui.cancelEdit(keepqueue)
	print('!!! cancel edit', editwin)
	if not editwin then return end
	if editwin ~= ui then ui.show(editwin, false) end
	if curra then curra:unselect() end
	uilist:clear()
	olist:clear()
	hideAll()
	editwin, belonged, curr, currps, curra, currq = nil
	currfront, pickfront, pickgfront = nil
	if not keepqueue then for u, q in next, queues do
		if q ~= true then for i, v in ipairs(q) do ui.remove(nil, v) end end
		queues[u] = nil
	end end
end

local function showAll(u)
	ui.realShow(u, not delalls[u])
	if delalls[u] then return end
	local s = { u }
	for i, v in ipairs(s) do if v==u or ui.parents(v, u) then
		ui.show(v, not delalls[v])
		if not delalls[v] then
			local w = ui.back(v)
			while w do s[#s+1] = w w = ui.high(w) end
		end
	end end
end

local function enableCtrl(parent, ctrl)
	local belong = belongOffer(ctrl)
	if belong ~= ctrl then belongs[ctrl] = belong end
	local u = ui.front(ctrl)
	while u do enableCtrl(parent, u) u = ui.low(u) end
end
function ui.enableEdit(w, keepShow)
	print("!!!!!! enableEdit", w)
	ui.editmain.show = true
	local temp = editwin
	if editwin == w then return end

	if editwin then ui.cancelEdit()
	elseif not keepShow then hideAll()
	end
	ungo = ungo+1
	if ungos[ungo] ~= w then
		ungos[ungo] = w
		for i = ungo+1, #ungos do ungos[i] = nil end
	end
	if w ~= ui then
		if ui.parents(w, ui) == ui.modaltop then return end
	end
	editwin = w
	if w ~= ui then if keepShow then ui.realShow(w, true) else showAll(w) end end
	enableCtrl(w, w)
	local node = uinode^{ text='', show=true, expanded=false }
	uilist:addNode(node)
	node:set(w)
	node:expand(true)
	setCurr(w)
	if temp and w == ui  then --calculate pos
		local n ,front= 0 ,ui.front(ui)
		while front and front ~= temp do 
			front = ui.low(front)
			n = n + 1
		end
		uilist.panel:onWheel(-n)
		for i ,v in ipairs( uilist[1]) do 
			if v.u == temp then 
				v:onClick()
				return 
			end
		end
	end
end

function setCurr(ctrl)
	if ctrl == ui then return end
	if ctrl ~= belonged and belongs[belonged] ~= ctrl then belonged = ctrl end
	ui.focusTo(editmain)
	pickfront, pickgfront = nil
	if curr == ctrl then return end
	if editwin==ui and curr then hideAll() end
	if curra then curra:unselect() else editprop.aligns:set() end
	curr, currps, currfront = ctrl, {}
	local p = ui.parent(curr)
	while p ~= ui do currps[p], p = true, ui.parent(p) end
	if editwin==ui then showAll(curr) end
	local node = ui.back(uilist.panel)
	while node do
		node:expand(true)
		node = ui.back(node.panel)
		while node and not currps[node.u] do node = ui.high(node) end
	end
	olist:init()
	return true
end

function editmain.undo:onClick()
	local menu = editmain.menu
	menu:clear()
	for i = undo, 1, -1 do
		local n = menu.node^{}
		menu:addNode(n)
		n.go, n.i, n.text = false, i, undos[i].text
	end
	ui.show(menu, true)
end
function editmain.redo:onClick()
	local menu = editmain.menu
	menu:clear()
	for i = undo+1, #undos do
		local n = menu.node^{}
		menu:addNode(n)
		n.go, n.i, n.text = false, i, undos[i].text
	end
	ui.show(menu, true)
end
function editmain.ungo:onClick()
	local menu = editmain.menu
	menu:clear()
	for i = ungo-1, 1, -1 do
		local n = menu.node^{}
		menu:addNode(n)
		n.go, n.i, n.text = true, i, ui.name(ungos[i])
	end
	ui.show(menu, true)
end
function editmain.rego:onClick()
	local menu = editmain.menu
	menu:clear()
	for i = ungo+1, #ungos do
		local n = menu.node^{}
		menu:addNode(n)
		n.go, n.i, n.text = true, i, ui.name(ungos[i])
	end
	ui.show(menu, true)
end
function editmain.menu.node:onClick()
	if self.go then
		ungo = self.i-1 ui.enableEdit(ungos[ungo+1])
	elseif self.i <= undo then
		for i = undo, self.i, -1 do undos[i].un() end
	else
		for i = undo+1, self.i do undos[i].re() end
	end
end
local function addDo(un, re, text)
	undo = undo+1
	undos[undo] = { un=un, re=re, text=text }
	re()
end

local drawImage = ui.img''.drawImage
local function setDrawImage(s, draw)
	for k, v in next, s do if k ~= 'owner' and k ~= 'new' then
		if _Image==getmetatable(v) then v.drawImage = draw
		elseif type(v)=='table' then setDrawImage(v, draw)
		end
	end end
end
local hookRender
local function renderImg(self, full)
	local fu, fa = pickfront or curr, pickfront and pickgfront or not pickfront and curra
	if _Image==getmetatable(fa) then fa.drawImage = NOOP
	elseif ui.is(olist.attrimg, fa) then fa.img.drawImage = NOOP
	elseif ui.is(olist.attrimgt, fa) then fa.img.drawImage = NOOP
	elseif ui.is(olist.attrtable, fa) then setDrawImage(fa.o, NOOP)
	elseif fu==self.owner.backgs then setDrawImage(fu, NOOP)
	end
	local f = hookRender hookRender = nil
	if ui.full(f) then f(self) else ui.super() f(self) ui.child() end
	if _Image==getmetatable(fa) then fa.drawImage = drawImage
	elseif ui.is(olist.attrimg, fa) then fa.img.drawImage = drawImage
	elseif ui.is(olist.attrimgt, fa) then fa.img.drawImage = drawImage
	elseif ui.is(olist.attrtable, fa) then setDrawImage(fa.o, drawImage)
	elseif fu==self.owner.backgs then setDrawImage(fu, drawImage)
	end
	self.onRender = f
end

local onIdle = ui.appIdle
function ui.appIdle()
	_rd.bgColor = editprop.white.checked and 0xffffffff or 0
	onIdle()
end
local matrix, scale, scalex, scaley = _Matrix2D.new(), 1, 0, 0
local function scalexy(x, y)
	return math.max(0, math.min(x, ui.w*(scale-1))), math.max(0, math.min(y, ui.h*(scale-1)))
end
local function scaled(x, y, a)
	a = (not a or a==0) and toint(scale/2) or a<0 and 0 or a>0 and scale-1
	return x*scale-scalex+a, y*scale-scaley+a
end
local function unscaled(x, y)
	return toint((x+scalex)/scale, .5), toint((y+scaley)/scale, .5)
end
function ui.modaltop:onUpdate()
	if scale > 1 then
		_rd.texSampler = _RenderDevice.NearestTexSampler
		scalex, scaley = scalexy(scalex, scaley)
		matrix:setScaling(scale, scale)
		matrix:mulTranslationRight(scale/2-scalex, scale/2-scaley)
		_rd:pushMul2DMatrixRight(matrix)
	else
		_rd.texSampler = _RenderDevice.LinearTexSampler
	end
	if currfront or pickfront then
		local fu, fa = pickfront or curr, pickfront and pickgfront or not pickfront and curra
		local u = fu while u ~= ui do
			frontls[u] = ui.low(u) or true ui.front(nil, u)
			u = ui.parent(u)
		end
		if _Image==getmetatable(fa) or ui.is(olist.attrimg, fa) or ui.is(olist.attrimgt, fa)
			or ui.is(olist.attrtable, fa) or fu==fu.owner.backgs then
			hookRender = fu.onRender
			fu.onRender = ui.hookTo(renderImg, hookRender)
		end
		ui.front(ui, ui.modaltop)
	end
end
function ui.modaltop:onRender(full)
	ui.super()
	if currfront or pickfront then
		local fu, fa = pickfront or curr, pickfront and pickgfront or not pickfront and curra
		if _Image==getmetatable(fa) or ui.is(olist.attrimg, fa) or ui.is(olist.attrimgt, fa)
			or ui.is(olist.attrtable, fa) or fu==fu.owner.backgs then
			matrix:setTranslation(ui.pos(fu)) _rd:pushMul2DMatrixLeft(matrix)
			ui.drawImg(fu==fu.owner.backgs and fu.owner or fu,
				_Image==getmetatable(fa) and fa
				or ui.is(olist.attrimg, fa) and fa.img
				or ui.is(olist.attrimgt, fa) and fa.img
				or ui.is(olist.attrtable, fa) and fa.o or fu)
			_rd:pop2DMatrix()
		end
	end
	if scale > 1 then
		_rd:pop2DMatrix() _rd:pop2DMatrix() -- ui.modaltop
		matrix:setTranslation(self.x, self.y) _rd:pushMul2DMatrixLeft(matrix)
	end
	for u, l in next, frontls do
		if l==true then ui.back(nil, u) else ui.high(l, u) end
		frontls[u] = nil
	end
	ui.child()
	if noticing and os.now() < noticet then
		_rd:fillRect(50, ui.h*.7, ui.w-100, 30, 0x66aaffff)
		ui.fonts.s11be.textColor = 0xffffff00
		ui.fonts.s11be:drawText(50, ui.h*.7, ui.w-100, 30, noticing, 'cm')
	else
		noticing, noticet = nil
	end
end

function editprop.front:onUpdate()
	self.checked = currfront
end
function editprop.front:onChange()
	currfront = curr and self.checked
end

local function renderPos(u, img)
	local ux, uy, x, y, w, h = ui.pos(u)
	if img then x, y, w, h = ui.position(img, u) x, y = x+ux, y+uy
	else x, y, w, h = ux, uy, u.w, u.h
	end
	return floor(x), floor(y), math.max(floor(w or 0), 0), math.max(floor(h or 0), 0)
end
local function scalePos(a, x, y, w, h)
	x, y = scaled(x, y, a)
	return x, y, w*scale, h*scale
end

local matrix = _Matrix2D.new(0, 0)
local angle2Radius = math.pi/180
function editzone:onRender()
	local show = not hotkeyHide()
	if editwin ~= ui and curr then
		local c, cx, cy, cw, ch = curr, renderPos(curr, curra and curra.img)
		if show then -- and ui.hover(self)
			local w, u, L, C, R, T, M, B = editwin
			local s = ui.pick('testall', editwin, 0/0, 0/0, true)
			for i = 1, #s, 2 do if queues[s[i]] ~= true then
				local u, img = s[i], s[i+1]
				if u ~= c or img then
					local ok, ux, uy, uw, uh = false, renderPos(u, img)
					if ux == cx then L = true ok = true end
					if ux + floor(uw/2) == cx + floor(cw/2) then C = true ok = true end
					if ux + uw == cx + cw then R = true ok = true end
					if uy == cy then T = true ok = true end
					if uy + floor(uh/2) == cy + floor(ch/2) then M = true ok = true end
					if uy + uh == cy + ch then B = true ok = true end
					if ok then
						ux, uy, uw, uh = scalePos(-1, ux, uy, uw, uh)
						matrix:setTranslation(ux,uy) 
						if u.align and u.align[14] then matrix:mulRotationLeft(u.align[14]*angle2Radius)  end
						_rd:pushMul2DMatrixLeft(matrix)
						_rd:drawRect(0, 0, uw, uh, 0x77ffff00)
						_rd:pop2DMatrix()
					end
				end
			end end
			if L then _rd:drawLine(scaled(cx, 0, -1), 0, 1, ui.h, 0x77ffff00) end
			if C then _rd:drawLine(scaled(cx+floor(cw/2), 0), 0, 1, ui.h, 0x77ffff00) end
			if R then _rd:drawLine(scaled(cx+cw-1, 0, 1), 0, 1, ui.h, 0x77ffff00) end
			if T then _rd:drawLine(0, select(2, scaled(0, cy, -1)), ui.w, 1, 0x77ffff00) end
			if M then _rd:drawLine(0, select(2, scaled(0, cy+floor(ch/2))), ui.w, 1, 0x77ffff00) end
			if B then _rd:drawLine(0, select(2, scaled(0, cy+ch-1, 1)), ui.w, 1, 0x77ffff00) end
		end
		if show then
			if belonged then
				local x, y, w, h = scalePos(-1, renderPos(belonged))
				local flag = belonged.align and belonged.align[14]
				matrix:setTranslation(x-1,y-1)
				if flag then  matrix:mulRotationLeft(belonged.align[14]*angle2Radius)  end
				_rd:pushMul2DMatrixLeft(matrix)
				_rd:drawRect(0, 0, w+2, h+2, 0x77ffff00)
				_rd:pop2DMatrix()
				matrix:setTranslation(x-2,y-2)
				if flag then 
					 matrix:mulRotationLeft(belonged.align[14]*angle2Radius) 
				 end
				 _rd:pushMul2DMatrixLeft(matrix) 
				_rd:drawRect(0, 0, w+4, h+4, 0x77ffff00)
				_rd:pop2DMatrix()
			end
			local p = ui.parent(c)
			if p then
				local x, y, w, h = scalePos(-1, renderPos(p))
				_rd:drawRect(x-1, y-1, w+2, h+2, 0xcc8080ff)
			end
			cx, cy, cw, ch = scalePos(-1, cx, cy, cw, ch)
			local flag = belonged.align and belonged.align[14]
			matrix:setTranslation(cx-1,cy-1) 
			if flag then matrix:mulRotationLeft(belonged.align[14]*angle2Radius) end
			_rd:pushMul2DMatrixLeft(matrix)
			_rd:drawRect(0, 0, cw+2, ch+2, 0xaa44ff44)
			_rd:pop2DMatrix()
			matrix:setTranslation(cx-2,cy-2)
			if flag then 
				 matrix:mulRotationLeft(belonged.align[14]*angle2Radius) 
			end
			_rd:pushMul2DMatrixLeft(matrix)
			_rd:drawRect(0, 0, cw+4, ch+4, 0xaa44ff44)
			_rd:pop2DMatrix()
		end

	end
	if show then
		local u = curr or editwin or ui
		local x, y = unscaled(ui.mousex, ui.mousey)
		local mx, my = scaled(x, y)
		_rd:drawLine(mx, 0, 1, ui.h, 0x55ff8888)
		_rd:drawLine(0, my, ui.w, 1, 0x55ff8888)
		local ux, uy, uw, uh = renderPos(u, curra and curra.img)
		local sx, sy, sw, sh = scalePos(-1, ux, uy, uw, uh)
		sw, sh = math.max(0, math.min(sx+sw-8, ui.w)), math.max(0, math.min(sy+sh-16, ui.h)) -- r b
		sx, sy = math.max(0, math.min(sx+8, ui.w)), math.max(0, math.min(sy+16, ui.h))
		x, y = x-ux, y-uy
		self.mousefont:drawText(sx, 0, mx-sx, 0, x, 'ct')
		self.mousefont:drawText(mx, 0, sw-mx, 0, u.w-x-1, 'ct')
		self.mousefont:drawText(0, sy, 0, my-sy, y, 'lm')
		self.mousefont:drawText(0, my, 0, sh-my, u.h-y-1, 'lm')
	end
end

function editzone:onPick()
	if hotkeyTest() then ui.child(false) end
end

function editzone:pick(mode, x, y)
	if not editwin or editwin == ui then return mode=='all' and {} end
	if currfront then
		local u = curr while u ~= editwin do
			frontls[u] = ui.low(u) or true ui.front(nil, u)
			u = ui.parent(u)
		end
	end
	ui.front(ui, ui.modaltop)
	local frontbg = currfront and curr==curr.owner.backgs
	local ux, uy, pick, picki = ui.pos(editwin)
	x, y = unscaled(x or ui.mousex, y or ui.mousey)
	x, y = x-floor(ux), y-floor(uy)
	local s = ui.pick('testall', editwin, x, y, mode ~= 'all', frontbg)
	for i = #s-1, 1, -2 do
		if queues[s[i]]==true then table.replace(s, i, 2) end
	end
	if mode == 'all' then
		pick = s
	else
		if currfront then for i = 1, #s, 2 do
			if s[i]==curr and s[i+1]==(curra and curra.img or false) then
				pick, picki = s[i], s[i+1] break
			end
		end end
		if not pick then pick, picki = s[1], s[2] end
	end
	for u, l in next, frontls do
		if l==true then ui.back(nil, u) else ui.high(l, u) end
		frontls[u] = nil
	end
	return pick, picki
end

local function selectAlign()
	for k, v in next, ui.front(olist.panel) do
		if ui.is(olist.attralign, v) and v.uk=='align' then
			v:select()
		end
	end
end
function editzone:onPush()
	local u, img = self:pick()
	if u == curr and not img and (not curra or not curra.img) then
		selectAlign()
	end
end
function editzone:onClick()
	local u, img = self:pick()
	if u then setCurr(u) end
	if img then
		img = olist:search(img)
		if img then img:select() end
	elseif curra and curra.img then
		selectAlign()
	end
end

function editzone:onRightClick()
	local us = self:pick'all'
	self.menu:clear()
	for i = 1, #us, 2 do
		local n = self.menu.node^{ text=us[i+1] and ui.name(us[i])..'\\img' or ui.name(us[i]) }
		self.menu:addNode(n)
		n.u, n.img = us[i], us[i+1]
	end
	self.menu.show = true
end
function editzone.menu.node:onHover()
	pickfront, pickgfront = self.u, self.img
end
function editzone.menu.node:onUnhover()
	pickfront, pickgfront = nil
end
function editzone.menu.node:onRender()
	if ui.hover(self) then
		local x, y, w, h = scalePos(-1, renderPos(self.u, self.img))
		local xx, yy = ui.pos(self)
		x, y = x-xx, y-yy
		_rd:drawRect(x, y, w, h, 0xbbff0000)
		_rd:drawRect(x-1, y-1, w+2, h+2, 0xbbff0000)
	end
end
function editzone.menu.node:onClick()
	setCurr(self.u)
	if self.img then
		local attr = olist:search(self.img)
		if attr then attr:select() end
	elseif curra and curra.img then
		selectAlign()
	end
end


local point = {}
point[1] = {x = 0, y = 0 } --parallelogram
point[2] = {x = 0, y = 0}
point[3] = {x = 0, y = 0}
point[4] = {x = 0, y = 0}
point[5] = {x =0, y = 0}
local cos = math.cos
local sin = math.sin
local function inside(x, y)
	for i =1 , 5 do 
		point[i].x = point[i].x - x
		point[i].y = point[i].y - y 
	end
	local t1 = point[1].x >=0 and (point[1].y >=0 and 0 or 3) or (point[1].y >= 0 and 1 or 2)
	local sum = 0
	local ti = 1
	for i = 2, 5  do 
		ti = i
		local f = point[i].y*point[i-1].x - point[i].x*point[i-1].y
		if f == 0 and point[i-1].x *point[i].x <=0  and point[i-1].y *point[i].y <=0 then break end
		local t2 = point[i].x >=0 and (point[i].y >=0 and 0 or 3) or (point[i].y >= 0 and 1 or 2)
		if t2 == (t1+1)%4 then sum = sum + 1
		elseif t2 == (t1+3)%4 then sum = sum -1
		elseif t2 == (t1 + 2) %4 then
			sum = f > 0 and sum + 2 or sum -2
		end
		t1 = t2
	end
	return not(ti <= 5 and sum == 0)
end
local function rP(x,y, r) --Rotation Point
	r = r*angle2Radius
	return x*cos(r)-y*sin(r), y*cos(r) + x*sin(r)
end


function editzone:onDraging(x, y)
	if ui.mouseb==0 then
		if self.drag==nil and editwin ~= ui and curr then
			x, y = unscaled(ui.mousex-x, ui.mousey-y)
			local cx, cy, cw, ch = renderPos(curr, curra and curra.img)
			-- 判断可点区域	
			if curr.align and curr.align[14] then
				point[1].x, point[1].y = 0, 0
				point[2].x, point[2].y = rP(0, curr.h or 0, curr.align[14])
				point[3].x, point[3].y = rP(curr.w or 0, curr.h or 0, curr.align[14])
				point[4].x, point[4].y = rP(curr.w or 0, 0, curr.align[14])
				point[5].x, point[5].y = 0, 0
				if inside(x-cx, y-cy) then self.drag = editprop.aligns.attr end
			elseif cx <= x and x < cx+cw and cy <= y and y < cy+ch then
				self.drag = editprop.aligns.attr
			end
		end
		if self.drag and self.drag == editprop.aligns.attr then
			local cx, cy = renderPos(curr, curra and curra.img)
			if not self.dragx then
				self.dragx, self.dragy = x-cx, y-cy
			end
			x, y = unscaled(ui.mousex, ui.mousey)
			editprop.aligns:diff('move', x-cx-self.dragx, y-cy-self.dragy)
		else
			self.drag = nil
		end
	elseif scale > 1 then
		if not self.drag then x, y, self.drag = ui.mousex-x, ui.mousey-y, true end
		if not self.dragx then self.dragx, self.dragy = x+scalex, y+scaley end
		scalex, scaley = scalexy(self.dragx-ui.mousex, self.dragy-ui.mousey)
	end
end
function editzone:onDrag()
	self.drag, self.dragx, self.dragy = nil
end
function editzone:onWheel(w)
	if hotkeyHori() then scalex = scalexy(scalex-w*50, 0)
	else scaley = select(2, scalexy(0, scaley-w*50))
	end
end

function editzone:onHotkey(k)
	if k==27 then ui.focusTo(self) return end
	if hotkeyIn() or hotkeyOut() or hotkeyTest() then -- ctrl +/-
		local x, y = unscaled(ui.mousex, ui.mousey)
		scale = hotkeyTest() and 1 or hotkeyIn() and (scale==1 and 3 or 7) or (scale==7 and 3 or 1)
		x, y = scaled(x, y)
		scalex, scaley = scalexy(scalex+x-ui.mousex, scaley+y-ui.mousey)
		return not hotkeyTest()
	elseif editwin==ui or hotkeyTest() then
			if k == _System.KeyUp or k == _System.KeyDown then
			local t ,m = 1 ,#uilist[1]
			for i ,v in ipairs( uilist[1]) do 
				if v.u == curr then 
					t = i
					v:onClick()
					break
				end
			end
			if k == _System.KeyUp then 
				if t > 1 then 
					uilist[1][t-1]:onClick()
					uilist.panel:onWheel(1)
				end
			elseif k == _System.KeyDown then 
				if t < m  then 
					uilist[1][t+1]:onClick()
					uilist.panel:onWheel(-1)
				end
			end
		end
		return false
	end
	if curr then
		local mode = hotkeySize() and 'size' or 'move'
		local by = hotkeyBig() and 10 or 1 -- z
		if k == _System.KeyLeft then
			editprop.aligns:diff(mode, -by, 0)
		elseif k == _System.KeyDown then
			editprop.aligns:diff(mode, 0, by)
		elseif k == _System.KeyUp then
			editprop.aligns:diff(mode, 0, -by)
		elseif k == _System.KeyRight then
			editprop.aligns:diff(mode, by, 0)
		end
	end
	return true
end

local function genargs(...)
	local s = { ... }
	local n = 10
	for i = n, 1, -1 do
		if s[i] == nil then n = n - 1
		else break
		end
	end
	local p = ''
	for i = 1, n do
		if type(s[i]) == "string" then
			p = p .. "'" .. tostring(s[i]) .. "'"
		else
			p = p .. tostring(s[i])
		end
		if i < n then p = p .. ", " end
	end
	return p
end

local function genargs2(...)
	local s = genargs(...)
	if s == "" then
		return s
	else
		return ", " .. s
	end
end

function fun.number(k, v)
	if type(k) == "number" then k = "[".. k .. "]" end
	return k .. " = " .. v
end

function fun.boolean(k, v)
	if type(k) == "number" then k = "[".. k .. "]" end
	return k .. " = " .. tostring(v)
end

local function forkKey(k)
	return k:find'[\128-\255]' and ('[%s%q%s]'):format(os.info.uilangpre, k, os.info.uilangpost)
		or k
end
local function forkValue(v)
	return v:find'[\128-\255]' and ('%s%q%s'):format(os.info.uilangpre, v, os.info.uilangpost)
		or ('%q'):format(v)
end

function fun.string(k, v)
	if type(k) == "number" then k = "[".. k .. "]" end
	return ('%s = %s'):format(forkKey(k), forkValue(v)):gsub('\n', 'n')
end

function fun.image(k, v)
	if k == "addimg" then
		print("!! align", v.align, tostring(v.align))
	end
	local p
	if v.font == nil then
		local m
		if v.f=='g' and v.gl==-1 and v.gt==0 and v.gr==-1 and v.gb==0 then m = genargs2('hg', v.skip)
		elseif v.f=='g' and v.gl==0 and v.gt==-1 and v.gr==0 and v.gb==-1 then m = genargs2('vg', v.skip)
		elseif v.f=='g' and v.gl==-1 and v.gt==-1 and v.gr==-1 and v.gb==-1 then m = genargs2('g', v.skip)
		elseif v.f=='g' then m = genargs2('g', v.gl, v.gt, v.gr, v.gb, v.skip)
		else m = genargs2(v.f, v.qx, v.qy)
		end
		if v.rect._save then
			p = ("ui.img(%q, %d, %d, %d, %d, %s%s)"):format(
			_String.replace(v.res, '/', '\\'), v.rect.l, v.rect.t, v.rect.w, v.rect.h,
			fun.align(v, v.align), m)
		else
			p = ("ui.img(%q, %s%s)"):format(_String.replace(v.res, '/', '\\'),
				fun.align(v, v.align), m)
		end
	else
		p = ('ui.img(%s, 0x%x, %s, %s)'):format(v.font.font.key, v.font.textColor,
			tostring(v.align), forkValue(v.text)):gsub('\n', 'n')
	end
	if type(k) == "number" then
		return ("[%d] = %s"):format(k, p)
	elseif type(k) == "string" then
		return ("%s = %s"):format(forkKey(k), p)
	else
		return tostring(p)
	end
end

function fun.font(k, v)
	if type(k) == "number" then k = "[".. k .. "]" end
	assert(v.resname, 'no font resname')
	if v.font == v then
		return ("%s = ui.font(%s, %d, %q, 0x%x)"):format(k, forkValue(v.resname), v.size, v.style, v.textColor)
	elseif v.align then
		return ("%s = ui.font(%s, 0x%x, %q)"):format(k, v.font.key, v.textColor, v.align)
	else
		return ("%s = ui.font(%s, 0x%x)"):format(k, v.font.key, v.textColor)
	end
end

function fun.table(k, t, indent)
	if type(k) == "number" then k = "[".. k .. "]" end
	if not indent then indent = 0 end
	local s = forkKey(k)..' = {'
	local ks = tablekeys(t)
	table.sort(ks, function(a, b)
		local ta, tb = type(a), type(b)
		return ta < tb or ta==tb and a < b
	end)
	for i, k in ipairs(ks) do
		local v = t[k]
		s = ('%s\n%s%s,'):format(s, ('\t'):rep(indent+1),
			_Image==getmetatable(v) and fun.image(k, v) or
			_Font==getmetatable(v) and fun.font(k, v) or
			ui.is(ui.align, v) and fun.align(k, v) or
			fun[type(v)] and fun[type(v)](k, v, indent+1) or
			error(type(v)))
	end
	return ('%s\n%s}'):format(s, ('\t'):rep(indent))
end

function fun.align(k, v)
	if type(k) == "number" then
		return ("[%d] = %s"):format(k, tostring(v))
	elseif type(k) == "string" then
		return ("%s = %s"):format(forkKey(k), tostring(v))
	else
		if _Image==getmetatable(k) and v[13] then
			v = ui.align(unpack(v))
			v[11], v[12], v[13] = nil
		end
		return tostring(v)
	end
end

function genUI(w, n, indent, noseqp)
	if not indent then indent = 0 end
	if delalls[w] then return '' end
	local meta = getmeta(w)
	local s = {}
	if not noseqp then
		s[#s+1] = meta.seq < 9000000 and assert(ui.seqParent(meta.u)) or nil
	end
	s[#s+1] = meta.seq < 9000000 and meta.seq or nil
	s[#s+1] = meta.title and ('%q'):format(meta.title) or nil
	if meta.min == -1 then s[#s+1] = 'ui'
	else for i = meta.min,-2 do
		s[#s+1] = meta[i].name
	end end
	s[#s+1] = '{'
	s = table.concat(s, '^')
	local b1 = '\n'..('\t'):rep(indent+1)
	local t = meta.o
	tostring(t.align)
	if t.align and t.align[1] < 0 then t.w = nil end
	if t.align and t.align[3] < 0 then t.h = nil end
	local ks = sortKeys(tablekeys(t))
	for i, k in ipairs(ks) do
		local v = t[k]
		if ui.is(ui.align, v) then
			s = s .. b1 .. fun.align(k, v) .. ","
		elseif _Font==getmetatable(v) then
			s = s .. b1 .. fun.font(k, v) .. ","
		elseif ui.is(ui, v) then
			if not delalls[v] then
				s = (tonumber(k) and '%s%s[%d] = %s' or '%s%s%s = %s'):format(
					s, b1, tonumber(k) and k or forkKey(k), genUI(v, false, indent+1))
			end
		elseif _Image==getmetatable(v) then
			s = s .. b1 .. fun.image(k, v) .. ','
		elseif fun[type(v)] then
			s = s .. b1 .. fun[type(v)](k, v, indent+1) .. ","
		end
	end
	s = ('%s\n%s}'):format(s, ('\t'):rep(indent))
	if not n then
		s = s .. ","
	end
	if n then
		s = ('ui.load(%q, %d%s)\n%s = %s\n'):format(meta.load.name, meta.file,
			meta.newedit and ', true' or '', meta.name:gsub('^ui%.', 'ui.new.'), s)
	end
	return s
end

local function saveAll()
	if os.info.uilang(false) then
		notice(os.info.uilang'翻译版本不能保存')
		return
	end
	if next(ui.rects) then
		notice(os.info.uilang'合并图不能保存')
		return
	end
	ui.buildSeq()
	local s = { [0]='', '', '', '', '', '', '', '', '', '', edit='' }
	local ks = {}
	for k, v in next, ui do
		if k == 'top' or k == 'modal' or k == 'modaltop' then
		elseif k == 'forcename' or k=='onself' then
		elseif ui.is(ui, v) and v.owner==ui then ks[#ks+1] = k
		end
	end
	table.sort(ks, function (a, b) return getmeta(ui[a]).file < getmeta(ui[b]).file end)
	for i, k in ipairs(ks) do
		local v = ui[k]
		local m = getmeta(v)
		local m1 = getmeta(i > 1 and ui[ks[i-1]])
		if m1 and m.file <= m1.file then m.file = toint(m1.file/5, 1)*5 + 5 end
		i = k:lead'edit' and 'edit' or toint(m.file/1000)
		if not s[i] then i = 9 end
		local genUIs = genUI(v, true)
		local  meta = getmeta(v)
		local f = _File.new()
		if i == 0 or i == 1 or i == 'edit' then 
		else
			local meta = getmeta(v)
			--meta.load.name
			local name = ui.name(meta.u)
			f:create(os.info.uiconfpath..'conf_ui'..meta.file..string.sub(name , 4 ,string.len(name))..'.lua', 'utf8')
			f:write(genUIs)
			f:close()
		end
		s[i] = s[i]..genUIs

	end
	for i, s in next, s do
		local f = _File.new()
		if i == 0 or i==1 or  i == 'edit' then 
			f:create(os.info.uiconfpath..'conf_ui'..i..'.lua', 'utf8')
			f:write(s)
			f:close()
		end

	end

	print'!! save done'
	notice(os.info.uilang'保存完成')
end

function editmain.save:onClick()
	saveAll()
end

function ui.editalignc:onRender()
	_rd:fillRect(0, 0, self.w, self.h, 0xffa9a0a2)
	for k, v in next, self.ss do
		if v == self.owner.s then
			_rd:fillRect(0, 0, self.w, self.h, 0xff217b05)
			break
		end
	end
	if self==ui.hover() then
		_rd:fillRect(0, 0, self.w, self.h, 0xdd00ff00)
	end
	if self.owner.dragx then
		local mx, my = ui.mousex, ui.mousey
		local x, y = ui.pos(self)
		local rc = _Rect.intersect(_Rect.new(x, y, x+self.w, y+self.h),
			_Rect.new(self.owner.dragx, self.owner.dragy, mx, my))
		if rc.w > 0 or rc.h > 0 then
			_rd:fillRect(0, 0, self.w, self.h, 0xaaffff00)
		end
	end
	_rd:drawRect(0, 0, self.w, self.h, 0xff333333)
end

function ui.editalignc:onDraging()
	if self.owner.stretch and not self.owner.dragx then
		self.owner.dragx, self.owner.dragy = ui.mousex, ui.mousey
	end
end
function ui.editalignc:onDrag(c)
	if not self.owner.dragx then return end
	self.owner.dragx, self.owner.dragy = nil
	if ui.is(ui.editalignc, c) and c ~= self then
		local s = c.ss[c.row==self.row and 3 or c.col==self.col and 2 or 4]
		if s ~= self.owner.s then self.owner.s = s self.owner:onSelect(s) end
	end
end
function ui.editalignc:onClick()
	local s = self.ss[1]
	self.owner.s = s 
	self.owner:onSelect(s)
end

function ui.editaligns:set(attr, u)
	if not attr then self.show, self.attr, self.u = false return end
	self.show, self.attr, self.u = true, attr, u
	local a = (attr.img or u).align
	tostring(a)
	a = a and ui.align(unpack(a)) or ui.alignLT() 
	self.a = a
	self.Align.s = tostring(a):match'ui%.([a-zA-PR-Z]*)'
	self.Align.stretch = true
end
function ui.editaligns.dxy:onClick()
	self.owner.dx:setText(0) self.owner.dy:setText(0)
	self.owner.dx:onEnter()
end
function ui.editaligns.dwh:onClick()
	local owner = self.owner
	local a = owner.a
	tostring(a)
	if a.a:lead'size' then
		a[1], a[2], a[3], a[4], a.s, a.a = 1, 0, 1, 0
		if not owner.attr.img then ui.position(owner.u) end
		owner.attr:onChange(a)
		owner:set(owner.attr, owner.u)
	else
		if a.a:lead'stretch' and a.a:byte(9)==90 then
			if a[1]==0 then a[1] = 1 end
			if a[3]==0 then a[3] = 1 end
		end
		a[2], a[4], a.s, a.a = 0, 0
	end
	if not owner.attr.img then ui.position(owner.u) end
	owner.attr:onChange(a)
	owner:set(owner.attr, owner.u)
end
function ui.editaligns.qxy:onClick()
	self.owner.qx:setText'' self.owner.qy:setText''
	self.owner.qx:onEnter()
end
function ui.editaligns:onUpdate()
	local u, img = self.u, self.attr and self.attr.img
	if not u then return end
	self.text.text = tostring(self.a)
	local x, y, w, h
	if img then
		x, y, w, h = ui.position(img, u, self.a)
	else
		x, y, w, h = u.x, u.y, u.w, u.h
	end
	self.X:set(x) self.Y:set(y) self.W:set(w) self.H:set(h)
	self.dx:set(self.a[7]) self.dy:set(self.a[10])
	self.dw:set(self.a[2]) self.dh:set(self.a[4])
	self.dw.show = not not img or self.a[1]<=0
	self.dh.show = not not img or self.a[3]<=0
	self.qx:set(self.a[11] or '') self.qy:set(self.a[12] or '')
	self.R:set(self.a[14] or '')
	local x, y = ui.pos(u)
	local ex, ey = ui.pos(u, editwin)
	if img then
		local ix, iy = ui.position(img, u)
		x, y, ex, ey = x+ix, y+iy, ex+ix, ey+iy
	end
	self.pos.text = ('%.5g %.5g  %.5g %.5g'):format(x, y, ex, ey)
end
function ui.editalignv:set(v)
	if self.v ~= v then self.v = v self:setText(v) end
end
function ui.editalignv:onEnter()
	self.v = self.text
	local owner = self.owner
	local u, img = owner.u, owner.attr and owner.attr.img
	if not u then return end
	local ug, uga = img or u, (img or u).align
	ug.align = owner.a
	if not img then ui.position(u, nil) end
	if self==owner.X or self==owner.Y then
		ui.moveTo(ug, tonumber(owner.X.text) or 0, tonumber(owner.Y.text) or 0, u)
	elseif self==owner.W or self==owner.H then
		ui.sizeTo(ug, tonumber(owner.W.text) or 0, tonumber(owner.H.text) or 0, u)
	elseif self==owner.qx or self==owner.qy then
		local qx, qy = tonumber(owner.qx.text) or false, tonumber(owner.qy.text) or false
		owner.a[11], owner.a[12], owner.a[13] = qx, qy, (qx or qy) and (owner.a[13] or {})
		owner.a.s, owner.a.a = nil
	elseif self==owner.R then 
		owner.a[14] = tonumber(owner.R.text)
	else
		owner.a[7], owner.a[10] = tonumber(owner.dx.text) or 0, tonumber(owner.dy.text) or 0
		owner.a[2], owner.a[4] = tonumber(owner.dw.text) or 0, tonumber(owner.dh.text) or 0
		owner.a.s, owner.a.a = nil
		if not img then ui.position(u) end
	end
	ug.align = uga
	owner.attr:onChange(owner.a)
	owner:set(owner.attr, u)
end
function ui.editaligns.Align:onSelect(s)
	local owner = self.owner
	local u, img = owner.u, owner.attr and owner.attr.img
	if not u then return end
	local ug, x, y, w, h = img or u
	if not img then
		local m = getmeta(u)
		for i = #m, 1, -1 do w = m[i].o.w if type(w)=='number' then u.w = w break end end
		for i = #m, 1, -1 do h = m[i].o.h if type(h)=='number' then u.h = h break end end
	end
	if s:lead'align' and tostring(owner.a):lead'ui.size' then s = 'size'..s:sub(6) end
	ug.align, x, y, w, h = ui[s](), ui.position(ug, img and u)
	ui.position(ug, img and u)
	if not img or s:lead'size' then ui.sizeTo(ug, w, h, u) end
	ui.moveTo(ug, x, y, u)
	owner.attr:onChange(ug.align)
	owner:set(owner.attr, u)
end
function ui.editaligns:diff(mode, dx, dy)
	local u, img = self.u, self.attr and self.attr.img
	if not u then return end
	local ug, uga = img or u, (img or u).align
	ug.align = self.a
	if not img then
		ui.position(u)
		if mode=='move' then
			if u.x%1>0 then dx = dx>=0 and dx-u.x%1 or dx+1-u.x%1 end
			if u.y%1>0 then dy = dy>=0 and dy-u.y%1 or dy+1-u.y%1 end
		end
	end
	(mode=='move' and ui.moveDiff or ui.sizeDiff)(ug, dx, dy)
	if not img then
		ui.position(u)
		if mode=='size' then
			if dx ~= 0 and u.x%1>0 and u.w%2>0 then ui.sizeDiff(ug, dx>0 and 1 or -1, 0) end
			if dy ~= 0 and u.y%1>0 and u.h%2>0 then ui.sizeDiff(ug, 0, dy>0 and 1 or -1) end
			ui.position(u)
		end
	end
	ug.align = uga
	self.attr:onChange(self.a)
	self:set(self.attr, u)
end
function editprop.pic:set(attr)
	self.show = not not attr
	self.attr = attr
	local i = attr and attr.img
	self.img = i
	self.res.scrollx, self.res.scrolly = 0, 0
	local g = i and i.f=='g'
	self.grid.checked, self.gridl.show, self.gridt.show, self.skip.show = g, g, g, g
	self.gridl:setText(i and i.gl or -1) self.gridt:setText(i and i.gt or -1)
	self.skip:setText(i and i.skip or '')
	self.qx.show, self.qy.show = not g, not g
	self.qy:setText(i and i.qx or '') self.qy:setText(i and i.qy or '')
	local h = i and (i.f=='hf' or i.f=='f' or g and i.gl ~= 0 and i.gr < 0)
	self.hori.checked, self.gridr.show = h, g and not h
	self.gridr:setText(i and not h and i.gr or math.max(i and i.gl or 0, 0))
	local v = i and (i.f=='vf' or i.f=='f' or g and i.gt ~= 0 and i.gb < 0)
	self.vert.checked, self.gridb.show = v, g and not v
	self.gridb:setText(i and not v and i.gb or math.max(i and i.gt or 0, 0))
	self.Rect.checked = i and i.rect._save
	self.rect:setText(not i and '' or
		('%d %d %d %d'):format(i.rect.l, i.rect.t, i.rect.w, i.rect.h))
end

local drawImage = _Image.new''.drawImage
function editprop.pic.res:onRender()
	if editprop.white.checked then
		_rd:fillRect(0, 0, self.w, self.h, 0xffffffff)
	end
	local i = self.owner.img
	if not i then return end
	_rd:useClip(_rd.x, _rd.y, _rd.x+self.w, _rd.y+self.h)
	local w, h = i.rect.w, i.rect.h
	local x, y = toint(self.w/2-w/2), toint(self.h/2-h/2)
	local scale, flip = ui.hover(self) and 5 or 1
	x, y, w, h = x-w*(scale-1)/2, y-h*(scale-1)/2, w*scale, h*scale
	if w+2 <= self.w then self.scrollx = 0
	else
		self.scrollx = x-math.min(math.max(self.w-2-w, x-self.scrollx), 1)
		x = x-self.scrollx
	end
	if h+2 <= self.h then self.scrolly = 0
	else
		self.scrolly = y-math.min(math.max(self.h-2-h, y-self.scrolly), 1)
		y = y-self.scrolly
	end
	_rd.texSampler = _RenderDevice.NearestTexSampler
	flip, i.flip = i.flip, 0
	drawImage(i, x, y, x+w, y+h)
	i.flip = flip
	_rd.texSampler = _RenderDevice.LinearTexSampler
	if not hotkeyHide() then
		_rd:drawRect(x-1, y-1, w+2, h+2, 0xff199341)
		if i.f=='g' then
			local Aw, Ah, L, T, R, B = w/scale, h/scale, i.gl, i.gt, i.gr, i.gb
			if L>Aw then L = Aw elseif L<0 then L = Aw+L if L<0 then L = 0 end end
			if T>Ah then T = Ah elseif T<0 then T = Ah+T if T<0 then T = 0 end end
			if R>Aw-L then R = Aw-L end
			if B>Ah-T then B = Ah-T end
			if L>0 then _rd:drawLine(x+L*scale-1, y, 1, h, 0x66199341) end
			if T>0 then _rd:drawLine(x, y+T*scale-1, w, 1, 0x66199341) end
			if R>0 then _rd:drawLine(x+w-R*scale, y, 1, h, 0x66199341) end
			if B>0 then _rd:drawLine(x, y+h-B*scale, w, 1, 0x66199341) end
		end
	end
	_rd:popClip()
end
function editprop.pic.res:onWheel(w)
	if hotkeyHori() then self.scrollx = self.scrollx-w*50
	else self.scrolly = self.scrolly-w*50
	end
end

local function changePic(res, noghv)
	local p = editprop.pic
	local i = p.img
	if not i then return end
	local g, h, v = p.grid.checked, p.hori.checked, p.vert.checked
	if noghv then g, h, v = false, false, false end
	local r, rl, rt, rw, rh = p.Rect.checked and i.rect
	if type(res)=='string' then r = r and _Image.new(res).rect
	else res = i.res
	end
	if r then
		rl, rt, rw, rh = p.rect.text:match'^[ ]*(%d+)[ ,]+(%d+)[ ,]+(%d+)[ ,]+(%d+)[ ]*$'
		rl, rt, rw, rh = toint(rl), toint(rt), toint(rw), toint(rh)
		if not rl or not rt or not rw or not rh then
			rl, rt, rw, rh = r.l, r.t, r.w, r.h
		end
	end
	i = ui.img(res, rl, rt, rw, rh, i.align,
		g and 'g' or (h and v and 'f' or h and 'hf' or v and 'vf') or nil,
		g and (toint(p.gridl.text) or 0) or toint(p.qx.text),
		g and (toint(p.gridt.text) or 0) or toint(p.qy.text),
		h and -1 or g and (toint(p.gridr.text) or 0) or nil,
		v and -1 or g and (toint(p.gridb.text) or 0) or nil,
		toint(g and p.skip.text))
	p.attr:onChange(i)
	p:set(p.attr)
end
editprop.pic.grid.onChange = changePic
editprop.pic.hori.onChange = changePic
editprop.pic.vert.onChange = changePic
editprop.pic.gridl.onEnter = changePic
editprop.pic.gridt.onEnter = changePic
editprop.pic.gridr.onEnter = changePic
editprop.pic.gridb.onEnter = changePic
editprop.pic.skip.onEnter = changePic
editprop.pic.qx.onEnter = changePic
editprop.pic.qy.onEnter = changePic
editprop.pic.Rect.onChange = changePic
editprop.pic.rect.onEnter = changePic
function olist.attrimg.value:onEnter()
	self.owner:select()
	changePic(self.text, true)
end

_app:onDrag(function(res)
	local dir = _sys.currentFolder..'\\'
	local file = res[1]:lead(dir) and res[1]:sub(#dir+1) or res[1]
	if file and editprop.pic.attr then
		changePic(file, true)
	elseif _sys:getExtention(file)=='pfx' and curr then
		curr.res = file
	elseif _sys:getExtention(file)=='swf' and curr then
		curr.res = file
	end
end)

function editprop.wh.menu:onNew()
	for i = 1, #os.info.uieditwh, 2 do
		local n = self.node^{}
		self:addNode(n)
		n.ww, n.hh = os.info.uieditwh[i], os.info.uieditwh[i+1]
		n.text = ('%g %g'):format(n.ww, n.hh)
	end
end
function editprop.wh:onUpdate()
	self.text = ('%g %g'):format(ui.w, ui.h)
end
function editprop.wh:onClick()
	self.menu.show = true
end
function editprop.wh.menu.node:onClick()
	_rd.w, _rd.h = self.ww + ui.marginr, self.hh + ui.marginb
end
---------------------_app---------------------------
function uieditKeyDown( keycode )
	if keycode == _System.KeyS and _sys:isKeyDown(_System.KeyCtrl) then
		saveAll()
	end
end



