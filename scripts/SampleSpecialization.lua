--
-- SampleSpecialization
--
-- Author:  Xentro
-- Website: https://xentro.se, https://github.com/Xentro

SampleSpecialization = {
	MOD_NAME = g_currentModName
}

function SampleSpecialization.prerequisitesPresent(specializations)
	return true
end


-- These are functions which are called by the game and is linked to the new way of how the vehicles handle specializations as to how to use them is anyones guess at the moment.
-- registerEvents
-- registerEventListeners
-- registerFunctions
-- registerOverwrittenFunctions

function SampleSpecialization.registerEventListeners(vehicleType)
	-- print("-- SampleSpecialization:registerEventListeners")
	
	SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", SampleSpecialization)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad",    SampleSpecialization)
end


function SampleSpecialization:onPreLoad(savegame)
	print("-- Calling SampleSpecialization:onPreLoad function in vehicle")
	print("-- global text: " .. g_i18n:getText("GLOBAL_TEXT_1"))
end

function SampleSpecialization:onLoad(savegame)
	self.spec_SampleSpecialization = self["spec_" .. SampleSpecialization.MOD_NAME .. ".SampleSpecialization"]

	print("-- self.spec_SampleSpecialization " .. tostring(self.spec_SampleSpecialization))
end