--[[
    * Copyright (c) 2011-2014 by Adam Hellberg.
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

KT.ExpTracker = {
    Strings = {
        COMBATLOG_XPGAIN_EXHAUSTION1,       -- "%s dies, you gain %d experience. (%s exp %s bonus)";
        COMBATLOG_XPGAIN_EXHAUSTION1_GROUP, -- "%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)";
        COMBATLOG_XPGAIN_EXHAUSTION1_RAID,  -- "%s dies, you gain %d experience. (%s exp %s bonus, -%d raid penalty)";
        COMBATLOG_XPGAIN_EXHAUSTION2,       -- "%s dies, you gain %d experience. (%s exp %s bonus)";
        COMBATLOG_XPGAIN_EXHAUSTION2_GROUP, -- "%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)";
        COMBATLOG_XPGAIN_EXHAUSTION2_RAID,  -- "%s dies, you gain %d experience. (%s exp %s bonus, -%d raid penalty)";
        COMBATLOG_XPGAIN_EXHAUSTION4,       -- "%s dies, you gain %d experience. (%s exp %s penalty)";
        COMBATLOG_XPGAIN_EXHAUSTION4_GROUP, -- "%s dies, you gain %d experience. (%s exp %s penalty, +%d group bonus)";
        COMBATLOG_XPGAIN_EXHAUSTION4_RAID,  -- "%s dies, you gain %d experience. (%s exp %s penalty, -%d raid penalty)";
        COMBATLOG_XPGAIN_EXHAUSTION5,       -- "%s dies, you gain %d experience. (%s exp %s penalty)";
        COMBATLOG_XPGAIN_EXHAUSTION5_GROUP, -- "%s dies, you gain %d experience. (%s exp %s penalty, +%d group bonus)";
        COMBATLOG_XPGAIN_EXHAUSTION5_RAID,  -- "%s dies, you gain %d experience. (%s exp %s penalty, -%d raid penalty)";
        COMBATLOG_XPGAIN_FIRSTPERSON,       -- "%s dies, you gain %d experience.";
        COMBATLOG_XPGAIN_FIRSTPERSON_GROUP, -- "%s dies, you gain %d experience. (+%d group bonus)";
        COMBATLOG_XPGAIN_FIRSTPERSON_RAID   -- "%s dies, you gain %d experience. (-%d raid penalty)";
    }
}

local ET = KT.ExpTracker

function ET:CheckMessage(message)
    local name, exp
    for i = 1, #self.Strings do
        local str = self.Strings[i]
        name, exp = message:match(str)
    end

    
end
