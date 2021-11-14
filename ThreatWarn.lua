local player_guid
local unit_was_affecting_combat
local unit_was_affecting_combat_when

local timeSinceLastUpdate = 0
local combatInterval = 0.1
local function tw_combat_update(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= combatInterval then
        if (UnitAffectingCombat("player")) and unit_was_affecting_combat == false then
          unit_was_affecting_combat_when = GetTime()
          unit_was_affecting_combat = true
        elseif not (UnitAffectingCombat("player")) and unit_was_affecting_combat == true then
          unit_was_affecting_combat = false
        end
        timeSinceLastUpdate = 0
    end
end

local function tw_send_msg(spell_name, miss_type)
  local msg = ">> " .. spell_name .. " " .. miss_type .. " <<"
  if IsInRaid() then
    SendChatMessage(msg,"RAID")
  elseif IsInGroup() then
    SendChatMessage(msg,"PARTY")
  end
end

local function tw_combat_log(...)
  local _, combat_event, _, src_guid = ...
  local spell_id, spell_name = select(12, ...)
  if combat_event == "SPELL_MISSED" and src_guid == player_guid then
    if (spell_id == 33987 or spell_id == 30356 or spell_id == 30357 or spell_id == 26996 or spell_id == 32700 or spell_id == 20271) then 
      local get_time = GetTime()
      if get_time - unit_was_affecting_combat_when <= 10 then
        local miss_type = select(15, ...)
        tw_send_msg(spell_name, miss_type)
      end
    elseif (spell_id == 31789 or spell_id == 355 or spell_id == 6795) then
      local miss_type = select(15, ...)
      tw_send_msg(spell_name, miss_type)
    end
  end
  if (src_guid == player_guid and spell_id == 5209 and combat_event == "SPELL_CAST_SUCCESS") then
    tw_send_msg(spell_name, "CAST")
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
tw_frame:SetScript('OnUpdate', tw_combat_update)
tw_frame:RegisterEvent("PLAYER_LOGIN")

