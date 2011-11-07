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

local MAX_LOAD_INDEX = 200

KillTrack.MobList = {
	LoadWarning = false
}

local KT = KillTrack
local ML = KT.MobList

local Sort = KT.Sort.Desc

local GUI = LibStub("AceGUI-3.0")

local frame, scrollHeader, idHeader, nameHeader, cKillsHeader, gKillsHeader, scrollContainer, scroll, loadButton

local loadFrame = CreateFrame("Frame")

local index = 0
local count = 0

local function update(_, elapsed)
	index = index + 1
	ML:AddItem(index)
	local c = floor((index)/100)
	if c > count and index < MAX_LOAD_INDEX then
		count = count + 1
		--w = c/10
		loadButton:SetDisabled(false)
		loadFrame:SetScript("OnUpdate", nil)
	elseif index >= MAX_LOAD_INDEX and not ML.LoadWarning then
		StaticPopup_Show("KILLTRACK_LOADWARNING")
		ML.LoadWarning = true
		loadFrame:SetScript("OnUpdate", nil)
	elseif index >= #KT.Temp.MobEntries then
		index = 0
		count = 0
		ML.LoadWarning = false
		frame:SetStatusText(("%d/%d mob entries loaded."):format(#KT.Temp.MobEntries, #KT.Temp.MobEntries))
		loadButton:SetDisabled(true)
		loadFrame:SetScript("OnUpdate", nil)
	end
end

StaticPopupDialogs["KILLTRACK_LOADWARNING"] = {
	text = "\124cffFF0000*** WARNING ***\124r\nLoading more than 200 entries may cause severe lag or client crashes.\nDo you want to continue?",
	button1 = "Continue",
	button2 = "Purge",
	button3 = "Cancel",
	OnAccept = function() loadFrame:SetScript("OnUpdate", update) end,
	OnCancel = function() index = 0 count = 0 ML.LoadWarning = false ML:HideGUI() KT:ShowPurge() end, -- This is actually button2, not 3
	OnAlt = function() index = 0 end,
	showAlert = true,
	timeout = 0,
	hideOnEscape = false,
	whileDead = true
}

function ML:ShowGUI()
	frame = GUI:Create("Frame")
	frame:SetHeight(600)
	frame:SetWidth(560)
	frame:SetLayout("Flow")
	frame:SetTitle("KillTrack - Mob List")
	frame:SetCallback("OnClose", function(frame) frame:Release() end)

	local loadHeader = GUI:Create("SimpleGroup")
	loadHeader:SetFullWidth(true)
	loadHeader:SetLayout("Flow")
	loadButton = GUI:Create("Button")
	loadButton:SetText("Load more entries")
	loadButton:SetFullWidth(true)
	loadButton:SetHeight(24)
	loadButton:SetCallback("OnClick", function(button)
		button:SetDisabled(true)
		loadFrame:SetScript("OnUpdate", update)
	end)
	loadButton:SetDisabled(true)
	loadHeader:AddChild(loadButton)

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
		loadButton:SetDisabled(true)
		index = 0
		count = 0
		ML.LoadWarning = false
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
		loadButton:SetDisabled(true)
		index = 0
		count = 0
		ML.LoadWarning = false
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
		loadButton:SetDisabled(true)
		index = 0
		count = 0
		ML.LoadWarning = false
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
		loadButton:SetDisabled(true)
		index = 0
		count = 0
		ML.LoadWarning = false
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

	frame:AddChild(loadHeader)
	frame:AddChild(scrollHeader)
	frame:AddChild(scrollContainer)

	self:UpdateList()
end

function ML:HideGUI()
	frame:Release()
end

function ML:AddItem(index)
	local entry = KT.Temp.MobEntries[index]
	local container = GUI:Create("SimpleGroup")
	container:SetFullWidth(true)
	container:SetLayout("Flow")
	local id = GUI:Create("InteractiveLabel")
	id:SetWidth(100)
	id:SetFont("Fonts\\FRIZQT__.TTF", 12)
	id:SetText(tostring(entry.Id))
	id:SetColor(1, 1, 1)
	id:SetHighlight(0.1, 0.1, 0.1)
	id:SetUserData("NPC_ID", entry.Id)
	id:SetUserData("NPC_NAME", entry.Name)
	id:SetCallback("OnClick", function(self)
		KT:ShowDelete(self:GetUserData("NPC_ID"), self:GetUserData("NPC_NAME"))
	end)
	local name = GUI:Create("Label")
	name:SetWidth(200)
	name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	name:SetText(entry.Name)
	name:SetColor(1, 1, 1)
	local cKills = GUI:Create("Label")
	cKills:SetWidth(100)
	cKills:SetFont("Fonts\\FRIZQT__.TTF", 12)
	cKills:SetText(entry.cKills)
	cKills:SetColor(1, 1, 1)
	local gKills = GUI:Create("Label")
	gKills:SetWidth(100)
	gKills:SetFont("Fonts\\FRIZQT__.TTF", 12)
	gKills:SetText(entry.gKills)
	gKills:SetColor(1, 1, 1)
	container:AddChild(id)
	container:AddChild(name)
	container:AddChild(cKills)
	container:AddChild(gKills)
	scroll:AddChild(container)
	frame:SetStatusText(("%d/%d mob entries loaded."):format(index, #KT.Temp.MobEntries))
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

	KT.Temp.MobEntries = KT:GetSortedMobTable(Sort)

	loadFrame:SetScript("OnUpdate", update)

	--[[
	local co = coroutine.create(AddItems)

	while coroutine.status(co) ~= "dead" do
		local errorfree, count, container = coroutine.resume(co)
		if errorfree then
			scroll:AddChild(container)

		else
			message("Unknown error encountered while loading mob list.")
			error("Unknown error encountered while loading mob list.")
		end
	end

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
	--]]
end
