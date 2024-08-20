stds.wow = {
  globals = {
    _G = {
      other_fields = true
    },
    SlashCmdList = {
      other_fields = true
    },
    StaticPopupDialogs = {
      other_fields = true
    }
  },
  read_globals = {
    "BackdropTemplateMixin",
    "C_AddOns",
    "ChatTypeInfo",
    "CombatLogGetCurrentEventInfo",
    "COMBATLOG_XPGAIN_EXHAUSTION1",
    "COMBATLOG_XPGAIN_EXHAUSTION1_GROUP",
    "COMBATLOG_XPGAIN_EXHAUSTION1_RAID",
    "COMBATLOG_XPGAIN_EXHAUSTION2",
    "COMBATLOG_XPGAIN_EXHAUSTION2_GROUP",
    "COMBATLOG_XPGAIN_EXHAUSTION2_RAID",
    "COMBATLOG_XPGAIN_EXHAUSTION4",
    "COMBATLOG_XPGAIN_EXHAUSTION4_GROUP",
    "COMBATLOG_XPGAIN_EXHAUSTION4_RAID",
    "COMBATLOG_XPGAIN_EXHAUSTION5",
    "COMBATLOG_XPGAIN_EXHAUSTION5_GROUP",
    "COMBATLOG_XPGAIN_EXHAUSTION5_RAID",
    "COMBATLOG_XPGAIN_FIRSTPERSON",
    "COMBATLOG_XPGAIN_FIRSTPERSON_GROUP",
    "COMBATLOG_XPGAIN_FIRSTPERSON_RAID",
    "CreateFrame",
    "date",
    "DEFAULT_CHAT_FRAME",
    "Enum",
    "GetServerTime",
    "FauxScrollFrame_GetOffset",
    "FauxScrollFrame_OnVerticalScroll",
    "FauxScrollFrame_Update",
    "floor",
    "GameMenuFrame",
    "GameTooltip",
    "GetAddOnMetadata",
    "HideUIPanel",
    "InterfaceOptionsFrame",
    "InterfaceOptions_AddCategory",
    "InterfaceOptionsFrame_OpenToCategory",
    "IsAddOnLoaded",
    "IsControlKeyDown",
    "IsGUIDInGroup",
    "IsInGroup",
    "IsInRaid",
    "IsShiftKeyDown",
    "PlaySound",
    "RaidBossEmoteFrame",
    "RaidNotice_AddMessage",
    "RaidWarningFrame",
    "SendChatMessage",
    "Settings",
    "SOUNDKIT",
    "StaticPopup_Show",
    "time",
    "TooltipDataProcessor",
    "UIParent",
    "UnitCanAttack",
    "UnitExists",
    "UnitGUID",
    "UnitInParty",
    "UnitInRaid",
    "UnitIsPlayer",
    "UnitIsTapDenied",
    "UnitName",
    "UnitTokenFromGUID",
    "UnitXP",
    "UnitXPMax",
    "wipe",
    "WOW_PROJECT_ID",
    "WOW_PROJECT_MAINLINE"
  }
}

stds.externs = {
  read_globals = {
    "LibStub"
  }
}

std = "lua51+wow+externs"
max_line_length = 120
codes = true

ignore = {
  "212/self"
}

files = {
}

exclude_files = {
  "libs/LibDataBroker-1-1",
  ".luacheckrc",
  ".release"
}
