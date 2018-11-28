--
-- SampleSpecialization
--
-- @author:    	Xentro (Marcus@Xentro.se)
-- @website:	www.Xentro.se
-- @history:	


SampleSpecialization = {};

function SampleSpecialization.prerequisitesPresent(specializations)
	print("-- SampleSpecialization.prerequisitesPresent");
	
	return true;
end;


-- These are functions which are called by the game and is linked to the new way of how the vehicles handle specializations as to how to use them is anyones guess at the moment.
-- registerEvents
-- registerEventListeners
-- registerFunctions
-- registerOverwrittenFunctions

function SampleSpecialization.registerEventListeners(vehicleType)
	print("-- SampleSpecialization:registerEventListeners");
	
	-- Beware that function names used in older version of FS won't work in FS19!
	local functionNames = {
		"onPreLoad",
		"onLoad"
	};
	
	for i, v in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, v, SampleSpecialization);
	end;
end;


function SampleSpecialization:onPreLoad(savegame)
	print("-- Calling SampleSpecialization:onPreLoad function in vehicle");
end;

function SampleSpecialization:onLoad(savegame)
	print("-- Calling SampleSpecialization:onLoad function in vehicle");
end;