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
	Name = "KillTrack",
	Version = GetAddOnMetadata("KillTrack", "Version"),
	Events = {},
	Global = {},
	CharGlobal = {},
	Temp = {},
	Sort = {
		Desc = 0,
		Asc = 1,
		CharDesc = 2,
		CharAsc = 3,
		AlphaD = 4,
		AlphaA = 5,
		IdDesc = 6,
		IdAsc = 7
	},
	Session = {
		Count = 0,
		Kills = {}
	},
	Messages = {
		Announce = "[KillTrack] Session Length: %s. Session Kills: %d. Kills Per Minute: %.2f."
	}
}

local KT = KillTrack

local KTT = KillTrack_Tools

local FirstDamage = {} -- Tracks first damage to a mob registered by CLEU
local LastDamage = {} -- Tracks whoever did the most recent damage to a mob
local DamageValid = {} -- Determines if mob is tapped by player/group

local Units = {
	"target",
	"targetpet",
	"focus",
	"focuspet",
	"pet",
	"mouseover",
	"mouseoverpet",
}

for i = 1, 40 do
	if i <= 4 then
		Units[#Units + 1] = "party" .. i
		Units[#Units + 1] = "partypet" .. i
	end
	Units[#Units + 1] = "raid" .. i
	Units[#Units + 1] = "raidpet" .. i
end

for i = 1, #Units * 2 do
	Units[#Units + 1] = Units[i] .. "target"
end

if KT.Version == "@" .. "project-version" .. "@" then
	KT.Version = "Development"
	KT.Debug = true
end

local function FindUnitByGUID(guid)
	for i = 1, #Units do
		if UnitGUID(Units[i]) == guid then return Units[i] end
	end
	return nil
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
	if type(self.Global.ACHIEV_THRESHOLD) ~= "number" then
		self.Global.ACHIEV_THRESHOLD = 1000
	end
	if type(self.Global.COUNT_GROUP) ~= "boolean" then
		self.Global.COUNT_GROUP = false
	end
	if type(self.Global.MOBS) ~= "table" then
		self.Global.MOBS = {}
	end
	if type(_G["KILLTRACK_CHAR"]) ~= "table" then
		_G["KILLTRACK_CHAR"] = {}
	end
	if type(KT.Global.BROKER) ~= "table" then
		KT.Global.BROKER = {}
	end
	if type(KT.Global.BROKER.SHORT_TEXT) ~= "boolean" then
		KT.Global.BROKER.SHORT_TEXT = false
	end
	self.CharGlobal = _G["KILLTRACK_CHAR"]
	if type(self.CharGlobal.MOBS) ~= "table" then
		self.CharGlobal.MOBS = {}
	end
	self:Msg("AddOn Loaded!")
	self.Session.Start = time()
	self.Broker:OnLoad()
end

function KT.Events.COMBAT_LOG_EVENT_UNFILTERED(self, ...)
	local event = (select(2, ...))
	if event == "SWING_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" then
		local s_name = tostring((select(5, ...)))
		local guid = (select(8, ...))
		--local t_id = tonumber(KTT:GUIDToID((select(8, ...))))
		if FirstDamage[guid] == nil then
			-- s_name is (probably) the player who first damaged this mob and probably has the tag
			FirstDamage[guid] = s_name
		end

		LastDamage[guid] = s_name

		if DamageValid[guid] == nil then
			-- if DamageValid returns true for a GUID, we can tell with 100% certainty that it's valid
			-- But this relies on one of the valid unit names currently being the damaged mob
			-- Or if it's false, we can tell with 100% certainty that someone else tagged the mob

			local unit = FindUnitByGUID(guid)

			if not unit then return end

			local tapped = UnitIsTapped(unit)

			if not tapped then return end

			DamageValid[guid] = tapped and UnitIsTappedByPlayer(unit)
		end

		return
	end

	if event ~= "UNIT_DIED" then return end
	-- Perform solo/group checks
	local guid = (select(8, ...))
	local id = KTT:GUIDToID(guid)
	local name = tostring((select(9, ...)))
	local firstDamage = FirstDamage[guid] or "<No One>"
	local lastDamage = LastDamage[guid] or "<No One>"
	local firstByPlayer = firstDamage == UnitName("player") or firstDamage == UnitName("pet")
	local firstByGroup = self:IsInGroup(firstDamage)
	local lastByPlayer = lastDamage == UnitName("player") or lastDamage == UnitName("pet")
	local pass

	-- All checks after DamageValid should be safe to remove
	-- The checks after DamageValid are also not 100% failsafe
	-- Scenario: You deal the killing blow to an already tapped mob <- Would count as kill with current code

	-- if DamageValid[guid] is set, it can be used to decide if the kill was valid with 100% certainty
	if DamageValid[guid] ~= nil then
		pass = DamageValid[guid]
	else -- The one who dealt the very first bit of damage was probably the one who got the tag on the mob
		-- This should apply in most (if not all) situations and is probably a safe fallback when we couldn't retrieve tapped status from GUID->Unit
		pass = firstByPlayer or firstByGroup
	end

	if not self.Global.COUNT_GROUP and pass and not lastByPlayer then
		pass = false -- Player or player's pet did not deal the killing blow and addon only tracks player kills
	end

	if not pass or id == 0 then return end
	FirstDamage[guid] = nil
	DamageValid[guid] = nil
	self:AddKill(id, name)
	if self.Timer:IsRunning() then
		self.Timer:SetData("Kills", self.Timer:GetData("Kills", true) + 1)
	end
end

function KT.Events.UPDATE_MOUSEOVER_UNIT(self, ...)
	if UnitIsPlayer("mouseover") then return end
	local id = KTT:GUIDToID(UnitGUID("mouseover"))
	if UnitCanAttack("player", "mouseover") then
		local gKills, cKills = self:GetKills(id)
		GameTooltip:AddLine(("Killed %d (%d) times."):format(cKills, gKills), 1, 1, 1)
	end
	if KT.Debug then
		GameTooltip:AddLine(("ID = %d"):format(id))
	end
	GameTooltip:Show()
end

function KT:ToggleDebug()
	self.Debug = not self.Debug
	if self.Debug then
		KT:Msg("Debug enabled!")
	else
		KT:Msg("Debug disabled!")
	end
end

function KT:IsInGroup(unit)
	if unit == UnitName("player") then return true end
	if UnitInParty(unit) then return true end
	if UnitInRaid(unit) then return true end
	return false
end

function KT:SetThreshold(threshold)
	if type(threshold) ~= "number" then
		error("KillTrack.SetThreshold: Argument #1 (threshold) must be of type 'number'")
	end
	self.Global.ACHIEV_THRESHOLD = threshold
	self:ResetAchievCount()
	KT:Msg(("New kill notice (achievement) threshold set to %d."):format(threshold))
end

function KT:ToggleCountMode()
	self.Global.COUNT_GROUP = not self.Global.COUNT_GROUP
	if self.Global.COUNT_GROUP then
		KT:Msg("Now counting kills for every player in the group (party/raid)!")
	else
		KT:Msg("Now counting your own killing blows ONLY.")
	end
end

function KT:AddKill(id, name)
	name = name or "<No Name>"
	if type(self.Global.MOBS[id]) ~= "table" then
		self.Global.MOBS[id] = { Name = name, Kills = 0, AchievCount = 0 }
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
	self:AddSessionKill(name)
	if type(self.Global.MOBS[id].AchievCount) ~= "number" then
		self.Global.MOBS[id].AchievCount = floor(self.Global.MOBS[id].Kills / self.Global.ACHIEV_THRESHOLD)
		if self.Global.MOBS[id].AchievCount >= 1 then
			self:KillAlert(self.Global.MOBS[id])
		end
	else
		local achievCount = self.Global.MOBS[id].AchievCount
		self.Global.MOBS[id].AchievCount = floor(self.Global.MOBS[id].Kills / self.Global.ACHIEV_THRESHOLD)
		if self.Global.MOBS[id].AchievCount > achievCount then
			self:KillAlert(self.Global.MOBS[id])
		end
	end
end

function KT:AddSessionKill(name)
	if self.Session.Kills[name] then
		self.Session.Kills[name] = self.Session.Kills[name] + 1
	else
		self.Session.Kills[name] = 1
	end
	self.Session.Count = self.Session.Count + 1
end

function KT:GetSortedSessionKills(max)
	max = tonumber(max) or 3
	local t = {}
	for k,v in pairs(self.Session.Kills) do
		t[#t + 1] = {Name = k, Kills = v}
	end
	table.sort(t, function(a, b) return a.Kills > b.Kills end)
	-- Trim table to only contain 3 entries
	local trimmed = {}
	local c = 0
	for i,v in ipairs(t) do
		trimmed[i] = v
		c = c + 1
		if c >= max then break end
	end
	return trimmed
end

function KT:ResetSession()
	wipe(self.Session.Kills)
	self.Session.Count = 0
	self.Session.Start = time()
end

function KT:GetKills(id)
	local gKills, cKills = 0, 0
	for k,v in pairs(self.Global.MOBS) do
		if k == id and type(v) == "table" then
			gKills = v.Kills
			if self.CharGlobal.MOBS[k] then
				cKills = self.CharGlobal.MOBS[k].Kills
			end
		end
	end
	return gKills, cKills
end

function KT:GetTotalKills()
	local count = 0
	for k,v in pairs(self.Global.MOBS) do
		count = count + v.Kills
	end
	return count
end

function KT:GetSessionStats()
	if not self.Session.Start then return 0, 0, 0 end
	local now = time()
	local session = now - self.Session.Start
	local kps = self.Session.Count / session
	local kpm = kps * 60
	local kph = kpm * 60
	return kps, kpm, kph, session
end

function KT:PrintKills(identifier)
	local found = false
	local name = "<No Name>"
	local gKills = 0
	local cKills = 0
	if type(identifier) ~= "string" and type(identifier) ~= "number" then identifier = "<No Name>" end
	for k,v in pairs(self.Global.MOBS) do
		if type(v) == "table" and (tostring(k) == tostring(identifier) or v.Name == identifier) then
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
		if UnitExists("target") and not UnitIsPlayer("target") then
			identifier = UnitName("target")
		end
		self:Msg(("Unable to find %q in mob database."):format(tostring(identifier)))
	end
end

function KT:Announce(target)
	if target == "GROUP" then
		target = ((IsInRaid() and "RAID") or (IsInGroup() and "PARTY")) or "SAY"
	end
	local _, kpm, _, length = self:GetSessionStats()
	local msg = self.Messages.Announce:format(KTT:FormatSeconds(length), self.Session.Count, kpm)
	SendChatMessage(msg, target)
end

function KT:Msg(msg)
	DEFAULT_CHAT_FRAME:AddMessage("\124cff00FF00[KillTrack]\124r " .. msg)
end

function KT:KillAlert(mob)
	local data = {
		Text = ("%d kills on %s!"):format(mob.Kills, mob.Name),
		Title = "Kill Record!",
		bTitle = "Congratulations!",
		Icon = "Interface\\Icons\\ABILITY_Deathwing_Bloodcorruption_Death",
		FrameStyle = "GuildAchievement"
	}
	if IsAddOnLoaded("Glamour") then
		if not GlamourShowAlert then
			KT:Msg("ERROR: GlamourShowAlert == nil! Notify AddOn developer.")
			return
		end
		GlamourShowAlert(500, data)
	else
		RaidNotice_AddMessage(RaidBossEmoteFrame, data.Text, ChatTypeInfo["SYSTEM"])
		RaidNotice_AddMessage(RaidBossEmoteFrame, data.Text, ChatTypeInfo["SYSTEM"])
	end
	self:Msg(data.Text)
end

function KT:GetMob(id)
	for k,v in pairs(self.Global.MOBS) do
		if type(v) == "table" and (tostring(k) == tostring(id) or v.Name == id) then
			return v, self.CharGlobal.MOBS[k]
		end
	end
	return false, nil
end

function KT:GetSortedMobTable(mode, filter, caseSensitive)
	if not tonumber(mode) then mode = self.Sort.Desc end
	if mode < 0 or mode > 7 then mode = self.Sort.Desc end
	if filter and filter == "" then filter = nil end
	local t = {}
	for k,v in pairs(self.Global.MOBS) do
		assert(type(v) == "table", "Unexpected mob entry type in db: " .. type(v) .. ". Expected table")
		local matches = nil
		if filter then
			local name = caseSensitive and v.Name or v.Name:lower()
			filter = caseSensitive and filter or filter:lower()
			local status, result = pcall(string.match, name, filter)
			matches = status and result
		end
		if matches or not filter then
			local cKills = 0
			if self.CharGlobal.MOBS[k] and type(self.CharGlobal.MOBS[k]) == "table" then
				cKills = self.CharGlobal.MOBS[k].Kills
			end
			local entry = {Id = k, Name = v.Name, gKills = v.Kills, cKills = cKills}
			table.insert(t, entry)
		end
	end
	local function compare(a, b)
		if mode == self.Sort.Asc then
			return a.gKills < b.gKills
		elseif mode == self.Sort.CharDesc then
			return a.cKills > b.cKills
		elseif mode == self.Sort.CharAsc then
			return a.cKills < b.cKills
		elseif mode == self.Sort.AlphaD then
			return a.Name > b.Name
		elseif mode == self.Sort.AlphaA then
			return a.Name < b.Name
		elseif mode == self.Sort.IdDesc then
			return a.Id > b.Id
		elseif mode == self.Sort.IdAsc then
			return a.Id < b.Id
		else
			return a.gKills > b.gKills -- Descending
		end
	end
	table.sort(t, compare)
	return t
end

function KT:Delete(id, charOnly)
	id = tonumber(id)
	if not id then error(("Expected 'id' param to be number, got %s."):format(type(id))) end
	local found = false
	local name
	if self.Global.MOBS[id] then
		name = self.Global.MOBS[id].Name
		if not charOnly then self.Global.MOBS[id] = nil end
		if self.CharGlobal.MOBS[id] then
			self.CharGlobal.MOBS[id] = nil
		end
		found = true
	end
	if found then
		self:Msg(("Deleted %q (%d) from database."):format(name, id))
		StaticPopup_Show("KILLTRACK_FINISH", 1)
	else
		self:Msg(("ID: %d was not found in the database."):format(id))
	end
end

function KT:Purge(threshold)
	local count = 0
	for k,v in pairs(KT.Global.MOBS) do
		if type(v) == "table" and v.Kills < threshold then
			self.Global.MOBS[k] = nil
			count = count + 1
		end
	end
	for k,v in pairs(KT.CharGlobal.MOBS) do
		if type(v) == "table" and v.Kills < threshold then
			self.CharGlobal.MOBS[k] = nil
			count = count + 1
		end
	end
	self:Msg(("Purged %d entries with a kill count below %d"):format(count, threshold))
	self.Temp.Threshold = nil
	StaticPopup_Show("KILLTRACK_FINISH", tostring(count))
end

function KT:Reset()
	local count = #KT.Global.MOBS + #KT.CharGlobal.MOBS
	wipe(self.Global.MOBS)
	wipe(self.CharGlobal.MOBS)
	KT:Msg(("%d mob entries have been removed!"):format(count))
	StaticPopup_Show("KILLTRACK_FINISH", tostring(count))
end

function KT:ResetAchievCount()
	for _,v in pairs(self.Global.MOBS) do
		v.AchievCount = floor(v.Kills / self.Global.ACHIEV_THRESHOLD)
	end
end

KT.Frame = CreateFrame("Frame")

for k,_ in pairs(KT.Events) do
	KT.Frame:RegisterEvent(k)
end

KT.Frame:SetScript("OnEvent", function(_, event, ...) KT:OnEvent(_, event, ...) end)
