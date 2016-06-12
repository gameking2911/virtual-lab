local os, rawget, rawset, next, ipairs, getmeta, setmeta, type, getargs, toint, string
	= os, rawget, rawset, next, ipairs, getmetatable, setmetatable, type, debug.getargs, toint, string
os.info = os.info or {}
os.info.defaultfont = os.info.defaultfont or '宋体'

local args, a, n = {}
local function f(p, i, k, un)
	k = toint(k) or k
	if i == '#' then
		k = k<=n and tostring(args[k]) or nil
	else
		k = a and a[k]~=nil and tostring(a[k]) or nil
	end
	if un == '@' then k = k and k:lead('[') and k:sub(6) or k end
	return k and p=='%' and ('%q'):format(k) or k
end

local function Text(str, ...)
	n, a = select('#',...), ...
	if n==0 then return str end
	for i = 1, n do args[i] = select(i, ...) end
	for i = n+1, #args do args[i] = nil end
	return (str:gsub('{(%%?)(#?)([^{%@.}]+)(%@?)}', f))
end

local function assert(ok, format, ...)
	if not ok then 
	error(format==nil and 'assertion failed!'
		or select('#', ...)>0 and Text(format, ...) or format, 2)
		end
	return ok
end
local _iowrite = _iowrite
local function print(...)
	for i = 1,select('#', ...) do
		local v = select(i, ...)
		if type(v)~='string' and type(v)~='number' then v = tostring(v) end
		if i==1 then _iowrite(v) else _iowrite('\t', v) end
	end
	_iowrite('\r\n')
end

local ui, uim = { w=_rd.w, h=_rd.h }
-- meta {
--   u=self name='' supname=''
--   min=-x ...-2=superm 0=uim 1...=supersuperm #=selfm [self]=true [supersuper]=true
--   o={offer} ou={offer,superui^{}} on={on} sub>=0
--   file=x newedit=true|nil key=key|nil seq=q seql=q
--   parent=parentm high=siblingm low=siblingm back=childm front=childm
--   show=true|false load=loader title=''|nil
-- }

local function Uimeta(u)
	local m = getmeta(u) if not (m and m[0]==uim) then error(tostring(u)..' not ui') end return m
end
local function uimeta(u)
	local m = getmeta(u) if not (m and u~=ui and m[0]==uim) then error(tostring(u)..' not ui') end return m
end
local function isUi(u)
	local m = getmeta(u) return m and m[0]==uim and m
end
local function isui(u)
	local m = getmeta(u) return m and u~=ui and m[0]==uim and m
end
local function isuiu(u)
	local m = getmeta(u) return m and u~=ui and m[0]==uim and u
end

local names = setmeta({ ui=ui }, { __mode='v' })
local function byName(n)
	return names[n]
end
ui.byName = byName
local function __tostring(self)
	return ('%s~%p'):format(getmeta(self).name, self)
end
function ui.name(u)
	return Uimeta(u).name
end
function ui.superName(u)
	local m = Uimeta(u) m = m[m.min]
	return m and m.name
end

function ui.supersName(u)
	local m, t = Uimeta(u), {}
	for i=#m, 1, -1 do t[#t+1] = m[i].name end
	return t
end

local function assertParent(p)
	if not p.back then assert(not p.front) return end
	assert(p.back.parent == p)
	assert(p.front.parent == p)
	assert(not p.back.low)
	assert(not p.front.high)
	local m = p.back
	while m.high do
		assert(m==m.high.low)
		m = m.high
		assert(m.parent==p)
	end
	assert(m==p.front)
end

--------------------------------------------------------------------

local newmeta, news, newqs, doNew = {}, {}
local unseq9, seqps = 9000000, setmeta({}, { __mode='kv' })
local Align, position, forcename = {}
local file, _Loader, loads, loader, newedit = 10, _Loader, {}
local loadfilenum = file

local function newName(m, om, key, u)
	local t = type(key)
	if t~='number' and t~='string' and t~='table' then error('invalid new ui key '..tostring(key)) end
	if t~='string' and not m[forcename] then
		local sup = m[m.min]
		if not sup then m.name = '^ui^'
		elseif sup.supname then m.name = sup.supname
		else sup.supname = '^'..sup.name..'^' m.name = sup.supname
		end
	else
		assert(t~='table', 'table as ui key can not forcename')
		m.name = om.name..'.'..tostring(key)
		names[m.name] = u
	end
	if t=='string' or t=='number' then m.key = key end
end
local function __seq(q, u)
	local m = getmeta(u)
	if q==0 then assert(m.min < -1, 'no super 0^') end
	if type(q)=='string' then
		if os.info.uiedit then assert(not m.title) m.title = q end
	elseif m.seq or q==0 then
		seqps[m], m.__pow = q
	else
		if not (q > 1 and q < 9000000) then error('invalid seq '..tostring(q)) end
		m.seq, m.seql = q, q
	end
	return u
end
local function __pow(super, sub)
	local m = getmeta(sub)
	if m then assert(m[ui])
	else
		assert(sub.owner==nil and sub.new==nil)
		m = { min=-1, [ui]=true, o=sub, ou=table.copy({}, sub, true), on={},
			sub=0, __pow=__seq }
		sub = setmeta({}, m) m[sub] = true
	end
	if super ~= ui then
		m.min = m.min-1 m[m.min] = Uimeta(super)
	end
	return sub
end
if os.info.uiedit then ui.maxnewkey = 0 end
local function tsort(a, b)
	local ta, tb = type(a), type(b)
	return ta==tb and a < b or ta < tb
end
local function newSuper(owner, key, u)
	assert(key ~= 'owner' and key ~= 'new', 'invalid key')
	local m, om = getmeta(u), Uimeta(owner)
	assert(owner[key]==nil, '{#1}.{#2} exist', om.name, key)
	assert(m[ui] and not m[0])
	if ui.maxnewkey and type(key)=='string' and key:lead'new' then
		ui.maxnewkey = math.max(ui.maxnewkey, toint(key:sub(4)) or 0)
	end
	for i = m.min, -2 do local p = m[i]
		p.sub = p.sub+1
		assert(p.parent or news[p], 'can NOT be sub of removed ui {#1}', p.u)
		if not m[p.u] then for i, pp in ipairs(p) do if not m[pp.u] then
			m[#m+1], m[pp.u] = pp, true
			table.copy(u, pp.ou, true)
			if loader.l==true and pp.load ~= loader then loader[pp.u] = true end
		end end end
	end
	m[0], m[#m+1], m.u = uim, m, u
	local o, ou, q, ks = m.o, m.ou, m.seq
	table.copy(u, o, true)
	newName(m, om, key, u)
	m.load = loader
	if loader.l==true then loader[u] = true end
	if owner==ui then
		om.o[key] = u
	if file then  m.file, m.newedit, file, newedit = loadfilenum and loadfilenum or file , newedit, file+1 loadfilenum = nil end
	end
	m.__tostring, m.__pow, m.__seq = __tostring, __pow
	news[m] = true
	if q then
		assert(not newqs[q], 'duplicate sequence {#1}', q)
	else
		q, unseq9 = unseq9, unseq9+1
		m.seq, m.seql = q, seqps[m]==0 and m[m.min].seql or q
	end
	newqs[q] = m
	u.owner, u.new = owner, setmeta({ [false]=u }, newmeta)
	rawset(owner, key, u)
	if LOG_UI then
		-- print('@ new ui', m.name, u)
	end
	for k, v in next, u do
		local m = getmeta(v)
		if m==Align then
			u[k] = setmeta({ unpack(v) }, m)
		elseif m and m[ui] and v ~= owner then
			if not ks then ks = {} end
			ks[#ks+1] = k
		end
	end
	if ks then
		tsort(ks)
		for i, k in ipairs(ks) do
			local v = u[k]
			if o[k]==nil then v = __seq(0, __pow(v, {})) ou[k] = v end
			u[k] = nil newSuper(u, k, v)
		end
	end
end
function newmeta:__newindex(key, u)
	if not newqs then newqs = { getmeta(self[false]) } end
	newSuper(self[false], key, u)
	if doNew then doNew(u, getmeta(u)) end
end

local function sortSeql(a, b)  return a.seql < b.seql end
local function unseqP(m, qp)
	if m[qp.u] then return qp ~= uim and m end
	m = unseqP(m, Uimeta(qp.u.owner))
	return isui(m and m.u[qp.key])
end
local function newP(q, m, newqs, qs)
	local p
	repeat
		local qp, o, sup = seqps[m], Uimeta(m.u.owner)
		if qp==0 then
			sup = m[m.min] qp = seqps[sup]
			if type(qp) ~= 'table' then
				m, q, p = sup, sup.seq
			else
				repeat p, o = o==uim and qp or unseqP(o, qp), getmeta(o.u.owner) until p
			end
		elseif qp then
			p = newqs and assert(newqs[qp] or qs[-qp], 'inexist {#1}^{#2}', qp, q) or qp
		else
			p = o
		end
	until p
	local pp, P = p, p
	while pp and pp ~= m do pp = pp.parent end
	if pp then
		repeat
			p = getmeta(p.u.owner) pp = p
			while pp and pp ~= m do pp = pp.parent end
		until not pp
		print('INFO cyclic seq parent', m.u, P.u, 'change to', p.u)
	end
	return q, m, p
end
local function newParent()
	local newps, qs = {}, { [-1]=newqs[1] }
	newqs[1] = nil
	local q, m, p = next(newqs)
	while q do
		q, m, p = newP(q, m, newqs, qs)
		seqps[m], m.parent, m.low, newps[p] = p, p, newps[p], m
		qs[-q], newqs[q] = m
		q, m = next(newqs)
	end
	newqs = nil
	for p, m in next, newps do
		if p.front then
			repeat
				local n, pm, ql, l = m.low, p.back, 0
				repeat
					if pm.seql > ql and pm.seql <= m.seql then 
						ql, l = pm.seql, pm 
					end
					pm = pm.high
				if pm and pm.seql > m.seql then break end
				until not pm
				if not l then p.back, p.back.low, m.high, m.low = m, m, p.back
				elseif l.high then l.high, l.high.low, m.high, m.low = m, m, l.high, l
				else p.front, l.high, m.low = m, m, l
				end
				m = n
			until not m
		else
			local i, n = 1
			repeat qs[i], m, i = m, m.low, i+1 until not m
			for i = i, #qs do qs[i] = nil end
			table.sort(qs, sortSeql)
			n = #qs
			for i = 2, n-1 do qs[i].low, qs[i].high = qs[i-1], qs[i+1] end
			qs[1].high, qs[n].low, qs[1].low = qs[2], qs[n-1]
			p.back, p.front = qs[1], qs[n]
		end
	end
	for q, m in next, qs do if q < -1 then
		local u = m.u
		m.show = false if u.show==nil then u.show = u.owner ~= ui end
		u.x, u.y, u.w, u.h = 0, 0, u.w or 0, u.h or 0
		position(u)
	end end
end

uim = {
	name='ui', u=ui, min=-1, [ui]=true, o={}, on={}, seq=1, seql=1,
	__tostring=__tostring, __pow=__pow,
}
uim[0] = uim setmeta(ui, uim)
ui.new = setmeta({ [false]=ui }, newmeta)
ui.mousex, ui.mousey, ui.mouseb, ui.elapse = 0, 0, false, 0

if os.info.uiReadonly then
	local s = {}
	uim.__index = s
	function uim.__newindex(ui, k, v)
		local ok, ks = pcall(tostring, k)
		if not ok then ks = type(k) end
		local ok, vs = pcall(tostring, v)
		if not ok then vs = type(v) end
--		print('~~~~set ui~~~~', ks, vs)
		assert(rawget(ui, k)==nil and s[k]==nil, 'duplicate ui.{#1}', k)
		s[k] = v
	end
end

_G.ui = ui

--------------------------------------------------------------------

local onself, onsuperi, onname, onmode, on1, on2, on3, onchild, onthis, pick
local onfull, onhook = setmeta({}, { __mode='k' }), setmeta({}, { __mode='kv' })
local hideupdates, hotkeys = setmeta({}, { __mode='k' }), setmeta({}, { __mode='k' })

local super, child
local function On(u, on, mode, a, b, c)
	local Onself, Onsuperi, Onname, Onmode, On1, On2, On3, Onchild, Pick
		= onself, onsuperi, onname, onmode, on1, on2, on3, onchild, pick
	onself, onsuperi, onname, onmode, on1, on2, on3, onchild, pick
		= u, 0, on, mode, a, b, c
	ui.onself, ui.onname = u, on
	local on = u[on]
	if onfull[on] then
		on(u, a, b, c)
	elseif mode==0 then
		if on then super() on(u, a, b, c) end
	elseif mode==1 then
		if on then super() on(u, a, b, c) end child()
	elseif mode==2 then
		if on then super() if child()==u then on(u, a, b, c) end
		else child() end
	elseif mode==3 then
		if on then super() if onthis==u then on(u, a, b, c) end end child()
	else -- 4
		if on then super() child() if onthis==u then on(u, a, b, c) end
		else child() end
	end
	onself, onsuperi, onname, onmode, on1, on2, on3, onchild, Onchild, pick =
	Onself, Onsuperi, Onname, Onmode, On1, On2, On3, Onchild, onchild, Pick
	ui.onself, ui.onname = nil
	return Onchild
end
function super()
	assert(onsuperi, 'already ui.super() in {#1}.{#2}', onself, onname)
	local first, m = onsuperi==0 and 0 or 1, getmeta(onself) local n = #m
	for i = n-onsuperi-first, 0, -1 do
		local on = m[i].on[onname]
		if on and first==0 then
			first = 1
		elseif on then
			onsuperi = n-i
			if onfull[on] then
				on(onself, on1, on2, on3)
			elseif onmode<=1 then
				super() on(onself, on1, on2, on3)
			elseif onmode==2 then
				super() if onchild==onself then on(onself, on1, on2, on3) end
			else -- 3 or 4
				super() if onthis==onself then on(onself, on1, on2, on3) end
			end
			onsuperi = nil return -- child in On
		end
	end
	if onmode==2 or onmode==4 then child() end
	onsuperi = nil
end
ui.super = super

local function argFull(...)
	for i = 1, select('#', ...) do if select(i, ...) == 'full' then return true end end
	return false
end
function ui.full(f)
	return onfull[f]
end

local function onNew(u, m)
	if newqs then newParent() end
	news[m] = nil
	for i = 1,#m-1 do
		local p = m[i] if news[p] then onNew(p.u, p) end
	end
	for k, v in next, u do
		if type(k)=='string' and type(v)=='function' then
			m.on[k] = v
			if argFull(getargs(v)) then onfull[v] = true end
		end
	end
	for i = 0,#m do table.copy(u, m[i].on, true) end
	if u.onHideUpdate then hideupdates[u] = true end
	if u.onHotkey then hotkeys[u] = true end
	On(u, 'onNew', 1)
end
function ui.onNew()
	assert(not doNew, 'already ui.onNew')
	newParent()
	doNew = onNew
	local m = next(news)
	while m do
		if not news[m.parent] then ui.load(m.u) onNew(m.u, m) m = nil end
		m = next(news, m)
	end
	ui.load''
end

--------------------------------------------------------------------

local thiss, thats
local pushx, pushy, pushd, dragx, dragy, drop = nil, nil, true
local hovers, focuss, hover, focus = {}, {}
local endDrag

local function Ons(u, on, a, b, c, thiz, thizz, thatz)
	local Onself, Onname, On1, On2, On3, Onthis, Thiss, Thats, Onchild
		= onself, onname, on1, on2, on3, onthis, thiss, thats, onchild
	onself, onname, on1, on2, on3, onthis, thiss, thats, onchild
		= u, on, a, b, c, thiz, thizz, thatz
	local c = child()
	onself, onname, on1, on2, on3, onthis, thiss, thats, onchild =
	Onself, Onname, On1, On2, On3, Onthis, Thiss, Thats, Onchild
	return c
end
local function onFromTo(from, to, tos, onFrom, onTo)
	local tm, fm, tt = getmeta(to), getmeta(from)
	local froms = fm and table.copy({}, tos) or {}
	for k in next, tos do tos[k] = nil end
	if tm then tt = tm repeat tos[tt] = true tt = tt.parent until not tt end
	if fm then Ons(ui, onFrom, nil, nil, nil, from, froms, tos) end
	if tm then Ons(ui, onTo, nil, nil, nil, to, tos, froms) end
end
local function hoverTo(h, keeppush)
	if hover ~= h then
		-- if h and not hover then _app.cursor = '' end
		if pushx and not keeppush then pushx, pushy = nil end
		if dragx then drop = nil endDrag() end
		h, hover = hover, h or nil
		onFromTo(h, hover, hovers, 'onUnhover', 'onHover')
		-- if h and not hover then _app.cursor = '' end
	end
end
local function focusTo(f)
	if focus ~= f then
		if pushx then pushx, pushy = nil end
		if dragx then drop = nil endDrag() end
		f, focus = focus, f or nil
		onFromTo(f, focus, focuss, 'onUnfocus', 'onFocus')
	end
end
local function pushTo(x, y, b)
	pushx, pushy, pushd = x, y, true
	local c = Ons(ui, b ~= 1 and 'onPush' or 'onRightPush', nil, nil, nil, focus, focuss)
	pushd = c==true and focus.onDraging and 6 or c
	return c
end

local function onShow(u, m)
	local show, o = u.show
	while m.show ~= show do
		m.show = show
		if not show then
			if hovers[m] then hoverTo() end
			if focuss[m] then focusTo() end
		end
		On(u, show and 'onShow' or 'onHide', 0)
		show = u.show
	end
end
function ui.show(u, show)
	local m = uimeta(u)
	if show==nil then return u.show end
	u.show = show
	onShow(u, m)
	return u.show
end
local function realShow(u, m, removed)
	if u==ui then return true end
	repeat
		if not removed then assert(m, '{#1} already removed', u)
		elseif not m then return false
		end
		if not m.u.show then return false end
		m = m.parent
	until m==uim
	return true
end
function ui.realShow(u, show, removed)
	local m = Uimeta(u)
	if show==nil then return realShow(u, m, removed) end
	if not show then
		u.show = false onShow(u, m)
		return
	end
	repeat
		u = m.u u.show = true
		onShow(u, m) m = m.parent
	until m==uim
end

--------------------------------------------------------------------

local _rd, matrix = _rd, _Matrix2D.new()
local push2DMatrix, pop2DMatrix = _rd.push2DMatrix, _rd.pop2DMatrix
local pushMul2DMatrixLeft, pushMul2DMatrixRight = _rd.pushMul2DMatrixLeft, _rd.pushMul2DMatrixRight
local useClip, popClip = _rd.useClip, _rd.popClip
local setTranslation, setScaling = matrix.setTranslation, matrix.setScaling
local rdx, rdy, transparent = 0, 0
local angle2Radius = math.pi/180
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

function child(result)
	if result ~= nil then onchild = result return result end
	if onchild ~= nil then return onchild end
	onchild = true
	local M, m, u = getmeta(onself)
	if onname=='onNew' then
		repeat local stop = true
			m = M.back while m do
				if news[m] then onNew(m.u, m) stop = false end
			m = m.parent==M and m.high end
		until stop
	elseif onname=='onShow' or onname=='onHide' then
		local m = M.back while m do
			On(m.u, onname, 0, onself.show and m.u.show)
		m = m.parent==M and m.high end
	elseif onname=='onUpdate' then
		m = M.back while m do
			u = m.u onShow(u, m)
			if u.show then
				position(u)
				if isui(u.backgs) then ui.back(u, u.backgs) end
				On(u, onname, 1)
			end
		m = m.parent==M and m.high end
	elseif onname=='onRender' then
		local m = M.back while m do
			u = m.u
			if u.show and m.show and (onself~=ui or not transparent or transparent[u]) then
				local x, y = u.x, u.y --rdx = rdx+x rdy = rdy+y
				-- Rotation r 
				 setTranslation(matrix, x, y) 
				 if u.align and u.align[14] then matrix:mulRotationLeft(u.align[14]*angle2Radius) end
				pushMul2DMatrixLeft(_rd, matrix)
				On(u, onname, 1) pop2DMatrix(_rd)
				--rdx = rdx-x rdy = rdy-y
			end
		m = m.parent==M and m.high end
	elseif onname=='onPick' then
		local p = onself==ui 
		if not p then 
			if onself.align and onself.align[14] then
				point[1].x, point[1].y = 0, 0
				point[2].x, point[2].y = rP(0, onself.h or 0, onself.align[14])
				point[3].x, point[3].y = rP(onself.w or 0, onself.h or 0, onself.align[14])
				point[4].x, point[4].y = rP(onself.w or 0, 0, onself.align[14])
				point[5].x, point[5].y = 0, 0
				p = inside(on1, on2)
			else
				p =  0 <= on1 and on1 < (onself.w or 0) and 0 <= on2 and on2 < (onself.h or 0)
			end
		end
		if pick ~= 'nochild' then local m = M.front while m do
			local u = m.u if u.show and (onself~=ui or not transparent or transparent[u])
				and (p or pick=='allchild') then
				local c = On(u, onname, 2, on1-(u.x or 0), on2-(u.y or 0))
				if c=='passp' then onchild = false return false end
				if c then onchild = c  return c end
			end
		m = m.parent==M and m.low end end
		onchild = p and onself
	elseif onname=='onHover' or onname=='onUnhover'
		or onname=='onFocus' or onname=='onUnfocus' then
		if onself ~= onthis then
			local mode = (onname=='onHover' or onname=='onFocus') and 3 or 4
			local m = M.back while m do
				if thiss[m] then On(m.u, onname, mode, thats[m] or false)  end
			m = m.parent==M and m.high end
		end
	elseif onname=='onPush' or onname=='onRightPush'
		or onname=='onClick' or onname=='onRightClick' or onname=='onWheel'
		or onname=='onDraging' or onname=='onDrag' or onname=='onDrop' then
		if onself ~= onthis then
			local m = M.back while m do
				if thiss[m] then
					if onname=='onClick' and ui.preClick and m.u[onname]
						then ui.preClick(m.u) end
					local c = On(m.u, onname, 3, on1, on2, on3)
					if c ~= nil then onchild = c end
				end
			m = m.parent==M and m.high end
		end
	else
		local m = M.back while m do
			On(m.u, onname, 0, on1, on2)
		m = m.parent==M and m.high end
	end
	return onchild
end
ui.child = child

function ui.hook(h)
	return onhook[h]
end
-- refer h and f weakly
function ui.hookTo(h, f, full)
	assert(type(h)=='function')
	if not f then onhook[h] = nil onfull[h] = nil return h end
	assert(type(f)=='function')
	full = not not full or argFull(debug.getargs(h)) or nil
	assert(full or not onfull[f], 'hooker must be full if hooked is full')
	onhook[h] = onhook[f] or f
	onfull[h] = full
	return h
end

--------------------------------------------------------------------

-- move c
function ui.parent(c, p)
	if c==ui then assert(not p, "can't change ui`parent") return nil end
	local cm, m = Uimeta(c), p and Uimeta(p) local cp = cm.parent
	if not p or m==cp then return cp and cp.u end
	local P = m while P ~= cm and P.parent do P = P.parent end
	assert(P==uim and cp, P==cm and 'cyclic ui' or 'removed ui')
	local ch, cl = cm.high, cm.low
	if ch then ch.low = cl else cp.front = cl end
	if cl then cl.high = ch else cp.back = ch end
	local mf = m.front
	cm.parent, cm.low, cm.high = m, mf
	m.front = cm if mf then mf.high = cm else m.back = cm end
	if focuss[cm] then for k in next, focuss do focuss[k] = nil end
		local p = getmeta(focus) repeat focuss[p] = true p = p.parent until not p end
	if hovers[cm] then for k in next, hovers do hovers[k] = nil end
		local p = getmeta(hover) repeat hovers[p] = true p = p.parent until not p end
	return p
end
-- move h
function ui.high(u, h)
	local m, hm = uimeta(u), h and uimeta(h) local mh = m.high
	if not h or hm==mh then return mh and mh.u end
	local hp, hh, hl = hm.parent, hm.high, hm.low
	local P = m while P ~= hm and P.parent do P = P.parent end
	assert(P==uim and hp, P==hm and 'cyclic ui' or 'removed ui')
	if hh then hh.low = hl else hp.front = hl end
	if hl then hl.high = hh else hp.back = hh end
	local mp = m.parent
	hm.parent, hm.low, hm.high = mp, m, mh
	m.high = hm if mh then mh.low = hm else mp.front = hm end
	if mp ~= hp and focuss[hm] then for k in next, focuss do focuss[k] = nil end
		local p = getmeta(focus) repeat focuss[p] = true p = p.parent until not p end
	if mp ~= hp and hovers[hm] then for k in next, hovers do hovers[k] = nil end
		local p = getmeta(hover) repeat hovers[p] = true p = p.parent until not p end
	return h
end
-- move l
function ui.low(u, l)
	local m, lm = uimeta(u), l and uimeta(l) local ml = m.low
	if not l or lm==ml then return ml and ml.u end
	local lp, lh, ll = lm.parent, lm.high, lm.low
	local P = m while P ~= lm and P.parent do P = P.parent end
	assert(P==uim and lp, P==lm and 'cyclic ui' or 'removed ui')
	if lh then lh.low = ll else lp.front = ll end
	if ll then ll.high = lh else lp.back = lh end
	local mp = m.parent
	lm.parent, lm.high, lm.low = mp, m, ml
	m.low = lm if ml then ml.high = lm else mp.back = lm end
	if mp ~= lp and focuss[lm] then for k in next, focuss do focuss[k] = nil end
		local p = getmeta(focus) repeat focuss[p] = true p = p.parent until not p end
	if mp ~= lp and hovers[lm] then for k in next, hovers do hovers[k] = nil end
		local p = getmeta(hover) repeat hovers[p] = true p = p.parent until not p end
	return l
end
-- move b
function ui.back(u, b)
	local bm = b and uimeta(b) if b and u==nil then u = bm.parent.u end
	local m = Uimeta(u) local mb = m.back
	if not b or bm==mb then return mb and mb.u end
	local bp, bh, bl = bm.parent, bm.high, bm.low
	local P = m while P ~= bm and P.parent do P = P.parent end
	assert(P==uim and bp, P==bm and 'cyclic ui' or 'removed ui')
	if bh then bh.low = bl else bp.front = bl end
	if bl then bl.high = bh else bp.back = bh end
	bm.parent, bm.high, bm.low = m, mb
	m.back = bm if mb then mb.low = bm else m.front = bm end
	if m ~= bp and focuss[bm] then for k in next, focuss do focuss[k] = nil end
		local p = getmeta(focus) repeat focuss[p] = true p = p.parent until not p end
	if m ~= bp and hovers[bm] then for k in next, hovers do hovers[k] = nil end
		local p = getmeta(hover) repeat hovers[p] = true p = p.parent until not p end
	return b
end
-- move f
function ui.front(u, f)
	local fm = f and uimeta(f) if f and u==nil then u = fm.parent.u end
	local m = Uimeta(u) local mf = m.front
	if not f or fm==mf then return mf and mf.u end
	local fp, fh, fl = fm.parent, fm.high, fm.low
	local P = m while P ~= fm and P.parent do P = P.parent end
	assert(P==uim and fp, P==fm and 'cyclic ui' or 'removed ui')
	if fh then fh.low = fl else fp.front = fl end
	if fl then fl.high = fh else fp.back = fh end
	fm.parent, fm.low, fm.high = m, mf
	m.front = fm if mf then mf.high = fm else m.back = fm end
	if m ~= fp and focuss[fm] then for k in next, focuss do focuss[k] = nil end
		local p = getmeta(focus) repeat focuss[p] = true p = p.parent until not p end
	if m ~= fp and hovers[fm] then for k in next, hovers do hovers[k] = nil end
		local p = getmeta(hover) repeat hovers[p] = true p = p.parent until not p end
	return f
end

function ui.parents(u, p)
	local c, pm = uimeta(u), Uimeta(p)
	local m = c.parent
	while m and m ~= pm do
		c, m = m, m.parent
	end
	return m and c.u
end

local function remove(k, u, s)
	local m = uimeta(u)
	if not m.parent then return end
	s[m] = true
	if hovers[m] then hoverTo() end
	if focuss[m] then focusTo() end
	local o = u.owner
	if k ~= nil then
		assert(o[k]==u) o[k] = nil
	else for k, v in next, o do
		if v==u then o[k] = nil end -- remove all keys
	end end
	for i = m.min, -2 do m[i].sub = m[i].sub-1 end
	if m.name then names[m.name] = nil end
	local lname = getmeta(u).load.name
	loads[lname][u] = nil
	local p, l, h = m.parent, m.low, m.high
	if p.front==m then p.front = l end
	if p.back==m then p.back = h end
	if l then l.high = h end
	if h then h.low = l end
	m.parent, m.low, m.high = nil
	for k, v in next, u do
		if v ~= u and isui(v) and v.owner==u then remove(k, v, s) end
	end
	if m.back then
		print('INFO remove', u, 'children from other uis')
		repeat
			remove(nil, m.back.u, s)
		until not m.back
	end
end
function ui.remove(k, u)
	local s, ss = {}
	remove(k, u, s)
	for m in next, s do if m.sub > 0 then
		ss = ss or {} ss[#ss+1] = tostring(m.u)
	end end
	if ss then
		error('must remove all subs of '..table.concat(ss, '|'))
	end
	if k then 
		uim.o[k] = nil
		news[k] = nil
	end
	getmeta(uim.u.forcename).load[u] = nil
	-- local lname = getmeta(u).load.name
	-- loads[lname] = nil
end

function ui.noremove(u)
	local m = Uimeta(u)
	return m and (m.parent or m==uim) and u
end

function ui.ownerTo(k, u, owner, key)
	assert(key and key ~= 'owner' and key ~= 'new', 'invalid key')
	local o = u.owner
	if not owner then owner = o end
	local meta, ometa = uimeta(u), Uimeta(owner)
	assert(owner[key]==nil, '{#1}.{#2} exist', ometa.name, key)
	if k ~= nil then
		assert(o[k]==u) o[k] = nil
	else for k, v in next, o do
		if v==u then o[k] = nil end -- remove all keys
	end end
	if meta.name then names[meta.name] = nil end
	newName(meta, ometa, key, u)
	u.owner = owner rawset(owner, key, u)
end

if os.info.uiedit then
function ui.setOffer(u, key, value, olds)
	assert(doNew, 'must after ui.onNew')
	assert(type(value) ~= 'function')
	local um, vm = uimeta(u), getmeta(value)
	local vu = vm and vm[ui]
	if vm ~= Align and value==um.o[key] then return end
	assert(not vu or not vm.u)
	if vu then
		for i = vm.min, -2 do for j = 1, #vm[i] do
			assert(vm[i][j] ~= um, 'circular offer')
		end end
	end
	if not um.sub then
		um.o[key], um.ou[key] = value, value return
	end
	local ms, n, m = (value==nil or vu) and {}, uim
	local dels, delss, done = {}
	while n do
		m = n
		if m[u] then
			local i = #m
			while m[i] ~= um and m[i].o[key]==nil do i = i-1 end
			if m[i]==um then
				if ms then ms[m] = 0
				else
					local w = m.u
					if olds then olds[w] = w[key] end
					if isUi(w[key]) then remove(key, w[key], dels) end
					w[key] = vm==Align and setmeta(table.sub(value), vm) or value
					if m.ou[key] then m.ou[key] = nil end
				end
			end
		end
		n = m.back
		while not n and m do n, m = m.high, m.parent end
	end
	um.o[key], um.ou[key] = value, value
	if ms then
		for m in next, ms do
			local n = 0
			for i = 1, #m-1 do if ms[m[i]] then n = n+1 end end
			ms[m] = n
		end
		repeat
			done = true
			for m, n in next, ms do if n==0 then
				local w = m.u
				if olds then olds[w] = olds[w[key]] end
				if vu then
					local i, v = #m, value
					if m ~= um then
						v = nil repeat i = i-1 v = m[i].ou[key] until v assert(i > 0)
						v = __pow(v, {}) m.ou[key] = v
					end
					if isUi(w[key]) then remove(key, w[key], dels) end
					w[key] = nil w.new[key] = v
				else -- value==nil
					local i, v = #m
					while m[i] ~= um do i = i-1 end
					while i > 1 and not v do i = i-1 v = m[i].ou[key] end
					if isUi(w[key]) then remove(key, w[key], dels) end
					local vm = getmeta(v)
					if vm and vm[0]==uim then
						v = __pow(v, {}) m.ou[key] = v
						w[key] = nil w.new[key] = v
					else
						w[key] = vm==Align and setmeta(table.sub(v), vm) or v
						m.ou[key] = nil
					end
				end
				done, ms[m] = false
				for mm, nn in next, ms do if mm[w] then ms[mm] = nn-1 end end
			end end
		until done
	end
	for m in next, dels do if m.sub > 0 then
		delss = delss or {} delss[#delss+1] = tostring(m.u)
	end end
	if delss then
		error('must remove all subs of '..table.concat(delss, '|'))
	end
end

local function buildPs(ps, m)
	ps[m] = assert(seqps[m])
	for k, v in next, m.o do
		m = isui(v)
		if m and not ps[m] then buildPs(ps, m) end
	end
end
local function buildQs(cs, qs, m)
	local s = cs[m]
	if s then for i, m in ipairs(s) do
		qs[#qs+1] = m
		buildQs(cs, qs, m)
	end end
end
local function sortUiseql(a, b)
	return (a.u==ui.top and 999000000 or a.u==ui.modal and 999000001 or a.u==ui.modaltop and 999000002 or a.seql)
		< (b.u==ui.top and 999000000 or b.u==ui.modal and 999000001 or b.u==ui.modaltop and 999000002 or b.seql)
end
function ui.buildSeq(new)
	local ps, cs, qs = {}, {}, {}
	for k, v in next, uim.o do buildPs(ps, getmeta(v)) end
	for c, p in next, ps do
		local s = cs[p]
		if not s then s = {} cs[p] = s end
		s[#s+1] = c
	end
	for p, c in next, cs do table.sort(c, p==uim and sortUiseql or sortSeql) end
	buildQs(cs, qs, uim) qs[#qs+1] = true
	local i, qi = 0, uim
	for j, q in ipairs(qs) do
		local iseq = qi ~= new and qi.seq<9000000 and qi.seq or 0
		local d = (q==true or q.u==ui.top) and (j-i)*50 or (q ~= new and q.seq<9000000 and q.seq or 0) - iseq
		local dd = (iseq==0 or iseq>=1000 and (j-i > 5 and 10 or j-i > 3 and 3)) or 1
		if d >= (j-i)*dd then
			dd = d >= (j-i+1)*dd and toint(iseq/dd, 1)*dd or iseq
			for k = i+1, j-1 do
				local m, q = qs[k], dd + toint(d*(k-i)/(j-i))
				if m.seql==m.seq then m.seql = -q end
				m.seq = q
			end
			if q ~= true and q.seql==q.seq then q.seql = -q.seq end
			i, qi = j, q
		end
	end
	assert(qs[#qs-1].seq < 9000000)
	for j, m in ipairs(qs) do if m ~= true and m.seql > 0 then
		i = m
		repeat i = i[i.min] until i.seql < 0
		m.seql = i.seql
	end end
	for j, m in ipairs(qs) do if m ~= true then
		assert(m.seql < 0) m.seql = -m.seql
	end end
end
function ui.seqParent(u)
	local m = seqps[getmeta(u)]
	return m and m.seq
end

function ui.setSeq(u, p2, l2)
	ui.buildSeq()
	local m = uimeta(u)
	assert(m.seq==m.seql, '{#1} unconfig', u)
	assert(seqps[m]==m.parent, 'coder control {#1}', u)
	p2, l2 = Uimeta(p2), l2 and uimeta(l2)
	assert(not l2 or l2.parent==p2)
	assert(p2.seq==p2.seql, '{#1} unconfig', p2.u)
	local p0 = m.parent
	if p0 ~= p2 then
		ui.parent(m.u, p2.u)
		print('setSeq p', m.u, p2.u)
		seqps[m] = p2
	end
	if l2 then
		m.seq = (l2.seql+(l2.high and math.max(l2.high.seql, l2.seql+1) or 9000000-1))/2
	else
		m.seq = (p2.back and p2.back.seql or 9000000-1)/2
	end
	m.seql = m.seq
	ui.buildSeq(m)
	if p0 ~= p2 then
		for w in next, seqps do if w.parent and w.seql==m.seql then
			seqps[w] = 0
		end end
		seqps[m] = p2
		repeat
			local q, w, p
			repeat w, p = next(seqps, w) until not w or p==0
			if w then
				q, w, p = newP(w.seq, w)
				seqps[w] = p
				ui.parent(w.u, p.u)
				print('setSeq p', w.u, p.u)
			end
		until not w
	end
	for w in next, seqps do if w.parent and w.seql==m.seql then
		local v, l = w.parent.back
		while v do
			if v.seql < w.seql and (not l or v.seql > l.seql) then l = v end
			v = v.high
		end
		if l then ui.high(l.u, w.u) print('setSeq h', l.u, w.u) end
	end end
end
end

-------------------------------------------------------------------------------

local drawPoint, drawLine = _rd.drawPoint, _rd.drawLine
local drawRect, fillRect = _rd.drawRect, _rd.fillRect
function _rd:drawLine(x, y, w, h, c, to)
	if not to and (w==0 or h==0) then return end
	w, h = w+(to and 0 or w>0 and x-1 or x+1), h+(to and 0 or h>0 and y-1 or y+1)
	drawLine(_rd, x, y, w, h, c) drawPoint(_rd, w, h, c)
end

function _rd:drawRect(x, y, w, h, c, to)
	if not to and (w==0 or h==0) then return end
	w, h = w+(to and 0 or w>0 and x-1 or x+1), h+(to and 0 or h>0 and y-1 or y+1)
	drawRect(_rd, x, y, w, h, c) drawPoint(_rd, w, h, c)
end
function _rd:fillRect(x, y, w, h, c, to)
	w, h = w+(to and (w>x and 1 or -1) or x), h+(to and (h>y and 1 or -1) or y)
	fillRect(_rd, x, y, w, h, c)
end

local frameodd, buffer = true, _DrawBoard.new(_rd.w, _rd.h)
local useDrawBoard, resetDrawBoard, drawBuffer = _rd.useDrawBoard, _rd.resetDrawBoard, buffer.drawImage
local _Font, _Image = _Font, _Image

local pickfont = _Font.new(os.info.defaultfont, 10, 1, 0, true)
local pickfont2 = _Font.new(os.info.defaultfont, 10, 1, 0, true)
pickfont.textColor = 0xffffff00 pickfont.edgeColor = 0xff000000
pickfont2.textColor = 0xffffffff pickfont2.edgeColor = 0xff000000
local picktime, picktimes, pickn = 0, 0, false
local function pickInfo(u, x, y, layer, as, bs)
	local oks = false
	local M = getmeta(u) local C = M.back
	while C do
		local u = C.u
		local ux, uy, uw, uh = u.x or 0, u.y or 0, u.w or 0, u.h or 0
		if u.show then
			local ok = ux <= x and x < ux+uw and uy <= y and y < uy+uh
			if ok then
				_rd:drawRect(ui.mousex-x+ux, ui.mousey-y+uy, uw, uh,
					0xff000000+math.random(0, 0xffffff))
			end
			local i, fu, xx, yy = #as, u, ui.pos(u)
			while fu ~= ui and fu.owner ~= ui do fu = fu.owner end
			as[i+1] = ('%2d%s%s  %s'):format(layer, (ok and ' ' or '-'):rep(layer),
				getmeta(u).name, fu ~= ui and getmeta(fu).file or '')
			bs[i+1] = ('~%p %6.1f%6.1f %6.1f%6.1f %6.1f%6.1f'):format(u, xx, yy, ux, uy, uw, uh)
			ok = pickInfo(u, x-ux, y-uy, layer+1, as, bs) or ok
			oks = oks or ok
			if not ok then for j = i+1, #as do as[j], bs[j] = nil end end
		end
	C = C.high end
	return oks
end

local lasttime, appIdle2 = os.now()
function ui.appIdle()
	frameodd = not frameodd or dragx
	if not doNew or NO_UI then return end
	local time = os.now()
	ui.w, ui.h = _rd.w - (ui.marginr or 0), _rd.h - (ui.marginb or 0)
	for u in next, hideupdates do
		if not realShow(u, getmeta(u), true) then On(u, 'onHideUpdate', 0) end
	end
	ui.front(ui, ui.modaltop) ui.low(ui.modaltop, ui.modal) ui.low(ui.modal, ui.top)
	Ons(ui, 'onUpdate')
	ui.elapse, lasttime = time-lasttime, time
	ui.front(ui, ui.modaltop) ui.low(ui.modaltop, ui.modal) ui.low(ui.modal, ui.top)
	rdx, rdy = 0, 0 Ons(ui, 'onRender')
	if pickn then
		picktimes = picktimes + os.now() - time pickn = pickn+1
		if pickn==5 then pickn = 0 picktime = picktimes/5 picktimes = 0 end
		local as, bs = {}, {} pickInfo(ui, ui.mousex, ui.mousey, 1, as, bs)
		as[#as+1] = tostring(drop or hover)
		local lp, l = (drop or hover) and ui.load(drop or hover)
		bs[#bs+1] = ('%2dms %s %s   %s%3d'):format(picktime, tostring(hover and hover.show),
			tostring(focus and getmeta(focus).name), tostring(l and l.name), l and lp*100 or 0)
		local w, h = 0, #as*pickfont.height
		for i = 1, #as do w = math.max(w, pickfont:stringWidth(as[i])) end
		local x, y = math.min(ui.mousex+7, _rd.w-w-7), math.max(ui.mousey-h, 0)
		_rd:fillRect(x-7, y-7, w+7, h+7, 0x55000080)
		for i, a in ipairs(as) do
			(i%2==1 and pickfont or pickfont2):drawText(x, y+(i-1)*pickfont.height, a)
		end
		w, h = 0, w
		for i = 1, #bs do w = math.max(w, pickfont2:stringWidth(bs[i])) end
		x = x-7-w-7 >= 0 and x-7-w-7 or x+h+7+7 h = #bs*pickfont2.height
		_rd:fillRect(x-7, y-7, w+7, h+7, 0x55000080)
		for i, b in ipairs(bs) do
			(i%2==1 and pickfont or pickfont2):drawText(x, y+(i-1)*pickfont2.height, b)
		end
	end
	appIdle2()
end

-------------------------------------------------------------------------------

function ui.appMouseMove(x, y) ui.mousex, ui.mousey = x, y end

function endDrag()
	local d = drop dragx, dragy, drop = nil
	if d then
		local s = {}
		local m = getmeta(d) repeat s[m] = true m = m.parent until not m
		Ons(ui, 'onDrop', hover, nil, nil, d, s)
	end
	return Ons(ui, 'onDrag', d, nil, nil, hover, hovers)
end

local mousehover = true
function ui.appMouseDown(b, x, y)
	if y==nil then b, x, y = 0, b, x end -- onMouseDbclick
	if NO_UI then return end
	if ui.mouseb then ui.appMouseUp() end
	ui.mousex, ui.mousey, ui.mouseb = x, y, b
	local h = isuiu(Ons(ui, 'onPick', x, y))
	hoverTo(h) focusTo(h)
	if hover then pushTo(x, y, b) return false end
	mousehover = false
end
function ui.appMouseUp()
	local b = ui.mouseb ui.mouseb = false
	if not mousehover then mousehover = true return end
	if dragx then
		pushx, pushy = nil
		if endDrag() then
			local h = Ons(ui, 'onPick', ui.mousex, ui.mousey)
			hoverTo(isuiu(h))
		else
			hoverTo()
		end
	elseif pushx then
		assert(focus)
		pushx, pushy = nil
		if hover==focus then
			if b ~= 1 and ui.onClickReport then ui:onClickReport(hover) end
			Ons(ui, b ~= 1 and 'onClick' or 'onRightClick', nil, nil, nil, focus, focuss)
		end
	end
	return false
end

function appIdle2()
	if NO_UI or not doNew or not frameodd then return end
	local x, y = ui.mousex, ui.mousey
	
	local h = isuiu(Ons(ui, 'onPick', x, y))
	if dragx then
		local fx, fy = ui.pos(focus) drop = h
		Ons(ui, 'onDraging', x-fx-dragx, y-fy-dragy, h, focus, focuss)
	elseif not pushx then
		if mousehover then hoverTo(h) end
	elseif type(pushd) == 'number' then
		if h ~= focus or math.abs(x-pushx) >= pushd or math.abs(y-pushy) >= pushd then
			local fx, fy = ui.pos(focus) dragx, dragy, drop = pushx-fx, pushy-fy, h
			Ons(ui, 'onDraging', x-pushx, y-pushy, h, focus, focuss)
		end
	elseif pushd=='push' then
		if h ~= focus then pushx, pushy = nil end
		hoverTo(h) focusTo(h) pushTo(x, y, ui.mouseb)
	else
		hoverTo(h==focus and h, true)
	end
end

function ui.appMouseWheel(v)
	if hover then
		Ons(ui, 'onWheel', v, nil, nil, hover, hovers)
		return false
	end
end

function ui.appTouchBegin(x, y)
	ui.appMouseMove(x, y)
	return ui.appMouseDown(0, x, y)
end
ui.appTouchMove = ui.appMouseMove
function ui.appTouchEnd(x, y)
	ui.appMouseMove(x, y)
	local ret = ui.appMouseUp(0)
	ui.appMouseMove(-1000, -1000)
	return ret
end

local function onHotkey(M, k)
	if focus then
		local m = M.front while m do
			if focuss[m] and onHotkey(m, k)==false then return false end
		m = m.parent==M and m.low end
	end
	local m, u = M.front while m do u = m.u
		if u.show and (M ~= uim or not transparent or transparent[u])
			and not focuss[m] and onHotkey(m, k)==false then return false end
	m = m.parent==M and m.low end
	if hotkeys[M.u] and On(M.u, 'onHotkey', 0, k)==false then return false end
end

function ui.appKeyDown(k)
	if k==191 and _sys:isKeyDown(17) then pickn = not pickn and 0 end -- Ctrl /
	if focus and On(focus, 'onKey', 0, k)==false then return false end
	if onHotkey(uim, k)==false then return false end
end

function ui.appChar(c)
	if c < 32 then return end
	if focus and On(focus, 'onKey', 0, 0, c)==false then return false end
end
function ui.appKeyboardString(s)
	if focus and On(focus, 'onKeys', 0, s)==false then return false end
end

function ui.appIMEString(s)
	ui.ime = s ~= '' and s or nil
end

--------------------------------------------------------------------------

function ui.hover(u)
	if u==nil then return hover end
	return hovers[getmeta(u)] or false
end
function ui.focus(u)
	if u==nil then return focus end
	return focuss[getmeta(u)] or false
end
function ui.focusTo(u)
	if u == nil then focusTo() return end
	local m = uimeta(u)
	while m and m.parent ~= uim do m = m.parent end
	if m and (not transparent or transparent[m.u]) then focusTo(u) end
end
function ui.push(u)
	if u==nil then return pushx and hover end
	return pushx and hovers[getmeta(u)] or false
end

function ui.transparent(v, ...)
	if v==nil then return transparent end
	if v then
		transparent = setmetatable({ [ui.modaltop]=true }, { __mode='k' })
		for i = 1, select('#', ...) do
			local u = select(i, ...)
			if isui(u) then transparent[u] = true
			else transparent[assert(byName(u))] = true
			end
		end
		local m = getmeta(hover) while m do
			if not m.parent and not transparent[m.u] then hoverTo() end
		m = m.parent end
		local m = getmeta(focus) while m do
			if not m.parent and not transparent[m.u] then focusTo() end
		m = m.parent end
	else
		transparent = nil
	end
end

--------------------------------------------------------------------------

do
local qa9 = 1
local function a(w,dw, h,dh, X,x,dx, Y,y,dy, qx,qy,qa, r)
	local a = { w or 0,dw or 0; h or 0,dh or 0;
		X or 0,x or 0,dx or 0;Y or 0,y or 0,dy or 0;qx or false,qy or false,qa; r}
	if (qx or qy) and not qa then a[13], qa9 = qa9, qa9+1 end
	return setmeta(a, Align)
end
ui.align = a

function ui.is(super, sub)
	local m = getmeta(sub)
	if super==a then return m==Align
	else return m and m[0]==uim and super.new and m[super]==true
	end
end

function ui.alignLT(dx,dy,r) return a(1,0, 1,0, 0,0,dx, 0,0,dy, nil,nil,nil ,r) end
function ui.alignCT(dx,dy,r) return a(1,0, 1,0, .5,-.5,dx, 0,0,dy, nil,nil,nil ,r) end
function ui.alignRT(dx,dy,r) return a(1,0, 1,0, 1,-1,dx, 0,0,dy, nil,nil,nil ,r) end

function ui.alignLM(dx,dy,r) return a(1,0, 1,0, 0,0,dx, .5,-.5,dy, nil,nil,nil ,r) end
function ui.alignCM(dx,dy,r) return a(1,0, 1,0, .5,-.5,dx, .5,-.5,dy, nil,nil,nil ,r) end
function ui.alignRM(dx,dy,r) return a(1,0, 1,0, 1,-1,dx, .5,-.5,dy, nil,nil,nil ,r) end

function ui.alignLB(dx,dy,r) return a(1,0, 1,0, 0,0,dx, 1,-1,dy, nil,nil,nil ,r) end
function ui.alignCB(dx,dy,r) return a(1,0, 1,0, .5,-.5,dx, 1,-1,dy, nil,nil,nil ,r) end
function ui.alignRB(dx,dy,r) return a(1,0, 1,0, 1,-1,dx, 1,-1,dy, nil,nil,nil ,r) end

function ui.alignLTQ(dx,dy,qx,qy) return a(1,0, 1,0, 0,0,dx, 0,0,dy, qx,qy) end
function ui.alignCTQ(dx,dy,qx,qy) return a(1,0, 1,0, .5,-.5,dx, 0,0,dy, qx,qy) end
function ui.alignRTQ(dx,dy,qx,qy) return a(1,0, 1,0, 1,-1,dx, 0,0,dy, qx,qy) end
function ui.alignLMQ(dx,dy,qx,qy) return a(1,0, 1,0, 0,0,dx, .5,-.5,dy, qx,qy) end
function ui.alignCMQ(dx,dy,qx,qy) return a(1,0, 1,0, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.alignRMQ(dx,dy,qx,qy) return a(1,0, 1,0, 1,-1,dx, .5,-.5,dy, qx,qy) end
function ui.alignLBQ(dx,dy,qx,qy) return a(1,0, 1,0, 0,0,dx, 1,-1,dy, qx,qy) end
function ui.alignCBQ(dx,dy,qx,qy) return a(1,0, 1,0, .5,-.5,dx, 1,-1,dy, qx,qy) end
function ui.alignRBQ(dx,dy,qx,qy) return a(1,0, 1,0, 1,-1,dx, 1,-1,dy, qx,qy) end

function ui.stretch(dw,dh,dx,dy) return a(-1,dw or 0, -1,dh or 0, .5,-.5,dx, .5,-.5,dy) end

function ui.stretchT(dw,dx,dy) return a(-1,dw or 0, 1,0, .5,-.5,dx, 0,0,dy) end
function ui.stretchM(dw,dx,dy) return a(-1,dw or 0, 1,0, .5,-.5,dx, .5,-.5,dy) end
function ui.stretchB(dw,dx,dy) return a(-1,dw or 0, 1,0, .5,-.5,dx, 1,-1,dy) end

function ui.stretchL(dh,dx,dy) return a(1,0, -1,dh or 0, 0,0,dx, .5,-.5,dy) end
function ui.stretchC(dh,dx,dy) return a(1,0, -1,dh or 0, .5,-.5,dx, .5,-.5,dy) end
function ui.stretchR(dh,dx,dy) return a(1,0, -1,dh or 0, 1,-1,dx, .5,-.5,dy) end

function ui.stretchTZ(dw,h,dx,dy) return a(-1,dw or 0, 0,h, .5,-.5,dx, 0,0,dy) end
function ui.stretchMZ(dw,h,dx,dy) return a(-1,dw or 0, 0,h, .5,-.5,dx, .5,-.5,dy) end
function ui.stretchBZ(dw,h,dx,dy) return a(-1,dw or 0, 0,h, .5,-.5,dx, 1,-1,dy) end

function ui.stretchLZ(w,dh,dx,dy) return a(0,w, -1,dh or 0, 0,0,dx, .5,-.5,dy) end
function ui.stretchCZ(w,dh,dx,dy) return a(0,w, -1,dh or 0, .5,-.5,dx, .5,-.5,dy) end
function ui.stretchRZ(w,dh,dx,dy) return a(0,w, -1,dh or 0, 1,-1,dx, .5,-.5,dy) end

function ui.stretchQ(dw,dh,dx,dy,qx,qy) return a(-1,dw or 0, -1,dh or 0, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.stretchTQ(dw,dx,dy,qx,qy) return a(-1,dw or 0, 1,0, .5,-.5,dx, 0,0,dy, qx,qy) end
function ui.stretchMQ(dw,dx,dy,qx,qy) return a(-1,dw or 0, 1,0, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.stretchBQ(dw,dx,dy,qx,qy) return a(-1,dw or 0, 1,0, .5,-.5,dx, 1,-1,dy, qx,qy) end
function ui.stretchLQ(dh,dx,dy,qx,qy) return a(1,0, -1,dh or 0, 0,0,dx, .5,-.5,dy, qx,qy) end
function ui.stretchCQ(dh,dx,dy,qx,qy) return a(1,0, -1,dh or 0, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.stretchRQ(dh,dx,dy,qx,qy) return a(1,0, -1,dh or 0, 1,-1,dx, .5,-.5,dy, qx,qy) end
function ui.stretchTZQ(dw,h,dx,dy,qx,qy) return a(-1,dw or 0, 0,h, .5,-.5,dx, 0,0,dy, qx,qy) end
function ui.stretchMZQ(dw,h,dx,dy,qx,qy) return a(-1,dw or 0, 0,h, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.stretchBZQ(dw,h,dx,dy,qx,qy) return a(-1,dw or 0, 0,h, .5,-.5,dx, 1,-1,dy, qx,qy) end
function ui.stretchLZQ(w,dh,dx,dy,qx,qy) return a(0,w, -1,dh or 0, 0,0,dx, .5,-.5,dy, qx,qy) end
function ui.stretchCZQ(w,dh,dx,dy,qx,qy) return a(0,w, -1,dh or 0, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.stretchRZQ(w,dh,dx,dy,qx,qy) return a(0,w, -1,dh or 0, 1,-1,dx, .5,-.5,dy, qx,qy) end

function ui.sizeLT(w,h,dx,dy) return a(0,w, 0,h, 0,0,dx, 0,0,dy) end
function ui.sizeCT(w,h,dx,dy) return a(0,w, 0,h, .5,-.5,dx, 0,0,dy) end
function ui.sizeRT(w,h,dx,dy) return a(0,w, 0,h, 1,-1,dx, 0,0,dy) end

function ui.sizeLM(w,h,dx,dy) return a(0,w, 0,h, 0,0,dx, .5,-.5,dy) end
function ui.sizeCM(w,h,dx,dy) return a(0,w, 0,h, .5,-.5,dx, .5,-.5,dy) end
function ui.sizeRM(w,h,dx,dy) return a(0,w, 0,h, 1,-1,dx, .5,-.5,dy) end

function ui.sizeLB(w,h,dx,dy) return a(0,w, 0,h, 0,0,dx, 1,-1,dy) end
function ui.sizeCB(w,h,dx,dy) return a(0,w, 0,h, .5,-.5,dx, 1,-1,dy) end
function ui.sizeRB(w,h,dx,dy) return a(0,w, 0,h, 1,-1,dx, 1,-1,dy) end

function ui.sizeLTQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, 0,0,dx, 0,0,dy, qx,qy) end
function ui.sizeCTQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, .5,-.5,dx, 0,0,dy, qx,qy) end
function ui.sizeRTQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, 1,-1,dx, 0,0,dy, qx,qy) end
function ui.sizeLMQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, 0,0,dx, .5,-.5,dy, qx,qy) end
function ui.sizeCMQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, .5,-.5,dx, .5,-.5,dy, qx,qy) end
function ui.sizeRMQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, 1,-1,dx, .5,-.5,dy, qx,qy) end
function ui.sizeLBQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, 0,0,dx, 1,-1,dy, qx,qy) end
function ui.sizeCBQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, .5,-.5,dx, 1,-1,dy, qx,qy) end
function ui.sizeRBQ(w,h,dx,dy,qx,qy) return a(0,w, 0,h, 1,-1,dx, 1,-1,dy, qx,qy) end

function Align:__tostring()
	if self.s then return self.s end
	local w,dw, h,dh, X,x,dx, Y,y,dy, qx,qy,qa, r = unpack(self)
	local a1 = X==0 and x==0 and 'L' or X==.5 and x==-.5 and 'C' or X==1 and x==-1 and 'R'
	local a2 = Y==0 and y==0 and 'T' or Y==.5 and y==-.5 and 'M' or Y==1 and y==-1 and 'B'
	local q, qx, qy = qa and 'Q', qx or 'nil', qy or 'nil'
	if w==1 and dw==0 and h==1 and dh==0 and a1 and a2 then
		self.s = r and ('ui.align%s%s(%g,%g,%g)'):format(a1,a2, dx,dy, r) or (q and 'ui.align%s%s%s(%g,%g, %s,%s)' or dx==0 and dy==0 and 'ui.align%s%s()'
			or  'ui.align%s%s%s(%g,%g)'):format(a1,a2,q or '', dx,dy, qx,qy,r)
		self.a = ('align%s%s%s'):format(a1,a2,q or '')
	elseif w==-1 or h==-1 then
		if w==-1 and h==-1 and a1=='C' and a2=='M' then
			self.s = (q and 'ui.stretch%s(%g,%g,%g,%g, %s,%s)' or dx==0 and dy==0 and 'ui.stretch%s(%g,%g)'
				or 'ui.stretch%s(%g,%g,%g,%g)'):format(q or '', dw,dh,dx,dy, qx,qy)
			self.a = q and 'stretchQ' or 'stretch'
		elseif w==-1 and h==1 and a1=='C' and a2 then
			self.s = (q and 'ui.stretch%s%s(%g,%g,%g, %s,%s)' or dx==0 and dy==0 and 'ui.stretch%s%s(%g)'
				or 'ui.stretch%s%s(%g,%g,%g)'):format(a2,q or '', dw,dx,dy, qx,qy)
			self.a = ('stretch%s%s'):format(a2,q or '')
		elseif w==1 and h==-1 and a1 and a2=='M' then
			self.s = (q and 'ui.stretch%s%s(%g,%g,%g, %s,%s)' or dx==0 and dy==0 and 'ui.stretch%s%s(%g)'
				or 'ui.stretch%s%s(%g,%g,%g)'):format(a1,q or '', dh,dx,dy)
			self.a = ('stretch%s%s'):format(a1,q or '')
		elseif h==0 and a1=='C' and a2 or w==0 and a1 and a2=='M' then
			self.s = (q and 'ui.stretch%sZ%s(%g,%g,%g,%g, %s,%s)' or dx==0 and dy==0 and 'ui.stretch%sZ%s(%g,%g)'
				or 'ui.stretch%sZ%s(%g,%g,%g,%g)'):format(h==0 and a2 or a1,q or '', dw,dh,dx,dy)
			self.a = ('stretch%sZ%s'):format(h==0 and a2 or a1,q or '')
		end
	elseif w==0 and h==0 and a1 and a2 then
		self.s = (q and 'ui.size%s%s%s(%g,%g,%g,%g, %s,%s)' or dx==0 and dy==0 and 'ui.size%s%s%s(%g,%g)'
			or 'ui.size%s%s%s(%g,%g,%g,%g)'):format(a1,a2,q or '', dw,dh,dx,dy, qx,qy)
		self.a = ('size%s%s%s'):format(a1,a2,q or '')
	end
	if not self.s then
		self.s = (q and 'ui.align(%g,%g, %g,%g, %g,%g,%g, %g,%g,%g, %s,%s)' or
			'ui.align(%g,%g, %g,%g, %g,%g,%g, %g,%g,%g)'):format(w,dw, h,dh, X,x,dx, Y,y,dy, qx,qy)
	end
	return self.s
end
end

local function alignApply(align, pw, ph, cw, ch, low)
	local w,dw, h,dh, X,x,dx, Y,y,dy, qx,qy,qa, r = unpack(align)
	w, h = (w>=0 and cw or -pw)*w + dw, (h>=0 and ch or -ph)*h + dh
	x, y = pw*X + w*x + dx, ph*Y + h*y + dy
	if qa then
		while low do local u = low.u
			if not u.align or u.align[13] ~= qa then break
			elseif u.show then
				if qx then x = (u.x or 0) + (u.w or 0) + qx end
				if qy then y = (u.y or 0) + (u.h or 0) + qy end
				break
			end
			low = low.low
		end
	end
	return x, y, w, h
end

function position(u, parent, align, low)
	local x, y, w, h
	if align==nil then align = u.align end
	if not align then
		x, y, w, h = 0, 0, u.w or 0, u.h or 0
	elseif _Image==getmeta(u) then
		x, y, w, h = alignApply(align, parent.w or 0, parent.h or 0, u.W, u.H)
	else
		local m = uimeta(u)
		if not parent then parent = m.parent.u end
		x, y, w, h = alignApply(align, parent.w or 0, parent.h or 0, u.w or 0, u.h or 0,
			isUi(low) or m.low)
	end
	u.x, u.y, u.w, u.h = x, y, w, h
	return x, y, w, h
end
ui.position = position

local function moveDiff(u, dx, dy)
	local ua = u.align
	if ua then
		ua[7] = ua[7]+(dx or 0) ua[10] = ua[10]+(dy or 0) ua.a, ua.s = nil
	else
		u.align = ui.alignLT(dx or 0, dy or 0)
	end
end
ui.moveDiff = moveDiff
function ui.moveTo(u, x, y, imgp)
	if getmeta(u)==_Image then
		assert(imgp, 'img no parent')
		local ux, uy = alignApply(u.align, imgp.w or 0, imgp.h or 0, u.W, u.H)
		moveDiff(u, x and x-ux or 0, y and y-uy or 0)
	else
		moveDiff(u, x and x-(u.x or 0) or 0, y and y-(u.y or 0) or 0)
		ui.position(u)
	end
end

local function sizeDiff(u, dw, dh)
	local img, ua = getmeta(u)==_Image, u.align
	if not ua then ua = ui.alignLT() u.align = ua end
	if ua then
		local ua1, ua3 = ua[1], ua[3]
		if ua1<=0 then
			ua[2] = ua[2]+(dw or 0)
		elseif img then
			if dw ~= 0 or dh ~= 0 and ua3>0 then ua[1] = 0 ua[2] = u.w+(dw or 0) end
		else
			local dw = (dw or 0)/ua1
			if dw ~= 0 then u.w = u.w + dw end
		end
		if ua3<=0 then
			ua[4] = ua[4]+(dh or 0)
		elseif img then
			if dw ~= 0 and ua1>0 or dh ~= 0 then ua[3] = 0 ua[4] = u.h+(dh or 0) end
		else
			local dh = (dh or 0)/ua[3]
			if dh ~= 0 then u.h = u.h + dh end
		end
		ua.a, ua.s = nil
	end
end
ui.sizeDiff = sizeDiff
function ui.sizeTo(u, w, h, imgp)
	if getmeta(u)==_Image then
		assert(imgp, 'img no parent')
		local x, y, uw, uh = alignApply(u.align, imgp.w or 0, imgp.h or 0, u.W, u.H)
		sizeDiff(u, w and w-uw or 0, h and h-uh or 0)
	else
		sizeDiff(u, w and w-(u.w or 0) or 0, h and h-(u.h or 0) or 0)
		ui.position(u)
	end
end

function ui.pos(u, to)
	local m, tm, x, y = nil, to ~= nil and Uimeta(to), 0, 0
	if u=='mouse' then
		x, y = ui.mousex, ui.mousey
	else
		m = Uimeta(u) repeat
			x = x+(m.u.x or 0) y = y+(m.u.y or 0)
			m = m.parent
		until not m or m==tm
	end
	if to=='mouse' then
		x, y = x-ui.mousex, y-ui.mousey
	elseif not m and tm then
		repeat
			x = x-(tm.u.x or 0) y = y-(tm.u.y or 0)
			tm = tm.parent
		until not tm
	end
	return x, y
end

local function pickImg(s, x, y, show, u, ...)
	local uw, uh = u.w or 0, u.h or 0
	for i = 1, select('#', ...) do
		local img = select(i, ...)
		if not img then
		elseif isui(img) then
			if not show or img.show then
				pickImg(s, x-(img.x or 0), y-(img.y or 0), show, img, unpack(img))
			end
		elseif getmeta(img)==_Image then
			local X, Y, W, H = 0, 0, img.W, img.H
			if img.align then X, Y, W, H = alignApply(img.align, uw, uh, W, H) end
			if (X <= x and x < X+W or x ~= x) and (Y <= y and y < Y+H or y ~= y) then
				table.push(s, u, img)
			end
		elseif type(img)=='table' then
			pickImg(s, x, y, show, u, unpack(img))
		end
	end
end
function ui.pick(mode, test, x, y, show, frontbg)
	if mode=='testall' then
		local testm, s = test and Uimeta(test) or uim, {}
		if not x or not y then x, y = ui.pos('mouse', test) end
		if show and test and not test.show then return s end
		local n, m = testm
		x, y = x+(n.u.x or 0), y+(n.u.y or 0)
		repeat
			if not n then m = m.parent
			else repeat
				m, n, x, y = n, n.front, x-(n.u.x or 0), y-(n.u.y or 0)
				if n and show and not n.u.show then while n and not n.u.show do n = n.low end end
				if frontbg then pickImg(s, x, y, show, m.u, m.u.backgs) end
			until not n end
			local flag 
			if m.u.align and m.u.align[14] then 
				point[1].x, point[1].y = 0, 0
				point[2].x, point[2].y = rP(0,  m.u.h or 0,  m.u.align[14])
				point[3].x, point[3].y = rP( m.u.w or 0,  m.u.h or 0,  m.u.align[14])
				point[4].x, point[4].y = rP( m.u.w or 0, 0,  m.u.align[14])
				point[5].x, point[5].y = 0, 0
				flag = inside(x, y)			
			elseif (0 <= x and x < (m.u.w or 0) or x ~= x) and
				(0 <= y and y < (m.u.h or 0) or y ~= y) and m ~= uim then 
				flag = true
			end
			if flag then
				table.push(s, m.u, false)
			end
			if not frontbg then pickImg(s, x, y, show, m.u, m.u.backgs) end
			n, x, y = m.low, x+(m.u.x or 0), y+(m.u.y or 0)
			if show then while n and not n.u.show do n = n.low end end
		until m==testm
		return s
	else
		pick = mode
	end
end

-------------------------------------------------------------------------------

local DrawImage = _Image.new''.drawImage
ui.rects = {}
local function drawImage(i, l, t, w, h )
	if not (w > 0 and h > 0) then return end
	if i.font then
		if w==i.W and h==i.H then
			i.font:drawText(l, t, w, h, i.text)
		else
			setTranslation(matrix, l, t) pushMul2DMatrixLeft(_rd, matrix)
			setScaling(matrix, w/i.W, h/i.H) pushMul2DMatrixLeft(_rd, matrix)
			i.font:drawText(0, 0, i.W, i.H, i.text)
			pop2DMatrix(_rd) pop2DMatrix(_rd)
		end
		return
	end
	l, t, w, h = toint(l, -1), toint(t, -1), toint(w, -1), toint(h, -1)
	local r, b, qx, qy = l+w, t+h, i.qx, i.qy
	if i.loading and not i.load.l then
		local t = i.load.interload
		if t and os.now() < (i.load.nextload or 0) then return end
		local async = _sys.asyncLoad _sys.asyncLoad = false
		_sys.asyncLoad, i.resname, i.loading = async, i.res
		if t then i.load.nextload = os.now() + t end
	end
	if not i.ready then
		if ui.loadimg then
			local lw, lh = ui.loadimg.w, ui.loadimg.h
			DrawImage(ui.loadimg, l+w/2-lw/2, l+h/2-lh/2, l+w/2+lw/2, l+h/2+lh/2)
		end
		if i.loading then ui.load(i.load.name, true) end
		return
	end
	if i.f=='g' then
		local W, H, A, k = i.W, i.H, i.rect, i.skip
		local Aw, Ah, L, T, R, B = A.w, A.h, i.gl, i.gt, i.gr, i.gb
		if L>Aw then L = Aw elseif L<0 then L = Aw+L if L<0 then L = 0 end end
		if T>Ah then T = Ah elseif T<0 then T = Ah+T if T<0 then T = 0 end end
		if R>Aw-L then R = Aw-L end
		if B>Ah-T then B = Ah-T end
		local RR, BB = R<0 and L or R, B<0 and T or B
		local P, Q, U, V = i.l, i.t, i.l+W-RR, i.t+H-BB
		if L>0 and T>0 then A.w,A.h,A.l,A.t = L,T,P,Q
			if k~=1                 then            DrawImage(i, l, t, l+L, t+T) end
			if k~=3 and R<0         then i.flip = 1 DrawImage(i, r-L, t, r, t+T) end
			if k~=7 and B<0         then i.flip = 2 DrawImage(i, l, b-T, l+L, b) end
			if k~=9 and R<0 and B<0 then i.flip = 3 DrawImage(i, r-L, b-T, r, b) end end
		if R>0 and T>0 then A.w,A.h,A.l,A.t = R,T,U,Q
			if k~=3                 then i.flip = 0 DrawImage(i, r-R, t, r, t+T) end
			if k~=9 and B<0         then i.flip = 2 DrawImage(i, r-R, b-T, r, b) end end
		if L>0 and B>0 then A.w,A.h,A.l,A.t = L,B,P,V
			if k~=7                 then i.flip = 0 DrawImage(i, l, b-B, l+L, b) end
			if k~=9 and R<0         then i.flip = 1 DrawImage(i, r-L, b-B, r, b) end end
		if R>0 and B>0 then A.w,A.h,A.l,A.t = R,B,U,V
			if k~=9                 then i.flip = 0 DrawImage(i, r-R, b-B, r, b) end end
		if w>L+RR and P+L<U then
			if T>0 then A.r,A.h,A.l,A.t = U,T,P+L,Q
				if k~=2         then i.flip = 0 DrawImage(i, l+L, t, r-RR, t+T) end
				if k~=8 and B<0 then i.flip = 2 DrawImage(i, l+L, b-BB, r-RR, b) end end
			if B>0 then A.r,A.h,A.l,A.t = U,B,P+L,V
				if k~=8 then i.flip = 0 DrawImage(i, l+L, b-BB, r-RR, b) end end
		end
		if h>T+BB and Q+T<V then
			if L>0 then A.w,A.b,A.l,A.t = L,V,P,Q+T
				if k~=4         then i.flip = 0 DrawImage(i, l, t+T, l+L, b-BB) end
				if k~=6 and R<0 then i.flip = 1 DrawImage(i, r-RR, t+T, r, b-BB) end end
			if R>0 then A.w,A.b,A.l,A.t = R,V,U,Q+T
				if k~=6 then i.flip = 0 DrawImage(i, r-RR, t+T, r, b-BB) end end
		end
		if w>L+RR and h>T+BB and P+L<U and Q+T<V then A.r,A.b,A.l,A.t = U, V, P+L, Q+T
			if k~=5 then i.flip = 0 DrawImage(i, l+L, t+T, r-RR, b-BB) end end
		i.flip, A.w, A.h, A.l, A.t = 0, R<0 and W-L or W, B<0 and H-T or H, P, Q
	elseif not (qx or qy) then
		DrawImage(i, l, t, r, b)
	else
		local W, H = i.W, i.H
		useClip(_rd, _rd.x+l, _rd.y+t, _rd.x+r, _rd.y+b)
		if qx and qy then
			for y = t, b, H+qy do for x = l, r, W+qx do
				DrawImage(i, x, y, x+W, y+H)
			end end
		elseif qx then
			for x = l, r, W+qx do DrawImage(i, x, t, x+W, b) end
		else
			for y = t, b, H+qy do DrawImage(i, l, y, r, y+H) end
		end
		popClip(_rd)
	end
end

function ui.img(res, ...)
	local i, loading
	if type(res)=='string' then
		res = res:gsub('/', '\\')
		local r, l, t, w, h, flip, gl, gt, gr, gb = ui.rects[res]
		res, loading = r and r.res or res, r and loader.l==true or nil
		i = _Image.new(loading and '' or res)
		i.res, i.loading, i.load = res, loading, loader
		if loading then loader[i] = true end
		if getmeta((...))==Align then -- align,flip,(tilex|gl,tiley|gt,(gr),(gb)),skip
			i.align, flip, gl, gt, gr, gb, i.skip = ...
		else -- l,t,w,h,align,flip,(tilex|gl,tiley|gt,(gr),(gb)),skip
			l, t, w, h, i.align, flip, gl, gt, gr, gb, i.skip = ...
			if i.align then assert(getmeta(i.align)==Align) else i.align = ui.alignLT() end
		end
		if l or t or w or h then
			local w9, h9 = (r and r.w or i.w) - l, (r and r.h or i.h) - t
			if w > w9 then w = w9 > 0 and w9 or 0 end
			if h > h9 then h = h9 > 0 and h9 or 0 end
			if r then l, t = l+r.l, t+r.t end
			r = i.rect
			r.w, r.h, r.l, r.t, r._save = w, h, l, t, true
			i.l, i.t, i.W, i.H = l, t, w, h
		elseif r then
			i.rect = r
			i.l, i.t, i.W, i.H = r.l, r.t, r.w, r.h
		else
			i.l, i.t, i.W, i.H = 0, 0, i.w, i.h
		end
		if flip and flip:tail'g' then
			if flip=='hg' then i.skip, gl, gt, gr, gb = gl, -1, 0, -1, 0
			elseif flip=='vg' then i.skip, gl, gt, gr, gb = gl, 0, -1, 0, -1
			elseif flip ~= 'g' then error('wrong grid '..flip)
			elseif not gt and not gr and not gb then
				i.skip, gl, gt, gr, gb = gl, -1, -1, -1, -1
			else
				assert(type(gl)=='number', 'wrong grid l {#1}', gl)
				assert(type(gt)=='number', 'wrong grid l {#1}', gt)
				assert(type(gr)=='number', 'wrong grid l {#1}', gr)
				assert(type(gb)=='number', 'wrong grid l {#1}', gb)
			end
			if gr < 0 then i.W = i.W+(gl < 0 and math.max(i.W+gl, 0) or gl) end
			if gb < 0 then i.H = i.H+(gt < 0 and math.max(i.H+gt, 0) or gt) end
			assert(not i.skip or i.skip >= 1 and i.skip <= 9, 'wrong grid skip {#1}', i.skip)
			i.f, i.gl, i.gt, i.gr, i.gb = 'g', gl, gt, gr, gb
		else
			if flip then
				i.flip = assert(flip=='hf' and 1 or flip=='vf' and 2 or flip=='f' and 3,
					'wrong flip {#1}', flip)
				i.f = flip
			end
			i.qx, i.qy = gl and math.max(gl, 1-i.W), gt and math.max(gt, 1-i.H)
		end
		i.w, i.h = -1, -1
	elseif getmeta(res)==_Image then -- ui.img(ui.img, align)
		loading = loader.l==true and res.resname=='' or nil
		i = _Image.new(loading and '' or res.res)
		i.res, i.loading, i.load = res.res, loading, loader
		if loading then loader[i] = true end
		i.rect, i.l, i.t, i.W, i.H = res.rect, res.l, res.t, res.W, res.H
		i.flip, i.f, i.gl, i.gt, i.gr, i.gb = res.flip, res.f, res.gl, res.gt, res.gr, res.gb
		i.skip, i.qx, i.qy = res.skip, res.qx, res.qy
		if ... then assert(getmeta((...))==Align) i.align = ... else i.align = ui.alignLT() end
		i.w, i.h = -100, -100
	elseif getmeta(res)==_Font then -- ui.img(ui.font, color, ui.align, text)
		i = _Image.new'' i.load = loader
		local color, align, text = ...
		i.l, i.t, i.W, i.H = 0, 0, res:stringWidth(text), res:stringHeight(text)
		if align then assert(getmeta(align)==Align) i.align = align else i.align = ui.alignLT() end
		i.font, i.text, i.w, i.h = ui.font(res, color), text, -1, -1
	else
		error'invalid image'
	end
	i.drawImage = drawImage
	return i
end

local drawx, drawy = 0, 0
local function drawImg(u, ...)
	local uw, uh = u.w or 0, u.h or 0
	for i = 1, select('#', ...) do
		local img = select(i, ...)
		if not img then
		elseif isui(img) then
			if img.show then
				local x, y = img.x or 0, img.y or 0
				drawx, drawy = drawx+x, drawy+y
				drawImg(img, unpack(img))
				drawx, drawy = drawx-x, drawy-y
			end
		elseif getmeta(img)==_Image then
			local x, y, W, H = 0, 0, img.W, img.H
			if img.align then x, y, W, H = alignApply(img.align, uw, uh, W, H) end
			img:drawImage(drawx+x, drawy+y, W, H)
		elseif type(img)=='table' then
			drawImg(u, unpack(img))
		end
	end
end
ui.drawImg = drawImg

function uim.on:onRender()
	if self.backgs then drawImg(self, self.backgs) end
end

-------------------------------------------------------------------------------

local Font = { l=_Font.hLeft, c=_Font.hCenter, r=_Font.hRight,
	t=_Font.vTop, m=_Font.vCenter, b=_Font.vBottom, }
table.copy(Font, { lt=Font.l+Font.t, ct=Font.c+Font.t, rt=Font.r+Font.t,
	lm=Font.l+Font.m, cm=Font.c+Font.m, rm=Font.r+Font.m,
	lb=Font.l+Font.b, cb=Font.c+Font.b, rb=Font.r+Font.b, })
local DrawText = _Font.new('', 1).drawText
local function drawText(self, x, y, w, h, text, a)
	if type(w)=='string' then DrawText(self, x, y, w, Font[h or self.align] or 0)
	else DrawText(self, x, y, x+w, y+h, text, Font[a or self.align] or 0) end
end

function ui.font(name, size, style, color, align)
	local f
	if getmeta(name)==_Font then
		name = name.font or name
		f = name:clone()
		f.font, f.style, color, align = name, name.style, size, style -- ui.font(font, color, align)
	else
		local find = string.find
		f = _Font.new(name, size, not not find(style,'g',1,true),
			find(style,'e',1,true) and 1 or 0, not not find(style,'b',1,true),
			not not find(style,'i',1,true), not not find(style,'u',1,true),
			not not find(style,'s',1,true), not not find(style,'p',1,true),
			not not find(style,'r',1,true))
		f.font, f.style = f, style
	end
	if align then f.align = Font[align] and align or error('wrong align '..tostring(align)) end
	f.textColor = color f.edgeColor = 0xaa000000
	f.drawText = drawText
	return f
end

------------------------------------------------------------------------------

local function loadRes(l, s, u)
	s[u] = true
	for k, v in next, u do
		if u==l then v = k end
		if _Image==getmeta(v) or ui.is(ui.pfx, v) or ui.is(ui.swf, v) then
			if u==l then u[v] = nil end
			--if v.res and not s[v.res] then
			if v.res and v.res ~= '' and not s[v.res] then
				s[v.res] = true pcall(l.l.load, l.l, v.res)
				if LOG_UILOAD then print('INFO ui.load', l.name, v.res) end
			end
		end
		if not s[v] and (type(v)=='table' and getmeta(v)==nil or u==l and isui(v)) then
			if u==l then u[v] = nil end
			loadRes(l, s, v)
		end
	end
end
function ui.load(name, start, onDone, interload)
	if name==nil then return loader end
	local l
	if isui(name) then
		l = uimeta(name).load
	else
		assert(type(name)=='string')
		l = loads[name]
		if not l then
			l = { name=name, l=true } loads[name] = l
		end
		loader = l
	end
	local ll = l.l
	if not ll then return 1, l
	elseif ll ~= true then
		if onDone ~= nil then ll.onDone = onDone end return math.min(ll.progress, .99), l
	elseif not start then return 0, l
	elseif file and type(start)=='number' then
		-- assert(doNew or file <= start and start <= 9999, 'invalid ui.load file number {#1}', start)
		file, newedit = file <= start and start or file , not not onDone
		loadfilenum = start
		return 0, l
	else
		ll = _Loader.new()
		l.l, ll.paused = ll, true
		if interload ~= nil then l.interload = interload end
		local function finish(a, b, delay)
			if not delay and os.info.devmode and next(ui.rects) then
				_enqueue(os.now(0)+500000, nil, finish, nil, nil, true)
			else
				print('INFO ui.loaded', l.name)
				l.l = nil if ll.onDone then onDone(l.name) end
			end
		end
		ll:onFinish(finish)
		loadRes(l, {}, l)
		ll.paused = false
		return l.l and math.min(ll.progress, .99) or 1, l
	end
end
ui.load''

forcename = ui^{}
ui.new.forcename = forcename

ui.new.top = 1^8000000^ui^{ align=ui.stretch(), show=true }
ui.new.modal = 1^8500000^ui^{ align=ui.stretch() }
ui.new.modaltop = 1^8999000^ui^{ align=ui.stretch(), show=true }

function ui.top:onPick() ui.child(false) end
function ui.modaltop:onPick(full)
	ui.pick'allchild'
	if ui.child()==self then ui.child(false) end
end

function ui.modal:onUpdate(full)
	ui.child()
	local C = getmeta(self).back
	while C do
		if C.u.show then return end
		C = C.high
	end
	self.show = false
end
function ui.modal:onHideUpdate()
	local C = getmeta(self).back
	while C do
		if C.u.show then self.show = true return end
		C = C.high
	end
end

if not os.info.uiedit then
	function ui.modal:onHotkey()
		ui.child(false)
	end
	local shake, shakem = nil, _Matrix2D.new()
	function ui.modal:onPush()
		shake = _now() + 250
	end
	function ui.modal:onRender(full)
		_rd:fillRect(0, 0, self.w, self.h, 0xaa000000)
		if shake and _now() > shake then shake = nil end
		if shake then
			setTranslation(shakem, math.random(-2,2), math.random(-2,2))
			pushMul2DMatrixLeft(_rd, shakem)
		end
		ui.child()
		if shake then pop2DMatrix(_rd) end
	end
end
