local is_debugging
local player_guid
local count_delay_from_start

local function tw_combat_log(...)
  local timestamp, combat_event, _, src_guid, src_name, src_flags, src_raid_flags, dst_guid, dst_name, dst_flags, dst_raid_flags = ...
  local spell_id, spell_name = select(12, ...)
  --local spell_id = select(7, GetSpellInfo(spell_name))
  count_delay_from_start = GetTime()
  if is_debugging and ((src_guid == player_guid or src_guid == UnitGUID("target"))) and spell_id == 33987 then
      print(spell_id)
      print(spell_name)
      print(combat_event)
      --print(spell_type)
  end
end

local function tw_on_load(self)
  print("|cFFFFB6C1ThreatWarn|r loaded. Made by Dramamama - Earthshaker.")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  is_debugging = true;
  player_guid = UnitGuid("player")
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