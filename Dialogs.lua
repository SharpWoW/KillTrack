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

StaticPopupDialogs["KILLTRACK_FINISH"] = {
	text = "%s entries removed.",
	button1 = "Okay",
	timeout = 10,
	enterClicksFirstButton = true,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["KILLTRACK_DELETE"] = {
	text = "Delete %s with ID %s?",
	button1 = "Delete all",
	button2 = "Character only",
	button3 = "Cancel",
	OnAccept = function() KT:Delete(KT.Temp.DeleteId) end,
	OnCancel = function() KT:Delete(KT.Temp.DeleteId, true) end, -- Cancel is actually the second (button2) button.
	showAlert = true,
	timeout = 10,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["KILLTRACK_PURGE"] = {
	text = "Remove all mob entries with their kill count below this treshold:",
	button1 = "Purge",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self, data, data2) KT:Purge(tonumber(self.editBox:GetText())) end,
	OnCancel = function() KT.Temp.Treshold = nil end,
	OnShow = function(self, data)
		if tonumber(KT.Temp.Treshold) then
			self.editBox:SetText(tostring(KT.Temp.Treshold))
		else
			self.button1:Disable()
		end
	end,
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
	OnAccept = function() KT:Reset() end,
	showAlert = true,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

function KT:ShowDelete(id, name)
	id = tonumber(id)
	name = tostring(name)
	if not id then error("'id' must be a number.") end
	self.Temp.DeleteId = id
	StaticPopup_Show("KILLTRACK_DELETE", name, id)
end

function KT:ShowPurge(treshold)
	if tonumber(treshold) then
		self.Temp.Treshold = tonumber(treshold)
	end
	StaticPopup_Show("KILLTRACK_PURGE")
end

function KT:ShowReset()
	StaticPopup_Show("KILLTRACK_RESET")
end
