--[[
	* Copyright (c) 2011-2013 by Adam Hellberg.
	*
	* This file is part of KillTrack.
	*
	* KillTrack is free software: you can redistribute it and/or modify
	* it under the terms of the GNU General Public License as published by
	* the Free Software Foundation, either version 3 of the License, or
	* (at your option) any later version.
	*
	* KillTrack is distributed in the hope that it will be useful,
	* but WITHOUT ANY WARRANTY; without even the implied warranty of
	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	* GNU General Public License for more details.
	*
	* You should have received a copy of the GNU General Public License
	* along with KillTrack. If not, see <http://www.gnu.org/licenses/>.
--]]

KillTrack_Tools = {}

local KTT = KillTrack_Tools

------------------
-- NUMBER TOOLS --
------------------

function KTT:FormatSeconds(seconds)
	local hours = floor(seconds / 3600)
	local minutes = floor(seconds / 60) - hours * 60
	local seconds = seconds - minutes * 60 - hours * 3600
	return ("%02d:%02d:%02d"):format(hours, minutes, seconds)
end

------------------
-- STRING TOOLS --
------------------

function KTT:Trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function KTT:Split(s)
	local r = {}
	for token in string.gmatch(s, "[^%s]+") do
		table.insert(r, token)
	end
	return r
end

-----------------
-- TABLE TOOLS --
-----------------

function KTT:InTable(tbl, val)
	for _,v in pairs(tbl) do
		if v == val then return true end
	end
	return false
end

function KTT:TableCopy(tbl, cache)
	if type(tbl) ~= "table" then return tbl end
	cache = cache or {}
	if cache[tbl] then return cache[tbl] end
	local copy = {}
	cache[tbl] = copy
	for k, v in pairs(tbl) do
		copy[self:TableCopy(k, cache)] = self:TableCopy(v, cache)
	end
	return copy
end

function KTT:TableLength(table)
	local count = 0
	for _,_ in pairs(table) do
		count = count + 1
	end
	return count
end

-----------------
-- OTHER TOOLS --
-----------------

function KTT:GUIDToID(guid)
	if not guid then return nil end
	local id = guid:match("^%w+:0:%d+:%d+:%d+:(%d+):[A-Z%d]+$")
	return tonumber(id)
end
