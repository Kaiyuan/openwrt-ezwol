-- Copyright 2024
-- Licensed under the MIT License

module("luci.controller.ezwol", package.seeall)

function index()
	entry({"admin", "services", "ezwol"}, cbi("ezwol"), _("EzWoL"), 60).dependent = false
	entry({"admin", "services", "ezwol", "generate_key"}, call("generate_key")).leaf = true
	entry({"admin", "services", "ezwol", "status"}, call("action_status")).leaf = true
end

function generate_key()
	local key = ""
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local urandom = io.open("/dev/urandom", "rb")
	
	if urandom then
		for i = 1, 32 do
			local byte = urandom:read(1):byte()
			local idx = (byte % #chars) + 1
			key = key .. chars:sub(idx, idx)
		end
		urandom:close()
	else
		-- Fallback method
		math.randomseed(os.time())
		for i = 1, 32 do
			local idx = math.random(1, #chars)
			key = key .. chars:sub(idx, idx)
		end
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json({key = key})
end

function action_status()
	local sys = require "luci.sys"
	local running = false
	
	-- Check if ezwold is running
	local status = sys.exec("pgrep -f ezwold >/dev/null 2>&1 && echo running || echo stopped")
	if status:match("running") then
		running = true
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json({running = running})
end

