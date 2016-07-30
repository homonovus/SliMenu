hook.Add( "OnLuaError", "MenuErrorHandler", function( str, realm, addontitle, addonid )
	MsgN()
	if realm == "server" then
		MsgC(Color(200,200,100),"[SV] ",Color(255,255,255),str)
		MsgN()
	elseif realm == "client" then
		MsgC(Color(100,200,200),"[CL] ",Color(255,255,255),str)
		MsgN()
	elseif realm == "menu" then
		MsgC(Color(100,200,100),"[SV] ",Color(255,255,255),str)
		MsgN()
	else
		MsgC(Color(200,100,100),"[??] ",Color(255,255,255),str)
		MsgN()
	end
end)
