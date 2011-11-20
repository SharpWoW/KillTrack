--

local BAR_MAX_WIDTH = 190

local function Enabled(object, enabled)
	if not object.Enable or not object.Disable then return end
	if enabled then
		object:Enable()
	else
		object:Disable()
	end
end

local function Toggle(object)
	if not object.IsEnabled or not object.Enable or not object.Disable then return end
	if object:IsEnabled() then
		object:Disable()
	else
		object:Enable()
	end
end

KillTrack.TimerFrame = {
	Running = false
}

local KT = KillTrack
local TF = KT.TimerFrame
local T = KillTrack.Timer

function TF:InitializeControls()
	KillTrackTimerFrame_CurrentCount:SetText("0")
	KillTrackTimerFrame_TimeCount:SetText("00:00:00")
	KillTrackTimerFrame_ProgressLabel:SetText("0%")
	KillTrackTimerFrame_ProgressBar:SetWidth(0.01)
	self:UpdateControls()
end

function TF:UpdateControls()
	Enabled(KillTrackTimerFrame_CancelButton, self.Running)
	Enabled(KillTrackTimerFrame_CloseButton, not self.Running)
end

function TF:UpdateData(data, state)
	if state == T.State.START then
		self:InitializeControls()
	else
		local kills = T:GetData("Kills", true)
		local kpm, kps
		if data.Current <= 0 then
			kpm, kps = 0, 0
		else
			kpm = kills / (data.Current / 60)
			kps = kills / data.Current
		end
		KillTrackTimerFrame_CurrentCount:SetText(kills)
		KillTrackTimerFrame_TimeCount:SetText(data.LeftFormat)
		KillTrackTimerFrame_ProgressLabel:SetText(floor(data.Progress*100) .. "%")
		KillTrackTimerFrame_ProgressBar:SetWidth(data.Progress <= 0 and 0.01 or BAR_MAX_WIDTH * data.Progress)
		KillTrackTimerFrame_KillsPerMinuteCount:SetText(("%.2f"):format(kpm))
		KillTrackTimerFrame_KillsPerSecondCount:SetText(("%.2f"):format(kps))
		if state == T.State.STOP then self:Stop() end
	end
	self:UpdateControls()
end

function TF:Start(s, m, h)
	if self.Running then return end
	self.Running = true
	self:InitializeControls()
	KillTrackTimerFrame:Show()
	T:Start(s, m, h, function(d, u) TF:UpdateData(d, u) end, nil)
end

function TF:Stop()
	if not self.Running then return end
	self.Running = false
end

function TF:Cancel()
	T:Stop()
end

function TF:Close()
	self:InitializeControls()
	KillTrackTimerFrame:Hide()
end
