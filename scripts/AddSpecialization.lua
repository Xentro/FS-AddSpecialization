--
-- AddSpecialization
-- 
-- Insert specializations into vehicleType's
--
-- Author:  Xentro
-- Website: https://xentro.se, https://github.com/Xentro
--

AddSpecialization = {
	specializationToAdd = {},
	printHeader 	= "Add Specialization ( %s ) - %s: %s",
	
	RES_REQUIRED	= 0,
	RES_NOT_ALLOWED	= 1,
	RES_ALLOWED		= 2
}

function AddSpecialization:init()
	for i, ss in ipairs(AddSpecialization.specializationToAdd) do
		if g_specializationManager:getSpecializationByName(ss.name) == nil then
			g_specializationManager:addSpecialization(ss.name, ss.className, ss.filename, nil)
			
			-- Key functions are called early so we need to add the specialization before it gets to that stage.
			AddSpecialization:add()
		else
			print(string.format(AddSpecialization.printHeader, ss.name, "Error", "Specialization have been loaded already by another mod! This process will stop now."))
		end
	end
end

function AddSpecialization:loadModDesc()
	local xmlFile = loadXMLFile("AddSpecializationModDesc", Utils.getFilename("modDesc.xml", g_currentModDirectory))

	local i = 0
	while true do
		local key = string.format("modDesc.addSpecialization.specialization(%d)", i)
		if not hasXMLProperty(xmlFile, key) then break end
		
		local name 			= getXMLString(xmlFile, key .. "#name")
		local className 	= getXMLString(xmlFile, key .. "#className")
		local filename 		= getXMLString(xmlFile, key .. "#filename")
		local l10nNameTag 	= getXMLString(xmlFile, key .. "#l10nNameTag")
		
		if name ~= nil and className ~= nil and filename ~= nil then
			local filename = Utils.getFilename(filename, g_currentModDirectory)
			
			if fileExists(filename) then
				local entry = {
					name 			 = name,
					className 		 = className,
					filename 		 = filename,
					l10nNameTag 	 = l10nNameTag,
					debug 	 		 = Utils.getNoNil(getXMLBool(xmlFile, key .. "#debug"), false),
					vehicleTypeLimit = AddSpecialization:loadSearchType(xmlFile, key, "vehicleTypeLimit", getXMLBool),
					restrictions	 = AddSpecialization:loadSearchType(xmlFile, key, "restrictions", 	getXMLInt),
					searchWords		 = AddSpecialization:loadSearchType(xmlFile, key, "searchWords", 		getXMLInt)
				}
				
				-- Add specialization name to not allowed
				table.insert(entry.restrictions, {name = entry.name, state = AddSpecialization.RES_NOT_ALLOWED})
				table.insert(entry.searchWords,  {name = entry.name, state = AddSpecialization.RES_NOT_ALLOWED})

				table.insert(AddSpecialization.specializationToAdd, entry)
			else
				print(string.format(AddSpecialization.printHeader, name, "Info", "File don't exist " .. filename))
			end
		end
		
		i = i + 1
	end

	delete(xmlFile)
end

function AddSpecialization:loadSearchType(xmlFile, k, t, f)
	local entry = {}
	local i = 0
	while true do
		local key = string.format(k .. "." .. t .. "(%d)", i)
		if not hasXMLProperty(xmlFile, key) then break end
		
		local state = f(xmlFile, key .. "#state")
		local name  = getXMLString(xmlFile, key .. "#name")
		
		if state ~= nil and name ~= nil then
			if t == "vehicleTypeLimit" then
				entry[name] = state
			else
				table.insert(entry, {name = name, state = state})
			end
		end
		
		i = i + 1
	end
	
	return entry
end

function AddSpecialization:checkTable(t, vehicle, counter, specList)
	for _, r in ipairs(t) do
		if r.state == AddSpecialization.RES_REQUIRED then
			counter.required.total = counter.required.total + 1
			specList["Required"][r.name] = false
		elseif r.state == AddSpecialization.RES_ALLOWED then
			counter.allowed.total = counter.allowed.total + 1
			specList["Allowed"][r.name] = false
		end
		
		for name in pairs(vehicle.specializationsByName) do
			if string.find(name:lower(), r.name:lower()) ~= nil then
				if r.state == AddSpecialization.RES_REQUIRED then
					counter.required.found = counter.required.found + 1
					specList["Required"][r.name] = true

				elseif r.state == AddSpecialization.RES_NOT_ALLOWED then
					specList["Not Allowed"][r.name] = true
					return true

				elseif r.state == AddSpecialization.RES_ALLOWED then
					counter.allowed.found = counter.allowed.found + 1
					specList["Allowed"][r.name] = true
				end

				break -- We found our target, stop this loop
			end
		end
	end

	return false
end

function AddSpecialization:add()
	for _, ss in ipairs(AddSpecialization.specializationToAdd) do
		local counter = {
			type = {
				current = 0,
				total = 0
			}
		}
		local skipTypeCheck = true
		local passState = false
		
		for name, state in pairs(ss.vehicleTypeLimit) do
			skipTypeCheck = false
			
			if not state then
				passState = true  -- If only false then let all types which haven't been setup pass.
			else
				passState = false -- If we got both True/False then only allow those that are set to true.
				break
			end
		end
		
		for vehicleType, vehicle in pairs(g_vehicleTypeManager:getTypes()) do
			if vehicle ~= nil then
				counter.type.total = counter.type.total + 1 
				
				if (skipTypeCheck 																					-- VehicleType search is empty, let it pass
				or not passState and ss.vehicleTypeLimit[vehicleType] ~= nil and ss.vehicleTypeLimit[vehicleType]	-- Check True / False state and let pass according
				or passState and ss.vehicleTypeLimit[vehicleType] ~= nil and ss.vehicleTypeLimit[vehicleType]		-- Only false vehicleType's have been set, let all which aren't set to False pass
				or passState and ss.vehicleTypeLimit[vehicleType] == nil) then
					local forceStop = false
					local specList = {
						["Required"]    = {},
						["Not Allowed"] = {},
						["Allowed"]     = {}
					}
					counter.required = {
						found = 0,
						total = 0
					}
					counter.allowed = {
						found = 0,
						total = 0
					}
					
					forceStop = self:checkTable(ss.restrictions, vehicle, counter, specList)

					if not forceStop then
						forceStop = self:checkTable(ss.searchWords, vehicle, counter, specList)
					end
					
					if (counter.required.found ~= counter.required.total or counter.allowed.total > 0 and counter.allowed.found == 0) then
						forceStop = true
					end
					
					-- Do some prints
					if ss.debug then
						if counter.required.total > 0 then
							print(string.format(AddSpecialization.printHeader, ss.name, "Debug", "Inserted: " .. tostring(not forceStop) .. ", Required ( " .. counter.required.found .. " / " .. counter.required.total .. " ), Allowed ( " .. counter.allowed.found .. " / " .. counter.allowed.total .. " ) specialization's found in " .. vehicleType))
						end
						
						for typeName, type in pairs(specList) do
							local txt = ""
							local found = ""
							local missing = ""

							for specName, v in pairs(type) do
								if v then
									found = found .. specName .. ", "
								else
									missing = missing .. specName .. ", "
								end
							end

							if found ~= "" then
								txt = txt .. "Found " .. found
							end

							if missing ~= "" then
								txt = txt .. "Missing " .. missing
							end

							if txt ~= "" then
								-- print(string.format(AddSpecialization.printHeader, ss.name, "Debug", "   " .. typeName .. ": " .. txt)) -- List specializations found / missing for the 3 search states
							end
						end
					end
					
					-- We passed the checks, add script
					if not forceStop then
						g_vehicleTypeManager:addSpecialization(vehicleType, ss.name)
						counter.type.current = counter.type.current + 1
					end
				else
					print(string.format(AddSpecialization.printHeader, ss.name, "Debug", "Inserted: false, vehicleType: " .. vehicleType))
				end
			end
		end
		
		print(string.format(AddSpecialization.printHeader, ss.name, "Info", "We have successfully added specialization Into ( " .. counter.type.current .. " / " .. counter.type.total .. ") of the vehicleTypes."))
		
		-- make l10n global 
		if ss.l10nNameTag ~= nil then
			local global = getmetatable(_G).__index;

			local i = 1
			while true do
				local txt = string.format(ss.l10nNameTag .. "_%d", i)

				if not g_i18n:hasText(txt) then
					break
				end
				
				global.g_i18n.texts[txt] = g_i18n:getText(txt)

				if ss.debug then
					print(string.format(AddSpecialization.printHeader, ss.name, "Debug", "Adding text " .. txt .. " to global"))
				end

				i = i + 1
			end
		end
	end
end

-- This can be replaced with an table too if that is much more preferred.
AddSpecialization:loadModDesc()
AddSpecialization:init()
