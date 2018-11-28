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