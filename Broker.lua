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
		Short = "KPM: %.2f",
		Long = "Kills Per Minute: %.2f"
	}
}

local KTB = KT.Broker

local UPDATE = 1
local t = 0

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local frame = CreateFrame("Frame")

local data = {
	type = "data source",
	label = KT.Name,
	icon = "Interface\\AddOns\\KillTrack\\icon.tga",
	tocname = KT.Name
}

local obj = ldb:NewDataObject("Broker_KillTrack", data)

function obj.OnTooltipShow(tip)
	tip:AddLine(("%s |cff00FF00(%s)|r"):format(KT.Name, KT.Version), 1, 1, 1)
	tip:AddLine(" ")
	tip:AddLine("Most kills this session:", 1, 1, 0)
	local added = 0
	for k,v in pairs(KT.Session.Kills) do
		tip:AddDoubleLine(k, v)
		added = added + 1
	end
	if added <= 0 then
		tip:AddLine("No kills this session", 1, 0, 0)
	end
	tip:AddLine(" ")
	tip:AddLine("Most kills total:", 1, 1, 0)
	local added = 0
	for _,v in pairs(KT:GetSortedMobTable()) do
		tip:AddDoubleLine(v.Name, ("%d (%d)"):format(v.cKills, v.gKills))
		added = added + 1
		if added >= 3 then break end
	end
	if added <= 0 then
		tip:AddLine("No kills recorded yet", 1, 0, 0)
	end
	tip:AddLine(" ")
	tip:AddDoubleLine("Left Click", "Open mob database", 0, 1, 0, 0, 1, 0)
	tip:AddDoubleLine("Middle Click", "Toggle short/long text", 0, 1, 0, 0, 1, 0)
	tip:AddDoubleLine("Right Click", "Reset session statistics", 0, 1, 0, 0, 1, 0)
	tip:Show()
end

function obj.OnClick(self, button)
	if button == "LeftButton" then
		KT.MobList:ShowGUI()
	elseif button == "MiddleButton" then
		KTB:ToggleTextMode()
	elseif button == "RightButton" then
		KT:ResetSession()
	end
end

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
	KT.Global.BROKER.SHORT_TEXT = not KT.Global.BROKER.SHORT_TEXT
	self:UpdateText()
end

function KTB:OnLoad()
	frame:SetScript("OnUpdate", function(self, elapsed) KTB:OnUpdate(self, elapsed) end)
	self:UpdateText()
end
