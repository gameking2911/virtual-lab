ui.load("", 100)
ui.new.pass = 1^1000^ui^{
}
ui.load("", 105)
ui.new.passc = 1^1050^ui^{
}
ui.load("", 110)
ui.new.passp = 1^1100^ui^{
}
ui.load("", 115)
ui.new.pickc = 1^1150^ui^{
}
ui.load("", 120)
ui.new.pickcp = 1^1200^ui^{
}
ui.load("", 125)
ui.new.cursor = 1^1250^ui^{
	cursor = "",
}
ui.load("", 150, true)
ui.new.label = 1^1500^ui^{
	w = 50,
	h = 20,
	autosize = false,
	font = ui.font(ui.fonts.default, 0xffffffff, "lm"),
	text = "label",
}
ui.load("other", 152, true)
ui.new.htmlLabel = 1^1680275^ui^{
	w = 50,
	h = 20,
	font = ui.font(ui.fonts.h16, 0xffffffff, "lm"),
	multiline = false,
	text = "",
}
ui.load("", 155, true)
ui.new.button = 1^1550^ui.cursor^{
	w = 80,
	h = 30,
	audio = "",
	bg = true,
	bghover = ui.img("image\\button2.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgidle = ui.img("image\\button1.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgpush = ui.img("image\\button3.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgselect = ui.img("image\\button1.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	disable = false,
	fg = 1,
	fghover = {
	},
	fgidle = {
	},
	fgpush = {
	},
	fgselect = {
	},
	font = ui.font(ui.fonts.default, 0xffffffff, "cm"),
	pushy = 1,
	radio = false,
	select = false,
	text = "",
	volume = 100,
}
ui.load("", 160, true)
ui.new.checkbox = 1^1600^ui^{
	w = 20,
	h = 20,
	bgidle = ui.img("image\\empty.png", ui.stretch(0,0)),
	bgselect = ui.img("image\\choose.png", ui.stretch(0,0)),
	disable = false,
	select = false,
}
ui.load("", 165, true)
ui.new.radiobox = 1^1650^ui^{
	w = 24,
	h = 24,
	bgidle = ui.img("image\\radio.png", ui.stretch(0,0)),
	bgselect = ui.img("image\\radio1.png", ui.stretch(0,0)),
	select = false,
}
ui.load("", 170, true)
ui.new.input = 1^1700^ui.cursor^{
	w = 100,
	h = 30,
	bgfocus = ui.img("image\\input1.png", ui.stretch(0,0), 'g', 11, 12, -1, 12),
	bgidle = ui.img("image\\input.png", ui.stretch(0,0), 'g', 11, 12, -1, 12),
	caret = 0,
	disable = false,
	fgcaret = ui.img("image\\inputs_tag.png", ui.alignLT(0,2)),
	font = ui.font(ui.fonts.default, 0xffffffff, "lm"),
	pass = "",
	text = "",
}
ui.load("", 200, true)
ui.new.progress = 1^2000^ui^{
	w = 200,
	h = 30,
	backgs = ui.img("image\\jindu1.png", ui.stretch(0,0), 'g', 20, 0, -1, 0),
	anima = false,
	fg = ui.img("image\\jindu.png", ui.stretch(0,0), 'g'),
	font = ui.font(ui.fonts.default, 0xfffff223, "cm"),
	format = "%d/%d",
	max = 999,
	now = 20,
	orien = false,
	speed = 0,
	style = 0,
}
ui.load("", 201, true)
ui.new.progexpr = 1^1680262^ui^{
	w = 200,
	h = 35,
	backgs = ui.img("image\\jindu1.png", ui.stretch(0,0), 'g', 20, 0, -1, 0),
	anima = false,
	conf = {
		[1] = {
			expr = 10,
		},
		[2] = {
			expr = 20,
		},
		[3] = {
			expr = 30,
		},
	},
	confkey = "expr",
	fg = ui.img("image\\jindu.png", ui.stretch(0,0), 'g'),
	fgid = 0,
	fgidle = {
	},
	font = ui.font(ui.fonts.default, 0xfffff223, "cm"),
	format = "%d/%d",
	lv = 1,
	now = 0,
	orien = false,
	speed = 1000,
}
ui.load("other", 204, true)
ui.new.listnode = 1^1680288^ui^{
	w = 200,
	h = 35,
	backgs = ui.img("", ui.stretch(0,0)),
	bghover = ui.img("image\\uiimg\\menu3qietu_169.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgidle = ui.img("image\\uiimg\\nwebibg_18.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgpush = ui.img("image\\uiimg\\nwebibg_18.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgselect = ui.img("image\\uiimg\\menu3qietu_169.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	forceq = false,
	select = false,
}
ui.load("", 205, true)
ui.new.list = 1^2050^ui^{
	w = 200,
	h = 250,
	backgs = ui.img("image\\button22.png", ui.stretch(0,0), 'g', 5, 5, -1, 5),
	autoalign = false,
	autosize = false,
	forceq = false,
}
ui.load("other", 206, true)
ui.new.roll = 1^1680301^ui^{
	w = 200,
	h = 250,
	backgs = ui.img("", ui.stretch(0,0)),
	speed = 0.10000000000000001,
}
ui.load("", 210, true)
ui.new.scrollv = 1^2100^ui^{
	w = 20,
	h = 250,
	backgs = ui.img("image\\button22.png", ui.stretch(0,0), 'g', 5, 5, -1, 5),
	bbtn = 2100^2120^ui.button^{
		w = 20,
		h = 20,
		align = ui.alignCB(),
		bg = false,
		fgidle = ui.img("image\\button_huangse_02.png", ui.stretch(0,0)),
	},
	slider = 2100^2130^ui.button^{
		w = 15,
		h = 40,
		align = ui.alignCT(0,20),
		bg = false,
		fgidle = ui.img("image\\black.png", ui.stretch(0,0), 'g', 4, 4, -1, -1),
	},
	style = 0,
	tbtn = 2100^2110^ui.button^{
		w = 20,
		h = 20,
		align = ui.alignCT(),
		bg = false,
		fgidle = ui.img("image\\button_huangse_01.png", ui.stretch(0,0)),
	},
}
ui.load("", 215, true)
ui.new.tpage = 1^2150^ui^{
	w = 200,
	h = 220,
	align = ui.alignCB(),
}
ui.load("", 220, true)
ui.new.tab = 1^2200^ui^{
	w = 200,
	h = 250,
	backgs = ui.img("image\\button22.png", ui.stretch(0,0), 'g', 5, 5, -1, 5),
}
ui.load("", 225, true)
ui.new.richtext = 1^2250^ui^{
	w = 200,
	h = 200,
	backgs = ui.img("image\\button22.png", ui.stretch(0,0), 'g', 5, 5, -1, 5),
	autosize = false,
	font = ui.font(ui.fonts.default, 0xffffffff, "lt"),
	text = "",
}
ui.load("", 230, true)
ui.new.pfx = 1^2300^ui.pass^{
	w = 0,
	h = 0,
	align = ui.alignCM(),
	bind = true,
	loop = 1,
	res = "",
	reset = true,
	scale = 20,
	speed = 0,
}
ui.load("", 235, true)
ui.new.swf = 1^2350^ui.pass^{
	res = "",
	swfsize = true,
}
ui.load("", 240, true)
ui.new.slider = 1^2400^ui^{
	w = 200,
	h = 30,
	bar = 2400^2410^ui.button^{
		w = 300,
		h = 15,
		align = ui.alignCM(0,-0.5),
		bg = false,
		fgidle = ui.img("image\\button1.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	},
	btn = 2400^2420^ui.button^{
		w = 10,
		h = 25,
		align = ui.alignCM(),
		bg = false,
		fgidle = ui.img("image\\button1.png", ui.stretch(0,0)),
	},
	max = 100,
	min = 0,
	snapInterval = 1,
	snapping = false,
	style = 0,
	value = 0,
}
ui.load("", 243, true)
ui.new.drag = 1^2430^ui^{
	w = 150,
	h = 30,
	disable = false,
}
ui.load("", 244, true)
ui.new.dropDownList = 1^2440^ui^{
	w = 100,
	h = 180,
	align = ui.alignLT(696,181),
	btn_dropdown = 2440^2442^ui.checkbox^{
		w = 14,
		h = 14,
		align = ui.alignRT(0,8),
		bg = false,
		fgidle = ui.img("image\\button_huangse_01.png", ui.stretch(0,0)),
	},
	inputtext = 2440^2441^ui.input^{
		w = 100,
		h = 30,
		bgfocus = ui.img("image\\input1.png", ui.stretch(0,0), 'g', 11, 12, -1, 12),
		bgidle = ui.img("image\\input.png", ui.stretch(0,0), 'g', 11, 12, -1, 12),
		caret = 0,
		disable = false,
		fgcaret = ui.img("image\\inputs_tag.png", ui.stretchL(-4)),
		font = ui.font(ui.fonts.default, 0xffffffff, "lm"),
		text = "",
	},
	list = 2440^2443^ui.list^{
		w = 100,
		h = 150,
		align = ui.alignLT(0,30),
		backgs = ui.img("image\\button22.png", ui.stretch(0,0), 'g', 5, 5, -1, 5),
		show = false,
		forceq = false,
	},
}
ui.load("", 246, true)
ui.new.mesh = 1^2460^ui^{
	w = 10,
	h = 10,
	align = ui.alignCM(),
	animation = {
	},
	loop = true,
	mesh = {
	},
	mirror = false,
	scale = 10,
	setinf = "",
	skeleton = "",
	translation = {
		x = 0,
		y = 0,
		z = 0,
	},
	vector = {
		x = 1,
		y = -1,
		z = 0,
	},
}
ui.load("", 247, true)
ui.new.imglabel = 1^2470^ui^{
	w = 100,
	h = 40,
	align = ui.alignLT(),
	show = true,
	font = ui.font(ui.fonts.h16, 0xfffff223, "lt"),
	imgtb = {
		[1] = {
			i = 1,
			j = 1,
			letter = "1",
			shrink = 20,
		},
		[2] = {
			i = 1,
			j = 2,
			letter = "2",
			shrink = 0,
		},
		[3] = {
			i = 1,
			j = 3,
			letter = "3",
			shrink = 0,
		},
		[4] = {
			i = 1,
			j = 4,
			letter = "4",
			shrink = 0,
		},
		[5] = {
			i = 2,
			j = 1,
			letter = "5",
			shrink = 0,
		},
		[6] = {
			i = 2,
			j = 2,
			letter = "6",
			shrink = 0,
		},
		[7] = {
			i = 2,
			j = 3,
			letter = "7",
			shrink = 0,
		},
		[8] = {
			i = 2,
			j = 4,
			letter = "8",
			shrink = 0,
		},
		[9] = {
			i = 3,
			j = 1,
			letter = "9",
			shrink = 0,
		},
		[10] = {
			i = 3,
			j = 2,
			letter = "0",
			shrink = 0,
		},
	},
	pngh = 64,
	pngw = 64,
	res = "",
	text = "",
}
ui.load("", 250, true)
ui.new.clipper = 1^2501^ui.passp^{
	w = 700,
	h = 550,
	align = ui.alignCM(),
	dragEnable = true,
}
ui.load("", 251, true)
ui.new.color = 1^2511^ui^{
	w = 22,
	h = 22,
	backgs = ui.img("image\\uiimg\\transparent.png", ui.stretch(0,0)),
	alpha = 55,
	rgb = "00000",
}
ui.load("", 252, true)
ui.new.window = 1^2521^ui^{
	w = 100,
	h = 100,
	align = ui.alignLT(),
	backgs = ui.img("", ui.stretch(0,0)),
	enablemove = false,
	maxheight = 150,
	maxweight = 150,
	minheight = 50,
	minweight = 50,
}
ui.load("", 253, true)
ui.new.obliqueList = 1^2531^ui^{
	w = 200,
	h = 250,
	forceq = false,
	lateral = false,
}
ui.load("", 254, true)
ui.new.accordin = 1^2540^ui^{
	w = 100,
	h = 100,
}
ui.load("", 255, true)
ui.new.affector = 1^2550^ui^{
	w = 400,
	h = 100,
	disable = false,
}
ui.load("", 256, true)
ui.new.treenode = 1^2560^ui.pickc^{
	w = 100,
	h = 20,
	H = 20,
	bghover = ui.img("image\\uiimg\\menu3(1)_03.png", ui.stretch(0,0)),
	bgidle = ui.img("image\\uiimg\\pfxtian_33.png", ui.stretch(0,0)),
	bgpush = ui.img("image\\uiimg\\pfxtian_33.png", ui.stretch(0,0)),
	bgselect = ui.img("image\\uiimg\\menu3qietu_169.png", ui.stretch(0,0)),
	expanded = true,
	panel = 2560^2561^ui.passp^{
		h = 0,
		align = ui.stretchT(-0,0,23),
	},
}
ui.load("", 257, true)
ui.new.checkbox1 = 1^2570^ui.checkbox^{
	hoveridle = ui.img("", ui.stretch(0,0)),
	hoverselect = ui.img("", ui.stretch(0,0)),
}
ui.load("", 258, true)
ui.new.progress1 = 1^2580^ui.progress^{
	fg = ui.img("", ui.stretch(0,0)),
	max = 100,
}
ui.load("", 259, true)
ui.new.size = 1^2590^ui^{
	w = 10,
	h = 10,
	bghover = ui.img("", ui.stretch(0,0)),
	corner = "lt",
	maxh = 500,
	maxw = 500,
	minh = 10,
	minw = 10,
}
ui.load("", 260, true)
ui.new.size1 = 1^2600^ui^{
	w = 10,
	h = 10,
	bghover = ui.img("", ui.stretch(0,0)),
	corner = "l",
	maxh = 500,
	maxw = 500,
	minh = 10,
	minw = 10,
}
ui.load("", 261, true)
ui.new.button1 = 1^2610^ui^{
	w = 80,
	h = 30,
	bg = true,
	bghover = ui.img("image\\button2.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgidle = ui.img("image\\button1.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgpush = ui.img("image\\button3.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	bgselect = ui.img("image\\button1.png", ui.stretch(0,0), 'g', 10, 0, -1, 0),
	disable = false,
	fg = 1,
	fghover = {
	},
	fgidle = {
	},
	fgpush = {
	},
	fgselect = {
	},
	font = ui.font(ui.fonts.default, 0xffffffff, "cm"),
	pushy = 1,
	radio = false,
	select = false,
	text = "",
}
ui.load("", 262, true)
ui.new.color1 = 1^2620^ui^{
	w = 120,
	h = 20,
	alpha = 100,
	rgb = "ff0000",
}
ui.load("", 265, true)
ui.new.colorPicker = 1^2650^ui^{
	w = 200,
	h = 380,
	align = ui.alignLT(416,149),
	backgs = ui.img("image\\uiimg\\nwebibg_18.png", ui.stretch(0,0)),
	a = 255,
	area1 = 2650^2651^ui^{
		w = 148,
		h = 148,
		align = ui.alignLT(9,58),
	},
	area2 = 2650^2652^ui^{
		w = 20,
		h = 148,
		align = ui.alignLT(166,58),
	},
	b = 255,
	colorA = 2650^2653^ui^{
		w = 135,
		h = 22,
		align = ui.alignLT(51,8),
	},
	colorModelBtn = 2650^1585935^ui^{
		w = 15,
		h = 13,
		align = ui.alignLT(171,215),
		backgs = ui.img("image\\uiimg\\mode_2.png", ui.alignLT()),
	},
	colors = 2650^2654^ui.label^{
		w = 50,
		h = 20,
		align = ui.alignLT(9,35),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
		text = "Colors",
	},
	g = 255,
	input1 = 2650^537851^ui.input^{
		w = 30,
		h = 16,
		align = ui.alignLT(161,232),
		bgfocus = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		bgidle = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
		text = "",
	},
	input2 = 2650^1340639^ui.input^{
		w = 30,
		h = 16,
		align = ui.alignLT(161,259),
		bgfocus = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		bgidle = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
	},
	input3 = 2650^1474437^ui.input^{
		w = 30,
		h = 16,
		align = ui.alignLT(161,286),
		bgfocus = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		bgidle = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
	},
	input4 = 2650^1541336^ui.input^{
		w = 30,
		h = 16,
		align = ui.alignLT(161,313),
		bgfocus = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		bgidle = ui.img("image\\uiimg\\color_input.png", ui.stretch(0,0)),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
	},
	label1 = 2650^1593368^ui.label^{
		w = 12,
		h = 12,
		align = ui.alignLT(9,234),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "cm"),
		text = "R",
	},
	label2 = 2650^1604518^ui.label^{
		w = 12,
		h = 12,
		align = ui.alignLT(9,261),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "cm"),
		text = "G",
	},
	label3 = 2650^1607305^ui.label^{
		w = 12,
		h = 12,
		align = ui.alignLT(9,288),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "cm"),
		text = "B",
	},
	label4 = 2650^1607770^ui.label^{
		w = 12,
		h = 12,
		align = ui.alignLT(9,315),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "cm"),
		text = "A",
	},
	modeBtn = 2650^1563635^ui^{
		w = 15,
		h = 13,
		align = ui.alignLT(171,39),
		backgs = ui.img("image\\uiimg\\mode_1.png", ui.alignLT()),
	},
	presetColorUI = 2650^1607886^ui^{
		w = 14,
		h = 14,
		align = ui.alignLT(9,357),
	},
	presets = 2650^2655^ui.label^{
		w = 50,
		h = 20,
		align = ui.alignLT(9,334),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
		text = "Presets",
	},
	r = 255,
	slider1 = 2650^2656^ui^{
		w = 123,
		h = 13,
		align = ui.alignLT(28,234),
	},
	slider2 = 2650^2657^ui^{
		w = 123,
		h = 13,
		align = ui.alignLT(28,261),
	},
	slider3 = 2650^2658^ui^{
		w = 123,
		h = 13,
		align = ui.alignLT(28,288),
	},
	slider4 = 2650^2659^ui^{
		w = 123,
		h = 13,
		align = ui.alignLT(28,315),
	},
	sliders = 2650^2660^ui.label^{
		w = 50,
		h = 20,
		align = ui.alignLT(9,211),
		font = ui.font(ui.fonts.yh8, 0xffffffff, "lm"),
		text = "Sliders",
	},
}
