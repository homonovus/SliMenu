slimenu_config = slimenu_config or luadata.ReadFile("slimenu_config.txt")

--let the hijacking begin
--credit to EPOE for most of the redirects
--https://github.com/Metastruct/EPOE/

function ToStringTableInfo(t)
	local num=0
	local nonnum=0
	local tables
	local meta=getmetatable(t)
	local str=tostring(t)
	str=str:gsub("table: ","table:( ")
	for k,v in pairs(t) do
		local ktype=type(k)
		if ktype=="number" then
			num=num+1
		elseif ktype=="table" then
			nonnum=nonnum+1
			tables=true
		else
			nonnum=nonnum+1
		end
		if type(v) == "table" then
			tables=true
		end
	end
	if nonnum>0 then
		str=str..', !#'..nonnum
	end
	if num>0 then
		local nums=#t
		if nums==num then
			str=str..', #'..num
		else
			str=str..', #'..num..'/'..nums
		end
	end
	/*if num>0 and nonnum>0 then
		str=str..', count='..(num+nonnum)
	end*/
	if meta then
		str=str..', meta'
	end
	if tables then
		str=str..', subtables'
	end
	str=str..' )'
	return str
end

function ToStringEx(delim,...)
	local res=""
	local count=select('#',...)
	count=count==0 and 1 or count
	for n=1,count do
		local e = select(n,...)
		if type(e)=="table" then
			e=ToStringTableInfo(e)
		elseif e == nil then
			e=type(select(n,...))
		else
		    e=tostring(e)
		end
		res = res .. (n==1 and "" or delim) .. e
	end
	return res
end

oldPrint = oldPrint or print
oldMsgC = oldMsgC or MsgC
oldMsgN = oldMsgN or MsgN
oldMsg = oldMsg or Msg
olderror = olderror or error

function print(...)
	oldPrint(...)
	local ok,str=pcall(ToStringEx," ",...)
	if not ok then oldPrint(str) end
	if not str then return end
	if IsValid(console2) and IsValid(console2.log) then
		console2.log:InsertColorChange(255,255,255,255)
		console2.log:AppendText("\n"..str)
	end
end


function Msg(...)
	oldMsg(...)
	local ok,str=pcall(ToStringEx,"",...)
	if not ok then oldPrint(str) end
	if not str then return end

	if IsValid(console2) and IsValid(console2.log) then
		console2.log:InsertColorChange(255,150,0,255)
		console2.log:AppendText(str)
	end
end

function MsgN(...)
	oldMsgN(...)
	local ok,str=pcall(ToStringEx,"",...)
	if not ok then oldPrint(str) end
	if not str then return end

	if IsValid(console2) and IsValid(console2.log) then
		console2.log:InsertColorChange(255,150,0,255)
		console2.log:AppendText(str.."\n")
	end
end

local function _MsgC(col,...)
	oldMsgC(col,...)
	if not col or not col.r then return end
	local ok,str=pcall(ToStringEx,"",...)
	if not ok then oldPrint(str) end
	if not str then return end

	if IsValid(console2) and IsValid(console2.log) then
		console2.log:InsertColorChange(col.r,col.b,col.g,col.a)
		console2.log:AppendText(str)
	end
end

function MsgC(...)
	local last_col = Color(255,255,255,255)
	local vals={} -- todo: use unpack(n,a,b)
	for i=1,select('#',...) do
		local v=select(i,...)

		if IsColor(v) then
			if next(vals) then _MsgC(last_col,unpack(vals)) end
			vals={}
			last_col=v
		else
			table.insert(vals,v)
		end

	end

	if next(vals) then
		_MsgC(last_col,unpack(vals))
	end
end

function error(...)
	local ok,str=pcall(ToStringEx," ",...)
	if not ok then oldPrint(str) end
	if not str then return end

	if IsValid(console2) and IsValid(console2.log) then
		console2.log:InsertColorChange(200,100,100,255)
		console2.log:AppendText("\nERROR: "..str.."\n")
		console2.log:AppendText(debug.traceback().."\n")
	end

	olderror(...)
end

--file hack for "LUA" for menu state
oldFileRead = oldFileRead or file.Read
oldFileExists = oldFileExists or file.Exists
function file.Read(f,d)
	if d == "LUA" then
		oldFileRead("lua/"..f,"GAME")
	else
		oldFileRead(f,d)
	end
end

function file.Exists(f,d)
	if d == "LUA" then
		oldFileExists("lua/"..f,"GAME")
	else
		oldFileExists(f,d)
	end
end

function m2_interstate()
	_G.console2 = vgui.Create("DFrame")
	console2:SetSize(800,300)
	console2:SetPos(ScrW()-800,ScrH()-300)
	console2:SetTitle("Console2")
	console2:SetIcon("icon16/application_xp_terminal.png")
	console2:SetSizable(true)
	console2:MakePopup()

	console2.lblTitle:SetFont("BudgetLabel")
	console2.lblTitle:SetColor(slimenu_config.AccentColor)
	console2.btnMinim:SetDisabled(false)
	console2.btnMaxim:SetVisible(false)
	console2.btnClose:SetVisible(false)
	console2.btnMinim.DoClick = function() console2:SetVisible(false) end

	function console2.btnMinim:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,slimenu_config.AccentColor)
		draw.DrawText("u","Marlett",10,2,Color(0,0,0),TEXT_ALIGN_CENTER)
	end

	function console2:PerformLayout()
		local titlePush = 0

		if ( IsValid( self.imgIcon ) ) then

			self.imgIcon:SetPos( 5, 5 )
			self.imgIcon:SetSize( 16, 16 )
			titlePush = 16

		end

		self.btnClose:SetPos(0,0)
		self.btnClose:SetSize(0,0)

		self.btnMaxim:SetPos(0,0)
		self.btnMaxim:SetSize(0,0)

		self.btnMinim:SetPos( self:GetWide() - 31 - 4, 4 )
		self.btnMinim:SetSize( 32, 18 )

		self.lblTitle:SetPos( 8 + titlePush, 2 )
		self.lblTitle:SetSize( self:GetWide() - 25 - titlePush, 20 )

	end

	function console2:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,220))
	end

	console2.log = vgui.Create("RichText",console2)
	local log = console2.log
	log:Dock(FILL)
	log:SetVerticalScrollbarEnabled(true)
	function log:PerformLayout()
		self:SetBGColor(Color(0,0,0))
		self:SetFontInternal("BudgetLabel")
	end

	local function logHelp()
		log:InsertColorChange(0,150,130,255)
		log:AppendText("Welcome to Console2\n")
		log:InsertColorChange(255,255,255,255)
		log:AppendText("Console2 is NOT a full console replacement, only a log for prints and lua execution.\n")
		log:AppendText("Here are some quick start tips:\n")
		log:InsertColorChange(0,150,130,255)
		log:AppendText(".m ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(" - Runs on menu state\n")
		log:InsertColorChange(0,150,130,255)
		log:AppendText(".c ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(" - Runs on client state\n")
		log:InsertColorChange(0,150,130,255)
		log:AppendText(".help ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(" - This message\n")
		log:InsertColorChange(0,150,130,255)
		log:AppendText(".reload ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(" - Reloads Console2\n")
		log:InsertColorChange(0,150,130,255)
		log:AppendText(".clear ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(" - Clears the log\n")
		log:AppendText("Enjoy Console2, I guess.")
	end

	logHelp()

	local function logMenu(str)
		log:InsertColorChange(100,200,100,255)
		log:AppendText("\n[Menu] ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(str)
	end

	local function logClient(str)
		log:InsertColorChange(100,200,200,255)
		log:AppendText("\n[Client] ")
		log:InsertColorChange(255,255,255,255)
		log:AppendText(str)
	end

	local input_box = vgui.Create("EditablePanel",console2)
	input_box:Dock(BOTTOM)
	input_box:SetTall(24)
	local inp = vgui.Create("DTextEntry",input_box)
	inp:Dock(FILL)
	inp.m_bHistory = true
	inp:SetFont("BudgetLabel")

	function inp:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,Color(30,30,30))
		self:DrawTextEntryText(slimenu_config.AccentColor,self:GetHighlightColor(),slimenu_config.AccentColor)
		return false
	end

	local send = vgui.Create("DButton",input_box)
	send:Dock(RIGHT)
	send:SetWide(32)
	send:SetText("Send")

	function inp:OnEnter()
		local str = inp:GetValue()
		inp:SetValue("")

		inp:SetText("")
		inp:OnValueChange("")

		local cmd,args = str:match("^(.+) (.+)")
		if cmd and args then
			if cmd == ".m" then
				CompileString(args,"interstate_menu",true)()
				oldPrint("[Console2] menu: "..args)
				logMenu(args)
			elseif cmd == ".c" then
				CompileString("interstate.RunOnClient("..args..")","interstate_client",true)()
				oldPrint("[Console2] client: "..args)
				logClient(args)
			elseif cmd == ".help" then
				logHelp()
			end
		elseif str == ".help" then
			logHelp()
		elseif str == ".reload" then
			console2:Close()
			m2_interstate()
		elseif str == ".clear" then
			console2.log:SetText("")
			console2.log:GotoTextEnd()
		else
			MsgC(Color(128,128,128),"\nUnknown command.")
		end
	end

	send.DoClick = inp.OnEnter
end

hook.Add( "OnLuaError", "Console2", function( str, realm, addontitle, addonid )
	if IsValid(console2) and IsValid(console2.log) then
		console2.log:InsertColorChange(200,100,100,255)
		console2.log:AppendText("\nError: ")
		console2.log:InsertColorChange(255,255,255,255)
		console2.log:AppendText(str)
		console2.log:InsertColorChange(100,200,100,255)
		console2.log:AppendText("\nRealm: ")
		console2.log:InsertColorChange(255,255,255,255)
		console2.log:AppendText(realm)
		console2.log:InsertColorChange(200,200,100,255)
		console2.log:AppendText("\nStack: ")
		console2.log:InsertColorChange(255,255,255,255)
		console2.log:AppendText(debug.traceback())
	end
end)
