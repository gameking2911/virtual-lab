﻿_rd.camera.eye=_Vector3.new(0,-30,30)_rd.camera.look=_Vector3.new(0,0,0)_rd.lightMode = 2local mouse = {mousex = 0, mousey = 0}-- _rd.camera.thetaMax = 1.2-- _rd.camera.thetaMin = 0.2-- _rd.camera.radiusMin = 10-- _rd.camera.radiusMax = 45local moveFlag = false_G.CamFlag = truewhen{}function mouseMove(x,y)	if CamFlag then		if _sys:isKeyDown(_System.MouseRight) or (_sys.os ~= 'win32' and moveFlag) then			_rd.camera:movePhi(-(mouse.mousex - x) * 0.005)			_rd.camera:moveTheta(-(mouse.mousey - y) * 0.005)		end		mouse.mousex = x		mouse.mousey = y	endendwhen{}function touchBegin(x,y)	mouse.mousex = x	mouse.mousey = y	moveFlag = trueendwhen{}function touchEnd(x,y)	mouse.mousex = x	mouse.mousey = y	moveFlag = falseendwhen{}function mouseWheel(delta)	if CamFlag then			_rd.camera:moveRadius(delta * -0.1 * _rd.camera.radius)		moveFlag = false	endend