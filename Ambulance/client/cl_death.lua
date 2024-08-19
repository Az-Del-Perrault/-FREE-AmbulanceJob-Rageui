PlayerDead = false 
Time = 0
SendAppel = true

  
AddEventHandler('esx:onPlayerDeath', function(a, b, c)
    PlayerDead = true
    Citizen.CreateThread(function()
		DoScreenFadeOut(800)
		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

        local coords = GetEntityCoords(PlayerPedId(), false)
		DoScreenFadeIn(800)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed, false)
        RespawnPed(PlayerPedId(), {coords = coords, heading = 0.0})
        TriggerServerEvent("ambulance:playerdie")
	end)

    while not IsEntityDead(PlayerPedId()) do 
        Wait(1)
    end

    Citizen.CreateThread(function()
        SendAppel = true
        local mainmenucoma = RageUI.CreateMenu("Coma", "Vous êtes dans le coma")
        mainmenucoma:SetRectangleBanner(0, 0, 0, 0)
        mainmenucoma.Closable = false
        RageUI.Visible(mainmenucoma, not RageUI.Visible(mainmenucoma))
        Timer()
        
        while PlayerDead do 
            Wait(0)
    
            RageUI.IsVisible(mainmenucoma, function()
                
                RageUI.Separator("Temps Restant: "..Time.." minute(s)")
                
                RageUI.Button("Prévenir les secours", nil, {RightLabel = "→"}, SendAppel, {
                    onSelected = function()
                        SendAppel = false 
                        TriggerServerEvent("ambulance:ambulancejob:sendappel")
                    end
                })

                RageUI.Button("Réaparaitre à l'hôpital", nil, {RightLabel = "→"}, (Time == 0), {
                    onSelected = function()
                        PlayerDead = false
                        SendNUIMessage({
                            action = "close"
                        })
                        TriggerServerEvent("ambulance:respawnhospital")
                    end
                })
                
            end, function()
            end)
    
            if not RageUI.Visible(mainmenucoma) then 
                mainmenucoma = RMenu:DeleteType("mainmenucoma")
            end

            if PlayerDead then 
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
            else
                RageUI.CloseAll()
            end
        end

    end)
end)

RegisterNetEvent("ambulance:playerisdeadclientside")
AddEventHandler("ambulance:playerisdeadclientside", function(ped)
    
    TriggerEvent("esx:onPlayerDeath")
    SetPlayerInvincible(ped, true)
end)

CreateThread(function()
    Wait(200)
    TriggerServerEvent("ambulance:checkifplayerisdead")
end)

RegisterNetEvent("ambulance:renamiplayerclientside")
AddEventHandler("ambulance:renamiplayerclientside", function()
    PlayerDead = false 
    SendNUIMessage({
        action = "close"
    })
    TriggerServerEvent("ambulance:updateappel", "playerrevive")
end)

function RespawnPed(ped, spawn)
	SetEntityCoordsNoOffset(ped, spawn.coords, false, false, false, true)
	NetworkResurrectLocalPlayer(spawn.coords, spawn.heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', spawn)
	ClearPedBloodDamage(ped)
end

function Timer()
    Citizen.CreateThread(function()
        Time = Config.TimeDeath
        while true do 
            Wait(60000)
            Time = Time -1 
            if Time == 0 then 
                break
            end
        end
    end)
end
