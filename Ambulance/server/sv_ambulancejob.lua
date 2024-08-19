ESX = exports["es_extended"]:getSharedObject()


Ambulance = {
    Service = {}, 
    Appel = {},
    Count = 0
}

Desc = function(color, title, desc, webhook)

    local Content = {
        {
            ["author"] = {
                ["name"] = "rAmbulance",
            },
            ["title"] = title,
            ["description"] = desc,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "2022 - "..os.date("%Y").." • "..os.date("%x %X %p"),
            },
        }
    }    
    PerformHttpRequest(webhook, function() end, 'POST', json.encode({username = nil, embeds = Content}), {['Content-Type'] = 'application/json'})
end

TwoField = function(color, title, desc, titlefield, namefield, titlefield2, namefield2, webhook)

    local Content = {
        {
            ["author"] = {
                ["name"] = "rAmbulance",
            },
            ["title"] = title,
            ["description"] = desc,
            ["color"] = color,
            ["fields"] = {
                {
                    ["name"] = titlefield,
                    ["value"] = namefield
                },
                {
                    ["name"] = titlefield2,
                    ["value"] = namefield2
                },
            },
            ["footer"] = {
                ["text"] = "2022 - "..os.date("%Y").." • "..os.date("%x %X %p"),
            },
        }
    }
    PerformHttpRequest(webhook, function() end, 'POST', json.encode({username = nil, embeds = Content}), {['Content-Type'] = 'application/json'})
end


PlayerDead = {}

function Ambulance:RecieveCounter(action, player)

    if action == "start" then 
        Ambulance.Count = Ambulance.Count +1
    else
        Ambulance.Count = Ambulance.Count -1
    end
    for source, v in pairs(Ambulance.Service) do 
        local xPlayer = ESX.GetPlayerFromId(source)
        if action == "start" then 
            xPlayer.showAdvancedNotification("~r~911", "Ambulance", "Un ambulancier viens de ~g~démarer~s~ son service", "CHAR_CALL911")
            TriggerClientEvent("ambulance:recivecounterambulance", source, Ambulance.Count)
        elseif action == "finish" then 
            xPlayer.showAdvancedNotification("~r~911", "Ambulance", "Un ambulancier viens de ~r~terminer~s~ son service", "CHAR_CALL911")
            TriggerClientEvent("ambulance:recivecounterambulance", source, Ambulance.Count)
            Ambulance.Service[player] = nil
        end
    end
end

function Ambulance:ReciveAppel()
    for source, v in pairs(Ambulance.Service) do 
        TriggerClientEvent("ambulance:recieveambulancejob", source, Ambulance.Appel)
    end
end


RegisterNetEvent("ambulance:ambulancejob:takeservice")
AddEventHandler("ambulance:ambulancejob:takeservice", function(action)

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == "ambulance" then 
        if action then 
            Ambulance.Service[source] = {}
            Ambulance.Service[source].identifier = xPlayer.identifier 
            Ambulance.Service[source].reanimation = 0
            Ambulance:RecieveCounter("start")
            Ambulance:ReciveAppel()
        else
            Ambulance:RecieveCounter("finish", source)

        end
    else
        print("Ban")
    end
end)

RegisterNetEvent("ambulance:updateappel")
AddEventHandler("ambulance:updateappel", function(action, player)

    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromIdentifier(player)

    if action == "take" then 
        if tPlayer ~= nil then 
            if Ambulance.Appel[player] then 
                Ambulance.Appel[player].statut = "~g~Pris"
                Ambulance:ReciveAppel()
                Distance = #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(tPlayer.source)))
                TriggerClientEvent("esx:showNotification", tPlayer.source, "Votre appel à été pris en compte\nDistance: "..ESX.Math.Round(Distance, 2).." km")
            end
        end
    elseif action == "delete" then 
        if tPlayer ~= nil then 
            Ambulance.Appel[player] = nil 
            Ambulance:ReciveAppel()
            TriggerClientEvent("esx:showNotification", tPlayer.source, "Votre appel à été suprrimé")
        end
    
    elseif action == "playerrevive" then 
        if PlayerDead[xPlayer.identifier] then 
            PlayerDead[xPlayer.identifier] = nil 
        else
            print("ban")
        end
    end

end)


RegisterNetEvent("ambulance:ambulancejob:sendappel")
AddEventHandler("ambulance:ambulancejob:sendappel", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not Ambulance.Appel[xPlayer.identifier] then 
        if Ambulance.Count >= 1 then 
            Ambulance.Appel[xPlayer.identifier] = {}
            Ambulance.Appel[xPlayer.identifier].pos = GetEntityCoords(GetPlayerPed(source))
            Ambulance.Appel[xPlayer.identifier].name = xPlayer.getName()
            Ambulance.Appel[xPlayer.identifier].statut = "~r~En Attente"
            Ambulance:ReciveAppel()
        else
            TriggerClientEvent("esx:showNotification", source, "Il n'y a aucun EMS en ville")
        end
    else
        TriggerClientEvent("esx:showNotification", source, "Vous avez déjà un appel en cours")
    end
end)

RegisterNetEvent("ambulance:reanimplayer")
AddEventHandler("ambulance:reanimplayer", function(player)

    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(player)

    if xPlayer.job.name == "ambulance" then 
        if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(player))) < 10 then 
            if PlayerDead[tPlayer.identifier] then 
                if xPlayer.getInventoryItem("medikit").count >= 1 then 
                    Ambulance.Service[source].reanimation = Ambulance.Service[source].reanimation +1
                    TriggerClientEvent("ambulance:renamiplayerclientside", tPlayer.source)
                    TriggerClientEvent("esx:showNotification", source, "Vous venez de réanimer un citoyen, vous avez reçu une prime de ~g~"..(Config.Remuneration*Ambulance.Service[source].reanimation*1.5).."$")
                    xPlayer.addAccountMoney(Config.Accounts["cash"], (Config.Remuneration*Ambulance.Service[source].reanimation*1.5))
                    tPlayer.removeAccountMoney(Config.Accounts["cash"], Config.PriceReanimation)
                    TriggerClientEvent("esx:showNotification", tPlayer.source, "Vous avez été réanimé par un médecin, la facture s'élève à "..Config.PriceReanimation.."$")
                    Desc(15548997, "Un EMS à réanimer un joueur", "L'ambulancier **"..xPlayer.identifier.."** (ID: **"..source.."**) à réanimer le joueur **"..tPlayer.identifier.."** (ID: **"..tPlayer.source.."**) et à touché **"..(Amount*Ambulance.Service[source].reanimation*1.5).."$**", Config.Logs.ReanimationEMS)
                else
                    TriggerClientEvent("esx:showNotification", source, "Vous n'avez pas de médikit pour réanimer le citoyen")
                end
            else
                print("ban")
            end
        else
            print("ban")
        end

    end
  
end)


RegisterNetEvent("ambulance:renaimplayerdefibirlateur")
AddEventHandler("ambulance:renaimplayerdefibirlateur", function(player)

    local xPlayer = ESX.GetPlayerFromId(source)

    local tPlayer = ESX.GetPlayerFromId(player)
    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(player))) < 10 then 
        if PlayerDead[tPlayer.identifier] then 
            TriggerClientEvent("ambulance:renamiplayerclientside", tPlayer.source)
            TriggerClientEvent("esx:showNotification", tPlayer.source, "Vous avez été réanimé par un défibirlateur")
            TriggerClientEvent("esx:showNotification", source, "Vous avez réanimé le citoyen")
            xPlayer.removeAccountMoney(Config.Accounts["cash"], Config.PriceDefibirlateur)
        else
            TriggerClientEvent("esx:showNotification", tPlayer.source, "Le citoyen n'est pas mort")
        end

    else
        print('banvvvv')
    end


end)
RegisterNetEvent("ambulance:healplayer")
AddEventHandler("ambulance:healplayer", function(player)

    local xPlayer = ESX.GetPlayerFromId(source)

    local tPlayer = ESX.GetPlayerFromId(player)
    if xPlayer.job.name == "ambulance" then
        if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(player))) < 10 then 
            TriggerClientEvent("pqofiqoioqjgfjqzjîiqf", tPlayer.source)
        else
            print("'ban")
        end
    else
        print('ban')
    end

end)


RegisterNetEvent("ambulance:annonceems")
AddEventHandler("ambulance:annonceems", function(action)

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == "ambulance" then 
        if action == "dispo" then 
            TriggerClientEvent("esx:showNotification", -1, "~f~Annonces Ems~s~ \nLes ambulanciers sont disponible pour venir vous secourir")
        elseif action == "pause" then 
            TriggerClientEvent("esx:showNotification", -1, "~f~Annonces Ems~s~ \nLes ambulanciers sont disponible actuellement en pause ")
        elseif action == "indispo" then 
            TriggerClientEvent("esx:showNotification", -1, "~f~Annonces Ems~s~ \nLes ambulanciers sont actuellement indisponible ")
        end
    end
end)




ESX.RegisterUsableItem("medikit", function(source)

    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem("medikit", 1)
    TriggerClientEvent("ambulance:usemedikit", source)
end)

ESX.RegisterUsableItem("bandage", function(source)

    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem("bandage", 1)
    TriggerClientEvent("ambulance:usebandage", source)
end)


RegisterNetEvent("ambulance:playerdie")
AddEventHandler("ambulance:playerdie", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not PlayerDead[xPlayer.identifier] then 
        PlayerDead[xPlayer.identifier] = true 
    end
end)

RegisterNetEvent("ambulance:checkifplayerisdead")
AddEventHandler("ambulance:checkifplayerisdead", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if PlayerDead[xPlayer.identifier] then 
        TriggerClientEvent("ambulance:playerisdeadclientside", source)
    end
end)

RegisterNetEvent("ambulance:respawnhospital")
AddEventHandler("ambulance:respawnhospital", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if PlayerDead[xPlayer.identifier] then 
        PlayerDead[xPlayer.identifier] = nil 
        local pos = GetEntityCoords(GetPlayerPed(source))
        local loadout = xPlayer.getLoadout() 
        PosSud = (#(pos - Config.Hospital.RespwanSud))
        PosNord = (#(pos - Config.Hospital.RespawnNord))
        Pos3 = (#(pos - Config.Hospital.Pos3))
        ArmeSave = ""
        ArmeDelete = ""
        if Config.RemoveWeapon then 
            for k, v in pairs(loadout) do 
                if Config.ArmesPerm[v.name] then 
                    ArmeSave = ArmeSave.." "..v.label..", "
                else
                    ArmeDelete = ArmeDelete..""..v.label..", "
                    xPlayer.removeWeapon(v.name)
                end
            end
        end
     
        TriggerClientEvent("esx:showNotification", source, "Vous avez été réanimé par l'unité X, vos armes vont ont été retirés")
        TwoField(15548997, "Un joueur à été réanimé à l'unité X", "Le joueur **"..xPlayer.identifier.."** (ID:** "..source.."**) à été réanimé par l'unité X", "Armes Perdu:",  (ArmeDelete == "" and "Aucune arme perdu" or ArmeDelete), "Arme Conservé: ", (ArmeSave == "" and "Aucune arme conservé" or ArmeSave), Config.Logs.RespawnHospital)
        if PosSud < PosNord then 
            SetEntityCoords(GetPlayerPed(source), Config.Hospital.RespwanSud)
        else
            SetEntityCoords(GetPlayerPed(source), Config.Hospital.RespawnNord)
        end

        if Ambulance.Appel[xPlayer.identifier] then 
            Ambulance.Appel[xPlayer.identifier] = nil 
            Ambulance:ReciveAppel()
        end
    else
        print("ban")
    end
end)


-- Register the revive command
lib.addCommand('revive', {
    help = '',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server ID (optional)',
            optional = true,
        }
    },
    restricted = 'group.admin'  -- Adjust the group based on your requirements
}, function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Config.AutorizedGroupRevive[xPlayer.getGroup()] then
        if not args.target then
            -- Revive the player who issued the command
            PlayerDead[xPlayer.identifier] = {}
            TriggerClientEvent("ambulance:renamiplayerclientside", source)
            Desc(3447003, "Revive", "Le staff **"..xPlayer.identifier.."** \nNom: "..xPlayer.getName().."** s'est réanimé", Config.Logs.Revive)
        else
            -- Revive the specified target player
            local tPlayer = ESX.GetPlayerFromId(args.target)
            if tPlayer then
                PlayerDead[tPlayer.identifier] = {}
                TriggerClientEvent("ambulance:renamiplayerclientside", tPlayer.source)
                TriggerClientEvent("esx:showNotification", tPlayer.source, "Vous avez été réanimé par un staff")
                Desc(3447003, "Revive", "Le staff **"..xPlayer.identifier.."** \nNom: "..xPlayer.getName().."** a réanimé le joueur **"..args.target.."**", Config.Logs.Revive)
            else
                TriggerClientEvent("esx:showNotification", source, "Le joueur n'est pas connecté")
            end
        end
    end
end)

-- Register the reviveall command
lib.addCommand('reviveall', {
    help = '',
    restricted = 'group.admin'  -- Adjust the group based on your requirements
}, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Config.AutorizedGroupRevive[xPlayer.getGroup()] then
        local players = ESX.GetPlayers()
        for _, playerId in ipairs(players) do
            local tPlayer = ESX.GetPlayerFromId(playerId)
            PlayerDead[tPlayer.identifier] = {}
            TriggerClientEvent("ambulance:renamiplayerclientside", playerId)
        end
        Desc(3447003, "ReviveAll Effecuté", "Le staff **"..xPlayer.identifier.."** \nNom: "..xPlayer.getName().."** a réanimé tous les joueurs", Config.Logs.ReviveAll)
    end
end)

-- Register the heal command
lib.addCommand('heal', {
    help = '',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server ID (optional)',
            optional = true,
        }
    },
    restricted = 'group.admin'  -- Adjust the group based on your requirements
}, function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Config.AutorizedGroupRevive[xPlayer.getGroup()] then
        if not args.target then
            -- Heal the player who issued the command
            TriggerClientEvent("pqofiqoioqjgfjqzjîiqf", source)
            TriggerClientEvent("esx:showNotification", source, "Vous avez été soigné par un staff")
        else
            -- Heal the specified target player
            local tPlayer = ESX.GetPlayerFromId(args.target)
            if tPlayer then
                TriggerClientEvent("pqofiqoioqjgfjqzjîiqf", tPlayer.source)
                TriggerClientEvent("esx:showNotification", tPlayer.source, "Vous avez été soigné par un staff")
            else
                TriggerClientEvent("esx:showNotification", source, "Le joueur n'est pas connecté")
            end
        end
    end
end)

local ox_inventory = exports.ox_inventory

local stashes = {
{
    id = 'vestaireambulance',
    label = 'Vestiaire Ambulance',
    slots = 50,
    weight = 100000,
    jobs = 'ambulance'
},
{
    id = 'coffreambulance',
    label = 'Coffre Ambulance',
    slots = 50,
    weight = 100000,
    jobs = 'ambulance'
}
}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        for i=1, #stashes do
            local stash = stashes[i]
            ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.jobs)
        end
    end
end)

