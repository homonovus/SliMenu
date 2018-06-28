include("slimenu/luadata.lua")

local def_config = {
	AccentColor = Color(0,150,130),
	LoadMenuPlugins = false,
}

slimenu_config = {}
setmetatable(slimenu_config, {__index = def_config})

do
	local t = luadata.ReadFile("slimenu_config.txt")
	if t then table.CopyFromTo(t, slimenu_config) end
end

local R=function(a,b,c,d,e) return function() return RunConsoleCommand(a,b,c,d,e) end end
local M=function(x) return function() return RunGameUICommand(x) end end
local C=function(x) return function() return JoinServer(x) end end
local NOT=function(f) return function(...) return not f(...) end end

surface.CreateFont("menu2_button",{
	font = "Roboto Medium",
	size = 24,
})

surface.CreateFont("menu2_text",{
	font = "Roboto Medium",
	size = 16,
})

local function m2_config()
	local config = vgui.Create("DFrame")
	config:SetSize(400,600)
	config:SetTitle("SliMenu Config")
	config:SetIcon("icon16/wrench_orange.png")
	config:Center()
	config:MakePopup()

	local lbl_col = vgui.Create("DLabel",config)
	lbl_col:Dock(TOP)
	lbl_col:SetText("Accent Color")

	local acccol = vgui.Create("DColorMixer",config)
	acccol:Dock(TOP)
	acccol:SetPalette(true)
	acccol:SetAlphaBar(false)
	acccol:SetWangs(true)
	acccol:SetColor(slimenu_config.AccentColor)

	local menup = vgui.Create("DCheckBoxLabel",config)
	menup:Dock(TOP)
	menup:DockMargin(0,4,0,0)
	menup:SetText("Load menu_plugins")
	menup:SetValue(slimenu_config.LoadMenuPlugins)
	function menup:OnChange(v) print("changed menuplugins") slimenu_config.LoadMenuPlugins = v end

	local apply = vgui.Create("DButton",config)
	apply:Dock(BOTTOM)
	apply:SetText("Apply changes and reload")
	apply:SetIcon("icon16/tick.png")

	apply.DoClick = function()
		local color = acccol:GetColor()
		color = Color(color.r,color.g,color.b,255)
		slimenu_config.AccentColor = color
		luadata.WriteFile("slimenu_config.txt", slimenu_config)

		include'includes/menu.lua'
		hook.Call("MenuStart")

		config:Close()
		console2:Close()
	end
end

local servers = {
	{"Metastruct",     "g1.metastruct.net"},
	{"IJWTB",          "192.223.29.49:27015"},
	{"HexaHedron",     "ip.hexahedron.pw"},
	{"Flex's Estates", "ext.kaosheaven.xyz"},
	{"PAC3",           "threekelv.in"}
}

local mainmenu = {
	{"resume_game",    gui.HideGameUI,          "icon16/joystick.png",     show=IsInGame},
	{"disconnect",     M"disconnect",           "icon16/disconnect.png",   show=IsInGame},
	{"Reconnect",      R"retry",                "icon16/connect.png",      show=WasInGame},
	{"server_players", M"openplayerlistdialog", "icon16/group_delete.png", show=IsInGame},

	{"new_game",       R"menu_play",         "icon16/world_add.png"}, -- i hope this works
	{"legacy_browser", M"openserverbrowser", "icon16/server_go.png"},

	{"Change Background", ChangeBackground, "icon16/picture.png", show=NOT(IsInGame)},

	{"options", M"openoptionsdialog", "icon16/wrench.png"},

	{"GameUI_Quit", M"quitnoconfirm", "icon16/door.png"},

	{"Servers", function() local smenu = DermaMenu() for _,s in next,servers do smenu:AddOption(s[1],function() JoinServer(s[2]) end):SetIcon("icon16/server.png") end smenu:Open() end,"icon16/server_key.png"},
}

-- addons
-- games
-- language
-- settings
-- lua cache?
-- workshop search
-- con filter out
-- console open
-- devmode quicktoggle
-- favorites and their status on main menu?
-- browser? / overlay?
-- client.vdf browser/editor
--

local isours
if pnlMainMenu and pnlMainMenu:IsValid() then pnlMainMenu:Remove() end

local bg = vgui.Create("menu2_background")
bg:ScreenshotScan( "backgrounds/" )

_G.pnlMainMenu = bg

local menu_bar = vgui.Create("EditablePanel",bg,"menu_bar")
menu_bar:Dock(TOP)
menu_bar:SetTall(24)

function menu_bar:Paint(w,h)
	draw.RoundedBox(0,0,0,w,h,Color(0,0,0,220))
end

local time = vgui.Create("DLabel",menu_bar)
time:Dock(RIGHT)
time:DockMargin(0,0,4,0)
time:SetText(os.date("%H:%M"))
time:SetFont("menu2_text")
time:SetColor(slimenu_config.AccentColor)
time:SizeToContents()

function menu_bar:Think()
	time:SetText(os.date("%H:%M"))
end

local btn_reload = vgui.Create("DImageButton",menu_bar)
btn_reload:Dock(RIGHT)
btn_reload:SetWide(24)
btn_reload:DockMargin(0,0,4,0)
btn_reload:SetImage("icon16/arrow_refresh.png")
btn_reload:SetText("")
btn_reload:SetTooltip("Reload Menu")
function btn_reload:PerformLayout()
	if ( IsValid( self.m_Image ) ) then
		self.m_Image:SetSize( 16, 16 )
		self.m_Image:SetPos( ( self:GetWide() - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
	end
	DLabel.PerformLayout( self )
end
function btn_reload:DoClick() include'includes/menu.lua' hook.Call("MenuStart") end

local btn_console = vgui.Create("DImageButton",menu_bar)
btn_console:Dock(RIGHT)
btn_console:SetWide(24)
btn_console:DockMargin(0,0,4,0)
btn_console:SetImage("icon16/application_osx_terminal.png")
btn_console:SetText("")
btn_console:SetTooltip("#GameUI_Console")
function btn_console:PerformLayout()
	if ( IsValid( self.m_Image ) ) then
		self.m_Image:SetSize( 16, 16 )
		self.m_Image:SetPos( ( self:GetWide() - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
	end
	DLabel.PerformLayout( self )
end
btn_console.DoClick = R"showconsole"

local btn_config = vgui.Create("DImageButton",menu_bar)
btn_config:Dock(RIGHT)
btn_config:SetWide(24)
btn_config:DockMargin(0,0,4,0)
btn_config:SetImage("icon16/wrench_orange.png")
btn_config:SetText("")
btn_config:SetTooltip("Config")
function btn_config:PerformLayout()
	if ( IsValid( self.m_Image ) ) then
		self.m_Image:SetSize( 16, 16 )
		self.m_Image:SetPos( ( self:GetWide() - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
	end
	DLabel.PerformLayout( self )
end
btn_config.DoClick = function()
	m2_config()
end

local menu_items = vgui.Create("EditablePanel",menu_bar)
menu_items:Dock(LEFT)
menu_items:SetWide(ScrW()/2)

local menulist_wrapper = vgui.Create('DPanelList',bg,'menulist_wrapper')
menulist_wrapper:EnableVerticalScrollbar(true)
menulist_wrapper:SetWide(350)
menulist_wrapper:Dock(LEFT)
menulist_wrapper:DockMargin(32,32,32,32)

local div_hack = vgui.Create'EditablePanel'
div_hack:SetTall(52)
div_hack:SetZPos(-20000)
menulist_wrapper:AddItem(div_hack)

local lastscroll = menulist_wrapper.VBar:GetScroll()

local addonslist
function CreateAddons()

	if addonslist and addonslist:IsValid() then addonslist:Remove() addonslist=nil end

	addonslist = vgui.Create('DForm',menulist_wrapper,'addonslist')
	addonslist:Dock(TOP)
	addonslist:SetName"#manage_addons"
	addonslist:SetExpanded(false)

	addonslist:SetCookieName"addonslist"
	addonslist:LoadCookies()

	menulist_wrapper:AddItem(addonslist)
	menulist_wrapper:InvalidateLayout(true)
	addonslist:InvalidateLayout(true)
	addonslist.Header:SetIcon 'icon16/plugin.png'
	addonslist.Header:SetFont("menu2_text")
	function addonslist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,slimenu_config.AccentColor)
	end


	local btn = vgui.Create("DButton",addonslist,'addonslist_button')
		addonslist:AddItem(btn)
		btn:SetText("#addons.enableall")
		btn:SetIcon 'icon16/add.png'
		btn:SetFont("menu2_text")

		function btn.DoClick(btn)
			for k,v in next,engine.GetAddons() do
				steamworks.SetShouldMountAddon(v.wsid or v.file,true)
			end
			isours = true
			steamworks.ApplyAddons()
			isours = true

			CreateMenu()

		end
	local btn = vgui.Create("DButton",addonslist,'addonslist_button')
		addonslist:AddItem(btn)
		btn:SetText("#addons.disableall")
		btn:SetIcon 'icon16/delete.png'
		btn:SetFont("menu2_text")

		function btn.DoClick(btn)
			for k,v in next,engine.GetAddons() do
				steamworks.SetShouldMountAddon(v.wsid or v.file,false)
			end
			isours = true
			steamworks.ApplyAddons()
			isours = true
			CreateMenu()
		end
	local btn = vgui.Create("DButton",addonslist,'addonslist_button')
		addonslist:AddItem(btn)
		btn:SetText("#addons.uninstallall")
		btn:SetIcon 'icon16/stop.png'
		btn:SetFont("menu2_text")
		function btn.DoClick(btn)
			for k,v in next,engine.GetAddons() do
				if v.wsid then
					print("Unsubscribe",v.wsid)
					steamworks.Unsubscribe(v.wsid)
				end
			end
			isours = true steamworks.ApplyAddons() isours = true
			CreateMenu()
		end

	local function AddButton(data,title,mounted,downloaded,wsid,filepath)

		local btn = vgui.Create("DCheckBoxLabel",addonslist,'addonslist_button')
			addonslist:AddItem(btn)
			btn:SetText(title or filepath)
			btn:SetChecked(mounted)
			btn:SetBright(true)
			btn:SetDisabled(not downloaded)
			btn.Label:SetFont("menu2_text")
			btn:SizeToContents()
			function btn:OnChange(val)
				print("mount",filepath,val)
				local old = steamworks.ShouldMountAddon(wsid)
				steamworks.SetShouldMountAddon(wsid,val)
				isours = true steamworks.ApplyAddons() isours = true
				local new = steamworks.ShouldMountAddon(wsid)
				btn:SetChecked(new)
				if old==new then
					print("Warning: ","could not toggle",filepath)
				end
			end
			btn.Label.DoRightClick=function()
				local m =DermaMenu()
					m:AddOption("#addon.unsubscribe",function()
						print("Unsubscribe",wsid)
						steamworks.Unsubscribe(wsid)
					end)
					m:AddOption("#copy",function()
						SetClipboardText('http://steamcommunity.com/sharedfiles/filedetails/?id='..wsid)
					end)
				m:Open()
			end

		btn:InvalidateLayout(true)
		--btn:Dock(TOP)
	end

	local t=engine.GetAddons()
	table.sort(t,function(a,b)
		if a.mounted==b.mounted then
			if a.wsid and b.wsid then
				return a.wsid<b.wsid
			elseif a.title and b.title then
				return a.title<b.title
			else
				return a.file<b.file
			end
		else
			return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
		end
	end)
	for _,data in next,t do
		AddButton(data,data.title,data.mounted,data.downloaded,data.wsid,data.file)
	end



	menulist_wrapper.VBar:SetScroll(lastscroll)

end



local settingslist
function CreateExtraSettings()

	if settingslist and settingslist:IsValid() then settingslist:Remove() settingslist=nil end

	settingslist = vgui.Create('DForm',menulist_wrapper,'settingslist')
	settingslist:Dock(TOP)
	settingslist:SetName"Extra Settings"
	settingslist:SetExpanded(false)
	settingslist.Header:SetIcon 'icon16/cog.png'
	settingslist.Header:SetFont("menu2_text")
	settingslist:SetCookieName"settingslist"
	settingslist:LoadCookies()

	function settingslist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,slimenu_config.AccentColor)
	end

	menulist_wrapper:AddItem(settingslist)
	menulist_wrapper:InvalidateLayout(true)
	settingslist:InvalidateLayout(true)

	local function AddCheck(txt,cvar)

		local
			c = vgui.Create( 'DCheckBoxLabel',settingslist,'settingslist_check')
				settingslist:AddItem(c)
			c:SetText( txt )
			c:SetConVar(cvar)
			c:SetBright(true)
			c.Label:SetFont("menu2_text")
			c:SizeToContents()
			c:InvalidateLayout(true)
		return c
	end

	local x = vgui.Create( 'DLabel',settingslist)
	x:SetText"Loading Screen"
	x:SetFont("menu2_text")
	settingslist:AddItem(x)
	AddCheck( "Enable","lua_loading_screen")
	AddCheck( "Transparency","lua_loading_screen_transp")
	AddCheck( "Try hiding","lua_loading_screen_hide")
	local x = vgui.Create( 'DLabel',settingslist)
	x:SetText"Download / Upload"
	x:SetFont("menu2_text")
	settingslist:AddItem(x)
	AddCheck( "Allow DL","cl_allowdownload")
	AddCheck( "Allow UL","cl_allowupload")
	AddCheck( "FastDL debug","download_debug")
	local x = vgui.Create( 'DLabel',settingslist)
	x:SetText" "
	x:SetFont("menu2_text")
	settingslist:AddItem(x)

end




local gameslist
function CreateGames()

	if gameslist and gameslist:IsValid() then gameslist:Remove() gameslist=nil end

	gameslist = vgui.Create('DForm',menulist_wrapper,'gameslist')
	gameslist:Dock(TOP)
	gameslist:SetName"#mounted_games"
	gameslist:SetExpanded(false)
	gameslist.Header:SetIcon 'icon16/joystick.png'
	gameslist.Header:SetFont("menu2_text")
	gameslist:SetCookieName"gameslist"
	gameslist:LoadCookies()

	function gameslist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,slimenu_config.AccentColor)
	end

	menulist_wrapper:AddItem(gameslist)
	menulist_wrapper:InvalidateLayout(true)
	gameslist:InvalidateLayout(true)

	local function AddButton(data,title,mounted,owned,installed,depot)

		local btn = vgui.Create("DCheckBoxLabel",gameslist,'gameslist_button')
			gameslist:AddItem(btn)
			btn:SetText(title)
			btn:SetChecked(mounted)
			btn:SetBright(true)
			btn:SetDisabled(not owned or not installed)
			btn.Label:SetFont("menu2_text")
			btn:SizeToContents()
			function btn:OnChange(val)
				engine.SetMounted(depot,val)
				btn:SetChecked(IsMounted(depot))
			end

		btn:InvalidateLayout(true)
		--btn:Dock(TOP)
	end

	local t=engine.GetGames()
	table.sort(t,function(a,b)
		if a.mounted==b.mounted then
			if a.mounted then
				return a.depot<b.depot
			else
				return ((a.installed and a.owned) and 0 or 1)<((b.installed and b.owned) and 0 or 1)
			end
		else
			return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
		end
	end)
	for _,data in next,t do
		AddButton(data,data.title,data.mounted,data.owned,data.installed,data.depot)
	end

	CreateAddons()

end



local menulist
local creating
local function _CreateMenu()
	creating = false

	lastscroll = menulist_wrapper.VBar:GetScroll()

	local function AddButton(data,text,menucmd,icon)

		if data.show and not data:show() then return end

		local btn = vgui.Create("DImageButton",menu_items,'menulist_button')
			btn:Dock(LEFT)
			btn:SetWide(24)
			btn:DockMargin(4,0,0,0)
			btn:SetText("")
			btn:SetTooltip("#"..text)
		btn.DoClick=function()
			menucmd()
			btn:SetSelected(false)
		end
		if icon and #icon>0 then
			btn:SetImage(icon)
		end
		btn:InvalidateLayout(true)

		btn:SetTextInset( 16+ 16, 0 )
		btn:SetContentAlignment(4)

		function btn:PerformLayout()
			if ( IsValid( self.m_Image ) ) then
				self.m_Image:SetSize( 16, 16 )
				self.m_Image:SetPos( ( self:GetWide() - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
			end
			DLabel.PerformLayout( self )
		end
	end

	if menu_items then
		for _,btn in next,menu_items:GetChildren() do
			btn:Remove()
		end
	end

	for _,data in next,mainmenu do
		AddButton(data,data[1],data[2],data[3])
	end

	CreateExtraSettings()
	CreateGames()

	if slimenu_config.LoadMenuPlugins then
		include'menu_plugins/init.lua'
	end

end

function CreateMenu()
	if creating then return end
	creating = true
	timer.Simple(0.2,function()
		_CreateMenu()
	end)
end

--CreateMenu()

hook.Add( "GameContentsChanged", "CreateMenu", function(mount,addon)
	if mount then return end

	-- EEK
	if not mount and not addon then return end

	if isours then isours = false return end

	CreateMenu()

end )

hook.Add( "InGame", "CreateMenu", function(is)
	CreateMenu()
end )

hook.Add( "ConsoleVisible", "CreateMenu", function(is)

	if IsDeveloper() then
		CreateMenu()
	end

end )

hook.Add( "MenuStart", "CreateMenu", function(status)
	CreateMenu()
end )

hook.Add( "LoadingStatus", "CreateMenu", function(status)
	--CreateMenu()
end )
