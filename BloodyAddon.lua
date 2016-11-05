local ADDON, data = ...

g_BloodyAddon_config = g_BloodyAddon_config or {}

local SPELL_IDS = {
	BloodShield = 77535,
    BoneShield = 49222,
    RuneWeapon = 81256,
    VampiricBlood = 55233,
    IceFort = 48792,
}

--[[
Future features to think about:
* Icebound Fortitude
* AMS
* Make the bones/ blood/ sword disappear when off (optional)
* Smooth movement for the main bar (at the cost of more CPU)
* Show the remaining duration for blood shield? Optional?
* Make the whole thing resizeable 
* Goddamnit what are they adding in 6.0?!

]]

local UnitHealthMax = UnitHealthMax
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

------------------------------------------------------------------

local function GetAuraData (aura)
    -- Returns time remaining, value, duration
    local name, _, _, _, _, duration, expires, _, _, _, _, _, _, _, value2 = UnitAura ('player', aura)
    if name==nil then
        return 0,0
    else
        return expires-GetTime(), value2, duration
    end
end

------------------------------------------------------------------

local function ShortNumber (n)
    if n<1000 then
        return tostring(n)
    elseif n<1000000 then
        return tostring(floor((n+500)/1000))..'K'
    else
        return tostring(floor((n+500000)/1000000))..'M'
    end
end

------------------------------------------------------------------

PlayerAuras = {}
local function ScanPlayerAuras ()
    -- Fills the PlayerAuras table with aura data. The keys are spell IDs, and each value is a table containing name, duration, expires, value2
	--CHANGES:Lanrutcon: value1 (the arg before value2) returns the values of buffs/debuffs (CATA)
    local i=1
    PlayerAuras = {}
	local name, count, duration, expires, spellID, value2, _
    
    -- Scan buffs
    while true do
        local name,_,_,count,_, duration, expires,_,_,_,spellID,_,_,value1, value2 = UnitBuff('player', i)
        i = i+1
        if name then
            PlayerAuras[spellID] = {duration=duration, expires=expires, value2=value1, name=name, count=count}
        else
            break
        end        
    end
    
	i=1
    -- Scan debuffs
    while true do
        local name,_,_,count,_, duration, expires,_,_,_,spellID,_,_,value1, value2 = UnitDebuff('player', i)
        i = i+1
        if name then
            PlayerAuras[spellID] = {duration=duration, expires=expires, value2=value1, name=name, count=count}
	    else
            break
        end        
    end
end


------------------------------------------------------------------

--CHANGES:Lanrutcon: there is no 3rd value in UnitClass.
local _,className, class = UnitClass('player')
if className=="DEATHKNIGHT" then                                                                              -- don't forget to check spec too......
    -- Main bar
    local f = CreateFrame ("Frame", 'frmBloodyAddon', UIParent)
    f:SetSize (120,120)
    f:SetPoint ("LEFT", UIParent, "LEFT", 250,0)
    f:SetFrameLevel (8)
    f:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\barbg'})
    
    f.head = CreateFrame ("Frame", '',f)
    f.head:SetSize(117,60)
    f.head:SetPoint ("TOP", f, "TOP",0,28)
    f.head:SetFrameLevel (10)
    f.head:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\head'})

    f.bar = CreateFrame ("StatusBar", nil, f)
    f.bar:SetSize(108,120)
    f.bar:SetPoint ("BOTTOM", f, "BOTTOM", 0.5, 1.5)
    f.bar:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\bar')
    f.bar:SetOrientation ("VERTICAL")
    f.bar:SetMinMaxValues (0,10)
    f.bar:SetFrameLevel (9)
    f.bar:SetValue(0)
    f.bar.val = 0
    function f.bar:OnUpdate ()
        self.time = GetTime()
        if self.time <= self.expires then
            self:GetParent().txtTime:SetText (string.format ("%2.1f", self.expires - self.time))
        end
    end

	-- Text
	f.txtTime = f.bar:CreateFontString(nil, "HIGH", "GameFontNormal")
    f.txtTime:SetSize (f:GetWidth(), 20)
	f.txtTime:SetPoint ("CENTER", f.bar, "CENTER", 0, 0)
	f.txtTime:SetJustifyH ("CENTER")
    f.txtTime:SetJustifyV ("CENTER")
	f.txtTime:SetFont ('Fonts\\FRIZQT__.TTF', 13, "")
	f.txtTime:SetTextColor (0.7,0.9,1)

    f.frost = CreateFrame ("StatusBar", nil, f)
    f.frost:SetSize(160,160)
    f.frost:SetPoint ("BOTTOM", f, "BOTTOM", 0.5, -5)
    f.frost:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\frost')
    f.frost:SetOrientation ("VERTICAL")
    f.frost:SetMinMaxValues (0,10)
    f.frost:SetFrameLevel (15)
    f.frost:SetValue(10)
    f.frost.val = 0

    f.mouth = CreateFrame ("Frame", nil, f)
    f.mouth:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\mouth'})
    f.mouth:SetSize (35,35)
    f.mouth:SetFrameLevel (14)
    f.mouth:SetPoint ("TOP", f.head, "TOP", 1, -21)
    
    function f:Update ()
        if PlayerAuras[SPELL_IDS.BloodShield] then
            self.bar.val = PlayerAuras[SPELL_IDS.BloodShield].value2
            self.bar.expires = PlayerAuras[SPELL_IDS.BloodShield].expires
            --self.bar.duration = PlayerAuras[SPELL_IDS.BloodShield].duration
            self.bar:SetScript ("OnUpdate", self.bar.OnUpdate)
        else
            self.bar:SetScript ("OnUpdate", nil)
            self.bar.val = 0
            self.txtTime:SetText ('')
        end
        self.bar:SetValue (self.bar.val)
    end
    
    -- Bones
    f.bones = CreateFrame ("Frame", '',f)
    f.bones:SetSize(130,65)
    f.bones:SetPoint ("BOTTOM", f, "BOTTOM",0,-25)
    f.bones:SetFrameLevel (8)
    f.bones:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\bonesbg'})
    f.bones.val = 0
    function f.bones:Update ()
        if PlayerAuras[SPELL_IDS.BoneShield] then
            self.val = PlayerAuras[SPELL_IDS.BoneShield].count
            self:Show ()
        else
            self.val = 0
			--self:SetShown (not g_BloodyAddon_config.hideWhenInactive)
			if(not g_BloodyAddon_config.hideWhenInactive) then
				self:Show()
			end
        end
        self.right:SetValue (self:BoneShieldStacksToBarValue (self.val-3))
        self.left:SetValue (self:BoneShieldStacksToBarValue (self.val))
    end
    
    f.bones.left = CreateFrame ("StatusBar", nil, f.bones)
    f.bones.left:SetSize(65,65)
    f.bones.left:SetPoint ("TOPLEFT", f.bones, "TOPLEFT")
    f.bones.left:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\bonesleft')
    f.bones.left:SetOrientation ("VERTICAL")
    f.bones.left:SetMinMaxValues (0,10)
    f.bones.left:SetFrameLevel (10)
    f.bones.left:SetValue(0)

    f.bones.right = CreateFrame ("StatusBar", nil, f.bones)
    f.bones.right:SetSize(65,65)
    f.bones.right:SetPoint ("TOPRIGHT", f.bones, "TOPRIGHT")
    f.bones.right:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\bonesright')
    f.bones.right:SetOrientation ("VERTICAL")
    f.bones.right:SetMinMaxValues (0,10)
    f.bones.right:SetFrameLevel (10)
    f.bones.right:SetValue(0)

    function f.bones:BoneShieldStacksToBarValue (v)
        if v<1 then 
            return 0
        elseif v==1 then 
            return 4
        elseif v==2 then 
            return 6
        else 
            return 10
        end
    end
    
    -- Sword
    f.sword = CreateFrame ("Frame", '',f)
    f.sword:SetSize(60,120)
    f.sword:SetPoint ("LEFT", f, "LEFT",-24,20)
    f.sword:SetFrameLevel (9)
    f.sword:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\swordbg'})
    f.sword.id = SPELL_IDS.RuneWeapon
    function f.sword:Update () 
        if PlayerAuras[self.id] then
            self.bar:SetMinMaxValues (PlayerAuras[self.id].duration * 60 * (-0.13), PlayerAuras[self.id].duration * 60 * 1.15)
            self.bar:SetScript ("OnUpdate", self.bar.OnUpdate)
            self:Show ()
        else
            self.bar:SetScript ("OnUpdate", nil)
            self.bar:SetValue (0)
            --self:SetShown (not g_BloodyAddon_config.hideWhenInactive)
			if(not g_BloodyAddon_config.hideWhenInactive) then
				self:Show()
			end
        end
    end
    
    f.sword.bar = CreateFrame ("StatusBar", nil, f.sword)
    f.sword.bar:SetSize(60,120)
    f.sword.bar:SetPoint ("CENTER", f.sword, "CENTER",0.4,0)
    f.sword.bar:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\sword')
    f.sword.bar:SetOrientation ("VERTICAL")
    f.sword.bar:SetMinMaxValues (-12,100)
    f.sword.bar:SetFrameLevel (10)
    f.sword.bar:SetValue(0)
    function f.sword.bar:OnUpdate ()
        self:SetValue (60 * (PlayerAuras[self:GetParent().id].expires - GetTime()))
    end
    
    -- Blood
    f.blood = CreateFrame ("Frame", '',f)
    f.blood:SetSize(60,120)
    f.blood:SetPoint ("RIGHT", f, "RIGHT",22,15)
    f.blood:SetFrameLevel (8)
    f.blood:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\bloodbg'})
    f.blood.id = SPELL_IDS.VampiricBlood
    function f.blood:Update ()
        if PlayerAuras[self.id] then
            self.bar:SetMinMaxValues (PlayerAuras[self.id].duration * 60 * (-0.33), PlayerAuras[self.id].duration * 60 * 1.32)
            self.bar:SetScript ("OnUpdate", self.bar.OnUpdate)
            self:Show ()
        else
            self.bar:SetScript ("OnUpdate", nil)
            self.bar:SetValue (0)
            --self:SetShown (not g_BloodyAddon_config.hideWhenInactive)
			if(not g_BloodyAddon_config.hideWhenInactive) then
				self:Show()
			end
        end
    end
    
    f.blood.bar = CreateFrame ("StatusBar", nil, f.blood)
    f.blood.bar:SetSize(60,120)
    f.blood.bar:SetPoint ("CENTER", f.blood, "CENTER",0,-0.5)
    f.blood.bar:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\blood')
    f.blood.bar:SetOrientation ("VERTICAL")
    f.blood.bar:SetMinMaxValues (-12,100)
    f.blood.bar:SetFrameLevel (10)
    f.blood.bar:SetValue(0)
    function f.blood.bar:OnUpdate ()
        self:SetValue (60 * (PlayerAuras[self:GetParent().id].expires - GetTime()))
    end

    -- Shard
    f.shard = CreateFrame ("Frame", '',f)
    f.shard:SetSize(30,190)
    f.shard:SetPoint ("LEFT", f, "LEFT",-37,7)
    f.shard:SetFrameLevel (9)
    f.shard:SetBackdrop ({bgFile='Interface\\addons\\'..ADDON..'\\shardbg'})
    f.shard.id = SPELL_IDS.IceFort
    function f.shard:Update () 
        if PlayerAuras[self.id] then
            self.bar:SetMinMaxValues (PlayerAuras[self.id].duration * 60 * (-0.07), PlayerAuras[self.id].duration * 60 * 1.08)
            self.bar:SetScript ("OnUpdate", self.bar.OnUpdate)
            self:GetParent().frost:Show ()
            self:GetParent().mouth:Show ()
            self:GetParent().bar:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\barfrozen')
            self:Show ()
        else
            self.bar:SetScript ("OnUpdate", nil)
            self.bar:SetValue (0)
            self:GetParent().frost:Hide ()
            self:GetParent().mouth:Hide ()
            self:GetParent().bar:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\bar')
            --self:SetShown (not g_BloodyAddon_config.hideWhenInactive)
			if(not g_BloodyAddon_config.hideWhenInactive) then
				self:Show()
			end
        end
    end
    
    f.shard.bar = CreateFrame ("StatusBar", nil, f.shard)
    f.shard.bar:SetSize(30,190)
    f.shard.bar:SetPoint ("CENTER", f.shard, "CENTER",0,0)
    f.shard.bar:SetStatusBarTexture('Interface\\addons\\'..ADDON..'\\shard')
    f.shard.bar:SetOrientation ("VERTICAL")
    f.shard.bar:SetMinMaxValues (-8,100)
    f.shard.bar:SetFrameLevel (10)
    f.shard.bar:SetValue(0)
    function f.shard.bar:OnUpdate ()
        self:SetValue (60 * (PlayerAuras[self:GetParent().id].expires - GetTime()))
    end
    
    -- Make movable
    f:SetMovable (true)
    f:SetUserPlaced (true)
    f:SetClampedToScreen (true)
    f:SetScript("OnMouseDown", function(self, button)
		if button=='LeftButton' then
			self:StartMoving ()
		end
	end)
	f:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing ()
	end)

    f.head:SetScript("OnMouseDown", function(self, button)
		if button=='LeftButton' then
			self:GetParent():StartMoving ()
		end
	end)
	f.head:SetScript("OnMouseUp", function(self)
		self:GetParent():StopMovingOrSizing ()
	end)
    f:EnableMouse (g_BloodyAddon_config.clickThrough)
    f.head:EnableMouse (g_BloodyAddon_config.clickThrough)
    
    ----------------------------------------------------------------------------
    -- Events and stuff
    
    function f:UNIT_AURA (unit)
		--CHANGES:Lanrutcon: There is no RegisterUnitEvent in Cataclysm. Adding a condition here.
		if(unit ~= "player") then
			return;
		end
        f:UNIT_MAXHEALTH () -- Because I just can't trust UnitHealthMax to not return after login -.-
        
        ScanPlayerAuras ()
        self:Update ()
        self.bones:Update ()
        self.blood:Update ()
        self.sword:Update ()
        self.shard:Update ()
    end

    function f:UNIT_MAXHEALTH (unit)
		--CHANGES:Lanrutcon: There is no RegisterUnitEvent in Cataclysm. Adding a condition here.
		if(unit ~= "player") then
			return;
		end
        self.bar:SetMinMaxValues (-0.05*UnitHealthMax ('player'), 0.75*UnitHealthMax ('player'))
    end
    
    function f:ACTIVE_TALENT_GROUP_CHANGED ()
        if GetSpecialization()==1 then
            self:Show()
        else
            self:Hide()
        end
    end
    
    function f:PLAYER_LOGIN ()
        if GetSpecialization()==1  and ((not g_BloodyAddon_config.hideOutOfCombat)  or  UnitAffectingCombat('player')) then
            self:Show()
        else
            self:Hide()
        end
    end

    function f:ADDON_LOADED (name)
        if name==ADDON then
            -- Load settings etc.
            g_BloodyAddon_config = g_BloodyAddon_config or {}
            
            f:SetScale (g_BloodyAddon_config.scale or 1.0)
            frmBloodyAddon:UNIT_AURA ()     -- To hide things if HideWhenInactive is on
            frmBloodyAddon:EnableMouse (not g_BloodyAddon_config.clickThrough)
            frmBloodyAddon.head:EnableMouse (not g_BloodyAddon_config.clickThrough)
            
            BloodyAddon_CreateOptions ()
        end
    end
    
    function f:PLAYER_REGEN_DISABLED ()
        frmBloodyAddon:Show ()
    end

    function f:PLAYER_REGEN_ENABLED ()
        if g_BloodyAddon_config.hideOutOfCombat then
            frmBloodyAddon:Hide ()
        end
    end

	--CHANGES:Lanrutcon: Changed RegisterUnitEvent to RegisterEvent and added/removed ACTIVE_TALENT_GROUP_CHANGED/PLAYER_SPECIALIZATION_CHANGED
	f:RegisterEvent ('UNIT_AURA')
	f:RegisterEvent ('UNIT_MAXHEALTH')
    f:RegisterEvent ('ACTIVE_TALENT_GROUP_CHANGED')
    f:RegisterEvent ('PLAYER_LOGIN')
    f:RegisterEvent ('ADDON_LOADED')
    f:RegisterEvent ('PLAYER_REGEN_DISABLED')
    f:RegisterEvent ('PLAYER_REGEN_ENABLED')
    f:SetScript ('OnEvent', function (self, e, ...) self[e](self,...) end)
    f:UNIT_AURA ()
    f:UNIT_MAXHEALTH ()
    
end

--CHANGES:Lanrutcon: Added Missing functions
function GetSpecialization()
	return GetPrimaryTalentTree();
end