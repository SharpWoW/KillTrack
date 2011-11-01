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

local KT = KillTrack

local function Purge(treshold)
	local count = 0
	for i,v in ipairs(KT.Global.MOBS) do
		if v.Kills < treshold then
			table.remove(KT.Global.MOBS, i)
			count = count + 1
		end
	end
	for i,v in pairs(KT.CharGlobal.MOBS) do
		if v.Kills < treshold then
			table.remove(KT.CharGlobal.MOBS, i)
			count = count + 1
		end
	end
	KT:Msg(("Purged %d entries with a kill count below %d"):format(count, treshold))
	StaticPopup_Show("KILLTRACK_FINISH", tostring(count))
end

local function Reset()
	local count = #KT.Global.MOBS + #KT.CharGlobal.MOBS
	wipe(KT.Global.MOBS)
	wipe(KT.CharGlobal.MOBS)
	KT:Msg("Mob entries have been removed!")
	StaticPopup_Show("KILLTRACK_FINISH", tostring(count))
end

StaticPopupDialogs["KILLTRACK_FINISH"] = {
	text = "%s entries removed.",
	button1 = "Okay",
	timeout = 10,
	enterClicksFirstButton = true,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["KILLTRACK_PURGE"] = {
	text = "Remove all mob entries with their kill count below this treshold:",
	button1 = "Purge",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self, data, data2) Purge(tonumber(self.editBox:GetText())) end,
	OnShow = function(self, data) self.button1:Disable() end,
	EditBoxOnTextChanged = function(self, data)
		if tonumber(self:GetText()) then
			self:GetParent().button1:Enable()
		else
			self:GetParent().button1:Disable()
		end
	end,
	showAlert = true,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["KILLTRACK_RESET"] = {
	text = "Remove all mob entries from the database? THIS CANNOT BE REVERSED.",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function() Reset() end,
	showAlert = true,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

function KT:Purge()
	StaticPopup_Show("KILLTRACK_PURGE")
end

function KT:Reset()
	StaticPopup_Show("KILLTRACK_RESET")
end
