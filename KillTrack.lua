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

KillTrack = {
	Events = {},
	Global = {},
	CharGlobal = {}
}

local KT = KillTrack

local function GUIDToID(guid)
	return tonumber(guid:sub(-12, -9), 16)
end

function KT:OnEvent(_, event, ...)
	if self.Events[event] then
		self.Events[event](self, ...)
	end
end

function KT.Events.ADDON_LOADED(self, ...)
	local name = (select(1, ...))
	if name ~= "KillTrack" then return end
	if type(_G["KILLTRACK"]) ~= "table" then
		_G["KILLTRACK"] = {}
	end
	self.Global = _G["KILLTRACK"]
	if type(self.Global.PRINTKILLS) ~= "boolean" then
		self.Global.PRINTKILLS = true
	end
	if type(self.Global.MOBS) ~= "table" then
		self.Global.MOBS = {}
	end
	if type(_G["KILLTRACK_CHAR"]) ~= "table" then
		_G["KILLTRACK_CHAR"] = {}
	end
	self.CharGlobal = _G["KILLTRACK_CHAR"]
	if type(self.CharGlobal.MOBS) ~= "table" then
		self.CharGlobal.MOBS = {}
	end
	self:Msg("AddOn Loaded!")
end

function KT.Events.COMBAT_LOG_EVENT_UNFILTERED(self, ...)
	local event = (select(2, ...))
	if event ~= "PARTY_KILL" then return end
	local id = GUIDToID((select(8, ...)))
	local name = tostring((select(9, ...)))
	if id == 0 then return end
	self:AddKill(id, name)
end

function KT.Events.UPDATE_MOUSEOVER_UNIT(self, ...)
	if UnitIsPlayer("mouseover") then return end
	if not UnitCanAttack("player", "mouseover") then return end
	local id = GUIDToID(UnitGUID("mouseover"))
	local gKills, cKills = self:GetKills(id)
	GameTooltip:AddLine(("Killed %d (%d) times."):format(gKills, cKills), 1, 1, 1)
	GameTooltip:Show()
end

function KT:AddKill(id, name)
	name = name or "<No Name>"
	if type(self.Global.MOBS[id]) ~= "table" then
		self.Global.MOBS[id] = { Name = name, Kills = 0 }
		self:Msg(("Created new entry for %q"):format(name))
	end
	self.Global.MOBS[id].Kills = self.Global.MOBS[id].Kills + 1
	if type(self.CharGlobal.MOBS[id]) ~= "table" then
		self.CharGlobal.MOBS[id] =  { Name = name, Kills = 0 }
		self:Msg(("Created new entry for %q on this character."):format(name))
	end
	self.CharGlobal.MOBS[id].Kills = self.CharGlobal.MOBS[id].Kills + 1
	if self.Global.PRINTKILLS then
		self:Msg(("Updated %q, new kill count: %d. Kill count on this character: %d"):format(name, self.Global.MOBS[id].Kills, self.CharGlobal.MOBS[id].Kills))
	end
end

function KT:GetKills(id)
	local gKills, cKills = 0, 0
	for k,v in pairs(self.Global.MOBS) do
		if k == id then
			gKills = v.Kills
			if self.CharGlobal.MOBS[k] then
				cKills = self.CharGlobal.MOBS[k].Kills
			end
		end
	end
	return gKills, cKills
end

function KT:PrintKills(identifier)
	local found = false
	local name = "<No Name>"
	local gKills = 0
	local cKills = 0
	if type(identifier) ~= "string" and type(identifier) ~= "number" then identifier = "<No Name>" end
	for k,v in pairs(self.Global.MOBS) do
		if tostring(k) == tostring(identifier) or v.Name == identifier then
			name = v.Name
			gKills = v.Kills
			if self.CharGlobal.MOBS[k] then
				cKills = self.CharGlobal.MOBS[k].Kills
			end
			found = true
		end
	end
	if found then
		self:Msg(("You have killed %q %d times in total, %d times on this character"):format(name, gKills, cKills))
	else
		self:Msg(("Unable to find %q in mob database."):format(tostring(identifier)))
	end
end

function KT:Msg(msg)
	DEFAULT_CHAT_FRAME:AddMessage("\124cff00FF00[KillTrack]\124r " .. msg)
end

SLASH_KILLTRACK1 = "/killtrack"
SLASH_KILLTRACK2 = "/kt"

SlashCmdList["KILLTRACK"] = function(msg, editBox)
	if msg == "target" and UnitExists("target") and not UnitIsPlayer("target") then
		local id = tonumber(UnitGUID("target"):sub(-12, -9), 16)
		KT:PrintKills(id)
	elseif msg == "print" then
		KT.Global.PRINTKILLS = not KT.Global.PRINTKILLS
		if KT.Global.PRINTKILLS then
			KT:Msg("Announcing kill updates.")
		else
			KT:Msg("No longer announcing kill updates.")
		end
	elseif msg == "purge" then
		KT:Msg("NYI")
	elseif msg == "reset" then
		KT:Reset()
	elseif msg and msg ~= "" then
		KT:PrintKills(msg)
	else
		KT:Msg(("%q is not a valid command."):format(tostring(msg)))
		KT:Msg("/kt target - Display number of kills on target mob.")
		KT:Msg("/kt <name> - Display number of kills on <name>, <name> can also be NPC ID.")
		KT:Msg("/kt print - Toggle printing kill updates to chat.")
		KT:Msg("/kt reset - Clear the mob database.")
		KT:Msg("/kt - Displays this help message.")
	end
end

KT.Frame = CreateFrame("Frame")

for k,_ in pairs(KT.Events) do
	KT.Frame:RegisterEvent(k)
end

KT.Frame:SetScript("OnEvent", function(_, event, ...) KT:OnEvent(_, event, ...) end)

-------------------
-- DISPLAY FRAME --
-------------------

--KT.Display = CreateFrame("Frame")
