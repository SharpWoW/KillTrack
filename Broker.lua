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

KT.Broker = {
	Text = {
		Short = "KPM: %f",
		Long = "Kills Per Minute: %f",
	}
}

local KTB = KT.Broker

local UPDATE = 1
local t = 0

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local data = {
	type = "data source",
	label = "KillTrack |cff00FF00(" .. KT.Version .. ")|r",
	icon = "Interface\\AddOns\\KillTrack\\icon.tga"
}

local obj = ldb:NewDataObject("Broker_KillTrack", data)

function KTB:UpdateText()
	local text = KT.Global.BROKER.SHORT_TEXT and self.Text.Short or self.Text.Long
	obj.text = text:format(KT:GetKPM())
end

function KTB:OnUpdate(frame, elapsed)
	t = t + elapsed
	if t >= UPDATE then
		self:UpdateText()
		t = 0
	end
end

function KTB:ToggleTextMode()
	if type(KT.Global.BROKER) ~= "table" then KT.Global.BROKER = {} end
	KT.Global.BROKER.SHORT_TEXT = not KT.Global.BROKER.SHORT_TEXT
	self:UpdateText()
end

local frame = CreateFrame("Frame")

frame:SetScript("OnUpdate", function(self, elapsed) KTB:OnUpdate(self, elapsed) end)

KTB:UpdateText()
