ESX = exports["es_extended"]:getSharedObject()
ESXLoad = false 
local ox_inventory = exports.ox_inventory

function LoadEsx()
    
    ESX.PlayerData = ESX.GetPlayerData()
    ESX.WeaponData = ESX.GetWeaponList()

    for k,v in pairs(ESX.WeaponData) do 
        v.hash = GetHashKey(v.name)
    end
    ESXLoad = true

end


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

CreateThread(function()
    Wait(600)
    LoadEsx()
end)


Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Blips.Position)

	SetBlipSprite(blip, Config.Blips.Sprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(Config.Blips.Name)
	EndTextCommandSetBlipName(blip)
end)
CreateThread(function()
    -- Wait until ESX is fully loaded
    while not ESXLoad do
        Wait(1)
    end

    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local Spam = false

        if ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance" then
            for k, v in pairs(Config.Position) do
                local dist = Vdist2(pos, v)
                
                if dist < 25 then  -- Adjusted distance for interaction
                    Spam = true
            

                        -- Add interaction coordinates
                        exports["inside-interaction"]:AddInteractionCoords(vector3(v.x, v.y, v.z), {
                            checkVisibility = true,
                            {
                                name = "coords_" .. k,  -- Unique name based on index
                                icon = "fa-solid fa-money-bill",  -- Icon to display
                                label = Config.Marker.Notif,  -- Interaction label
                                key = "E",  -- Key to trigger action
                                duration = 1000,  -- Interaction duration in milliseconds
                                action = function()
                                    -- Actions based on interaction points
                                    if k == "Boss" then
                                        if ESX.PlayerData.job.grade_name == "boss" then
                                            TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu) end, {wash = false})
                                        else
                                            ESX.ShowNotification("Vous n'etes pas patron")
                                        end
                                    elseif k == "Vestiaire" then
                                        VestiaireMenu()
                                    elseif k == "Coffre" then
                                        ox_inventory:openInventory('stash', 'coffreambulance')
                                    elseif k == "Garage" then
                                        OpenGarage()
                                    end
                                end
                            }
                        })
                    end
                end
            end
        -- Adjust wait times based on proximity to interactions
        if Spam then
            Wait(0)  -- Refresh quickly if near an interaction
        else
            Wait(250)  -- Reduce check frequency if far from interactions
        end
    end
end)


CreateThread(function()

    while not ESXLoad do 
        Wait(1)
    end

    while true do 
        Spam = false 

        local pos = GetEntityCoords(PlayerPedId())

        if ESX.PlayerData.job.name == "ambulance" then 
            for k, v in pairs(Config.Position2) do 
                local dist = Vdist2(pos, v)
                if dist < 5 then 
                    Spam = true 
                    if k ~= "SpawnVehicle" then 

                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ranger le véhicule")
                    end
                    if IsControlJustPressed(0, 51) then 
                        if  k == "DeleteVeh" or "SpawnHelico" then 
                            local veh = GetVehiclePedIsIn(PlayerPedId(), true)
                            if veh > 0 then 
                                DeleteEntity(veh)
                                ESX.ShowNotification("Votre véhicule à été rangé")
                            else
                                ESX.ShowNotification("Aucun véhicule à ranger")
                            end
                      
                        end
                    end
                end
            end
        end

        if Spam then 
            Wait(0)
        else
            Wait(250)
        end 
    end


end)




Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/revive', 'Revive un joueur', {{ name="revive", help="Indiquer l'ID du joueur"}})
    TriggerEvent('chat:addSuggestion', '/reviveall', 'Revive tout joueur', {{ name="reviveall", help="Indiquer l'ID du joueur"}})
end)