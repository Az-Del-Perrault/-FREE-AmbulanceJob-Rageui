local ox_inventory = exports.ox_inventory

VestiaireMenu = function()
    local mainvestiraire = RageUI.CreateMenu("Vestiaire", "Voici les tenues disponibles")
    mainvestiraire:SetRectangleBanner(0, 0, 0, 0)

    RageUI.Visible(mainvestiraire, not RageUI.Visible(mainvestiraire))

    while mainvestiraire do 
        Wait(1)

        RageUI.IsVisible(mainvestiraire, function()
        
            RageUI.Separator("Votre Grade: ~b~"..ESX.PlayerData.job.grade_label)

            RageUI.Button("Prendre mon service", nil, {RightLabel = "→"}, true, {
                onSelected = function()
                    RageUI.CloseAll()
                    InService = true
                    TriggerServerEvent("ambulance:ambulancejob:takeservice", true)
                    ESX.ShowNotification("Vous venez de prendre votre service")
                end
            })

            RageUI.Button("Ouvrir le casier", nil, {RightLabel = "→"}, true, {
                onSelected = function()
                    RageUI.CloseAll()
                    ox_inventory:openInventory('stash', 'vestaireambulance')
                end
            })


        end, function()
        end)

        if not RageUI.Visible(mainvestiraire) then 
            mainvestiraire = RMenu:DeleteType("mainvestiraire")
        end
    end


end