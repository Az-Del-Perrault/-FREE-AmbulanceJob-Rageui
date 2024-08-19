OpenGarage = function()

    local maingarage = RageUI.CreateMenu("Garage", "Vocii les véhicules disponibles")
    maingarage:SetRectangleBanner(0, 0, 0, 0)
    RageUI.Visible(maingarage, not RageUI.Visible(maingarage))

    while maingarage do 
        Wait(0)

        RageUI.IsVisible(maingarage, function()
        
            RageUI.Separator("↓ Voici les véhicules disponibles ↓")

            for k, v in pairs(Config.Garage) do 

                RageUI.Button(" "..v.label.." ", nil, {RightLabel = "→"}, true, {
                    onSelected = function()
                        ESX.Game.SpawnVehicle(k, (v.type == "car" and Config.Position2.SpawnVehicle or Config.Position2.SpawnHelico), Config.HeadingVehSpawn, function(veh) 
                            SetVehicleLivery(veh, 1)
                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                            RageUI.CloseAll()
                        end)
                        ESX.ShowNotification("Votre véhicule à été sorti", flash, saveToBrief, hudColorIndex)
                    end
                })

            end
        
        end, function()
        end)

        if not RageUI.Visible(maingarage) then 
            maingarage = RMenu:DeleteType("maingarage")
        end
    end 





end