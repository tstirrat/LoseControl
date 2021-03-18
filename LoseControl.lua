--[[ Code Credits - to the people whose code I borrowed and learned from:
Wowwiki
Kollektiv
Tuller
ckknight
The authors of Nao!!
And of course, Blizzard

Thanks! :)
]]

local L = "LoseControl"

local function log(msg)	DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

-------------------------------------------------------------------------------
local CC      = LOSECONTROL_CC
local Silence = LOSECONTROL_SILENCE
local Disarm  = LOSECONTROL_DISARM
local Root    = LOSECONTROL_ROOT
local Snare   = LOSECONTROL_SNARE
local PvE     = LOSECONTROL_PVE

local spellIds = {
	-- Death Knight
	[47481] = CC,		-- Gnaw (Ghoul)
	[51209] = CC,		-- Hungering Cold
	[47476] = Silence,	-- Strangulate
	[45524] = Snare,	-- Chains of Ice
	[55784] = Snare,	-- Desecration
	[58617] = Snare,	-- Glyph of Heart Strike
	[50436] = Snare,	-- Icy Clutch (Chilblains)
	-- Druid
	[5211]  = CC,		-- Bash (also Shaman Spirit Wolf ability)
	[33786] = CC,		-- Cyclone
	[2637]  = CC,		-- Hibernate (works against Druids in most forms and Shamans using Ghost Wolf)
	[22570] = CC,		-- Maim
	[9005]  = CC,		-- Pounce
	[339]   = Root,		-- Entangling Roots
	[19675] = Root,		-- Feral Charge Effect (immobilize with interrupt [spell lockout, not silence])
	[58179] = Snare,	-- Infected Wounds
	[61391] = Snare,	-- Typhoon
	-- Hunter
	[1499]  = CC,		-- Freezing Trap
	[24394] = CC,		-- Intimidation
	[1513]  = CC,		-- Scare Beast (works against Druids in most forms and Shamans using Ghost Wolf)
	[19503] = CC,		-- Scatter Shot
	[19386] = CC,		-- Wyvern Sting
	[34490] = Silence,	-- Silencing Shot
	[53359] = Disarm,	-- Chimera Shot - Scorpid
	[19306] = Root,		-- Counterattack
	[19185] = Root,		-- Entrapment
	[35101] = Snare,	-- Concussive Barrage
	[5116]  = Snare,	-- Concussive Shot
	--[13810] = Snare,	-- Frost Trap Aura (no duration, lasts as long as you stand in it)
	[61394] = Snare,	-- Glyph of Freezing Trap
	[2974]  = Snare,	-- Wing Clip
	-- Hunter Pets
	[50519] = CC,		-- Sonic Blast (Bat)
	[50541] = Disarm,	-- Snatch (Bird of Prey)
	[54644] = Snare,	-- Froststorm Breath (Chimera)
	[50245] = Root,		-- Pin (Crab)
	[50271] = Snare,	-- Tendon Rip (Hyena)
	[50518] = CC,		-- Ravage (Ravager)
	[54706] = Root,		-- Venom Web Spray (Silithid)
	[4167]  = Root,		-- Web (Spider)
	-- Mage
	[44572] = CC,		-- Deep Freeze
	[31661] = CC,		-- Dragon's Breath
	[12355] = CC,		-- Impact
	[118]   = CC,		-- Polymorph
	[18469] = Silence,	-- Silenced - Improved Counterspell
	[64346] = Disarm,	-- Fiery Payback
	[33395] = Root,		-- Freeze (Water Elemental)
	[122]   = Root,		-- Frost Nova
	[11071] = Root,		-- Frostbite
	[55080] = Root,		-- Shattered Barrier
	[11113] = Snare,	-- Blast Wave
	[6136]  = Snare,	-- Chilled (generic effect, used by lots of spells [looks weird on Improved Blizzard, might want to comment out])
	[120]   = Snare,	-- Cone of Cold
	[116]   = Snare,	-- Frostbolt
	[47610] = Snare,	-- Frostfire Bolt
	[31589] = Snare,	-- Slow
	-- Paladin
	[853]   = CC,		-- Hammer of Justice
	[2812]  = CC,		-- Holy Wrath (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
	[20066] = CC,		-- Repentance
	[20170] = CC,		-- Stun (Seal of Justice proc)
	[10326] = CC,		-- Turn Evil (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
	[63529] = Silence,	-- Shield of the Templar
	[20184] = Snare,	-- Judgement of Justice (not really a snare, druids might want this though)
	-- Priest
	[605]   = CC,		-- Mind Control
	[64044] = CC,		-- Psychic Horror
	[8122]  = CC,		-- Psychic Scream
	[9484]  = CC,		-- Shackle Undead (works against Death Knights using Lichborne)
	[15487] = Silence,	-- Silence
	--[64058] = Disarm,	-- Psychic Horror (duplicate debuff names not allowed atm, need to figure out how to support this later)
	[15407] = Snare,	-- Mind Flay
	-- Rogue
	[2094]  = CC,		-- Blind
	[1833]  = CC,		-- Cheap Shot
	[1776]  = CC,		-- Gouge
	[408]   = CC,		-- Kidney Shot
	[6770]  = CC,		-- Sap
	[1330]  = Silence,	-- Garrote - Silence
	[18425] = Silence,	-- Silenced - Improved Kick
	[51722] = Disarm,	-- Dismantle
	[31125] = Snare,	-- Blade Twisting
	[3409]  = Snare,	-- Crippling Poison
	[26679] = Snare,	-- Deadly Throw
	-- Shaman
	[51880] = CC,		-- Improved Fire Nova Totem
	[39796] = CC,		-- Stoneclaw Stun
	[51514] = CC,		-- Hex (although effectively a silence+disarm effect, it is conventionally thought of as a CC, plus you can trinket out of it)
	[64695] = Root,		-- Earthgrab (Storm, Earth and Fire)
	[63685] = Root,		-- Freeze (Frozen Power)
	--[3600]  = Snare,	-- Earthbind (no duration, lasts as long as you stand in it)
	[8056]  = Snare,	-- Frost Shock
	[8034]  = Snare,	-- Frostbrand Attack
	-- Warlock
	[710]   = CC,		-- Banish (works against Warlocks using Metamorphasis and Druids using Tree Form)
	[6789]  = CC,		-- Death Coil
	[5782]  = CC,		-- Fear
	[5484]  = CC,		-- Howl of Terror
	[6358]  = CC,		-- Seduction (Succubus)
	[30283] = CC,		-- Shadowfury
	[24259] = Silence,	-- Spell Lock (Felhunter)
	[18118] = Snare,	-- Aftermath
	[18223] = Snare,	-- Curse of Exhaustion
	-- Warrior
	[7922]  = CC,		-- Charge Stun
	[12809] = CC,		-- Concussion Blow
	[20253] = CC,		-- Intercept (also Warlock Felguard ability)
	[5246]  = CC,		-- Intimidating Shout
	[12798] = CC,		-- Revenge Stun
	[46968] = CC,		-- Shockwave
	[18498] = Silence,	-- Silenced - Gag Order
	[676]   = Disarm,	-- Disarm
	[58373] = Root,		-- Glyph of Hamstring
	[23694] = Root,		-- Improved Hamstring
	[1715]  = Snare,	-- Hamstring
	[12323] = Snare,	-- Piercing Howl
	-- Other
	[30217] = CC,		-- Adamantite Grenade
	[30216] = CC,		-- Fel Iron Bomb
	[20549] = CC,		-- War Stomp
	[25046] = Silence,	-- Arcane Torrent
	[39965] = Root,		-- Frost Grenade
	[55536] = Root,		-- Frostweave Net
	[13099] = Root,		-- Net-o-Matic
	[29703] = Snare,	-- Dazed
	-- PvE
	[28169] = PvE,		-- Mutating Injection (Grobbulus)
	[28059] = PvE,		-- Positive Charge (Thaddius)
	[28084] = PvE,		-- Negative Charge (Thaddius)
	[27819] = PvE,		-- Detonate Mana (Kel'Thuzad)
	[63024] = PvE,		-- Gravity Bomb (XT-002 Deconstructor)
	[63018] = PvE,		-- Light Bomb (XT-002 Deconstructor)
}
local abilities = {} -- localized names are saved here
for k, v in pairs(spellIds) do
	if GetSpellInfo(k) then
		abilities[GetSpellInfo(k)] = v
	else -- Thanks to inph for this idea. Helps weed out bad spells when Blizzard changes things.
		log(L .. " unknown spellId: " .. k)
	end
end

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	version = 1.4,
	icons = {
		["player"] = {
			enabled = true,
			size = 36,
			alpha = 1,
			point = "CENTER",
			frame = "UIParent",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
		["target"] = {
			enabled = true,
			size = 64,
			alpha = 1,
			point = "CENTER",
			frame = "TargetPortrait",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
		["focus"] = {
			enabled = true,
			size = 52,
			alpha = 1,
			point = "CENTER",
			frame = "FocusPortrait",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
		["party1"] = {
			enabled = true,
			size = 44,
			alpha = 1,
			point = "CENTER",
			frame = "PartyMemberFrame1Portrait",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
		["party2"] = {
			enabled = true,
			size = 44,
			alpha = 1,
			point = "CENTER",
			frame = "PartyMemberFrame2Portrait",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
		["party3"] = {
			enabled = true,
			size = 44,
			alpha = 1,
			point = "CENTER",
			frame = "PartyMemberFrame3Portrait",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
		["party4"] = {
			enabled = true,
			size = 44,
			alpha = 1,
			point = "CENTER",
			frame = "PartyMemberFrame4Portrait",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
		},
	},
	noCooldownCount = false,
	tracking = {
		[CC]      = true,
		[Silence] = true,
		[Disarm]  = true,
		[Root]    = false,
		[Snare]   = false,
		[PvE]     = true,
	},
	--minDuration = 1,
	--maxDuration = 60,
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires

-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown") -- Inherit from Cooldown frame, which exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Handle default settings
function LoseControl:ADDON_LOADED(arg1)
	if arg1 == L then
		if not _G.LoseControlDB or not _G.LoseControlDB.version or _G.LoseControlDB.version < DBdefaults.version then
			_G.LoseControlDB = CopyTable(DBdefaults)
			log(LOSECONTROL_RESET)
		end
		LoseControlDB = _G.LoseControlDB
		LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
	end
end
LoseControl:RegisterEvent("ADDON_LOADED")

-- This function gets reused to update the frame when the defaults are set
function LoseControl:VARIABLES_LOADED() -- fired after all addons and savedvariables are loaded
	local icon = LoseControlDB.icons[self.unitId] -- saves typing below :P
	self:SetWidth(icon.size)
	self:SetHeight(icon.size)
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:SetPoint(icon.point, icon.frame, icon.relativePoint, icon.x, icon.y)
	self:SetAlpha(icon.alpha)
end

-- This is the main event
function LoseControl:UNIT_AURA(unitId) -- fired when a (de)buff is gained/lost
	if unitId ~= self.unitId or not LoseControlDB.icons[unitId].enabled then return end -- only process the frame's unit if they are enabled

	local maxExpirationTime = 0
	local Duration, Icon

	for i = 1, 40 do
		local name, _, icon, _, debuffType, duration, expirationTime = UnitDebuff(unitId, i)

		if not name then break end -- no more debuffs, terminate the loop
		--log(i .. ") " .. name .. " | " .. rank .. " | " .. icon .. " | " .. count .. " | " .. debuffType .. " | " .. duration .. " | " .. expirationTime )

		if LoseControlDB.tracking[abilities[name]]
			and expirationTime > maxExpirationTime
			--and duration >= LoseControlDB.minDuration
			--and duration <= LoseControlDB.maxDuration
			--and not (debuffType == "Poison" and duration == 6) -- hack for Wyvern Sting -- broken in 3.1 because duration was changed to 6 secs down from 10
		then
			maxExpirationTime = expirationTime
			Duration = duration
			Icon = icon
		end
	end

	if maxExpirationTime == 0 then -- no debuffs found
		self.maxExpirationTime = 0
		self:Hide()
	elseif maxExpirationTime ~= self.maxExpirationTime then -- this is a different debuff, so initialize the cooldown
		self.maxExpirationTime = maxExpirationTime
		self.texture:SetTexture(Icon)
		self:Show()
		self:SetCooldown( maxExpirationTime - Duration, Duration )
		self:SetAlpha(LoseControlDB.icons[unitId].alpha) -- hack to apply transparency to the cooldown timer
	end
end

-- Handle mouse dragging
function LoseControl:StopMoving()
	local icon = LoseControlDB.icons[self.unitId]
	icon.point, icon.frame, icon.relativePoint, icon.x, icon.y = self:GetPoint()
	self:StopMovingOrSizing()
end

-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Cooldown")
	setmetatable(o, self)
	self.__index = self

	-- Init class members
	o.unitId = unitId -- ties the object to a unit
	o.texture = o:CreateTexture(nil, "BACKGROUND") -- displays the debuff
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o:SetFrameStrata("MEDIUM") -- so the icon appears on top of party member portraits
	o:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
	o:SetScript("OnDragStop", self.StopMoving) -- this is a custom function
	o:RegisterEvent("VARIABLES_LOADED")
	o:RegisterEvent("UNIT_AURA")

	return o
end

-- Create new object instance for each icon
local LC = {}
for k in pairs(DBdefaults.icons) do
	LC[k] = LoseControl:new(k)
end

-------------------------------------------------------------------------------
-- Add main Interface Option Panel
local O = L .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = L

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(L)

local subText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
local notes = GetAddOnMetadata(L, "Notes-" .. GetLocale())
if not notes then
	notes = GetAddOnMetadata(L, "Notes")
end
subText:SetText(notes)

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O.."Unlock", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."UnlockText"]:SetText(LOSECONTROL_UNLOCK)
Unlock:SetScript("OnClick", function(self)
	if self:GetChecked() then
		_G[O.."UnlockText"]:SetText(LOSECONTROL_UNLOCK .. LOSECONTROL_UNLOCK2)
		local keys = {} -- for random icon sillyness
		for k in pairs(spellIds) do
			tinsert(keys, k)
		end
		for k, v in pairs(LC) do
			BlizzardOptionsPanel_Slider_Enable(v.SizeSlider)
			BlizzardOptionsPanel_Slider_Enable(v.AlphaSlider)
			v:UnregisterEvent("UNIT_AURA")
			v:SetMovable(true)
			v:RegisterForDrag("LeftButton")
			v:EnableMouse(true)
			v.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)]))) --"Interface\\Icons\\Spell_Holy_SealOfMight")
			v:Show()
			v:SetCooldown( GetTime(), 30 )
			v:SetAlpha(LoseControlDB.icons[k].alpha) -- hack to apply the alpha to the cooldown timer
		end
	else
		_G[O.."UnlockText"]:SetText(LOSECONTROL_UNLOCK)
		for k, v in pairs(LC) do
			BlizzardOptionsPanel_Slider_Disable(v.SizeSlider)
			BlizzardOptionsPanel_Slider_Disable(v.AlphaSlider)
			v:RegisterEvent("UNIT_AURA")
			v:SetMovable(false)
			v:RegisterForDrag()
			v:EnableMouse(false)
			v.texture:SetTexture(nil)
			v:Hide()
		end
	end
end)

local DisableCooldownCount = CreateFrame("CheckButton", O.."DisableCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableCooldownCountText"]:SetText(LOSECONTROL_COOLDOWNCOUNT)
DisableCooldownCount:SetScript("OnClick", function(self)
	LoseControlDB.noCooldownCount = self:GetChecked()
	LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
end)

local Tracking = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
Tracking:SetText(LOSECONTROL_TRACKING)

local TrackCCs = CreateFrame("CheckButton", O.."TrackCCs", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackCCsText"]:SetText(CC)
TrackCCs:SetScript("OnClick", function(self)
	LoseControlDB.tracking[CC] = self:GetChecked()
end)

local TrackSilences = CreateFrame("CheckButton", O.."TrackSilences", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackSilencesText"]:SetText(Silence)
TrackSilences:SetScript("OnClick", function(self)
	LoseControlDB.tracking[Silence] = self:GetChecked()
end)

local TrackDisarms = CreateFrame("CheckButton", O.."TrackDisarms", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackDisarmsText"]:SetText(Disarm)
TrackDisarms:SetScript("OnClick", function(self)
	LoseControlDB.tracking[Disarm] = self:GetChecked()
end)

local TrackRoots = CreateFrame("CheckButton", O.."TrackRoots", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackRootsText"]:SetText(Root)
TrackRoots:SetScript("OnClick", function(self)
	LoseControlDB.tracking[Root] = self:GetChecked()
end)

local TrackSnares = CreateFrame("CheckButton", O.."TrackSnares", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackSnaresText"]:SetText(Snare)
TrackSnares:SetScript("OnClick", function(self)
	LoseControlDB.tracking[Snare] = self:GetChecked()
end)

local TrackPvE = CreateFrame("CheckButton", O.."TrackPvE", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackPvEText"]:SetText(PvE)
TrackPvE:SetScript("OnClick", function(self)
	LoseControlDB.tracking[PvE] = self:GetChecked()
end)

--[[
local minDurationSlider = CreateSlider(LOSECONTROL_MINDURATION, OptionsPanel, 0, 30, .5)
minDurationSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(LOSECONTROL_MINDURATION .. " (" .. value .. "s)")
	LoseControlDB.minDuration = value
end)

local maxDurationSlider = CreateSlider(LOSECONTROL_MAXDURATION, OptionsPanel, 0, 60, 1)
maxDurationSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(LOSECONTROL_MAXDURATION .. " (" .. value .. "s)")
	LoseControlDB.maxDuration = value
end)
]]

-- Arrange all the options neatly
title:SetPoint("TOPLEFT", 16, -16)
subText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
Unlock:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -16)
DisableCooldownCount:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 0, -24)
Tracking:SetPoint("TOPLEFT", DisableCooldownCount, "BOTTOMLEFT", 0, -24)
TrackCCs:SetPoint("TOPLEFT", Tracking, "BOTTOMLEFT", 0, -8)
TrackSilences:SetPoint("TOPLEFT", TrackCCs, "TOPRIGHT", 100, 0)
TrackDisarms:SetPoint("TOPLEFT", TrackSilences, "TOPRIGHT", 100, 0)
TrackRoots:SetPoint("TOPLEFT", TrackCCs, "BOTTOMLEFT", 0, -8)
TrackSnares:SetPoint("TOPLEFT", TrackSilences, "BOTTOMLEFT", 0, -8)
TrackPvE:SetPoint("TOPLEFT", TrackDisarms, "BOTTOMLEFT", 0, -8)
--minDurationSlider:SetPoint("TOPLEFT", TrackRoots, "BOTTOMLEFT", 0, -24)
--maxDurationSlider:SetPoint("TOPLEFT", minDurationSlider, "BOTTOMLEFT", 0, -16)

OptionsPanel.default = function() -- This method will run when the player clicks "defaults".
	_G.LoseControlDB.version = nil
	LoseControl:ADDON_LOADED(L)
	for _, v in pairs(LC) do
		v:VARIABLES_LOADED()
	end
end

OptionsPanel.refresh = function() -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above.
	DisableCooldownCount:SetChecked(LoseControlDB.noCooldownCount)
	TrackCCs:SetChecked(LoseControlDB.tracking[CC])
	TrackSilences:SetChecked(LoseControlDB.tracking[Silence])
	TrackDisarms:SetChecked(LoseControlDB.tracking[Disarm])
	TrackRoots:SetChecked(LoseControlDB.tracking[Root])
	TrackSnares:SetChecked(LoseControlDB.tracking[Snare])
	TrackPvE:SetChecked(LoseControlDB.tracking[PvE])
	--minDurationSlider:SetValue(LoseControlDB.minDuration)
	--maxDurationSlider:SetValue(LoseControlDB.maxDuration)
	for k, v in pairs(LC) do
		v.Enabled:SetChecked(LoseControlDB.icons[k].enabled)
		v.SizeSlider:SetValue(LoseControlDB.icons[k].size)
		v.AlphaSlider:SetValue(LoseControlDB.icons[k].alpha * 100)
	end
end

InterfaceOptions_AddCategory(OptionsPanel)

-------------------------------------------------------------------------------
-- Slider helper function, thanks to Kollektiv
local function CreateSlider(text, parent, low, high, step)
	local name = parent:GetName() .. text
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetWidth(160)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText(low)
	_G[name .. "High"]:SetText(high)
	return slider
end

-------------------------------------------------------------------------------
-- Create options frame for each icon
for _, v in ipairs({ "player", "target", "focus", "party1", "party2", "party3", "party4" }) do -- indexed manually so they appear in order
	local OptionsPanelFrame = CreateFrame("Frame", O .. v)
	OptionsPanelFrame.parent = L
	OptionsPanelFrame.name = LOSECONTROL_ICON[v]

	local Enabled = CreateFrame("CheckButton", O .. v .."Enabled", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	_G[O..v.."EnabledText"]:SetText(LOSECONTROL_ENABLED)
	Enabled:SetScript("OnClick", function(self)
		LoseControlDB.icons[v].enabled = self:GetChecked()
	end)

	local SizeSlider = CreateSlider(LOSECONTROL_SIZE, OptionsPanelFrame, 16, 512, 4)
	SizeSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(LOSECONTROL_SIZE .. " (" .. value .. "px)")
		LoseControlDB.icons[v].size = value
		LC[v]:SetWidth(value)
		LC[v]:SetHeight(value)
	end)

	local AlphaSlider = CreateSlider(LOSECONTROL_ALPHA, OptionsPanelFrame, 0, 100, 5) -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
	AlphaSlider:SetScript("OnValueChanged", function(self, value)
		_G[self:GetName() .. "Text"]:SetText(LOSECONTROL_ALPHA .. " (" .. value .. "%)")
		LoseControlDB.icons[v].alpha = value / 100 -- the real alpha value
		LC[v]:SetAlpha(value / 100)
		-- show the frame
	end)

	LC[v].Enabled = Enabled
	LC[v].SizeSlider = SizeSlider
	LC[v].AlphaSlider = AlphaSlider

	BlizzardOptionsPanel_Slider_Disable(SizeSlider) -- disabled by default til unlock
	BlizzardOptionsPanel_Slider_Disable(AlphaSlider) -- disabled by default til unlock

	Enabled:SetPoint("TOPLEFT", 16, -32)
	SizeSlider:SetPoint("TOPLEFT", Enabled, "BOTTOMLEFT", 0, -32)
	AlphaSlider:SetPoint("TOPLEFT", SizeSlider, "BOTTOMLEFT", 0, -32)

	OptionsPanelFrame.default = OptionsPanel.default
	OptionsPanelFrame.refresh = OptionsPanel.refresh

	InterfaceOptions_AddCategory(OptionsPanelFrame)
end

SlashCmdList[L] = function() InterfaceOptionsFrame_OpenToCategory(OptionsPanel) end
SLASH_LoseControl1 = "/lc"
SLASH_LoseControl2 = "/losecontrol"
