ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


InService = false
local Count = 0
local Appels = nil 
local AmbulanceMenu = {
    IndexAppel = 1
}

function MarkerPlayer(ped)
    local player = GetPlayerPed(ped)
	local pos = GetEntityCoords(player)
    DrawMarker(2, pos.x, pos.y, pos.z+1.0, 0.0, 0.0, 0.0, 179.0, 0.0, 0.0, 0.25, 0.25, 0.25, 81, 203, 231, 200, 0, 1, 2, 1, nil, nil, 0)
end

local EMSDispo = false
local EMSPause = false
local EMSIndispo = false
OpenAmbulanceMenu = function()

    local mainlmenuambulance = RageUI.CreateMenu("Ambulance", "Voici les intéractions disponibles")
    local annonceems = RageUI.CreateSubMenu(mainlmenuambulance, "Annonce", "Voici les annonces disponibles")
    local appelems = RageUI.CreateSubMenu(mainlmenuambulance, "Appels en Cours", "Voici les appels en cours")
    local interactioncitoyen = RageUI.CreateSubMenu(mainlmenuambulance, "Intéractions Citoyen", "Voici les actions disponibles")
    mainlmenuambulance:SetRectangleBanner(0, 0, 0, 0)
    annonceems:SetRectangleBanner(0, 0, 0, 0)
    appelems:SetRectangleBanner(0, 0, 0, 0)
    interactioncitoyen:SetRectangleBanner(0, 0, 0, 0)
    RageUI.Visible(mainlmenuambulance, not RageUI.Visible(mainlmenuambulance))

    while mainlmenuambulance do 

        Wait(0)
        RageUI.IsVisible(mainlmenuambulance, function()

            if Config.TenuObligatoirePourOpenMenu then 
                RageUI.Button( InService == false and "Veuillez prendre votre service" or "Service en cours", nil, {RightLabel = "→"}, InService, {
                    onSelected = function()
                    end
                })
            else
                RageUI.Button( InService == false and "Prendre son service" or "Terminer son service", "Vous permet de prendre votre service ambulancier", {RightLabel = "→"}, true, {
                    onSelected = function()
                        InService = not InService
                        TriggerServerEvent("ambulance:ambulancejob:takeservice")
                    end
                })
            end

            if InService then 
                RageUI.Separator("Abitants en activités: ~f~"..#GetActivePlayers().. "")
                RageUI.Button("Annonce", nil, {RightLabel = "→"}, true, {}, annonceems)
                RageUI.Button("Voir les appels", nil, {RightLabel = "→"}, true, {}, appelems)
                RageUI.Button("Intéraction citoyens", nil, {RightLabel = "→"}, true, {}, interactioncitoyen)
               
            end
        
        end, function()
        end)

        RageUI.IsVisible(annonceems, function()

            RageUI.Button("EMS Disponible", nil, {RightLabel = "→"}, not EMSDispo, {
                onSelected = function()
                    EMSDispo = true
                    TriggerServerEvent("ambulance:annonceems", "dispo")
                    Citizen.SetTimeout(10000, function()
                    EMSDispo = false 
                    end)
                end
            })

            RageUI.Button("EMS en Pause", nil, {RightLabel = "→"}, not EMSPause, {
                onSelected = function()
                    EMSPause = true
                    TriggerServerEvent("ambulance:annonceems", "pause")
                    Citizen.SetTimeout(10000, function()
                    EMSPause = false 
                    end)
                end
            })

            RageUI.Button("EMS Indisponible", nil, {RightLabel = "→"}, not EMSIndispo, {
                onSelected = function()
                    EMSIndispo = true
                    TriggerServerEvent("ambulance:annonceems", "indispo")
                    Citizen.SetTimeout(10000, function()
                    EMSIndispo = false 
                    end)
                end
            })
        
        end, function()
        end)

        RageUI.IsVisible(appelems, function()
            if Appels ~= nil then 

                for k, v in pairs(Appels) do 

                    RageUI.List("Appel de "..v.name, {"Prendre", "Supprimer"}, AmbulanceMenu.IndexAppel, "Statut de l'appel: "..v.statut, {}, true, {
                        onListChange = function(index)
                            AmbulanceMenu.IndexAppel = index 
                        end,
                        onSelected = function(index)
                            if index == 1 then 
                                blips = AddBlipForCoord(v.pos)
                                SetBlipSprite(blips, 353)
                                SetBlipColour(blips, 5)
                                SetBlipScale(blips, 0.7)
                                SetBlipDisplay(blips, 4)
                                SetBlipAsShortRange(blip, false)
                                SetBlipRoute(blips, true)
                                SetBlipRouteColour(blips, 59)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentSubstringPlayerName("Mort")
                                EndTextCommandSetBlipName(blips)
                                TriggerServerEvent("ambulance:updateappel", "take", k)
                            elseif index == 2 then 
                                if DoesBlipExist(blips) then 
                                    RemoveBlip(blips)
                                    TriggerServerEvent("ambulance:updateappel", "delete", k)
                                end
                            end

                        end
                    })
                end 

            else
                RageUI.Separator("Aucun appels")
            end
        
        end, function()
        end)

        RageUI.IsVisible(interactioncitoyen, function()

            RageUI.Button("Réanimer un citoyen", nil, {RightLabel = "→"}, true, {
                onActive = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        MarkerPlayer(closestPlayer)
                    end
                end,
                onSelected = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TaskStartScenarioInPlace(PlayerPedId(), 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                        Wait(10000)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("ambulance:reanimplayer", GetPlayerServerId(closestPlayer))
                    end
                end
            })

            RageUI.Button("Soigner un citoyen", nil, {RightLabel = "→"}, true, {
                onActive = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        MarkerPlayer(closestPlayer)
                    end
                end,
                onSelected = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TaskStartScenarioInPlace(PlayerPedId(), 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                        Wait(5000)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("ambulance:healplayer", GetPlayerServerId(closestPlayer))
                    end
                end
            })

            RageUI.Button("Faire une facture", nil, {RightLabel = "→"}, true, {
                onSelected = function()
                    -- Get the closest player
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then
                        -- Use ox_lib's input dialog to get the bill amount
                        local input = lib.inputDialog('Facture', {
                            { type = 'number', label = 'Montant de la facture', required = true }
                        })
            
                        if input and input[1] then

                            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_police', 'Amande Police', input[1])
                        else
                            ESX.ShowNotification('~r~Erreur ~w~~n~Montant de la facture invalide.')
                        end
                    else
                        ESX.ShowNotification('~r~Erreur ~w~~n~Il n\'y a aucun joueur aux alentours.')
                    end
                end,
            })
            
        
        end, function()
        end)

        if not RageUI.Visible(mainlmenuambulance) and
        not RageUI.Visible(annonceems) and 
        not RageUI.Visible(appelems) and
        not RageUI.Visible(interactioncitoyen) then 
            mainlmenuambulance = RMenu:DeleteType("mainlmenuambulance")
            annonceems = RMenu:DeleteType("annonceems")
            appelems = RMenu:DeleteType("appelems")
            interactioncitoyen = RMenu:DeleteType("interactioncitoyen")
        end
    end
end

RegisterCommand('ambulance', function()
    if ESX.PlayerData.job.name == 'ambulance' then
        OpenAmbulanceMenu()
	end
end)


RegisterKeyMapping("ambulance", "Menu F6 Ambulance", "keyboard", "F6")

RegisterNetEvent("ambulance:recivecounterambulance")
AddEventHandler("ambulance:recivecounterambulance", function(count)
    Count = count 
end)

RegisterNetEvent("ambulance:recieveambulancejob")
AddEventHandler("ambulance:recieveambulancejob", function(appel)
    Appels = appel 
end)

RegisterNetEvent("pqofiqoioqjgfjqzjîiqf")
AddEventHandler("pqofiqoioqjgfjqzjîiqf", function()
    SetEntityHealth(PlayerPedId(), 200)
    ESX.ShowNotification("Vous avez été soigné")
end)

RegisterNetEvent("ambulance:usemedikit")
AddEventHandler("ambulance:usemedikit", function()
    SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent("ambulance:usebandage")
AddEventHandler("ambulance:usebandage", function()
    SetEntityHealth(PlayerPedId(), 150)
end)