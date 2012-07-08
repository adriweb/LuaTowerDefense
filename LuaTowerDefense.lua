------------------------
---- LuaTowerDefense ---
----- Adriweb 2012 -----
---------------------------------------------------
-- TI-Planet.org and Inspired-Lua.org
-- BetterLuaAPI by Adriweb
-- Original Screen Manager by Levak
-- Highly modified version by Jim Bauwens
---------------------------------------------------
-- version 1.0

---------------------
-- Todo :
---------------------
-- attacking [animations]
-- lvl selection

-- to be saved with Luna


------------------------------------------------------------------
-- Overall Global Variables                    --
------------------------------------------------------------------

-- platform.apilevel = "1.0" -- let's try 3.2 direct compatibility

kXSize = 1 -- will get changed
kYSize = 1 -- will get changed

--
-- Uses BetterLuaAPI : https://github.com/adriweb/BetterLuaAPI-for-TI-Nspire
--

a_acute = string.uchar(225)
a_circ = string.uchar(226)
a_tilde = string.uchar(227)
a_diaer = string.uchar(228)
a_ring = string.uchar(229)
e_acute = string.uchar(233)
e_grave = string.uchar(232)
o_acute = string.uchar(243)
o_circ = string.uchar(244)
l_alpha = string.uchar(945)
l_beta = string.uchar(946)
l_omega = string.uchar(2126)
sup_plus = string.uchar(8314)
sup_minus = string.uchar(8315)
right_arrow = string.uchar(8594)

Color = {
    ["black"] = { 0, 0, 0 },
    ["red"] = { 255, 0, 0 },
    ["green"] = { 0, 255, 0 },
    ["blue"] = { 0, 0, 255 },
    ["white"] = { 255, 255, 255 },
    ["brown"] = { 165, 42, 42 },
    ["cyan"] = { 0, 255, 255 },
    ["darkblue"] = { 0, 0, 139 },
    ["darkred"] = { 139, 0, 0 },
    ["gold"] = { 255, 215, 0 },
    ["gray"] = { 127, 127, 127 },
    ["grey"] = { 127, 127, 127 },
    ["lightblue"] = { 173, 216, 230 },
    ["lightgreen"] = { 144, 238, 144 },
    ["magenta"] = { 255, 0, 255 },
    ["maroon"] = { 128, 0, 0 },
    ["navyblue"] = { 159, 175, 223 },
    ["orange"] = { 255, 165, 0 },
    ["pink"] = { 255, 192, 203 },
    ["purple"] = { 128, 0, 128 },
    ["royalblue"] = { 65, 105, 225 },
    ["silver"] = { 192, 192, 192 },
    ["violet"] = { 238, 130, 238 },
    ["yellow"] = { 255, 255, 0 }
}
Color.mt = { __index = function() return { 0, 0, 0 } end }
setmetatable(Color, Color.mt)

function copyTable(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function mergeTable(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

function deepcopy(t) -- This function recursively copies a table's contents, and ensures that metatables are preserved. That is, it will correctly clone a pure Lua object.
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            v = deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res, mt)
    return res
end

-- from http://snippets.luacode.org/snippets/Deep_copy_of_a_Lua_Table_2

function utf8(nbr)
    return string.uchar(nbr)
end

function test(arg)
    return arg and 1 or 0
end

function screenRefresh()
    return platform.window:invalidate()
end

function pww()
    return platform.window:width()
end

function pwh()
    return platform.window:height()
end

function drawPoint(gc, x, y)
    gc:fillRect(x, y, 1, 1)
end

function drawCircle(gc, x, y, diam)
    gc:drawArc(x, y, diam, diam, 0, 360)
end

function fillCircle(gc, x, y, diam)
    gc:fillArc(x, y, diam, diam, 0, 360)
end


function drawCenteredString(gc, str)
    gc:drawString(str, .5 * (pww() - gc:getStringWidth(str)), .5 * pwh(), "middle")
end

function drawXCenteredString(gc, str, y)
    gc:drawString(str, .5 * (pww() - gc:getStringWidth(str)), y, "top")
end

function setColor(gc, theColor)
    if type(theColor) == "string" then
        theColor = string.lower(theColor)
        if type(Color[theColor]) == "table" then gc:setColorRGB(unpack(Color[theColor])) end
    elseif type(theColor) == "table" then
        gc:setColorRGB(unpack(theColor))
    end
end

function verticalBar(gc, x)
    gc:fillRect(x, 0, 1, pwh())
end

function horizontalBar(gc, y)
    gc:fillRect(0, y, pww(), 1)
end

function nativeBar(gc, screen, y)
	gc:setColorRGB(128,128,128)
	gc:fillRect(screen.x+5, screen.y+y, screen.w-10, 2)
end

function drawSquare(gc, x, y, l)
    gc:drawPolyLine({ (x - l / 2), (y - l / 2), (x + l / 2), (y - l / 2), (x + l / 2), (y + l / 2), (x - l / 2), (y + l / 2), (x - l / 2), (y - l / 2) })
end

function drawRoundRect(gc, x, y, wd, ht, rd) -- wd = width, ht = height, rd = radius of the rounded corner
    x = x - wd / 2 -- let the center of the square be the origin (x coord)
    y = y - ht / 2 -- same for y coord
    if rd > ht / 2 then rd = ht / 2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max rd)
    gc:drawLine(x + rd, y, x + wd - (rd), y);
    gc:drawArc(x + wd - (rd * 2), y + ht - (rd * 2), rd * 2, rd * 2, 270, 90);
    gc:drawLine(x + wd, y + rd, x + wd, y + ht - (rd));
    gc:drawArc(x + wd - (rd * 2), y, rd * 2, rd * 2, 0, 90);
    gc:drawLine(x + wd - (rd), y + ht, x + rd, y + ht);
    gc:drawArc(x, y, rd * 2, rd * 2, 90, 90);
    gc:drawLine(x, y + ht - (rd), x, y + rd);
    gc:drawArc(x, y + ht - (rd * 2), rd * 2, rd * 2, 180, 90);
end

function fillRoundRect(gc, x, y, wd, ht, radius) -- wd = width and ht = height -- renders badly when transparency (alpha) is not at maximum >< will re-code later
    if radius > ht / 2 then radius = ht / 2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max radius)
    gc:fillPolygon({ (x - wd / 2), (y - ht / 2 + radius), (x + wd / 2), (y - ht / 2 + radius), (x + wd / 2), (y + ht / 2 - radius), (x - wd / 2), (y + ht / 2 - radius), (x - wd / 2), (y - ht / 2 + radius) })
    gc:fillPolygon({ (x - wd / 2 - radius + 1), (y - ht / 2), (x + wd / 2 - radius + 1), (y - ht / 2), (x + wd / 2 - radius + 1), (y + ht / 2), (x - wd / 2 + radius), (y + ht / 2), (x - wd / 2 + radius), (y - ht / 2) })
    x = x - wd / 2 -- let the center of the square be the origin (x coord)
    y = y - ht / 2 -- same
    gc:fillArc(x + wd - (radius * 2), y + ht - (radius * 2), radius * 2, radius * 2, 1, -91);
    gc:fillArc(x + wd - (radius * 2), y, radius * 2, radius * 2, -2, 91);
    gc:fillArc(x, y, radius * 2, radius * 2, 85, 95);
    gc:fillArc(x, y + ht - (radius * 2), radius * 2, radius * 2, 180, 95);
end

function drawLinearGradient(gc, color1, color2)
    -- syntax would be : color1 and color2 as {r,g,b}.
    -- don't really know how to do that. probably converting to hue/saturation/light mode and change the hue.
    -- todo with unpack(color1) and unpack(color2)
end

function bigText(gc)
    gc:setFont("serif", "b", 18)
end

function normalText(gc)
    gc:setFont("sansserif", "r", 12)
end





stdout	= print

function pprint(...)
	stdout(...)
	local out	= ""
	for _,v in ipairs({...}) do 
		out	=	out .. (_==1 and "" or "    ") .. tostring(v)
	end
	var.store("print", out)
end


function Pr(n, d, s, ex)
	local nc	= tonumber(n)
	if nc and nc<math.abs(nc) then
		return s-ex-(type(n)== "number" and math.abs(n) or (.01*s*math.abs(nc)))
	else
		return (type(n)=="number" and n or (type(n)=="string" and .01*s*nc or d))
	end
end

-- Apply an extension on a class, and return our new frankenstein 
function addExtension(oldclass, extension)
	local newclass	= class(oldclass)
	for key, data in pairs(extension) do
		newclass[key]	= data
	end
	return newclass
end

clipRectData	= {}

function gc_clipRect(gc, what, x, y, w, h)
	if what == "set" and clipRectData.current then
		clipRectData.old	= clipRectData.current
		
	elseif what == "subset" and clipRectData.current then
		clipRectData.old	= clipRectData.current
		x	= clipRectData.old.x<x and x or clipRectData.old.x
		y	= clipRectData.old.y<y and y or clipRectData.old.y
		h	= clipRectData.old.y+clipRectData.old.h > y+h and h or clipRectData.old.y+clipRectData.old.h-y
		w	= clipRectData.old.x+clipRectData.old.w > x+w and w or clipRectData.old.x+clipRectData.old.w-x
		what = "set"
		
	elseif what == "restore" and clipRectData.old then
		--gc:clipRect("reset")
		what = "set"
		x	= clipRectData.old.x
		y	= clipRectData.old.y
		h	= clipRectData.old.h
		w	= clipRectData.old.w
	elseif what == "restore" then
		what = "reset"
	end
	
	gc:clipRect(what, x, y, w, h)
	if x and y and w and h then clipRectData.current = {x=x,y=y,w=w,h=h} end
end

------------------------------------------------------------------
--                        Screen  Class                         --
------------------------------------------------------------------

Screen	=	class()

Screens	=	{}

function push_screen(screen, ...)
	current_screen():screenLoseFocus()
	table.insert(Screens, screen)
	platform.window:invalidate()
	current_screen():pushed(...)
end

function only_screen(screen, ...)
	current_screen():screenLoseFocus()
	Screens	=	{screen}
	platform.window:invalidate()
	screen:pushed(...)	
end

function remove_screen(...)
	platform.window:invalidate()
	current_screen():removed(...)
	res=table.remove(Screens)
	current_screen():screenGetFocus()
	return res
end

function current_screen()
	return Screens[#Screens] or DummyScreen
end

function Screen:init(xx,yy,ww,hh)
	self.yy	=	yy
	self.xx	=	xx
	self.hh	=	hh
	self.ww	=	ww
	
	
	self:ext()
	self:size(0)
end

function Screen:ext()
end

function Screen:size()
	local screenH	=	platform.window:height()
	local screenW	=	platform.window:width()

	if screenH	== 0 then screenH=212 end
	if screenW	== 0 then screenW=318 end

	self.x	=	math.floor(Pr(self.xx, 0, screenW)+.5)
	self.y	=	math.floor(Pr(self.yy, 0, screenH)+.5)
	self.w	=	math.floor(Pr(self.ww, screenW, screenW, 0)+.5)
	self.h	=	math.floor(Pr(self.hh, screenH, screenH, 0)+.5)
end


function Screen:pushed() end
function Screen:removed() end
function Screen:screenLoseFocus() end
function Screen:screenGetFocus() end

function Screen:resize(x,y) end

function Screen:draw(gc)
	self:size()
	self:paint(gc)
end

function Screen:paint(gc) end

function Screen:invalidate()
	platform.window:invalidate(self.x ,self.y , self.w, self.h)
end

function Screen:arrowKey()	end
function Screen:enterKey()	end
function Screen:backspaceKey()	end
function Screen:escapeKey()	end
function Screen:tabKey()	end
function Screen:backtabKey()	end
function Screen:charIn(char)	end
function Screen:timer() end
function Screen:mouseDown()	end
function Screen:mouseUp()	end
function Screen:mouseMove()	end
function Screen:contextMenu()	end

function Screen:appended() end

function Screen:destroy()
	self	= nil
end

------------------------------------------------------------------
--                   WidgetManager Extension                    --
------------------------------------------------------------------

WidgetManager	= {}

function WidgetManager:ext()
	self.widgets	=	{}
	self.focus	=	0
end

function WidgetManager:appendWidget(widget, xx, yy) 
	widget.xx	=	xx
	widget.yy	=	yy
	widget.parent	=	self
	widget:size()
	
	table.insert(self.widgets, widget)
	widget.pid	=	#self.widgets
	
	widget:appended(self)
	return self
end

function WidgetManager:getWidget()
	return self.widgets[self.focus]
end

function WidgetManager:drawWidgets(gc) 
	for _, widget in pairs(self.widgets) do
		widget:size()
		widget:draw(gc)
		
		gc:setColorRGB(0,0,0)
	end
end

function WidgetManager:postPaint(gc) 
end

function WidgetManager:draw(gc)
	self:size()
	self:paint(gc)
	self:drawWidgets(gc)
	self:postPaint(gc)
end


function WidgetManager:loop(n) end

function WidgetManager:stealFocus(n)
	local oldfocus=self.focus
	if oldfocus~=0 then
		local veto	= self:getWidget():loseFocus(n)
		if veto == -1 then
			return -1, oldfocus
		end
		self:getWidget().hasFocus	=	false
		self.focus	= 0
	end
	return 0, oldfocus
end

function WidgetManager:focusChange() end

function WidgetManager:switchFocus(n, b)
	if n~=0 and #self.widgets>0 then
		local veto, focus	= self:stealFocus(n)
		if veto == -1 then
			return -1
		end
		
		local looped
		self.focus	=	focus + n
		if self.focus>#self.widgets then
			self.focus	=	1
			looped	= true
		elseif self.focus<1 then
			self.focus	=	#self.widgets
			looped	= true
		end	
		if looped and self.noloop and not b then
			self.focus	= focus
			self:loop(n)
		else
			self:getWidget().hasFocus	=	true	
			self:getWidget():getFocus(n)
		end
	end
	self:focusChange()
end


function WidgetManager:arrowKey(arrow)	
	if self.focus~=0 then
		self:getWidget():arrowKey(arrow)
	end
	self:invalidate()
end

function WidgetManager:enterKey()	
	if self.focus~=0 then
		self:getWidget():enterKey()
	end
	self:invalidate()
end

function WidgetManager:backspaceKey()
	if self.focus~=0 then
		self:getWidget():backspaceKey()
	end
	self:invalidate()
end

function WidgetManager:escapeKey()	
	if self.focus~=0 then
		self:getWidget():escapeKey()
	end
	self:invalidate()
end

function WidgetManager:tabKey()	
	self:switchFocus(1)
	self:invalidate()
end

function WidgetManager:backtabKey()	
	self:switchFocus(-1)
	self:invalidate()
end

function WidgetManager:charIn(char)
	if self.focus~=0 then
		self:getWidget():charIn(char)
	end
	self:invalidate()
end

function WidgetManager:getWidgetIn(x, y)
	for n, widget in pairs(self.widgets) do
		local wox	= widget.ox or 0
		local woy	= widget.oy or 0
		if x>=widget.x-wox and y>=widget.y-wox and x<widget.x+widget.w-wox and y<widget.y+widget.h-woy then
			return n, widget
		end
	end 
end

function WidgetManager:mouseDown(x, y) 
	local n, widget	=	self:getWidgetIn(x, y)
	if n then
		if self.focus~=0 and self.focus~=n then self:getWidget().hasFocus = false self:getWidget():loseFocus()  end
		self.focus	=	n
		
		widget.hasFocus	=	true
		widget:getFocus()

		widget:mouseDown(x, y)
		self:focusChange()
	else
		if self.focus~=0 then self:getWidget().hasFocus = false self:getWidget():loseFocus() end
		self.focus	=	0
	end
end

function WidgetManager:mouseUp(x, y)
	if self.focus~=0 then
		self:getWidget():mouseUp(x, y)
	end
	self:invalidate()
end
function WidgetManager:mouseMove(x, y)
	if self.focus~=0 then
		self:getWidget():mouseMove(x, y)
	end
end

--------------------------
-- Our new frankenstein --
--------------------------

WScreen	= addExtension(Screen, WidgetManager)



--Dialog screen

Dialog	=	class(WScreen)

function Dialog:init(title,xx,yy,ww,hh)
	self.yy	=	yy
	self.xx	=	xx
	self.hh	=	hh
	self.ww	=	ww
	self.title	=	title
	self:size()
	
	self.widgets	=	{}
	self.focus	=	0
end


function Dialog:paint(gc)
	self.xx	= (pww()-self.w)/2
	self.yy	= (pwh()-self.h)/2
	self.x, self.y	= self.xx, self.yy
	
	gc:setFont("sansserif","r",10)
	gc:setColorRGB(224,224,224)
	gc:fillRect(self.x, self.y, self.w, self.h)

	for i=1, 14,2 do
		gc:setColorRGB(32+i*3, 32+i*4, 32+i*3)
		gc:fillRect(self.x, self.y+i, self.w,2)
	end
	gc:setColorRGB(32+16*3, 32+16*4, 32+16*3)
	gc:fillRect(self.x, self.y+15, self.w, 10)
	
	gc:setColorRGB(128,128,128)
	gc:drawRect(self.x, self.y, self.w, self.h)
	gc:drawRect(self.x-1, self.y-1, self.w+2, self.h+2)
	
	gc:setColorRGB(96,100,96)
	gc:fillRect(self.x+self.w+1, self.y, 1, self.h+2)
	gc:fillRect(self.x, self.y+self.h+2, self.w+3, 1)
	
	gc:setColorRGB(104,108,104)
	gc:fillRect(self.x+self.w+2, self.y+1, 1, self.h+2)
	gc:fillRect(self.x+1, self.y+self.h+3, self.w+3, 1)
	gc:fillRect(self.x+self.w+3, self.y+2, 1, self.h+2)
	gc:fillRect(self.x+2, self.y+self.h+4, self.w+2, 1)
			
	gc:setColorRGB(255,255,255)
	gc:drawString(self.title, self.x + 4, self.y+2, "top")
	
	self:postPaint(gc)
end

function Dialog:postPaint() end

--[[
function Dialog:grabDown(x,y) 
    print("grabDown")
    self.isGrabbing = not self.isGrabbing
end
 
function Dialog:mouseUp(x,y)
    cursor.set("default") 
    self.isGrabbing = false 
end
 
function Dialog:mouseDown(x,y)
    if x>self.x and x<(self.x+self.w) and y>self.y and y<(self.y+26) then
        self.isGrabbing = true
    end
end
 
function Dialog:mouseMove(x,y)
    if self.isGrabbing then
        cursor.set("drag grab")
        self.x = x
        self.y = y
    else
        if x>self.x and x<(self.x+self.w) and y>self.y and y<(self.y+26) then
            cursor.set("hand pointer")
        else
            cursor.set("default")
        end
    end
end ]]--





---
-- The dummy screen
---

DummyScreen	= Screen()



function uCol(col)
	return col[1] or 0, col[2] or 0, col[3] or 0
end

function textLim(gc, text, max)
	local ttext, out = "",""
	local width	= gc:getStringWidth(text)
	if width<max then
		return text, width
	else
		for i=1, #text do
			ttext	= text:usub(1, i)
			if gc:getStringWidth(ttext .. "..")>max then
				break
			end
			out = ttext
		end
		return out .. "..", gc:getStringWidth(out .. "..")
	end
end


------------------------------------------------------------------
--                        Widget  Class                         --
------------------------------------------------------------------

Widget	=	class(Screen)

function Widget:init()
	self.dw	=	10
	self.dh	=	10
	
	self:ext()
end

function Widget:setSize(w, h)
	self.ww	= w or self.ww
	self.hh	= h or self.hh
end

function Widget:setPos(x, y)
	self.xx	= x or self.xx
	self.yy	= y or self.yy
end

function Widget:size(n)
	if n then return end
	self.w	=	math.floor(Pr(self.ww, self.dw, self.parent.w, 0)+.5)
	self.h	=	math.floor(Pr(self.hh, self.dh, self.parent.h, 0)+.5)
	
	self.rx	=	math.floor(Pr(self.xx, 0, self.parent.w, self.w)+.5)
	self.ry	=	math.floor(Pr(self.yy, 0, self.parent.h, self.h)+.5)
	self.x	=	self.parent.x + self.rx
	self.y	=	self.parent.y + self.ry
end

function Widget:giveFocus()
	if self.parent.focus~=0 then
		local veto	= self.parent:stealFocus()
		if veto == -1 then
			return -1
		end		
	end
	
	self.hasFocus	=	true
	self.parent.focus	=	self.pid
	self:getFocus()
end

function Widget:getFocus() end
function Widget:loseFocus() end
function Widget:enterKey() 
	self.parent:switchFocus(1)
end
function Widget:arrowKey(arrow)
	if arrow=="up" then 
		self.parent:switchFocus(self.focusUp or -1)
	elseif arrow=="down"  then
		self.parent:switchFocus(self.focusDown or 1)
	elseif arrow=="left" then 
		self.parent:switchFocus(self.focusLeft or -1)
	elseif arrow=="right"  then
		self.parent:switchFocus(self.focusRight or 1)	
	end
end


WWidget	= addExtension(Widget, WidgetManager)


------------------------------------------------------------------
--                        Sample Widget                         --
------------------------------------------------------------------

-- First, create a new class based on Widget
box	=	class(Widget)

-- Init. You should define self.dh and self.dw, in case the user doesn't supply correct width/height values.
-- self.ww and self.hh can be a number or a string. If it's a number, the width will be that amount of pixels.
-- If it's a string, it will be interpreted as % of the parent screen size.
-- These values will be used to calculate self.w and self.h (don't write to this, it will overwritten everytime the widget get's painted)
-- self.xx and self.yy will be set when appending the widget to a screen. This value support the same % method (in a string)
-- They will be used to calculate self.x and self.h 
function box:init(ww,hh,t)
	self.dh	= 10
	self.dw	= 10
	self.ww	= ww
	self.hh	= hh
	self.t	= t
end

-- Paint. Here you can paint your widget stuff
-- Variable you can use:
-- self.x, self.y	: numbers, x and y coordinates of the widget relative to screen. So it's the actual pixel position on the screen.
-- self.w, self.h	: numbers, w and h of widget
-- many others

function box:paint(gc)
	gc:setColorRGB(0,0,0)
	
	-- Do I have focus?
	if self.hasFocus then
		-- Yes, draw a filled black square
		gc:fillRect(self.x, self.y, self.w, self.h)
	else
		-- No, draw only the outline
		gc:drawRect(self.x, self.y, self.w, self.h)
	end
	
	gc:setColorRGB(128,128,128)
	if self.t then
		gc:drawString(self.t,self.x+2,self.y+2,"top")
	end
end


------------------------------------------------------------------
--                         Input Widget                         --
------------------------------------------------------------------


sInput	=	class(Widget)

function sInput:init()
	self.dw	=	100
	self.dh	=	20
	
	self.value	=	""	
	self.bgcolor	=	{255,255,255}
	self.disabledcolor	= {128,128,128}
	self.font	=	{"sansserif", "r", 10}
	self.disabled	= false
end

function sInput:paint(gc)
	self.gc	=	gc
	local x	=	self.x
	local y = 	self.y
	
	gc:setFont(uCol(self.font))
	gc:setColorRGB(uCol(self.bgcolor))
	gc:fillRect(x, y, self.w, self.h)

	gc:setColorRGB(0,0,0)
	gc:drawRect(x, y, self.w, self.h)
	
	if self.hasFocus then
		gc:drawRect(x-1, y-1, self.w+2, self.h+2)
	end
		
	local text	=	self.value
	local	p	=	0
	
	
	gc_clipRect(gc, "subset", x, y, self.w, self.h)
	
	--[[
	while true do
		if p==#self.value then break end
		p	=	p + 1
		text	=	self.value:sub(-p, -p) .. text
		if gc:getStringWidth(text) > (self.w - 8) then
			text	=	text:sub(2,-1)
			break 
		end
	end
	--]]
	
	if self.disabled or self.value == "" then
		gc:setColorRGB(uCol(self.disabledcolor))
	end
	if self.value == ""  then
		text	= self.placeholder or ""
	end
	
	local strwidth = gc:getStringWidth(text)
	
	if strwidth<self.w-4 or not self.hasFocus then
		gc:drawString(text, x+2, y+1, "top")
	else
		gc:drawString(text, x-4+self.w-strwidth, y+1, "top")
	end
	
	if self.hasFocus and self.value ~= "" then
		gc:fillRect(self.x+(text==self.value and strwidth+2 or self.w-4), self.y, 1, self.h)
	end
	
	gc_clipRect(gc, "restore")
end

function sInput:charIn(char)
	if self.disabled or (self.number and not tonumber(self.value .. char)) then --or char~="," then
		return
	end
	--char = (char == ",") and "." or char
	self.value	=	self.value .. char
end

function sInput:backspaceKey()
	if not self.disabled then
		self.value	=	self.value:usub(1,-2)
	end
end

function sInput:enable()
	self.disabled	= false
end

function sInput:disable()
	self.disabled	= true
end




------------------------------------------------------------------
--                         Label Widget                         --
------------------------------------------------------------------

sLabel	=	class(Widget)

function sLabel:init(text, widget)
	self.widget	=	widget
	self.text	=	text
	self.ww		=	30
	
	self.hh		=	20
	self.lim	=	false
	self.color	=	{0,0,0}
	self.font	=	{"sansserif", "r", 10}
	self.p		=	"top"
	
end

function sLabel:paint(gc)
	gc:setFont(uCol(self.font))
	gc:setColorRGB(uCol(self.color))
	
	local text	=	""
	local ttext
	if self.lim then
		text, self.dw	= textLim(gc, self.text, self.w)
	else
		text = self.text
	end
	
	gc:drawString(text, self.x, self.y, self.p)
end

function sLabel:getFocus(n)
	if n then
		n	= n < 0 and -1 or (n > 0 and 1 or 0)
	end
	
	if self.widget and not n then
		self.widget:giveFocus()
	elseif n then
		self.parent:switchFocus(n)
	end
end


------------------------------------------------------------------
--                        Button Widget                         --
------------------------------------------------------------------

sButton	=	class(Widget)

function sButton:init(text, action)
	self.text	=	text
	self.action	=	action
	
	self.dh	=	27
	self.dw	=	48
		
	self.bordercolor	=	{136,136,136}
	self.font	=	{"sansserif", "r", 10}
	
end

function sButton:paint(gc)
	gc:setFont(uCol(self.font))
	self.ww	=	gc:getStringWidth(self.text)+8
	self:size()

	gc:setColorRGB(248,252,248)
	gc:fillRect(self.x+2, self.y+2, self.w-4, self.h-4)
	gc:setColorRGB(0,0,0)
	
	gc:drawString(self.text, self.x+4, self.y+4, "top")
		
	gc:setColorRGB(uCol(self.bordercolor))
	gc:fillRect(self.x + 2, self.y, self.w-4, 2)
	gc:fillRect(self.x + 2, self.y+self.h-2, self.w-4, 2)
	
	gc:fillRect(self.x, self.y+2, 1, self.h-4)
	gc:fillRect(self.x+1, self.y+1, 1, self.h-2)
	gc:fillRect(self.x+self.w-1, self.y+2, 1, self.h-4)
	gc:fillRect(self.x+self.w-2, self.y+1, 1, self.h-2)
	
	if self.hasFocus then
		gc:setColorRGB(40, 148, 184)
		gc:drawRect(self.x-2, self.y-2, self.w+3, self.h+3)
		gc:drawRect(self.x-3, self.y-3, self.w+5, self.h+5)
	end
end

function sButton:enterKey()
	if self.action then self.action() end
end

sButton.mouseUp	=	sButton.enterKey


------------------------------------------------------------------
--                      Scrollbar Widget                        --
------------------------------------------------------------------


scrollBar	= class(Widget)

scrollBar.upButton=image.new("\011\0\0\0\010\0\0\0\0\0\0\0\022\0\0\0\016\0\001\0001\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\198\255\255\255\255\255\255\255\255\156\243\255\255\255\255\255\255\255\2551\1981\198\255\255\255\255\255\255\214\218\0\128\214\218\255\255\255\255\255\2551\1981\198\255\255\255\255\247\222B\136\0\128B\136\247\222\255\255\255\2551\1981\198\255\255\247\222B\136!\132\0\128!\132B\136\247\222\255\2551\1981\198\247\222B\136!\132B\136R\202B\136!\132B\136\247\2221\1981\198\132\144B\136B\136\247\222\255\255\247\222B\136B\136\132\1441\1981\198\156\243\132\144\247\222\255\255\255\255\255\255\247\222\132\144\189\2471\1981\198\255\255\222\251\255\255\255\255\255\255\255\255\255\255\222\251\255\2551\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\198")
scrollBar.downButton=image.new("\011\0\0\0\010\0\0\0\0\0\0\0\022\0\0\0\016\0\001\0001\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\198\255\255\222\251\255\255\255\255\255\255\255\255\255\255\222\251\255\2551\1981\198\156\243\132\144\247\222\255\255\255\255\255\255\247\222\132\144\189\2471\1981\198\132\144B\136B\136\247\222\255\255\247\222B\136B\136\132\1441\1981\198\247\222B\136!\132B\136R\202B\136!\132B\136\247\2221\1981\198\255\255\247\222B\136!\132\0\128!\132B\136\247\222\255\2551\1981\198\255\255\255\255\247\222B\136\0\128B\136\247\222\255\255\255\2551\1981\198\255\255\255\255\255\255\214\218\0\128\214\218\255\255\255\255\255\2551\1981\198\255\255\255\255\255\255\255\255\156\243\255\255\255\255\255\255\255\2551\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\1981\198")

function scrollBar:init(h, top, visible, total)
	self.color1	= {96, 100, 96}
	self.color2	= {184, 184, 184}
	
	self.hh	= h or 100
	self.ww = 14
	
	self.visible = visible or 10
	self.total   = total   or 15
	self.top     = top     or 4
end

function scrollBar:paint(gc)
	gc:setColorRGB(255,255,255)
	gc:fillRect(self.x+1, self.y+1, self.w-1, self.h-1)
	
	gc:drawImage(self.upButton  , self.x+2, self.y+2)
	gc:drawImage(self.downButton, self.x+2, self.y+self.h-11)
	gc:setColorRGB(uCol(self.color1))
	if self.h > 28 then
		gc:drawRect(self.x + 3, self.y + 14, 8, self.h - 28)
	end
	
	if self.visible<self.total then
		local step	= (self.h-26)/self.total
		gc:fillRect(self.x + 3, self.y + 14  + step*self.top, 9, step*self.visible)
		gc:setColorRGB(uCol(self.color2))
		gc:fillRect(self.x + 2 , self.y + 14 + step*self.top, 1, step*self.visible)
		gc:fillRect(self.x + 12, self.y + 14 + step*self.top, 1, step*self.visible)
	end
end

function scrollBar:update(top, visible, total)
	self.top      = top     or self.top
	self.visible  = visible or self.visible
	self.total    = total   or self.total
end

function scrollBar:action(top) end

function scrollBar:mouseUp(x, y)
	local upX	= self.x+2
	local upY	= self.y+2
	local downX	= self.x+2
	local downY	= self.y+self.h-11
	local butH	= 10
	local butW	= 11
	
	if x>=upX and x<upX+butW and y>=upY and y<upY+butH and self.top>0 then
		self.top	= self.top-1
		self:action(self.top)
	elseif x>=downX and x<downX+butW and y>=downY and y<downY+butH and self.top<self.total-self.visible then
		self.top	= self.top+1
		self:action(self.top)
	end
end

function scrollBar:getFocus(n)
	if n==-1 or n==1 then
		self.parent:switchFocus(n)
	end
end


------------------------------------------------------------------
--                         List Widget                          --
------------------------------------------------------------------

sList	= class(WWidget)

function sList:init()
	Widget.init(self)
	self.dw	= 150
	self.dh	= 153

	self.ih	= 18

	self.top	= 0
	self.sel	= 1
	
	self.font	= {"sansserif", "r", 10}
	self.colors	= {50,150,190}
	self.items	= {}
end

function sList:appended()
	self.scrollBar	= scrollBar("100", self.top, #self.items,#self.items)
	self:appendWidget(self.scrollBar, -1, 0)
	
	function self.scrollBar:action(top)
		self.parent.top	= top
	end
end


function sList:paint(gc)
	local x	= self.x
	local y	= self.y
	local w	= self.w
	local h	= self.h
	
	
	local ih	= self.ih   
	local top	= self.top		
	local sel	= self.sel		
		      
	local items	= self.items			
	local visible_items	= math.floor(h/ih)	
	gc:setColorRGB(255, 255, 255)
	gc:fillRect(x, y, w, h)
	gc:setColorRGB(0, 0, 0)
	gc:drawRect(x, y, w, h)
	gc_clipRect(gc, "set", x, y, w, h)
	gc:setFont(unpack(self.font))

	
	
	local label, item
	for i=1, math.min(#items-top, visible_items+1) do
		item	= items[i+top]
		label	= textLim(gc, item, w-(5 + 12 + 2 + 1))
		
		if i+top == sel then
			gc:setColorRGB(unpack(self.colors))
			gc:fillRect(x+1, y + i*ih-ih + 1, w-(12 + 2 + 2), ih)
			
			gc:setColorRGB(255, 255, 255)
		end
		
		gc:drawString(label, x+5, y + i*ih-ih , "top")
		gc:setColorRGB(0, 0, 0)
	end
	
	self.scrollBar:update(top, visible_items, #items)
	
	gc_clipRect(gc, "reset")
end

function sList:arrowKey(arrow)	
	if arrow=="up" and self.sel>1 then
		self.sel	= self.sel - 1
		self:change(self.sel, self.items[self.sel])
		if self.top>=self.sel then
			self.top	= self.top - 1
		end
	end

	if arrow=="down" and self.sel<#self.items then
		self.sel	= self.sel + 1
		self:change(self.sel, self.items[self.sel])
		if self.sel>(self.h/self.ih)+self.top then
			self.top	= self.top + 1
		end
	end
end


function sList:mouseUp(x, y)
	if x>=self.x and x<self.x+self.w-16 and y>=self.y and y<self.y+self.h then
		
		local sel	= math.floor((y-self.y)/self.ih) + 1 + self.top
		if sel==self.sel then
			self:enterKey()
			return
		end
		if self.items[sel] then
			self.sel=sel
			self:change(self.sel, self.items[self.sel])
		else
			return
		end
		
		if self.sel>(self.h/self.ih)+self.top then
			self.top	= self.top + 1
		end
		if self.top>=self.sel then
			self.top	= self.top - 1
		end
						
	end 
	self.scrollBar:mouseUp(x, y)
end


function sList:enterKey()
	if self.items[self.sel] then
		self:action(self.sel, self.items[self.sel])
	end
end


function sList:change() end
function sList:action() end

function sList:reset()
	self.sel	= 1
	self.top	= 0
end

------------------------------------------------------------------
--                        Screen Widget                         --
------------------------------------------------------------------

sScreen	= class(WWidget)

function sScreen:init(w, h)
	Widget.init(self)
	self.ww	= w
	self.hh	= h
	self.oy	= 0
	self.ox	= 0
	self.noloop	= true
end

function sScreen:appended()
	self.oy	= 0
	self.ox	= 0
end

function sScreen:paint(gc)
	gc_clipRect(gc, "set", self.x, self.y, self.w, self.h)
	self.x	= self.x + self.ox
	self.y	= self.y + self.oy
end

function sScreen:postPaint(gc)
	gc_clipRect(gc, "reset")
end

function sScreen:setY(y)
	self.oy	= y or self.oy
end
						
function sScreen:setX(x)
	self.ox	= x or self.ox
end

function sScreen:showWidget()
	local w	= self:getWidget()
	if not w then print("bye") return end
	local y	= self.y - self.oy
	local wy = w.y - self.oy
	
	if w.y-2 < y then
		print("Moving up")
		self:setY(-(wy-y)+4)
	elseif w.y+w.h > y+self.h then
		print("moving down")
		self:setY(-(wy-(y+self.h)+w.h+2))
	end
	
	if self.focus == 1 then
		self:setY(0)
	end
end

function sScreen:getFocus(n)
	if n==-1 or n==1 then
		self:stealFocus()
		self:switchFocus(n, true)
	end
end

function sScreen:loop(n)
	self.parent:switchFocus(n)
	self:showWidget()
end

function sScreen:focusChange()
	self:showWidget()
end

function sScreen:loseFocus(n)
	if n and ((n >= 1 and self.focus+n<=#self.widgets) or (n <= -1 and self.focus+n>=1)) then
		self:switchFocus(n)
		return -1
	else
		self:stealFocus()
	end
	
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

sDropdown	=	class(Widget)


function sDropdown:init(items)
	self.dh	= 21
	self.dw	= 75
	self.screen	= WScreen()
	self.sList	= sList()
	self.sList.items	= items or {}
	self.screen:appendWidget(self.sList,0,0)
	self.sList.action	= self.listAction
	self.sList.loseFocus	= self.screenEscape
	self.sList.change	= self.listChange
	self.screen.escapeKey	= self.screenEscape
	self.lak	= self.sList.arrowKey	
	self.sList.arrowKey	= self.listArrowKey
	self.value	= items[1] or ""
	self.valuen	= #items>0 and 1 or 0
	self.rvalue	= items[1] or ""
	self.rvaluen=self.valuen
	
	self.sList.parentWidget = self
	self.screen.parentWidget = self
	--self.screen.focus=1
end

function sDropdown:screenpaint(gc)
	gc:setColorRGB(255,255,255)
	gc:fillRect(self.x, self.y, self.h, self.w)
	gc:setColorRGB(0,0,0)
	gc:drawRect(self.x, self.y, self.h, self.w)
end

function sDropdown:mouseDown()
	self:open()
end


sDropdown.img = image.new("\14\0\0\0\7\0\0\0\0\0\0\0\28\0\0\0\16\0\1\000{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239al{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239{\239alalal{\239{\239\255\255\255\255\255\255\255\255\255\255\255\255{\239{\239alalalalal{\239{\239\255\255\255\255\255\255\255\255{\239{\239alalalalalalal{\239{\239\255\255\255\255{\239{\239alalalalalalalalal{\239{\239{\239{\239alalalalalalalalalalal{\239{\239alalalalalal")

function sDropdown:arrowKey(arrow)	
	if arrow=="up" then
		self.parent:switchFocus(self.focusUp or -1)
	elseif arrow=="down" then
		self.parent:switchFocus(self.focusDown or 1)
	elseif arrow=="left" then 
		self.parent:switchFocus(self.focusLeft or -1)
	elseif arrow == "right" then
		self:open()
	end
end

function sDropdown:listArrowKey(arrow)
	if arrow == "left" then
		self:loseFocus()
	else
		self.parentWidget.lak(self, arrow)
	end
end

function sDropdown:listChange(a, b)
	self.parentWidget.value  = b
	self.parentWidget.valuen = a
end

function sDropdown:open()
	self.screen.yy	= self.y+self.h
	self.screen.xx	= self.x-1
	self.screen.ww	= self.w + 13
	local h = 2+(18*#self.sList.items)
	
	local py	= self.parent.oy and self.parent.y-self.parent.oy or self.parent.y
	local ph	= self.parent.h
	
	self.screen.hh	= self.y+self.h+h>ph+py-10 and ph-py-self.y-self.h-10 or h
	if self.y+self.h+h>ph+py-10  and self.screen.hh<40 then
		self.screen.hh = h < self.y and h or self.y-5
		self.screen.yy = self.y-self.screen.hh
	end
	
	self.sList.ww = self.w + 13
	self.sList.hh = self.screen.hh-2
	self.sList.yy =self.sList.yy+1
	self.sList:giveFocus()
	push_screen(self.screen)
end

function sDropdown:listAction(a,b)
	self.parentWidget.value  = b
	self.parentWidget.valuen = a
	self.parentWidget.rvalue  = b
	self.parentWidget.rvaluen = a
	self.parentWidget:change(a, b)
	remove_screen()
end

function sDropdown:change() end

function sDropdown:screenEscape()
	self.parentWidget.sList.sel = self.parentWidget.rvaluen
	self.parentWidget.value	= self.parentWidget.rvalue
	if current_screen() == self.parentWidget.screen then
		remove_screen()
	end
end

function sDropdown:paint(gc)
	gc:setColorRGB(255, 255, 255)
	gc:fillRect(self.x, self.y, self.w-1, self.h-1)
	
	gc:setColorRGB(0,0,0)
	gc:drawRect(self.x, self.y, self.w-1, self.h-1)
	
	if self.hasFocus then
		gc:drawRect(self.x-1, self.y-1, self.w+1, self.h+1)
	end
	
	gc:setColorRGB(192, 192, 192)
	gc:fillRect(self.x+self.w-21, self.y+1, 20, 19)
	gc:setColorRGB(224, 224, 224)
	gc:fillRect(self.x+self.w-22, self.y+1, 1, 19)
	
	gc:drawImage(self.img, self.x+self.w-18, self.y+9)
	
	gc:setColorRGB(0,0,0)
	local text = self.value
	if self.unitmode then
		text=text:gsub("([^%d]+)(%d)", numberToSub)
	end
	
	gc:drawString(textLim(gc, text, self.w-5-22), self.x+5, self.y, "top")
end



----------



function on.timer() current_screen():timer() screenRefresh() end

function on.arrowKey(arrw) current_screen():arrowKey(arrw) screenRefresh() end

function on.enterKey() current_screen():enterKey() screenRefresh() end

function on.escapeKey() current_screen():escapeKey() screenRefresh() end

function on.tabKey() current_screen():tabKey() screenRefresh() end

function on.backtabKey() current_screen():backtabKey() screenRefresh() end

function on.charIn(ch) current_screen():charIn(ch) screenRefresh() end

function on.backspaceKey() current_screen():backspaceKey() screenRefresh() end

function on.mouseDown(x, y) current_screen():mouseDown(x, y) screenRefresh() end

function on.mouseUp(x, y) current_screen():mouseUp(x, y) screenRefresh()  end

function on.mouseMove(x, y) current_screen():mouseMove(x, y) screenRefresh() end



-----------------

GameState = { level = 1,
              score = 0,
              bestScore = 0,
              lives = 20,
              money = 50,
              totalMoney = 50,
              totalWaves = 0,
              totalKills = 0,
              savedGame = false,
              finished = false } 
              

-----------------
--- "Classes" ---
-----------------

Enemy = class()
Tower = class()


-----------------
-----Enemy:-----
-----------------

enemiesTable = {}
totalEnemiesNumber = 0

function Enemy:init(gridX, gridY, theType, level, id)
    self.gridX = gridX
    self.gridY = gridY
    self.wd = math.floor(kXSize/#gameGrid.map[1])
    self.ht = math.floor((kYSize-1/10*kYSize)/#gameGrid.map)
    self.x = (gridX-0.6)*self.wd
    self.y = (gridY-0.4)*self.ht
    self.theType = theType -- {nil, "Air", "Water", "Fire", "Earth", Air = 2, Water = 3, Fire = 4, Earth = 5 }
    self.level = level
    self.id = id
    totalEnemiesNumber = id
    self.totalLife = 60+15*self.level
    self.life = 60+15*self.level 
    self.prevX = gridX
    self.prevY = gridY
    self.prev2X = self.prevX
	self.prev2Y = self.prevY
	self.edgesSeen = {}
	self.moves = 0
	self.needsDestroy = false
	self.killed = false
end

function Enemy:paint(gc)
    if self.theType == 3 then
        setColor(gc,"blue")
    elseif self.theType == 2 then
        setColor(gc,"white")
    elseif self.theType == 5 then
        gc:setColorRGB(90,200,30) -- greenish
    elseif self.theType == 4 then
        setColor(gc,"red")
    end
    --gc:fillRect(self.x, self.y, 6, 6)
    gc:drawString("*",self.x, self.y-3, "middle")
    
    if self.life >= 1 then setColor(gc, "red") end
    if self.life >= 27 then setColor(gc, "orange") end
    if self.life >= 55 then setColor(gc, "blue") end
    if self.life >= 80 then setColor(gc, "green") end
    
    gc:fillRect(self.x-4, self.y+1, 15*(self.life/self.totalLife), 2)
    -- life bar
    
    setColor(gc,"black")
end

function Enemy:move()
    if self.needsDestroy or self.killed then
        --print("destroyed called on :", self.id)
        if not self.killed then 
            GameState.lives = GameState.lives - 1
            if GameState.lives <= 0 then
                GameState.finished = true
                timer.stop()
                showGameOver()
            end
            StatusBar.livesLeft = GameState.lives -- destroyed because at the end.
        else -- > a tower killed the enemy
            GameState.score = GameState.score + 10*GameState.level
            GameState.totalKills = GameState.totalKills + 1
            if GameState.score > GameState.bestScore then GameState.bestScore = GameState.score end
            local addMoney = ((GameState.level > 5) and 1 or 2)*GameState.level
            GameState.money = GameState.money + addMoney
            GameState.totalMoney = GameState.totalMoney + addMoney
        end
        enemiesTable[self.id] = nil
        return 0
    end
	
    if self.moves == 0 then -- starting position.
    	self.gridX = self.gridX + 1 -- valid for map 1 only...
    	self.x = (self.gridX-0.6)*self.wd
        self.moves = self.moves + 1
        self.prev2X = self.prevX
        self.prevX = self.gridX
    	return 1
    end
    --print("----------")
    self.edgesSeen = {}
    self.possibilities = {}
    self:scanAround()
    
    self:setEdges()

    self:deleteImpossiblePossibilities()

    self:getNextPos()
    self.gridX = self.nextX
    self.gridY = self.nextY
     self.x = (self.gridX-0.6)*self.wd
     self.y = (self.gridY-0.4)*self.ht

    self.prev2X = self.prevX
    self.prev2Y = self.prevY
    self.prevX = self.gridX
    self.prevY = self.gridY
    self.moves = self.moves + 1
    
    self.needsDestroy = (gameGrid:getContent(self.gridX, self.gridY) == "finish") 
end

function Enemy:timer()
	--todo
end

local seen={}

function dump(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		if type(t[v])=="number" or type(t[v]) == "string" then
		   print(i .. "\t\t" .. v .. " (" .. type(t[v]) .. ") = ".. tostring(t[v]))
		else
		   print(i,v)
		end
		v=t[v]
		if type(v)=="table" and not seen[v] then
			dump(v,i.."\t")
		end
		if type(v)=="userdata" and not seen[v] then
			dump(getmetatable(v),i.."\t  ")
		end
	end
end

-- Enemy Path calculations --
-- AI thing :P --

function Enemy:scanAround()
	if gameGrid:getContent(self.gridX-1, self.gridY) == "road" or gameGrid:getContent(self.gridX-1, self.gridY) == "finish" then	self.possibilities[self.gridX-1 .. "-" .. self.gridY] = {self.gridX-1, self.gridY} end
	if gameGrid:getContent(self.gridX+1, self.gridY) == "road" or gameGrid:getContent(self.gridX+1, self.gridY) == "finish" then	self.possibilities[self.gridX+1 .. "-" .. self.gridY] = {self.gridX+1, self.gridY} end
	if gameGrid:getContent(self.gridX, self.gridY-1) == "road" or gameGrid:getContent(self.gridX, self.gridY-1) == "finish" then	self.possibilities[self.gridX .. "-" .. self.gridY-1] = {self.gridX, self.gridY-1} end
	if gameGrid:getContent(self.gridX, self.gridY+1) == "road" or gameGrid:getContent(self.gridX, self.gridY+1) == "finish" then	self.possibilities[self.gridX .. "-" .. self.gridY+1] = {self.gridX, self.gridY+1} end
end

function Enemy:setEdges()
	for i=self.gridX-1, self.gridX+1 do
		for j=self.gridY-1, self.gridY+1 do
			if gameGrid.gridSquares[j] and gameGrid.gridSquares[j][i] then
				if gameGrid:getContent(i, j) ~= "road" and gameGrid:getContent(i, j) ~= "start" then
					self.edgesSeen[i .. "-" .. j] = {i, j}
				end
			end
		end
	end
end

function getEdgesAt(x,y)
    local tt = {}
	for i=x-1, x+1 do
		for j=y-1, y+1 do
			if gameGrid.gridSquares[j] and gameGrid.gridSquares[j][i] then
				if gameGrid:getContent(i, j) ~= "road" and gameGrid:getContent(i, j) ~= "start" then
					tt[i .. "-" .. j] = {i, j}
				end
			end
		end
	end
	return tt
end

function Enemy:deleteImpossiblePossibilities()
    for k,v in pairs(self.possibilities) do
        --print("deleteimposs : ",k,v[1],v[2])
        --print("history, right now : ", self.prev2X, self.prev2Y)
        if v[1] == self.prev2X and v[2] == self.prev2Y then
            self.possibilities[k] = nil
            --print("removing case that was the previous position: ",k)
        end
    end
end

function Enemy:getNextPos()
    local counts = {}
    local revCounts = {}
    for k,coords in pairs(self.possibilities) do
        --print("*************************possibility : ",k)
        local test = getEdgesAt(coords[1], coords[2])
        for k2,v2 in pairs(test) do
            counts[k] = counts[k] or 0
            if not self.edgesSeen[v2[1] .. "-" .. v2[2]] then
                --print("edge never seen before on "..coords[1]..","..coords[2],v2[1],v2[2])
            else
                --print("edge seen before on "..coords[1]..","..coords[2],v2[1],v2[2])
                counts[k] = counts[k] + 1
            end
        end
    end
    local goodValue = -20
    local goodPos = ""
    for a,b in pairs(counts) do
        if b>goodValue then goodValue = b  goodPos = a end
    end
    --print("goodValue = "..goodValue, "goodPos = "..goodPos)

    self.nextX = self.possibilities[goodPos][1]
    self.nextY = self.possibilities[goodPos][2]
end



function showGameOver()
    
    GameOverWindow	= Dialog("Game over !", 20, 20, 200, 90)
    
    local GameOverTxt	= [[You lose the game ! 
Your score is : ]] .. GameState.score .. [[ 
]]
    
    local GameOverOKButton = sButton("Ok")
    
    for i, line in ipairs(GameOverTxt:split("\n")) do
        local theText	= sLabel(line)
        GameOverWindow:appendWidget(theText, 10, 27 + i*14-12)
    end
    
    GameOverWindow:appendWidget(GameOverOKButton,-10,-5)
    
    function GameOverWindow:postPaint(gc)
        nativeBar(gc, self, self.h-39)
    end
    
    GameOverOKButton:giveFocus()
    
    function GameOverWindow:escapeKey()
        GameOverOKButton:action()
    end
    
    function GameOverWindow:arrowKey(arrw)
        if arrw == "up" then
            self:backtabKey()
        elseif arrw == "down" then
            self:tabKey()
        end
    end
    
    function GameOverOKButton:action()
        remove_screen(GameOverWindow)
        finishGame()
    end
    
    push_screen(GameOverWindow)
        
end




-----------------
----- Tower:-----
-----------------

towersTable = {}
towerTypes = {nil, "Air", "Fire", "Water", "Earth" }
towersPrices = {nil, 20, 30, 50, 40} -- eh :/

function Tower:init(x, y, wd, ht, theType, lvl, id)
    self.x = x*wd
    self.gridX = x
    self.y = y*ht
    self.gridY = y
    self.width = wd
    self.height = ht
    self.theType = theType
    self.id = id
    self.level = lvl or 1
    print("type = ", self.theType)
    self.price = math.ceil(.8*towersPrices[self.theType]) -- 80% of the original price
    self.range = self.level -- lulz
end

function placeTower(gridX, gridY, wd, ht, theType, lvl, id)
    local theID = id or #towersTable+1
    local level = lvl or 1
    if gameGrid:getContent(gridX, gridY) == "nothing" and GameState.money - towersPrices[theType] >= 0 then
        towersTable[theID] = Tower(gridX, gridY, wd, ht, theType, level, theID)

        gameGrid.gridSquares[gridY][gridX].level = towersTable[theID].level
        gameGrid.gridSquares[gridY][gridX].range = towersTable[theID].range
        gameGrid.gridSquares[gridY][gridX].theType = towersTable[theID].theType
        gameGrid.gridSquares[gridY][gridX].id = towersTable[theID].id
        gameGrid.gridSquares[gridY][gridX].gridX = towersTable[theID].gridX
        gameGrid.gridSquares[gridY][gridX].gridY = towersTable[theID].gridY
        gameGrid.gridSquares[gridY][gridX].price = towersTable[theID].price
        gameGrid.gridSquares.selectedSquare.range = towersTable[theID].range -- FUUUUU :(
        --mergeTable(gameGrid.gridSquares[gridY][gridX], towersTable[theID])
        
        GameState.money = GameState.money - towersPrices[theType]
    end
    print("total towers placed : ", #towersTable)
end

function removeTower(id)
    print("removing tower #"..id)
    local theTower = copyTable(towersTable[id])
    towersTable[id] = {}
    gameGrid.gridSquares[theTower.gridY][theTower.gridX] = deepcopy(gameGridEmpty.gridSquares[theTower.gridY][theTower.gridX])
end

function Tower:upgrade()
    if self.level < 2 then
        self.level = self.level + 1
        self.range = self.range + 1
        gameGrid.gridSquares[self.gridY][self.gridX].level = self.level
        gameGrid.gridSquares[self.gridY][self.gridX].range = self.range
        GameState.money = GameState.money - self.price/2
        print("tower " .. self.id .. " upgraded to level " .. self.level .. ". Range is : " .. self.range)
    end
end

function Tower:action()
    self:checkNearby()
    self:attack()
end

function Tower:checkNearby()
    self.nearbyEnemies = {}
    for k,v in pairs(enemiesTable) do
        if math.abs(v.gridX-self.gridX) <= self.range
           and math.abs(v.gridY-self.gridY) <= self.range then
               self.nearbyEnemies[#self.nearbyEnemies+1] = v
               break
        end
    end
end

function Tower:attack()
    for k,v in pairs(self.nearbyEnemies) do
        self.attacking = true
        self.target = { x = v.x, y = v.y }
        if v.theType == self.theType then
            --print("same type !!")
            v.life = v.life - 51 --2shot
        else
            v.life = v.life - 35 --3shot
        end
        if v.life < 1 then
            v.killed = true
            --print("enemy destroyed !")
        end
    end
end

function Tower:paint(gc)
    print('why dafuq is that called (tower paint)')
end

function Tower:timer()
    print("tower timer called on tower n°" .. self.id)
end


-----------------------
----PauseMenuScreen----
-----------------------

PauseMenuScreen = Dialog("Pause Menu", 0, 0, 120, 150) -- 0, 0 useless ??

function PauseMenuScreen:arrowKey(arrw)
    if arrw == "up" then
        self:backtabKey()
    elseif arrw == "down" then
        self:tabKey()
    end
end

function PauseMenuScreen:escapeKey()
    gamePaused = false
    remove_screen(PauseMenuScreen)
    platform.window:invalidate()
end

ResumeButton = sButton(" Resume ", function() PauseMenuScreen:escapeKey() end)
PauseMenuScreen:appendWidget(ResumeButton, "23", "25")
ResumeButton:giveFocus()

helpButton = sButton(" Help ", function() showHelp() end)
PauseMenuScreen:appendWidget(helpButton, "33", "51")

statsButton = sButton(" Quit ", function() remove_screen(PauseMenuScreen) finishGame() end)
PauseMenuScreen:appendWidget(statsButton, "33", "75")


-----------------------

function finishGame()
    if not GameState.finished and (GameState.bestScore and GameState.bestScore > 0) then
        createSaveOrNot()
    else
        realFinishGame()
    end
end

function realFinishGame()
    remove_screen(GameScreen)
    collectgarbage() -- free up some memory
    gamePaused = false
    push_screen(Menu)
    if GameState.score > 0 then showStats() end
end

-----------------------
---- Save or Not ? ----
-----------------------

function createSaveOrNot()

    SaveOrNot = Dialog("Save the game ?", 0, 0, 140, 70) -- 0, 0 useless ??
    
    function SaveOrNot:arrowKey(arrw)
        if arrw == "up" then
            self:backtabKey()
        elseif arrw == "down" then
            self:tabKey()
        end
    end
    
    function SaveOrNot:escapeKey()
        remove_screen(SaveOrNot)
        realFinishGame()
    end
    
    theYesButton = sButton(" Yes ! ", function() 
                                        GameState.savedGame = true 
                                        document.markChanged() 
                                        SaveOrNot:escapeKey()
                                      end)
    SaveOrNot:appendWidget(theYesButton, "15", "50")
    ResumeButton:giveFocus()
    
    theNoButton = sButton(" No ! ", function() GameState.savedGame = false ; SaveOrNot:escapeKey() end)
    SaveOrNot:appendWidget(theNoButton, "60", "50")

    push_screen(SaveOrNot)
end


--------------------------------------
-- EnterKey cases while in game.... --
--------------------------------------
        
function makeAboutTowerWindow(tower)

    AboutTowerWindow = Dialog("Tower Detail :", 150, 20, 210, 120)
    
    local theText = "Lvl " .. tower.level .. " " .. towerTypes[tower.theType] .. [[ tower
120% damage on ]] .. towerTypes[tower.theType] .. [[ enemies 
Range : ]] .. tower.range .. [[ 
]]
    
    for i, line in ipairs(theText:split("\n")) do
        local theLine = sLabel(line)
        AboutTowerWindow:appendWidget(theLine, 10, 27 + i*14-12)
    end
    
    local OkButton	= sButton(" Ok ")
    
    function OkButton:action()
        remove_screen(AboutTowerWindow)
    end
    
    AboutTowerWindow:appendWidget(OkButton,-10,-5)
    
    OkButton:giveFocus()
    
    local sellButton = sButton(" Sell ")
    
    function sellButton:action()
        GameState.money = GameState.money + .8*tower.price
        GameState.totalMoney = GameState.totalMoney + .8*tower.price
        removeTower(tower.id)
        remove_screen(AboutTowerWindow)
    end
    
    AboutTowerWindow:appendWidget(sellButton,-60,-5)
    
    local upgradeButton = sButton("Upgrade")
    
    function upgradeButton:action()
        local theTower = towersTable[tower.id]
        theTower:upgrade()
        remove_screen(AboutTowerWindow)
    end
    
    AboutTowerWindow:appendWidget(upgradeButton,20,-5)
    
    function AboutTowerWindow:postPaint(gc)
        nativeBar(gc, self, self.h-40)
    end
    
    function AboutTowerWindow:escapeKey()
        remove_screen(AboutTowerWindow)
    end
    
    function AboutTowerWindow:arrowKey(arrw)
        if arrw == "right" then
            self:backtabKey()
        elseif arrw == "left" then
            self:tabKey()
        end
    end
end

function makeCreateTowerWindow()
    print("makeCreateTowerWindow")
    
    CreateTowerWindow	= Dialog("Place a tower :", 20, 20, 270, 140)
    
    local TowerStr	= [[The different types of towers do more 
damage on the same type of enemy.]]
    
    local CreateTowerCancelButton = sButton("Cancel")
    
    for i, line in ipairs(TowerStr:split("\n")) do
        local towerText	= sLabel(line)
        CreateTowerWindow:appendWidget(towerText, 10, 27 + i*14-12)
    end
    
    local createAirButton = sButton("Air ($20)")
    createAirButton.action = function() CreateTowerWindow:closeAndPlace("a") end
    local createFireButton = sButton("Fire ($30)")
    createFireButton.action = function() CreateTowerWindow:closeAndPlace("f") end
    local createEarthButton = sButton("Earth ($40)")
    createEarthButton.action = function() CreateTowerWindow:closeAndPlace("e") end
    local createWaterButton = sButton("Water ($50)")
    createWaterButton.action = function() CreateTowerWindow:closeAndPlace("w") end

    CreateTowerWindow:appendWidget(createAirButton, 5, 70)
    CreateTowerWindow:appendWidget(createFireButton, 60, 70)
    CreateTowerWindow:appendWidget(createEarthButton, 121, 70)
    CreateTowerWindow:appendWidget(createWaterButton, 190, 70)
    
    CreateTowerWindow:appendWidget(CreateTowerCancelButton,-10,-5)
    
    function CreateTowerWindow:postPaint(gc)
        nativeBar(gc, self, self.h-39)
    end
    
    CreateTowerCancelButton:giveFocus()
    
    function CreateTowerWindow:escapeKey()
        CreateTowerCancelButton:action()
    end
    
    function CreateTowerWindow:arrowKey(arrw)
        if arrw == "up" then
            self:backtabKey()
        elseif arrw == "down" then
            self:tabKey()
        end
    end
    
    function CreateTowerCancelButton:action()
        remove_screen(CreateTowerWindow)
    end
        
    function CreateTowerWindow:closeAndPlace(ch)
        remove_screen(CreateTowerWindow)
        local myTable = { a = 2, f = 3, w = 4, e = 5 } -- A, F, W, E
        placeTower(gameGrid.gridSquares.selectedSquare.gridX, gameGrid.gridSquares.selectedSquare.gridY, gameGrid.gridSquares.selectedSquare.width, gameGrid.gridSquares.selectedSquare.height, myTable[ch])
        StatusBar:takeSelectionInfo(gameGrid.gridSquares.selectedSquare)
    end
        
end

function makeAboutWaveWindow()
    print("makeAboutWaveWindow")
end

-----------------------
------GameScreen:------
-----------------------

GameScreen = WScreen()

function GameScreen:paint(gc)
    gameGrid:paint(gc)
    StatusBar:paint(gc)
end

function GameScreen:arrowKey(key)
    gameGrid:arrowKey(key)
end

function GameScreen:charIn(ch)
    --if ch == "d" then dump(enemiesTable, "enemiesTable") end
    --if ch == "p" then GameState.finished = true end
    gameGrid:charIn(ch)
end

function GameScreen:escapeKey()
    gamePaused = true
    push_screen(PauseMenuScreen)
end

function GameScreen:enterKey()

    local selection = gameGrid.gridSquares[gameGrid.gridSquares.selectedSquare.gridY][gameGrid.gridSquares.selectedSquare.gridX]
    local selectionContent = gameGrid:getContent(selection.gridX,selection.gridY) -- wtf... todo
                
    if selectionContent == "road" then
        if not GameState.currentWave and GameState.level < (#wavesTable+1) then
            createWaveConfirm()
            push_screen(WaveConfirm)
        end
    elseif selectionContent == "tower" then
        makeAboutTowerWindow(selection)
        push_screen(AboutTowerWindow)
    elseif selectionContent == "nothing" then
        makeCreateTowerWindow()
        push_screen(CreateTowerWindow)
    elseif selectionContent == "start" or selectionContent == "finish" then
        makeAboutWaveWindow()
        push_screen(AboutWaveWindow)
    end
end

function GameScreen:mouseDown(x, y)
	--gameGrid:mouseDown(x, y)
end

GameScreen.mouseUp = GameScreen.enterKey

function GameScreen:mouseMove(x, y)
	gameGrid:mouseMove(x, y)
end

function GameScreen:timer()
    if not gamePaused then
        for _,tower in pairs(towersTable) do
            tower:action()
        end
        local enCount = enCount or 0
        for _,enemy in pairs(enemiesTable) do
            enemy:move()
            enCount = enCount + 1
        end
        if timerNeedsStop then
            timerNeedsStop = false
            timer.stop()
            --print("timer stopped")
            return 0
        end
        if GameState.currentWave then
            GameState.currentWave:send()
        else
            
            if enCount < 1 then
                timerNeedsStop = true
            else 
                timerNeedsStop = false
            end
            -- TODO : check if lives left and do w/e accordingly
        end
        if timerNeedsStop and GameState.level >= #wavesTable then
            print("Game Finished !")
            GameState.finished = true
            createWaveConfirm() -- game finished blbalbab
	        push_screen(WaveConfirm)
        end
    end
end

function GameScreen:tabKey()
--debug
--var.store("map", testmap)
end


Grid = class()
Square = class()

testmap = { {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {8,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1},
            {8,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1},
            {1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1},
            {1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1},
            {1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1},
            {1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,9},
            {1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,9},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1} }
local testmapMT = { __index = function() return {1} end }
setmetatable(testmap, testmapMT) -- makes it so undefined aread will be walls.

function Square:init(gridX,gridY,wd,ht,theType,lvl,id) -- fonctionne en gridCoords
    self.x = gridX*wd
    self.gridX = gridX+1
    self.y = gridY*ht
    self.gridY = gridY+1
    self.width = wd
    self.height = ht
    self.theType = theType
    self.id = id or 0
    self.level = lvl or 0
end

function Square:paint(gc)
    setColor(gc,"grey")
    if self.theType ~= "selected" then 
        gc:fillRect(self.x, self.y, self.width, self.height) -- default bg color for square
    end
    
    -- Terrain
    if self.theType == 1 then -- nothing
        gc:fillRect(self.x, self.y, self.width, self.height)
        gc:setColorRGB(100,100,100)
        gc:drawRect(self.x, self.y, self.width, self.height)
    elseif self.theType == 0 then
        setColor(gc,"black")
        gc:fillRect(self.x, self.y, self.width, self.height)
    elseif self.theType == "selected" then
        setColor(gc,"blue")
        gc:drawRect(self.x+1, self.y+1, self.width-2, self.height-2)
    elseif self.theType == 8 then
        setColor(gc,"black")
        gc:fillRect(self.x, self.y, self.width, self.height)
        setColor(gc,"green")
        gc:fillRect(self.x, self.y, self.width/2, self.height)
    elseif self.theType == 9 then
        setColor(gc,"black")
        gc:fillRect(self.x, self.y, self.width, self.height)
        setColor(gc,"red")
        gc:fillRect(2+self.x+self.width/2, self.y, self.width/2, self.height)
        
    --Towers
    elseif self.theType == 2 then
        setColor(gc,"white")
        fillCircle(gc, self.x+.45*self.height, self.y+.2*self.height, self.height*2.3/3)
    elseif self.theType == 3 then
        setColor(gc,"red")
        fillCircle(gc, self.x+.45*self.height, self.y+.2*self.height, self.height*2.3/3)
    elseif self.theType == 4 then
        setColor(gc,"blue")
        fillCircle(gc, self.x+.45*self.height, self.y+.2*self.height, self.height*2.3/3)
    elseif self.theType == 5 then
        gc:setColorRGB(90,200,30) -- greenish
        fillCircle(gc, self.x+.45*self.height, self.y+.2*self.height, self.height*2.3/3)
    end
    
    if self.attacking then
        --print("hello attacking ? ") --TODO : doesnt get called. (enemy killed before ?)
        setColor(gc, "orange")
        gc:drawLine(self.target.x, self.target.y, self.x, self.y)
        setColor(gc, "black")
    end
    
    if self.gridY == gameGrid.gridSquares.selectedSquare.gridY 
       and self.gridX == gameGrid.gridSquares.selectedSquare.gridX
       and self.range then
        gc:setColorRGB(255,255,255)
        
        --todo better : 
        if self.range == 1 then
            gc:drawRect((self.gridX-2*self.range)*self.width, (self.gridY-2*self.range)*self.height, 3*self.range*self.width, 3*self.range*self.height )
        elseif self.range == 2 then
            gc:drawRect((self.gridX-1.5*self.range)*self.width, (self.gridY-1.5*self.range)*self.height, 2.5*self.range*self.width, 2.5*self.range*self.height )
        end
        
        gc:setColorRGB(0,0,0)
    end
    
    setColor(gc,"black") --reset
end

-----------------------------------

function theVerticalLine(gc, x)
    gc:fillRect(x, 0, 1, math.floor(9/10*kYSize))
    gc:fillRect(x, 0, 1, math.floor(9/10*kYSize))
end

function theHorizontalLine(gc, y)
    gc:fillRect(0, y, kXSize, 1)
end

terrainTypes = { nothing = 1, road = 0, start = 8, finish = 9 }
terrainTypes[0] = "road" ; terrainTypes[1] = "nothing" ; terrainTypes[8] = "start" ; terrainTypes[9] = "finish"

function Grid:getContent(x,y) -- fonctionne en gridCoords
    local content = ""
    if self.gridSquares[y] and self.gridSquares[y][x] then
        if self.gridSquares[y][x].theType == 0 then
            content = "road"
        elseif self.gridSquares[y][x].theType == 1 then
            content = "nothing"
        elseif self.gridSquares[y][x].theType == 8 then
            content = "start" -- 
        elseif self.gridSquares[y][x].theType == 9 then
            content = "finish" -- 
        elseif self.gridSquares[y][x].theType > 1 then
            content = "tower"
        end
    else
        content = "nothing" --warning
        --print("error ! get content void... ", x, y)
    end
    return content
end

function Grid:init(map)
    self.map = map
    self.gridSquares = {}
    for i1,v1 in ipairs(self.map) do
        self.gridSquares[i1] = {}
        for i2, v2 in ipairs(v1) do
            self.gridSquares[i1][i2] = Square(i2-1, i1-1, math.floor(kXSize/#self.map[1]), math.floor((kYSize-1/10*kYSize)/#self.map), v2)
        end
    end
    self.gridSquares.selectedSquare = Square(1, 1, math.floor(kXSize/#self.map[1]), math.floor((kYSize-1/10*kYSize)/#self.map), "selected")
    self.gridSquares.selectedSquare.gridX = 2 ; self.gridSquares.selectedSquare.gridY = 2
    self.gridSquares.selectedSquare.theSelection = true
    gameGridEmpty = deepcopy(self)
end

function Grid:paint(gc)
    for i1,v1 in ipairs(self.gridSquares) do
        for i2,square in pairs(v1) do
            square:paint(gc)
        end
    end
    for _,enemy in pairs(enemiesTable) do
		enemy:paint(gc)
	end
    self.gridSquares.selectedSquare:paint(gc, false)
    setColor(gc,"black")
end

function Grid:arrowKey(key)
    if key == "left" then
        self.gridSquares.selectedSquare.x = self.gridSquares.selectedSquare.x > 0 and self.gridSquares.selectedSquare.x - math.floor(kXSize/#self.map[1]) or self.gridSquares.selectedSquare.x
        self.gridSquares.selectedSquare.gridX = self.gridSquares.selectedSquare.gridX > 1 and self.gridSquares.selectedSquare.gridX - 1 or self.gridSquares.selectedSquare.gridX
    elseif key =="right" then
        self.gridSquares.selectedSquare.x = self.gridSquares.selectedSquare.x < (#self.map[1]-1)*math.floor(kXSize/#self.map[1]) and self.gridSquares.selectedSquare.x + math.floor(kXSize/#self.map[1]) or self.gridSquares.selectedSquare.x
        self.gridSquares.selectedSquare.gridX = self.gridSquares.selectedSquare.gridX < #self.map[1] and self.gridSquares.selectedSquare.gridX + 1 or self.gridSquares.selectedSquare.gridX
    elseif key =="up" then
        self.gridSquares.selectedSquare.y = self.gridSquares.selectedSquare.y > 0 and self.gridSquares.selectedSquare.y - math.floor((kYSize-1/10*kYSize)/#self.map) or self.gridSquares.selectedSquare.y
        self.gridSquares.selectedSquare.gridY = self.gridSquares.selectedSquare.gridY > 1 and self.gridSquares.selectedSquare.gridY - 1 or self.gridSquares.selectedSquare.gridY
    elseif key =="down" then
        self.gridSquares.selectedSquare.y = self.gridSquares.selectedSquare.y < (#self.map-1)*math.floor((kYSize-1/10*kYSize)/#self.map) and self.gridSquares.selectedSquare.y + math.floor((kYSize-1/10*kYSize)/#self.map) or self.gridSquares.selectedSquare.y
        self.gridSquares.selectedSquare.gridY = self.gridSquares.selectedSquare.gridY < #self.map and self.gridSquares.selectedSquare.gridY + 1 or self.gridSquares.selectedSquare.gridY
    end
    self.gridSquares.selectedSquare.range = self.gridSquares[self.gridSquares.selectedSquare.gridY][self.gridSquares.selectedSquare.gridX].range
    StatusBar.posText = "[" .. self.gridSquares.selectedSquare.gridX .. ";" .. self.gridSquares.selectedSquare.gridY .. "]"
    StatusBar:takeSelectionInfo(self.gridSquares.selectedSquare)
end

function Grid:charIn(ch)
    local myTable = { a = 2, f = 3, w = 4, e = 5 } -- A, F, W, E
    if myTable[ch] then
        placeTower(self.gridSquares.selectedSquare.gridX, self.gridSquares.selectedSquare.gridY, self.gridSquares.selectedSquare.width, self.gridSquares.selectedSquare.height, myTable[ch])
        StatusBar:takeSelectionInfo(self.gridSquares.selectedSquare)
    end
    ----debug
    --if ch == "+" then
    --	enemiesTable[totalEnemiesNumber + 1] = Enemy(1, 2, math.random(2,5), 1, totalEnemiesNumber + 1)
    --	enemiesTable[totalEnemiesNumber + 1] = Enemy(1, 3, math.random(2,5), 1, totalEnemiesNumber + 1)
    --end
end

function Grid:mouseDown(x, y)
    -- todo
end

function Grid:mouseMove(x, y)
    if x > 2 and y > 2 and x < self.gridSquares.selectedSquare.width*(#self.map[1]) and y < self.gridSquares.selectedSquare.height*(#self.map) then
        self.gridSquares.selectedSquare.gridX = math.floor(x/self.gridSquares.selectedSquare.width-0.1)+1
        self.gridSquares.selectedSquare.gridY = math.floor(y/self.gridSquares.selectedSquare.height-0.1)+1
        self.gridSquares.selectedSquare.x = self.gridSquares.selectedSquare.width*(self.gridSquares.selectedSquare.gridX-1)
        self.gridSquares.selectedSquare.y = self.gridSquares.selectedSquare.height*(self.gridSquares.selectedSquare.gridY-1)
        self.gridSquares.selectedSquare.range = self.gridSquares[self.gridSquares.selectedSquare.gridY][self.gridSquares.selectedSquare.gridX].range
        StatusBar.posText = "[" .. self.gridSquares.selectedSquare.gridX .. ";" .. self.gridSquares.selectedSquare.gridY .. "]"
        StatusBar:takeSelectionInfo(self.gridSquares.selectedSquare)
    end
end


----WaveConfirm----

function createWaveConfirm()
    
    GameState.finished = GameState.finished  or (GameState.level >= #wavesTable)
    
    local msg = GameState.finished and "Game Finished !" or "Start Wave ".. GameState.level .."?" 
    
    WaveConfirm = Dialog(msg, 0, 0, 120, 80) -- 0, 0 useless ??
    
    function WaveConfirm:arrowKey(arrw)
        self:tabKey()
    end
    
    function WaveConfirm:escapeKey()
        remove_screen(WaveConfirm)
    end
    
    function startTheWave()
        GameState.currentWave = Wave(GameState.level, wavesTable[GameState.level])
        WaveConfirm:escapeKey()
        GameState.level = GameState.level + 1
        GameState.totalWaves = GameState.totalWaves + 1
        timer.start(0.3)
    end
            
    WaveYesButton = sButton(" Yes ", function() startTheWave() end )
                                     
    if GameState.finished then
        noButton = sButton(" Ok ", function() remove_screen(WaveConfirm) finishGame() end)
    else
        noButton = sButton(" No ", function() WaveConfirm:escapeKey() end)
    end
    
    WaveConfirm:appendWidget(noButton, "60", "48")
    noButton:giveFocus()
        
    if GameState.finished then
        WaveConfirm:appendWidget(sLabel("Congratz!"), "10", "50")
    else
        WaveConfirm:appendWidget(WaveYesButton, "15", "48")
        WaveYesButton:giveFocus()
    end
    
end

-------------

wavesTable = { {2}, {3}, {2,3}, {2,4}, {3,4}, {2,5}, {3,5}, {4,5}, {3,4,5}, {3}, {4}, {5}, {2} } --types of enemies ; last 2 is bullcrap. :D
local wavesTableMT = { __index = function() print("***************************************game finished !!") end } -- no more waves
setmetatable(wavesTable, wavesTableMT)

-------------


Wave = class()

function Wave:init(level, types)
    --print("wave init called")
    if GameState.finished then print("Game is already finished, y u continue !") return 0 end
    self.level = level
    self.theTypes = types or {}
    local theTypesMT = { __index = function(tbl, key) return tbl[math.fmod(key,#tbl)+1] end } --always return a good type
    setmetatable(self.theTypes, theTypesMT)
    self.nbrTotal = 5 -- (pairs) --also, debug?
    self.currentPair = 1
    self.thePairs = {}
    for i=1, self.nbrTotal do
        table.insert(self.thePairs, {start1X = 1, start1Y = 2, start2X = 1, start2Y = 3, theType = self.theTypes[i] } )
    end
end

function Wave:create(pair)
    enemiesTable[totalEnemiesNumber + 1] = Enemy(pair.start1X, pair.start1Y, pair.theType or 2, self.level, totalEnemiesNumber + 1)
    enemiesTable[totalEnemiesNumber + 1] = Enemy(pair.start2X, pair.start2Y, pair.theType or 2, self.level, totalEnemiesNumber + 1)
    --print("created 2 enemies")
end

function Wave:send()
    --print("wave:send called !")

    if self.currentPair <= self.nbrTotal then    
        local pair = self.thePairs[self.currentPair]
        self.currentPair = self.currentPair + 1
        self:create(pair)
    else
        GameState.currentWave = nil
        --print("The whole wave has been sent.")
    end
end

-------------

StatusBar = class()
StatusBar.text = "Build towers !"
--StatusBar.posText = "[2;2]"
StatusBar.underSelected = {}

function StatusBar:takeSelectionInfo(selected)
   local msg = ""
   self.underSelected = gameGrid.gridSquares[selected.gridY][selected.gridX]
   
   if self.underSelected.theType > 1 and self.underSelected.theType < 7 then -- if it's a tower
       msg = towerTypes[self.underSelected.theType] .. " Tower (lvl " .. self.underSelected.level .. ")"
   else
       msg = terrainTypes[self.underSelected.theType]
   end
   StatusBar.text = msg
end

function StatusBar:paint(gc)
    gc:drawLine(0, 9/10*kYSize, kXSize, 9/10*kYSize)
    gc:drawLine(64, 9/10*kYSize, 64, kYSize)
    gc:drawLine(kXSize-110-#tostring(GameState.money), 9/10*kYSize, kXSize-110-#tostring(GameState.money), kYSize)
    gc:drawLine(kXSize-60, 9/10*kYSize, kXSize-60, kYSize)
    local theLevel = (GameState.level > 0) and GameState.level or "-"
    gc:drawString("Wave: ".. theLevel, 2, .5*kYSize*(1+9/10)-1, "middle")
    gc:drawString(self.text, 68, .5*kYSize*(1+9/10)-1, "middle")
    gc:drawString("$"..GameState.money, kXSize-gc:getStringWidth("$"..GameState.money)-72, .5*kYSize*(1+9/10)-1, "middle")
    gc:drawString("<3 : "..GameState.lives, kXSize-gc:getStringWidth("<3 : "..GameState.lives)-8, .5*kYSize*(1+9/10)-1, "middle")
    --gc:drawString(self.posText, kXSize-gc:getStringWidth(self.posText)-2, .5*kYSize*(1+9/10)-1, "middle")
end


---------------
-- Stats
---------------

function showStats()

    StatsWindow	= Dialog("Game Stats :", 150, 20, 268, 164)
    
    local StatsStr	= [[Here are some stats (more soon) :
    
Total waves sent : ]] .. GameState.totalWaves .. [[ 
Total enemies killed  : ]] .. GameState.totalKills .. [[ 
Last / Best Score : ]] .. GameState.score .. " / " .. GameState.bestScore .. [[ 
 
]]
    
    local StatsOkButton	= sButton("OK")
    
    for i, line in ipairs(StatsStr:split("\n")) do
        local StatsText	= sLabel(line)
        StatsWindow:appendWidget(StatsText, 10, 27 + i*14-12)
    end
    
    StatsWindow:appendWidget(StatsOkButton,-10,-5)
    
    function StatsWindow:postPaint(gc)
        nativeBar(gc, self, self.h-40)
        on.help = function() return 0 end
    end
    
    StatsOkButton:giveFocus()
    
    function StatsWindow:escapeKey()
        StatsOkButton:action()
    end
    
    function StatsWindow:arrowKey(arrw)
        if arrw == "up" then
            self:backtabKey()
        elseif arrw == "down" then
            self:tabKey()
        end
    end
    
    function StatsOkButton:action()
        remove_screen(StatsWindow)
    end
    
    push_screen(StatsWindow)

end

---------------------

HelpWindow	= Dialog("About LuaTowerDefense :", 150, 20, 270, 180)

local HelpStr	= [[                                                      v1.0
 -----------------------------
Adrien Bertrand (Adriweb). LGPL 3 License
Thanks to Levak and Jim Bauwens.
You can get help in the next tab.
Contact / More TI Stuff : tiplanet.org
Part of the 2012 Omnimaga contest]]

local HelpOkButton	= sButton("OK")

for i, line in ipairs(HelpStr:split("\n")) do
	local HelpText	= sLabel(line)
	HelpWindow:appendWidget(HelpText, 10, 27 + i*14-12)
end


HelpWindow:appendWidget(HelpOkButton,-10,-5)

function HelpWindow:postPaint(gc)
    cursor.show()
    gc:setFont("serif", "b", 14)
    gc:setColorRGB(0,0,0)
    drawXCenteredString(gc, " LuaTowerDefense " .. string.rep(" ", math.random(0,1)), HelpWindow.y+23+math.random(-1,1))
    gc:setColorRGB(1,150,150)
    drawXCenteredString(gc, " LuaTowerDefense " .. string.rep(" ", math.random(0,1)), HelpWindow.y+23+math.random(-1,1))
    gc:setColorRGB(0,0,0)
    drawXCenteredString(gc, "  LuaTowerDefense  ", HelpWindow.y+24+math.random(-1,1))
    gc:setFont("sansserif", "r", 6)
    gc:drawString("Don't even think about moving the mouse", HelpWindow.x+10, HelpWindow.y+HelpWindow.h-12)
	nativeBar(gc, self, self.h-40)
	on.help = function() return 0 end
end

HelpOkButton:giveFocus()

function HelpWindow:escapeKey()
    HelpOkButton:action()
end

function HelpWindow:arrowKey(arrw)
    if arrw == "up" then
        self:backtabKey()
    elseif arrw == "down" then
        self:tabKey()
    end
end

function HelpOkButton:action()
	remove_screen(HelpWindow)
	on.help = function() push_screen(HelpWindow) end
end


function showHelp()
    push_screen(HelpWindow)
end

-----------------
------MENU:------
-----------------

Menu = WScreen()

function Menu:paint(gc)
    bigText(gc)
    gc:setColorRGB(0,0,0)
    gc:fillRect(0,0, kXSize, kYSize)
    gc:drawImage(resizedGradImg, 0, kYSize-resizedGradImg:height()+4)
    gc:setColorRGB(1,200,200)
    drawXCenteredString(gc, " LuaTowerDefense", 8)
    gc:setColorRGB(255,255,255)
    drawXCenteredString(gc, "  LuaTowerDefense ", 9)
    normalText(gc)
end

function Menu:arrowKey(arrw)
    if arrw == "up" then
        self:backtabKey()
    elseif arrw == "down" then
        self:tabKey()
    end
end

function Menu:resize(x,y)
    resizedGradImg = gradientImg:copy(x,1/8*y)
end

playButton = sButton(" Play ! ", function() newOrLoad() end)
Menu:appendWidget(playButton, "41.5", "30")
playButton:giveFocus()

statsButton = sButton(" Stats ", function() showStats() end)
Menu:appendWidget(statsButton, "42", "50")

helpButton = sButton(" About ", function() showHelp() end)
Menu:appendWidget(helpButton, "41.5", "70")

-----------------

----newOrLoad----

function newOrLoad()
    
    newOrLoadDialog	= Dialog("New/Load ?", 150, 20, 210, 120)
    
    local theText	= [[There is a saved game.
Do you want to load it ?
Choose 'New' to start over.
]]
    
    for i, line in ipairs(theText:split("\n")) do
        local theLine = sLabel(line)
        newOrLoadDialog:appendWidget(theLine, 10, 27 + i*14-12)
    end
    
    local newButton	= sButton("New")
    
    function newButton:action()
        GameState.level = 1
        GameState.score = 0
        GameState.lives = 20
        GameState.money = 50
        GameState.totalMoney = 50
        GameState.savedGame = false
        GameState.finished = false
        remove_screen(newOrLoadDialog)
        startGame()
    end
    
    newOrLoadDialog:appendWidget(newButton,-10,-5)
    
    newButton:giveFocus()
    
    local loadButton	= sButton("Load")
    
    function loadButton:action()
        remove_screen(newOrLoadDialog)
        startGame()
    end
    
    newOrLoadDialog:appendWidget(loadButton,-60,-5)
    
    function newOrLoadDialog:postPaint(gc)
        nativeBar(gc, self, self.h-40)
    end
    
    function newOrLoadDialog:escapeKey()
        remove_screen(newOrLoadDialog)
    end
    
    function newOrLoadDialog:arrowKey(arrw)
        if arrw == "up" then
            self:backtabKey()
        elseif arrw == "down" then
            self:tabKey()
        end
    end
    
    push_screen(newOrLoadDialog)
    
    if not GameState.savedGame then 
        print("No saved game. Starting new...")
        newButton:action()
    end
    
end



function errorPopup()

    errorDialog = Dialog("Oops...", 50, 20, "85", "80")

    local textMessage	= [[LuaTD has encountered an error
-----------------------------
Sorry for the inconvenience.
Please report this bug to info@tiplanet.org
How/where/when it happened etc.
 (bug at line ]] .. errorHandler.errorLine .. ")"
    
    local errorOKButton	= sButton("OK")
    
    for i, line in ipairs(textMessage:split("\n")) do
        local errorLabel = sLabel(line)
        errorDialog:appendWidget(errorLabel, 10, 27 + i*14-12)
    end
    
    errorDialog:appendWidget(errorOKButton,-10,-5)
    
    function errorDialog:postPaint(gc)
        nativeBar(gc, self, self.h-40)
    end
    
    errorOKButton:giveFocus()
    
    function errorOKButton:action()
        remove_screen(errorDialog)
        errorHandler.errorMessage = nil
    end

    push_screen(errorDialog)
end


------------------------------
--Bindings to the on events:--
------------------------------
function on.paint(gc)
    for _, screen in pairs(Screens) do
        screen:draw(gc)
    end
end

function on.help()
    gamePaused = true
    showHelp()
end

function on.resize(x, y)
    -- Global Ratio Constants for On-Calc (shouldn't be used often though...)
    kXRatio = x / 318
    kYRatio = y / 212
    kXSize = x
    kYSize = y
    for _, screen in pairs(Screens) do
        screen:resize(x,y)
    end
    platform.window:invalidate() -- redraw everything
end

function on.save()
    if GameState.savedGame then
        print("Saving the game...")
    else 
        GameState.level = 1
        GameState.score = 0
        GameState.lives = 20
        GameState.money = 50
        GameState.totalMoney = 50
        GameState.savedGame = false
        GameState.finished = false
    end
    
    return GameState
end
 
function on.restore(tbl)
    if tbl.bestScore and tbl.bestScore > 0 then
        GameState = tbl
        GameState.totalMoney = GameState.money
    end
end


errorHandler = {}

function handleError(line, errMsg, callStack, locals)
    print("Error handled !", errMsg)
    errorHandler.display = true
    errorHandler.errorMessage = errMsg
    errorHandler.errorLine = line
    errorPopup()
    return true -- go on....
end

if platform.registerErrorHandler then
    platform.registerErrorHandler( handleError )
end


-----------------
----FUNCTIONS----
-----------------
function startGame()

    print("Starting game...")
    GameState.finished = false
    
    gameGrid = Grid(testmap)
    
    print("Grid Loaded")
    remove_screen(Menu)
    push_screen(GameScreen)
    cursor.show()
end

-----------------
-----Start !-----
-----------------
push_screen(Menu)


gradientImg = image.new("\001\000\000\000\020\000\000\000\000\000\000\000\002\000\000\000\016\000\001\000\132\144\132\144\198\152\008\161J\169\140\177\206\1851\198s\206\181\214\247\2229\231{\239\189\247\255\255\255\255\255\255\255\255\255\255\255\255")
