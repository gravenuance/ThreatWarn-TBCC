local player_guid
local unit_was_affecting_combat
local unit_was_affecting_combat_when

local single_target_threat_spells = {[33987] = 1, [30356] = 1, [30357] = 1, [26996]=1, [32700]=1, [20271]=1}
local taunt_spells = {[31789]=1, [355]=1, [6795]=1}
local aoe_threat_spells = {[5209]=1, [1161]=1}

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
  if (single_target_threat_spells[spell_id] ~= nil) then 
    local get_time = GetTime()
    if get_time - unit_was_affecting_combat_when <= 10 then
      local msg
      if combat_event == "SPELL_MISSED" and src_guid == player_guid then
        msg = select(15, ...)
        if (msg == "ABSORB") then
          return
        end
        tw_send_msg(spell_name, msg)
      else
        local crit = select(21, ...)
        if crit and src_guid == player_guid then
          tw_send_msg(spell_name, "CRITICAL")
        end
      end
    end
  elseif (taunt_spells[spell_id] ~= nil) then
    if combat_event == "SPELL_MISSED" and src_guid == player_guid then
      local msg = select(15, ...)
      tw_send_msg(spell_name, msg)
    end
  end
  if (src_guid == player_guid and (aoe_threat_spells[spell_id]~=nil) and combat_event == "SPELL_CAST_SUCCESS") then
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

