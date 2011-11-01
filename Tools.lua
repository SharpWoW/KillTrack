--[[
	* Copyright (c) 2011 by Adam Hellberg.
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

KTT.SortMode = {
	Descending = 0,
	Ascending = 1
}

function KTT:GetSortedMobTable(tbl, mode)
	local t = {}
	for k,v in pairs(tbl) do
		local entry = {Id = k, Name = v.Name, Kills = v.Kills}
		table.insert(t, entry)
	end
	if not mode or (mode < 0 or mode > 1) then
		mode = self.SortMode.Descending
	end
	local function compare(a, b)
		if mode == self.SortMode.Descending then
			return a.Kills > b.Kills
		else
			return a.Kills < b.Kills
		end
	end
	table.sort(t, compare)
	return t
end

-----------------
-- OTHER TOOLS --
-----------------

function KTT:GUIDToID(guid)
	return tonumber(guid:sub(-12, -9), 16)
end
