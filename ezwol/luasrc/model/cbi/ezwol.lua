-- Copyright 2024
-- Licensed under the MIT License

local m, s, o
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

m = Map("ezwol", translate("EzWoL - Easy Wake-on-LAN"),
	translate("A service that listens for MAC addresses on a network port and sends Wake-on-LAN magic packets to wake up devices on the LAN."))

-- Service status
s = m:section(TypedSection, "ezwol", translate("Service Status"))
s.anonymous = true
s.addremove = false

o = s:option(DummyValue, "_status", translate("Status"))
o.rawhtml = true
function o.cfgvalue(self, section)
	local running = sys.call("pgrep -f ezwold >/dev/null 2>&1") == 0
	if running then
		return '<span style="color:green;font-weight:bold">● Running</span>'
	else
		return '<span style="color:red;font-weight:bold">● Stopped</span>'
	end
end

-- Service settings
s = m:section(TypedSection, "ezwol", translate("Service Settings"))
s.anonymous = true
s.addremove = false

-- Enable/Disable
o = s:option(Flag, "enabled", translate("Enable Service"))
o.rmempty = false


-- Port configuration
o = s:option(Value, "port", translate("Listen Port"))
o.datatype = "port"
o.default = "61323"
o.placeholder = "61323"
o.rmempty = false
o.description = translate("TCP port to listen for incoming WoL requests (default: 61323)")

-- Authentication key
o = s:option(Value, "auth_key", translate("Authentication Key"))
o.password = true
o.rmempty = false
o.description = translate("Shared secret key for authenticating WoL requests. Keep this secure!")

-- Generate random key button
o = s:option(Button, "_generate")
o.title = translate("Generate Random Key")
o.inputtitle = translate("Generate New Key")
o.inputstyle = "apply"
o.description = translate("Generate a random 32-character authentication key")

function o.write(self, section)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local key = ""
	local urandom = io.open("/dev/urandom", "rb")
	
	if urandom then
		for i = 1, 32 do
			local byte = urandom:read(1):byte()
			local idx = (byte % #chars) + 1
			key = key .. chars:sub(idx, idx)
		end
		urandom:close()
	else
		-- Fallback
		math.randomseed(os.time())
		for i = 1, 32 do
			local idx = math.random(1, #chars)
			key = key .. chars:sub(idx, idx)
		end
	end
	
	uci:set("ezwol", section, "auth_key", key)
	uci:commit("ezwol")
	
	-- Redirect to show the new key
	luci.http.redirect(luci.dispatcher.build_url("admin/services/ezwol"))
end

-- Usage information
s = m:section(TypedSection, "ezwol", translate("Usage Information"))
s.anonymous = true
s.addremove = false
s.template = "ezwol/usage"

return m

