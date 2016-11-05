local ADDON, data = ...

function BloodyAddon_CreateOptions ()
    -- Default values!
    g_BloodyAddon_config = g_BloodyAddon_config or {}
    g_BloodyAddon_config.scale = g_BloodyAddon_config.scale or 1.0
    
    local Options = CreateFrame ("Frame", "BloodyAddonOptions", UIParent);
    Options.name = "BloodyAddon";
    Options:Hide ()
    InterfaceOptions_AddCategory (Options);
    
    Options.refresh = function ()
        self.sldScale:SetValue (g_BloodyAddon_config.scale)
        Options.chkHideWhenInactive:SetChecked (g_BloodyAddon_config.hideWhenInactive)
        Options.chkHideOutOfCombat:SetChecked (g_BloodyAddon_config.hideOutOfCombat)
        Options.chkClickThrough:SetChecked (g_BloodyAddon_config.clickThrough)
    end

    local Title = Options:CreateFontString (nil, "ARTWORK", "GameFontNormalLarge")
    Title:SetPoint ("TOPLEFT", 10, -16)
    Title:SetText (Options.name)
    Options.Title = Title

    
    -- Misc
    local TitleMisc = Options:CreateFontString (nil, "ARTWORK", "GameFontHighlight")
    TitleMisc:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", -2, -10)
    TitleMisc:SetText ('Miscellaneous:')
    Options.TitleMisc = TitleMisc

    
    -- Scale
    Options.lblScale = Options:CreateFontString (nil, "ARTWORK", "GameFontHighlight")
    Options.lblScale:SetPoint("TOPLEFT", TitleMisc, "BOTTOMLEFT", 8, -10)
    Options.lblScale:SetText ('Scale')
    
    Options.sldScale = CreateFrame ("Slider", 'BloodyAddonOptionsScale', Options, "OptionsSliderTemplate")
    Options.sldScale:SetSize (200, 16)
    Options.sldScale:SetPoint ("TOPLEFT", Options.lblScale, "BOTTOMLEFT", 0, -6)
    Options.sldScale:SetMinMaxValues (0.5, 1.5)
    Options.sldScale:SetValueStep (0.1)
    Options.sldScale:SetValue (g_BloodyAddon_config.scale)
    --Options.sldScale:SetObeyStepOnDrag (true) 
    
    Options.sldScale:SetScript ("OnValueChanged", function (self, value)
        g_BloodyAddon_config.scale = value
        frmBloodyAddon:SetScale (value)
    end)
    
    -- Hide when inactive
    Options.chkHideWhenInactive = CreateFrame ("CheckButton", nil, Options, "InterfaceOptionsCheckButtonTemplate")
    Options.chkHideWhenInactive:SetPoint ("TOPLEFT", TitleMisc, "BOTTOMLEFT", 3, -72)
    Options.chkHideWhenInactive.Text:SetText ("Hide when inactive")
    Options.chkHideWhenInactive:SetChecked (g_BloodyAddon_config.hideWhenInactive)
    Options.chkHideWhenInactive:SetScript ("OnClick", function (self, ...)
        g_BloodyAddon_config.hideWhenInactive = self:GetChecked ()
        frmBloodyAddon:UNIT_AURA ()
    end)
    Options.chkHideWhenInactive:SetScript("OnEnter", function(self, motion, ...)
        GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine ('Hide when inactive', 1, 1, 0)
        GameTooltip:AddLine ('If this option is enabled, the black backgrounds of most of the add-on\'s elements', 1, 1, 1)
        GameTooltip:AddLine ('will be invisible while their respective abilities aren\'t active.', 1, 1, 1)
        GameTooltip:Show ()
    end)
    Options.chkHideWhenInactive:SetScript("OnLeave", function(self, motion, ...)
        GameTooltip:Hide ()
    end)

    -- Hide out of combat
    Options.chkHideOutOfCombat = CreateFrame ("CheckButton", nil, Options, "InterfaceOptionsCheckButtonTemplate")
    Options.chkHideOutOfCombat:SetPoint ("TOPLEFT", TitleMisc, "BOTTOMLEFT", 3, -97)
    Options.chkHideOutOfCombat.Text:SetText ("Hide out of combat")
    Options.chkHideOutOfCombat:SetChecked (g_BloodyAddon_config.hideOutOfCombat)
    Options.chkHideOutOfCombat:SetScript ("OnClick", function (self, ...)
        g_BloodyAddon_config.hideOutOfCombat = self:GetChecked ()
        if g_BloodyAddon_config.hideOutOfCombat  and  (not UnitAffectingCombat('player')) then
            frmBloodyAddon:Hide ()
        end
        if not g_BloodyAddon_config.hideOutOfCombat then
            frmBloodyAddon:Show ()
        end
    end)
    Options.chkHideOutOfCombat:SetScript("OnEnter", function(self, motion, ...)
        GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine ('Hide out of combat', 1, 1, 0)
        GameTooltip:AddLine ('If this option is enabled, the entire add-on will be invisible when out of combat', 1, 1, 1)
        GameTooltip:Show ()
    end)
    Options.chkHideOutOfCombat:SetScript("OnLeave", function(self, motion, ...)
        GameTooltip:Hide ()
    end)

    -- Click-through
    Options.chkClickThrough = CreateFrame ("CheckButton", nil, Options, "InterfaceOptionsCheckButtonTemplate")
    Options.chkClickThrough:SetPoint ("TOPLEFT", TitleMisc, "BOTTOMLEFT", 3, -122)
    Options.chkClickThrough.Text:SetText ("Click-through")
    Options.chkClickThrough:SetChecked (g_BloodyAddon_config.clickThrough)
    Options.chkClickThrough:SetScript ("OnClick", function (self, ...)
        g_BloodyAddon_config.clickThrough = self:GetChecked ()
        frmBloodyAddon:EnableMouse (not g_BloodyAddon_config.clickThrough)
        frmBloodyAddon.head:EnableMouse (not g_BloodyAddon_config.clickThrough)
    end)
    Options.chkClickThrough:SetScript("OnEnter", function(self, motion, ...)
        GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine ('Click-through', 1, 1, 0)
        GameTooltip:AddLine ('When this option is enabled, the add-on is not movable and you can click through it', 1, 1, 1)
        GameTooltip:Show ()
    end)
    Options.chkClickThrough:SetScript("OnLeave", function(self, motion, ...)
        GameTooltip:Hide ()
    end)

end

