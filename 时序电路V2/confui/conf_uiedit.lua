ui.load("edit", 9951)
ui.new.editpass = 1^1608235^ui^{
}
ui.load("edit", 9952)
ui.new.editpassc = 1^1608245^ui^{
}
ui.load("edit", 9953)
ui.new.editpassp = 1^1608255^ui^{
}
ui.load("edit", 9954)
ui.new.editpickc = 1^1608265^ui^{
}
ui.load("edit", 9955)
ui.new.editpickcp = 1^1608275^ui^{
}
ui.load("edit", 9961)
ui.new.editcursor = 1^1608285^ui^{
	cursor = "hand",
}
ui.load("edit", 9962)
ui.new.edithotkey = 1^1608295^ui^{
	hotkey = "",
}
ui.load("edit", 9963)
ui.new.editlabel = 1^1608305^ui^{
	w = 20,
	h = 20,
	autow = false,
	font = ui.font(ui.fonts.s9e, 0xffffffff, "lm"),
	left = 0,
	text = "label",
	top = 0,
}
ui.load("edit", 9964)
ui.new.editcheckbox = 1^1608315^ui.editlabel^ui.editcursor^{
	w = 22,
	h = 22,
	backgs = ui.img("uieditor\\img\\tubiaocao_22.png", ui.alignLM()),
	autow = false,
	checked = false,
	enable = true,
	fg = ui.img("uieditor\\img\\duihao.png", ui.alignLM()),
	left = 25,
	text = "",
}
ui.load("edit", 9965)
ui.new.editinput = 1^1608325^ui.editcursor^{
	w = 100,
	h = 24,
	backgs = ui.img("uieditor\\img\\shurukuang02.png", ui.stretchM(6), 'hg'),
	curr = 0,
	cursor = "input",
	font = ui.font(ui.fonts.s9e, 0xffffffff, "lm"),
	left = 0,
	lineH = 16,
	maxlength = 280,
	pad = {
		b = 3,
		l = 2,
		r = 2,
		t = 3,
	},
	tag = ui.img("uieditor\\img\\inputs_tag.png", ui.alignCM()),
	text = "",
	textalign = "lm",
	top = 2,
}
ui.load("edit", 9966)
ui.new.editscroll = 1^1608355^ui^{
	w = 20,
	h = 300,
	align = ui.alignRT(),
	backgs = ui.img("uieditor\\img\\button_huatiaodi.png", ui.stretch(0,0)),
	bar = 1608355^1608365^ui.editcursor^{
		w = 20,
		h = 52,
		align = ui.alignCT(),
		backgs = ui.img("uieditor\\img\\button_huatiao.png", ui.alignCM()),
	},
	by = 20,
	down = 1608355^1608375^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignCB(),
		backgs = ui.img("uieditor\\img\\button_huangse_02.png", ui.alignCB()),
	},
	ty = 20,
	up = 1608355^1608385^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignCT(),
		backgs = ui.img("uieditor\\img\\button_huangse_02.png", ui.alignCT(), 'vf'),
	},
}
ui.load("edit", 9967)
ui.new.editmenu = 1^1608335^ui.editpickc^{
	backgs = ui.img("uieditor\\img\\tooltip_backgs.png", ui.stretch(0,0), 'g'),
	show = false,
	node = 1608335^1608345^ui.editpickc^{
		h = 22,
		align = ui.stretchT(0),
		backgs = {
			hover = ui.img("uieditor\\img\\menu_node_1.png", ui.stretch(-4,-4)),
			select = ui.img("uieditor\\img\\menu_node.png", ui.stretch(-4,-4)),
		},
		W = 30,
		enable = true,
		fonts = {
			hover = ui.font(ui.fonts.s9e, 0xffffff00, "lm"),
			idle = ui.font(ui.fonts.s9e, 0xffffffff, "lm"),
		},
		left = 16,
		top = 0,
	},
	top = 7,
}
ui.load("edit", 9968)
ui.new.editlist = 1^1608395^ui^{
	w = 300,
	h = 300,
	border = {
	},
	panel = 1608395^1608405^ui^{
		h = 0,
		align = ui.stretchT(-20,-10,0),
	},
	scroll = 1608395^1608415^ui.editscroll^{
		w = 20,
		align = ui.stretchR(0),
	},
}
ui.load("edit", 9969)
ui.new.edittree = 1^1608425^ui.editlist^{
}
ui.load("edit", 9970)
ui.new.edittreenode = 1^1608435^ui.editlabel^ui.editpickc^{
	h = 25,
	align = ui.stretchT(-25,12.5,0),
	exicon = 1608435^1608445^ui.editcursor^{
		w = 25,
		h = 25,
		align = ui.alignLT(-26,0),
		fg = 1,
		fghover = {
			[1] = ui.img("uieditor\\img\\treenode_exicon_4.png", ui.alignCM()),
			[2] = ui.img("uieditor\\img\\treenode_exicon_1.png", ui.alignCM()),
		},
		fgidle = {
			[1] = ui.img("uieditor\\img\\treenode_exicon_3.png", ui.alignCM()),
			[2] = ui.img("uieditor\\img\\note_stuffs_1.png", ui.alignCM()),
		},
		fgpush = {
			[1] = ui.img("uieditor\\img\\treenode_exicon_2.png", ui.alignCM()),
			[2] = ui.img("uieditor\\img\\treenode_exicon.png", ui.alignCM()),
		},
	},
	expanded = true,
	font = ui.font(ui.fonts.s9e, 0x66eeeeee, "lt"),
	panel = 1608435^1608455^ui.editpassp^{
		h = 0,
		align = ui.stretchT(-0,0,23),
	},
	top = 3,
}
ui.load("edit", 9971)
ui.new.editalignc = 1^1608465^ui^{
	w = 30,
	h = 30,
	col = 0,
	row = 0,
}
ui.load("edit", 9972)
ui.new.editalign = 1^1608475^ui^{
	w = 90,
	h = 90,
	[11] = 1608475^1608485^ui.editalignc^{
		align = ui.alignLT(),
		col = 1,
		row = 1,
		ss = {
			[1] = "alignLT",
			[2] = "stretchL",
			[3] = "stretchT",
			[4] = "stretch",
			[5] = "sizeLT",
			[6] = "stretchLZ",
			[7] = "stretchTZ",
		},
	},
	[12] = 1608475^1608495^ui.editalignc^{
		align = ui.alignCT(),
		col = 2,
		row = 1,
		ss = {
			[1] = "alignCT",
			[2] = "stretchC",
			[3] = "stretchT",
			[4] = "stretch",
			[5] = "sizeCT",
			[6] = "stretchCZ",
			[7] = "stretchTZ",
		},
	},
	[13] = 1608475^1608505^ui.editalignc^{
		align = ui.alignRT(),
		col = 3,
		row = 1,
		ss = {
			[1] = "alignRT",
			[2] = "stretchR",
			[3] = "stretchT",
			[4] = "stretch",
			[5] = "sizeRT",
			[6] = "stretchRZ",
			[7] = "stretchTZ",
		},
	},
	[21] = 1608475^1608515^ui.editalignc^{
		align = ui.alignLM(),
		col = 1,
		row = 2,
		ss = {
			[1] = "alignLM",
			[2] = "stretchL",
			[3] = "stretchM",
			[4] = "stretch",
			[5] = "sizeLM",
			[6] = "stretchLZ",
			[7] = "stretchMZ",
		},
	},
	[22] = 1608475^1608525^ui.editalignc^{
		align = ui.alignCM(),
		col = 2,
		row = 2,
		ss = {
			[1] = "alignCM",
			[2] = "stretchC",
			[3] = "stretchM",
			[4] = "stretch",
			[5] = "sizeCM",
			[6] = "stretchCZ",
			[7] = "stretchMZ",
		},
	},
	[23] = 1608475^1608535^ui.editalignc^{
		align = ui.alignRM(),
		col = 3,
		row = 2,
		ss = {
			[1] = "alignRM",
			[2] = "stretchR",
			[3] = "stretchM",
			[4] = "stretch",
			[5] = "sizeRM",
			[6] = "stretchRZ",
			[7] = "stretchMZ",
		},
	},
	[31] = 1608475^1608545^ui.editalignc^{
		align = ui.alignLB(),
		col = 1,
		row = 3,
		ss = {
			[1] = "alignLB",
			[2] = "stretchL",
			[3] = "stretchB",
			[4] = "stretch",
			[5] = "sizeLB",
			[6] = "stretchLZ",
			[7] = "stretchBZ",
		},
	},
	[32] = 1608475^1608555^ui.editalignc^{
		align = ui.alignCB(),
		col = 2,
		row = 3,
		ss = {
			[1] = "alignCB",
			[2] = "stretchC",
			[3] = "stretchB",
			[4] = "stretch",
			[5] = "sizeCB",
			[6] = "stretchCZ",
			[7] = "stretchBZ",
		},
	},
	[33] = 1608475^1608565^ui.editalignc^{
		align = ui.alignRB(),
		col = 3,
		row = 3,
		ss = {
			[1] = "alignRB",
			[2] = "stretchR",
			[3] = "stretchB",
			[4] = "stretch",
			[5] = "sizeRB",
			[6] = "stretchRZ",
			[7] = "stretchBZ",
		},
	},
}
ui.load("edit", 9973)
ui.new.editalignv = 1^1608575^ui.editinput^{
	w = 48,
	textalign = "rb",
}
ui.load("edit", 9974)
ui.new.editaligns = 1^1608585^ui^{
	w = 216,
	h = 140,
	Align = 1608585^1608595^ui.editalign^{
		align = ui.alignLT(0,1),
	},
	H = 1608585^1608605^ui.editalignv^{
		align = ui.alignLT(96,66),
	},
	R = 1608585^1608746^ui.editalignv^{
		align = ui.alignLT(150,108),
	},
	W = 1608585^1608615^ui.editalignv^{
		align = ui.alignLT(96,44),
	},
	X = 1608585^1608625^ui.editalignv^{
		align = ui.alignLT(96,0),
	},
	Y = 1608585^1608635^ui.editalignv^{
		align = ui.alignLT(96,22),
	},
	dh = 1608585^1608645^ui.editalignv^{
		align = ui.alignLT(150,66),
	},
	dw = 1608585^1608655^ui.editalignv^{
		align = ui.alignLT(150,44),
	},
	dwh = 1608585^1608685^ui.editcursor^{
		w = 16,
		h = 16,
		align = ui.alignLT(198,60),
		backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.stretch(0,0)),
	},
	dx = 1608585^1608665^ui.editalignv^{
		align = ui.alignLT(150,0),
	},
	dxy = 1608585^1608695^ui.editcursor^{
		w = 16,
		h = 16,
		align = ui.alignLT(198,16),
		backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.stretch(0,0)),
	},
	dy = 1608585^1608675^ui.editalignv^{
		align = ui.alignLT(150,22),
	},
	pos = 1608585^1608735^ui.editlabel^{
		align = ui.alignCB(0,-9),
		autow = true,
	},
	qx = 1608585^1608705^ui.editalignv^{
		align = ui.alignLT(96,88),
	},
	qxy = 1608585^1608725^ui.editcursor^{
		w = 16,
		h = 16,
		align = ui.alignLT(82,93),
		backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.stretch(0,0)),
	},
	qy = 1608585^1608715^ui.editalignv^{
		align = ui.alignLT(150,88),
	},
	text = 1608585^1608745^ui.editlabel^{
		align = ui.stretchB(0,1,4),
	},
}
ui.load("edit", 9980)
ui.new.editcurra = 1^1608755^ui^{
}
ui.load("edit", 9981)
ui.new.editattr = 1^1608765^ui.editcurra^{
	h = 23,
	align = ui.stretchT(0),
	show = false,
	name = 1608765^1608775^ui.editlabel^{
		w = 80,
		h = 23,
		align = ui.alignLT(),
	},
}
ui.load("edit", 9982)
ui.new.editattrroot = 1^1608785^ui^{
	align = ui.stretchT(-24,12,0),
	over = 1608785^1608795^ui.editcheckbox^{
		align = ui.alignLT(-24,2),
	},
	reset = 1608785^1608805^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignLT(60,2),
		backgs = ui.img("uieditor\\img\\jiantou02.png", ui.stretch(0,0)),
		show = false,
		reseting = false,
	},
}
ui.load("edit", 9983)
ui.new.edittoarray = 1^1608815^ui.editcursor^{
	w = 16,
	h = 18,
	align = ui.alignLT(42,2),
	backgs = ui.img("uieditor\\img\\jiantou_03.png", ui.stretch(0,0)),
	show = false,
	backgsno = ui.img("uieditor\\img\\jiantou_03.png", ui.stretch(0,0), 'hf'),
}
ui.load("edit", 9984)
ui.new.editattrv = 1^1608825^ui^{
	h = 23,
	align = ui.stretchT(-88,40,0),
}
ui.load("edit", 9985)
ui.new.editattrinput = 1^1608835^ui.editattrv^ui.editinput^{
	align = ui.stretchT(-88,40,-1),
}
ui.load("edit", 9986)
ui.new.editattrfont = 1^1608845^ui.editattr^{
	alpha = 1608845^1608875^ui.editinput^{
		w = 28,
		align = ui.alignLT(221,-1),
		font = ui.font(_lang"宋体", 10, "be", 0xffffffff),
	},
	color = 1608845^1608865^ui.editinput^{
		w = 55,
		align = ui.alignLT(160,-1),
		font = ui.font(_lang"宋体", 10, "be", 0xffffffff),
	},
	font = 1608845^1608855^ui.editlabel^{
		w = 80,
		align = ui.alignLT(80,0),
	},
}
ui.load("edit", 9990)
ui.new.editzone = 1^1608885^ui^{
	align = ui.stretch(0,0),
	show = true,
	menu = 8999000^8999310^ui.editmenu^{
	},
	mousefont = ui.font(ui.fonts.s9e, 0xaaff8888, "lt"),
}
ui.load("edit", 9991)
ui.new.editmain = 1^1608895^ui^{
	w = 500,
	align = ui.align(1,0, -1,200, 1,0,0, 0,0,0),
	backgs = {
		[1] = ui.img("uieditor\\img\\roundbg_1.png", ui.stretch(0,0), 'g'),
		[2] = ui.img("uieditor\\img\\roundbg_1.png", ui.stretch(0,0), 'g'),
	},
	copying = 1608895^1608985^ui.editlabel^{
		align = ui.alignLT(150,50),
		show = false,
		left = 20,
		no = 1608985^1608995^ui.editcursor^{
			w = 16,
			h = 16,
			align = ui.alignLT(0,2),
			backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.stretch(0,0)),
		},
	},
	lists = 1608895^1608905^ui^{
		align = ui.stretch(0,-80,0,40),
	},
	menu = 8999000^8999360^ui.editmenu^{
	},
	olist = 1608895^1609177^ui.edittree^{
		align = ui.align(-1,-10, -0.5,-8, 0,0,5, 1,-1,-4),
		attralign = 1609177^1609211^ui.editattr^{
			value = 1609211^1609222^ui.editattrv^ui.editlabel^{
			},
		},
		attrbool = 1609177^1609233^ui.editattr^{
			value = 1609233^1609245^ui.editattrv^ui.editcheckbox^{
			},
		},
		attrfont = 1609177^1609256^ui.editattrfont^{
			Align = 1609256^1609267^ui.editcursor^{
				w = 22,
				align = ui.stretchL(0,255,0),
			},
		},
		attrimg = 1609177^1609278^ui.editattr^{
			copy = 1609278^1609312^ui.editcursor^{
				w = 16,
				h = 16,
				align = ui.alignRT(0,2),
				backgs = ui.img(ui.fonts.s11be, 0xffaaff00, ui.alignLT(), _lang"⿻"),
			},
			toarray = 1609278^1609290^ui.edittoarray^{
			},
			value = 1609278^1609301^ui.editattrinput^{
				align = ui.stretchT(-108,30,-1),
			},
		},
		attrimgt = 1609177^1609324^ui.editattrfont^{
			h = 46,
			copy = 1609324^1609357^ui.editcursor^{
				w = 16,
				h = 16,
				align = ui.alignRT(0,2),
				backgs = ui.img(ui.fonts.s11be, 0xffaaff00, ui.alignLT(), _lang"⿻"),
			},
			toarray = 1609324^1609335^ui.edittoarray^{
			},
			value = 1609324^1609346^ui.editattrinput^{
				align = ui.stretchB(-88,40,0),
			},
		},
		attrnum = 1609177^1609369^ui.editattr^{
			value = 1609369^1609380^ui.editattrinput^{
			},
		},
		attrtable = 1609177^1609425^ui.edittreenode^ui.editcurra^{
			h = 23,
			show = false,
			add = 1609425^1609459^ui.editcursor^{
				w = 16,
				h = 18,
				align = ui.alignRT(-56,2),
				show = false,
				backgs1 = ui.img("uieditor\\img\\addbtn_backgs.png", ui.alignCM()),
				backgs2 = ui.img("uieditor\\img\\jiahao.png", ui.alignCM()),
			},
			del = 1609425^1609470^ui.editcursor^{
				w = 16,
				h = 18,
				align = ui.alignRT(-38,2),
				backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.sizeCM(16,16)),
				show = false,
			},
			down = 1609425^1609492^ui.editcursor^{
				w = 16,
				h = 18,
				align = ui.alignRT(-2,2),
				backgs = ui.img("uieditor\\img\\button_huatiaoshang.png", ui.alignCM(), 'vf'),
				show = false,
			},
			name = 1609425^1609436^ui.editlabel^ui.editpass^{
				h = 23,
				align = ui.stretchT(0),
			},
			noarray = 1609425^1609447^ui.edittoarray^{
			},
			up = 1609425^1609481^ui.editcursor^{
				w = 16,
				h = 18,
				align = ui.alignRT(-20,2),
				backgs = ui.img("uieditor\\img\\button_huatiaoshang.png", ui.alignCM()),
				show = false,
			},
		},
		attrtext = 1609177^1609391^ui.editattr^{
			value = 1609391^1609402^ui.editattrinput^{
			},
		},
		fontalign = 1609177^1609414^ui.editalign^{
			show = false,
		},
		onode = 1609177^1609188^ui.edittreenode^{
			h = 20,
			show = false,
			edit = 1609188^1609200^ui.editcursor^{
				w = 24,
				h = 20,
				align = ui.alignRT(-70,0),
				backgs = ui.img("uieditor\\img\\zhandou.png", ui.stretch(0,0)),
			},
			expanded = false,
			font = ui.font(ui.fonts.s9e, 0xff00ff00, "lt"),
		},
	},
	redo = 1608895^1608915^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignLT(45,10),
		backgs = ui.img("uieditor\\img\\jiantou_01.png", ui.stretch(0,0)),
	},
	rego = 1608895^1608925^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignLT(230,10),
		backgs = ui.img("uieditor\\img\\button_kuaijin_01.png", ui.alignCM()),
	},
	save = 1608895^1609005^ui.editcursor^{
		w = 40,
		h = 20,
		align = ui.alignRT(-110,13),
		backgs = ui.img(ui.fonts.s11be, 0xffaaff00, ui.alignLT(), _lang"保存"),
	},
	search = 1608895^1608955^ui.editinput^{
		w = 80,
		align = ui.alignLT(100,10),
	},
	seqing = 1608895^1608965^ui.editlabel^{
		align = ui.alignLT(20,50),
		show = false,
		left = 20,
		no = 1608965^1608975^ui.editcursor^{
			w = 16,
			h = 16,
			align = ui.alignLT(0,2),
			backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.stretch(0,0)),
		},
	},
	uilist = 1608895^1609015^ui.edittree^{
		align = ui.align(-1,-10, -0.5,-8, 0,0,5, 0,0,4),
		font = 8999000^8999410^ui.editmenu^{
		},
		menu = 8999000^8999460^ui.editmenu^{
			node = 8999460^8999510^ui.editmenu.node^{
				h = 18,
				align = ui.stretchT(-25,-10,0),
				top = -1,
			},
			page = 8999460^8999570^ui^{
				w = 170,
				h = 18,
				align = ui.alignCM(),
				W = 150,
				end_page = 8999570^8999575^ui.editlabel^ui.editcursor^{
					align = ui.alignRM(-35,0),
					backgs = ui.img("uieditor\\img\\button_huangse_right.png", ui.alignCM()),
					text = "",
				},
				home_page = 8999570^8999571^ui.editlabel^ui.editcursor^{
					align = ui.alignLM(25,0),
					backgs = ui.img("uieditor\\img\\button_huangse_left.png", ui.alignCM()),
					text = "",
				},
				next_page = 8999570^8999574^ui.editlabel^ui.editcursor^{
					align = ui.alignRM(-55,0),
					backgs = ui.img("uieditor\\img\\button_huangse_right.png", ui.alignCM()),
					text = "",
				},
				pageNodeNum = 40,
				pagenum = 8999570^8999573^ui.editlabel^{
					align = ui.alignCM(),
					text = "",
				},
				pre_page = 8999570^8999572^ui.editlabel^ui.editcursor^{
					align = ui.alignLM(45,0),
					backgs = ui.img("uieditor\\img\\button_huangse_left.png", ui.alignCM()),
					text = "",
				},
			},
			search = 8999460^8999560^ui.editinput^{
				align = ui.stretchT(-30,0,7),
				W = 150,
			},
		},
		newui = 1609015^1609031^ui^{
			w = 150,
			h = 80,
			align = ui.alignCM(),
			backgs = ui.img("uieditor\\img\\tooltip_backgs.png", ui.stretch(0,0), 'g'),
			show = false,
			btn_cancel = 1609031^1609076^ui.editcursor^{
				w = 30,
				h = 20,
				align = ui.alignRB(-30,-7),
				backgs = ui.img(ui.fonts.s11be, 0xffaaff00, ui.alignCM(), _lang"取消"),
			},
			btn_ok = 1609031^1609065^ui.editcursor^{
				w = 30,
				h = 20,
				align = ui.alignLB(17,-7),
				backgs = ui.img(ui.fonts.s11be, 0xffaaff00, ui.alignCM(), _lang"确定"),
			},
			loadname = 1609031^1609042^ui.editinput^{
				align = ui.stretchT(-30,0,3),
			},
			name = 1609031^1609053^ui.editinput^{
				align = ui.stretchT(-30,0,24),
			},
		},
		node = 1609015^1609098^ui.edittreenode^{
			h = 20,
			show = false,
			Show = 1609098^1609110^ui.editcheckbox^{
				align = ui.alignLT(202,-1),
			},
			add = 1609098^1609121^ui.editcursor^{
				w = 20,
				h = 20,
				align = ui.alignLT(250,0),
				backgs = ui.img("uieditor\\img\\addbtn_backgs.png", ui.alignLT()),
			},
			del = 1609098^1609132^ui.editcursor^{
				w = 18,
				h = 18,
				align = ui.alignLT(270,2),
				backgs = ui.img("uieditor\\img\\swindow_clobtn.png", ui.stretch(0,0)),
			},
			file = 1609098^1609143^ui.editlabel^{
				align = ui.alignLT(180,0),
				font = ui.font(ui.fonts.s9e, 0x66eeeeee, "rm"),
				text = "",
			},
			queue = 1609098^1609166^ui.editinput^{
				w = 22,
				align = ui.alignLT(295,-2),
			},
			seq = 1609098^1609155^ui.editcursor^{
				w = 20,
				h = 20,
				align = ui.alignLT(228,0),
				backgs = ui.img(ui.fonts.s11be, 0xffaaff00, ui.alignCM(), _lang"⿻"),
			},
		},
		title = 1609015^1609087^ui.editinput^{
			w = 150,
			align = ui.alignLT(0,-2),
			show = false,
		},
	},
	undo = 1608895^1608935^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignLT(15,10),
		backgs = ui.img("uieditor\\img\\jiantou_01.png", ui.stretch(0,0), 'hf'),
	},
	ungo = 1608895^1608945^ui.editcursor^{
		w = 20,
		h = 20,
		align = ui.alignLT(200,10),
		backgs = ui.img("uieditor\\img\\button_kuaijin_01.png", ui.alignCM(), 'hf'),
	},
}
ui.load("edit", 9992)
ui.new.editprop = 1^1609504^ui^{
	h = 200,
	align = ui.stretchB(0,0,200),
	backgs = {
		[1] = ui.img("uieditor\\img\\roundbg_1.png", ui.stretch(0,0), 'g'),
		[2] = ui.img("uieditor\\img\\roundbg_1.png", ui.stretch(0,0), 'g'),
	},
	show = true,
	aligns = 1609504^1609549^ui.editaligns^{
		align = ui.alignLB(16,-10),
		backgs = ui.img("uieditor\\img\\sideline_1.png", ui.stretch(14,12), 'g'),
		show = false,
	},
	front = 1609504^1609537^ui.editcheckbox^ui.edithotkey^{
		align = ui.alignLT(45,10),
		hotkey = "F",
		text = "F",
	},
	pic = 1609504^1609560^ui^{
		align = ui.stretch(-250,0,125,0),
		show = false,
		Rect = 1609560^1609695^ui.editcheckbox^{
			align = ui.alignLB(0,-5),
		},
		grid = 1609560^1609583^ui.editcheckbox^{
			align = ui.alignLT(0,10),
			text = _lang"╬",
		},
		gridb = 1609560^1609650^ui.editalignv^{
			align = ui.alignLT(50,82),
			show = false,
		},
		gridl = 1609560^1609616^ui.editalignv^{
			align = ui.alignLT(50,10),
			show = false,
		},
		gridr = 1609560^1609639^ui.editalignv^{
			align = ui.alignLT(50,60),
			show = false,
		},
		gridt = 1609560^1609628^ui.editalignv^{
			align = ui.alignLT(50,32),
			show = false,
		},
		hori = 1609560^1609594^ui.editcheckbox^{
			align = ui.alignLT(0,60),
			text = _lang"→",
		},
		qx = 1609560^1609673^ui.editalignv^{
			align = ui.alignLT(2,120),
		},
		qy = 1609560^1609684^ui.editalignv^{
			align = ui.alignLT(2,142),
		},
		rect = 1609560^1609706^ui.editinput^{
			w = 84,
			align = ui.alignLB(25,-4),
		},
		res = 1609560^1609571^ui^{
			align = ui.stretch(-120,-10,55,0),
			scrollx = 0,
			scrolly = 0,
		},
		skip = 1609560^1609661^ui.editalignv^{
			w = 25,
			align = ui.alignLT(73,131),
			show = false,
		},
		vert = 1609560^1609605^ui.editcheckbox^{
			align = ui.alignLT(0,82),
			text = _lang"↓",
		},
	},
	wh = 1609504^1609526^ui.editlabel^ui.editcursor^{
		align = ui.alignLT(90,11),
		autow = true,
		cursor = "hand",
		menu = 8999000^8999610^ui.editmenu^{
		},
	},
	white = 1609504^1609515^ui.editcheckbox^ui.edithotkey^{
		align = ui.alignLT(5,10),
		hotkey = "W",
		text = "W",
	},
}
