local player_guid
local unit_was_affecting_combat
local unit_was_affecting_combat_when

local combatInterval = 0.1
local function tw_combat_update(self, elapsed)
    self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
    if self.timeSinceLastUpdate >= combatInterval then
        if (UnitAffectingCombat("player")) and unit_was_affecting_combat == false then
          unit_was_affecting_combat_when = GetTime()
          unit_was_affecting_combat = true
        elseif (UnitAffectingCombat("player")) and unit_was_affecting_combat == true then
          unit_was_affecting_combat = false
        end
        self.timeSinceLastUpdate = 0
    end
end

local function tw_combat_log(...)
  local timestamp, combat_event, _, src_guid, src_name, src_flags, src_raid_flags, dst_guid, dst_name, dst_flags, dst_raid_flags = ...
  local spell_id, spell_name = select(12, ...)
  if (spell_id == 33987 or spell_id == 30356 or spell_id == 30357) and combat_event == "SPELL_MISSED" and src_guid == player_guid then
    local get_time = GetTime()
    if get_time - unit_was_affecting_combat_when <= 10 then
      local miss_type = select(15, ...)
      local msg = ">> " .. spell_name .. " " .. miss_type .. " <<"
      if IsInRaid() then
        SendChatMessage(msg,"RAID")
      elseif IsInGroup() then
        SendChatMessage(msg,"PARTY")
      else
        SendChatMessage(msg,"SAY")
      end
    end
  end
end

local function tw_on_load(self)
  print("|cFFFFB6C1ThreatWarn|r loaded.")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  player_guid = UnitGUID("player")
  unit_was_affecting_combat = false
  unit_was_affecting_combat_when = GetTime()
end

local event_handler = {
  ["PLAYER_LOGIN"] = function(self) tw_on_load(self) end,
  ["COMBAT_LOG_EVENT_UNFILTERED"] = function(self, ...) tw_combat_log(CombatLogGetCurrentEventInfo()) end,
}

local function tw_on_event(self,event, ...)
event_handler[event](self, event, ...)
end

if not tw_frame then 
  CreateFrame("Frame","tw_frame",UIParent)
end
tw_frame:SetScript("OnEvent",tw_on_event)
tw_frame:RegisterEvent("PLAYER_LOGIN")
tw_frame:SetScript('OnUpdate', tw_combat_update)
tw_frame.timeSinceLastUpdate = 0