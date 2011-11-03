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

KillTrack.MobList = {}

local KT = KillTrack
local ML = KT.MobList

local Sort = KT.Sort.Desc

local GUI = LibStub("AceGUI-3.0")

local frame, scrollHeader, idHeader, nameHeader, cKillsHeader, gKillsHeader, scrollContainer, scroll

function ML:ShowGUI()
	frame = GUI:Create("Frame")
	frame:SetHeight(600)
	frame:SetWidth(560)
	frame:SetLayout("Flow")
	frame:SetTitle("KillTrack - Mob List")
	frame:SetCallback("OnClose", function(frame) frame:Release() end)

	scrollHeader = GUI:Create("SimpleGroup")
	scrollHeader:SetFullWidth(true)
	scrollHeader:SetLayout("Flow")
	idHeader = GUI:Create("InteractiveLabel")
	idHeader:SetWidth(100)
	idHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
	idHeader:SetText("NPC ID")
	idHeader:SetColor(1, 1, 0)
	idHeader:SetHighlight(0.1, 0.1, 0.1)
	idHeader:SetCallback("OnClick", function()
		if Sort == KT.Sort.IdAsc then
			Sort = KT.Sort.IdDesc
		else
			Sort = KT.Sort.IdAsc
		end
		ML:UpdateList()
	end)
	nameHeader = GUI:Create("InteractiveLabel")
	nameHeader:SetWidth(200)
	nameHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
	nameHeader:SetText("Name")
	nameHeader:SetColor(1, 1, 0)
	nameHeader:SetHighlight(0.1, 0.1, 0.1)
	nameHeader:SetCallback("OnClick", function()
		if Sort == KT.Sort.AlphaA then
			Sort = KT.Sort.AlphaD
		else
			Sort = KT.Sort.AlphaA
		end
		ML:UpdateList()
	end)
	cKillsHeader = GUI:Create("InteractiveLabel")
	cKillsHeader:SetWidth(100)
	cKillsHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
	cKillsHeader:SetText("Character")
	cKillsHeader:SetColor(1, 1, 0)
	cKillsHeader:SetHighlight(0.1, 0.1, 0.1)
	cKillsHeader:SetCallback("OnClick", function()
		if Sort == KT.Sort.CharDesc then
			Sort = KT.Sort.CharAsc
		else
			Sort = KT.Sort.CharDesc
		end
		ML:UpdateList()
	end)
	gKillsHeader = GUI:Create("InteractiveLabel")
	gKillsHeader:SetWidth(100)
	gKillsHeader:SetFont("Fonts\\FRIZQT__.TTF", 12)
	gKillsHeader:SetText("Global")
	gKillsHeader:SetColor(1, 1, 0)
	gKillsHeader:SetHighlight(0.1, 0.1, 0.1)
	gKillsHeader:SetCallback("OnClick", function()
		if Sort == KT.Sort.Desc then
			Sort = KT.Sort.Asc
		else
			Sort = KT.Sort.Desc
		end
		ML:UpdateList()
	end)

	scrollHeader:AddChild(idHeader)
	scrollHeader:AddChild(nameHeader)
	scrollHeader:AddChild(cKillsHeader)
	scrollHeader:AddChild(gKillsHeader)

	scrollContainer = GUI:Create("SimpleGroup")
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)
	scrollContainer:SetLayout("Fill")
	scroll = GUI:Create("ScrollFrame")
	scroll:SetLayout("List")

	scrollContainer:AddChild(scroll)

	frame:AddChild(scrollHeader)
	frame:AddChild(scrollContainer)

	self:UpdateList()
end

function ML:HideGUI()
	frame:Release()
end

function ML:UpdateList()
	if Sort == KT.Sort.IdDesc or Sort == KT.Sort.IdAsc then
		idHeader:SetColor(1, 0, 0)
		nameHeader:SetColor(1, 1, 0)
		cKillsHeader:SetColor(1, 1, 0)
		gKillsHeader:SetColor(1, 1, 0)
	elseif Sort == KT.Sort.AlphaD or Sort == KT.Sort.AlphaA then
		idHeader:SetColor(1, 1, 0)
		nameHeader:SetColor(1, 0, 0)
		cKillsHeader:SetColor(1, 1, 0)
		gKillsHeader:SetColor(1, 1, 0)
	elseif Sort == KT.Sort.CharDesc or Sort == KT.Sort.CharAsc then
		idHeader:SetColor(1, 1, 0)
		nameHeader:SetColor(1, 1, 0)
		cKillsHeader:SetColor(1, 0, 0)
		gKillsHeader:SetColor(1, 1, 0)
	else
		idHeader:SetColor(1, 1, 0)
		nameHeader:SetColor(1, 1, 0)
		cKillsHeader:SetColor(1, 1, 0)
		gKillsHeader:SetColor(1, 0, 0)
	end

	scroll:ReleaseChildren()

	local entries = KT:GetSortedMobTable(Sort)

	for i,v in ipairs(entries) do
		local container = GUI:Create("SimpleGroup")
		container:SetFullWidth(true)
		container:SetLayout("Flow")
		local id = GUI:Create("InteractiveLabel")
		id:SetWidth(100)
		id:SetFont("Fonts\\FRIZQT__.TTF", 12)
		id:SetText(tostring(v.Id))
		id:SetColor(1, 1, 1)
		id:SetHighlight(0.1, 0.1, 0.1)
		id:SetUserData("NPC_ID", v.Id)
		id:SetUserData("NPC_NAME", v.Name)
		id:SetCallback("OnClick", function(self)
			KT:ShowDelete(self:GetUserData("NPC_ID"), self:GetUserData("NPC_NAME"))
		end)
		local name = GUI:Create("Label")
		name:SetWidth(200)
		name:SetFont("Fonts\\FRIZQT__.TTF", 12)
		name:SetText(v.Name)
		name:SetColor(1, 1, 1)
		local cKills = GUI:Create("Label")
		cKills:SetWidth(100)
		cKills:SetFont("Fonts\\FRIZQT__.TTF", 12)
		cKills:SetText(v.cKills)
		cKills:SetColor(1, 1, 1)
		local gKills = GUI:Create("Label")
		gKills:SetWidth(100)
		gKills:SetFont("FRIZQT__.TTF", 12)
		gKills:SetText(v.gKills)
		gKills:SetColor(1, 1, 1)
		container:AddChild(id)
		container:AddChild(name)
		container:AddChild(cKills)
		container:AddChild(gKills)
		scroll:AddChild(container)
	end
	
	frame:SetStatusText(("%d mob entries loaded."):format(#entries))
end
