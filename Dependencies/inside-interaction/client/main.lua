Data = {}

local function AddInteractionCoords(coords, args)
    if not coords.x or not coords.y or not coords.z then print("You have not completed any of the x, y, z arguments.") return end
    local name = "coords:"..coords.x.." "..coords.y.." "..coords.z

    if not args.distance then args.distance = cfg.Interaction.Distance end
    if not args.offset then args.offset = {label = 0.4, target = 0.0} end
    if not args.checkVisibility then args.checkVisibility = false end

    local hasName = true
    local hasFunction = true
    local CreateOptions = {}

    for i, v in ipairs(args) do
        if not v.name then hasName = false break end
        if not v.action then hasFunction = false break end
        if not v.key then v.key = cfg.Interaction.Key end
        if not v.label then v.label = cfg.Interaction.Label end
        if not v.duration then v.duration = cfg.Interaction.Duration end
        table.insert(CreateOptions, {name = v.name, action = v.action, key = v.key, label = v.label, duration = v.duration, icon = v.icon})
    end

    if not hasName then print("You did not enter a unique name.") return end
    if not hasFunction then print("You haven't entered a function.") return end

    if not Data[name] then
        Data[name] = {Options = CreateOptions, Handler = coords, Distance = args.distance, Offset = args.offset, checkVisibility = args.checkVisibility}
    else
        if not type(Data[name].Handler) == "table" then print("To create this interaction, it must be coordinate-based only and cannot contain any other types of interactions.") return end

        for _, v in ipairs(CreateOptions) do
            table.insert(Data[name].Options, v)
        end

        Data[name].Distance = args.distance
        Data[name].Offset = args.offset
        Data[name].checkVisibility = args.checkVisibility
    end

    if cfg.Debug then
        print("Current Interactions for Date ("..name.."):")
        for _, v in ipairs(Data[name].Options) do
            print(v.name, v.label)
        end
    end

    return name
end

exports("AddInteractionCoords", AddInteractionCoords)

local function AddInteractionEntity(entity, args)
    if not DoesEntityExist(entity) then print("There is no such Entity.") return end
    local name = "id:"..entity
    
    if not args.distance then args.distance = cfg.Interaction.Distance end
    if not args.offset then args.offset = {label = {x = 0.0, y = 0.0, z = 0.4}, target = {x = 0.0, y = 0.0, z = 0.0}} end
    if not args.checkVisibility then args.checkVisibility = false end

    local hasName = true
    local hasFunction = true
    local CreateOptions = {}

    for i, v in ipairs(args) do
        if not v.name then hasName = false break end
        if not v.action then hasFunction = false break end
        if not v.key then v.key = cfg.Interaction.Key end
        if not v.label then v.label = cfg.Interaction.Label end
        if not v.duration then v.duration = cfg.Interaction.Duration end
        table.insert(CreateOptions, {name = v.name, action = v.action, key = v.key, label = v.label, duration = v.duration, icon = v.icon})
    end

    if not hasName then print("You did not enter a unique name.") return end
    if not hasFunction then print("You haven't entered a function.") return end

    if not Data[name] then
        Data[name] = {Options = CreateOptions, Handler = entity, Distance = args.distance, Offset = args.offset, checkVisibility = args.checkVisibility}
    else
        if not type(Data[name].Handler) == "number" then print("To create this interaction, it must be based solely on the Entity ID and cannot contain any other types of interactions.") return end

        for _, v in ipairs(CreateOptions) do
            table.insert(Data[name].Options, v)
        end

        Data[name].Distance = args.distance
        Data[name].Offset = args.offset
        Data[name].checkVisibility = args.checkVisibility
    end

    if cfg.Debug then
        print("Current Interactions for Date ("..name.."):")
        for _, v in ipairs(Data[name].Options) do
            print(v.name, v.label)
        end
    end

    return name
end

exports("AddInteractionEntity", AddInteractionEntity)

local function AddInteractionEntityMultiple(entity, args)
    if not DoesEntityExist(entity) then print("There is no such Entity.") return end
    local name = "id:"..entity

    if not args.distance then args.distance = cfg.Interaction.Distance end
    if not args.checkVisibility then args.checkVisibility = false end

    local hasOffset = true
    local hasName = true
    local hasFunction = true
    local CreateOptions = {}

    for index, value in ipairs(args) do
        if not value.offset then hasOffset = false break end
        if not hasName then break end
        if not hasFunction then break end
        CreateOptions[index] = {}
        CreateOptions[index].offset = value.offset

        for i, v in ipairs(value.interaction) do
            if not v.name then hasName = false break end
            if not v.action then hasFunction = false break end
            if not v.key then v.key = cfg.Interaction.Key end
            if not v.label then v.label = cfg.Interaction.Label end
            if not v.duration then v.duration = cfg.Interaction.Duration end
            table.insert(CreateOptions[index], {name = v.name, action = v.action, key = v.key, label = v.label, duration = v.duration, icon = v.icon})
        end
    end

    if not hasOffset then print("You have not entered an offset.") return end
    if not hasName then print("You did not enter a unique name.") return end
    if not hasFunction then print("You haven't entered a function.") return end

    if not Data[name] then
        Data[name] = {Options = CreateOptions, Handler = entity, Distance = args.distance, checkVisibility = args.checkVisibility, isMultiple = true}
    else
        if not type(Data[name].Handler) == "number" or not Data[name].isMultiple then print("To create this interaction, it must be based solely on the Entity ID and cannot contain any other types of interactions.") return end

        for _, v in ipairs(CreateOptions) do
            table.insert(Data[name].Options, v)
        end

        Data[name].Distance = args.distance
        Data[name].checkVisibility = args.checkVisibility
    end

    if cfg.Debug then
        print("Current Interactions for Multiple Data ("..name.."):")
        for _, value in ipairs(Data[name].Options) do
            for i, v in ipairs(value) do
                print(v.name, v.label)
            end
        end
    end

    return name
end

exports("AddInteractionEntityMultiple", AddInteractionEntityMultiple)

local function RemoveInteraction(handler, unique_name)
    if not Data[handler] then print("There is no Interaction with such a Handler.") return end
    if not unique_name then Data[handler] = nil if cfg.Debug then print("You have deleted the Interaction ("..handler..")") end return end

    if unique_name then
        local foundName = false

        if Data[handler].isMultiple then
            for index, value in ipairs(Data[handler].Options) do
                if foundName then break end
                for i, v in ipairs(value) do
                    if v.name == unique_name then
                        foundName = true
                        table.remove(Data[handler].Options[index], i)
                        if #Data[handler].Options[index] == 0 then table.remove(Data[handler].Options, index) end
                        if cfg.Debug then print("You have removed the Interaction ("..unique_name..") in the Handler ("..handler..")") end
                        break
                    end
                end
            end
        else
            for i, v in ipairs(Data[handler].Options) do
                if v.name == unique_name then
                    foundName = true
                    table.remove(Data[handler].Options, i)
                    if cfg.Debug then print("You have removed the Interaction ("..unique_name..") in the Handler ("..handler..")") end
                    break
                end
            end
        end

        if not foundName then print("The specified unique name does not exist") return end
        if #Data[handler].Options == 0 then Data[handler] = nil end
    end
end

exports("RemoveInteraction", RemoveInteraction)


visibleEntities = {}

function checkVisibility()
    local player_coords = GetEntityCoords(PlayerPedId())
    local camera_coords = GetGameplayCamCoord()

    for name, v in pairs(Data) do
        if v.checkVisibility then
            if type(v.Handler) == "vector3" then
                local distance = #(player_coords - vector3(v.Handler.x, v.Handler.y, v.Handler.z))

                if distance <= v.Distance then
                    local rayHandle = StartShapeTestRay(camera_coords.x, camera_coords.y, camera_coords.z, v.Handler.x, v.Handler.y, v.Handler.z, 1, 0, 0)
                    local _, hit, _, _, _ = GetShapeTestResult(rayHandle)
                    visibleEntities[name] = (hit == 0)
                end
            else
                if DoesEntityExist(v.Handler) then
                    local entity_coords = GetEntityCoords(v.Handler)
                    local distance = #(player_coords - entity_coords)

                    if distance <= v.Distance then
                        if IsEntityOnScreen(v.Handler) then
                            local rayHandle = StartShapeTestRay(camera_coords.x, camera_coords.y, camera_coords.z, entity_coords.x, entity_coords.y, entity_coords.z, 1, v.Handler, 0)
                            local _, hit, _, _, _ = GetShapeTestResult(rayHandle)
                            visibleEntities[name] = (hit == 0)
                        else
                            visibleEntities[name] = false
                        end
                    end
                end
            end
        end
    end
end

CreateThread(function()
    if cfg.Debug then
        local coords = GetEntityCoords(PlayerPedId())

        local Coords = exports["inside-interaction"]:AddInteractionCoords(coords, {
            checkVisibility = true,
            {
                name = "coords",
                icon = "fa-regular fa-circle-up",
                label = "Coordinates",
                key = "E",
                duration = 1000,
                action = function()
                    print("coords")
                end
            }
        })

        --exports["inside-interaction"]:RemoveInteraction(Coords)
    end

    local renderTargetDelay = 0
    local raycastDelay = 500

    CreateThread(function()
        while true do
            checkVisibility()
            Wait(raycastDelay)
        end
    end)

    local KeyHold = false

    while true do
        local delay = 500
        local player = PlayerPedId()
        local player_coords = GetEntityCoords(player)
        local onScreenEntities = {}
        local closestEntity = nil
        local closestDistance = 1.5
    
        if not IsPauseMenuActive() and not IsPedInAnyVehicle(player, false) then
            for name, value in pairs(Data) do
                if value.checkVisibility and visibleEntities[name] or not value.checkVisibility then
                    if not value.isMultiple then
                        if not value.Display then value.Display = 1 end

                        local entity_coords = nil
                        if type(value.Handler) == "number" then
                            entity_coords = GetOffsetFromEntityInWorldCoords(value.Handler, value.Offset.target.x, value.Offset.target.y, value.Offset.target.z)
                        elseif type(value.Handler) == "vector3" then
                            entity_coords = vector3(value.Handler.x, value.Handler.y, value.Handler.z + value.Offset.target)
                        end

                        local distance = #(player_coords - entity_coords)

                        if distance <= value.Distance then
                            local isOnScreen, screenX, screenY = GetScreenCoordFromWorldCoord(entity_coords.x, entity_coords.y, entity_coords.z)
                            local scale = math.max(0.5, 1.0 - (distance / value.Distance) * (1.0 - 0.5))

                            if isOnScreen and distance < closestDistance and (screenX > 0.37 and screenX < 0.63) and (screenY > 0.25 and screenY < 0.75) then
                                local offset = nil
                                if type(value.Handler) == "number" then
                                    offset = GetOffsetFromEntityInWorldCoords(value.Handler, value.Offset.label.x, value.Offset.label.y, value.Offset.label.z)
                                elseif type(value.Handler) == "vector3" then
                                    offset = vector3(value.Handler.x, value.Handler.y, value.Handler.z + value.Offset.label)
                                end
                                local isOnScreenClosest, screenXClosest, screenYClosest = GetScreenCoordFromWorldCoord(offset.x, offset.y, offset.z)

                                if (IsControlJustReleased(2, 241) or IsDisabledControlJustReleased(2, 241)) or (IsControlJustReleased(0, Keys[cfg.Interaction.ScrollUp]) or IsDisabledControlJustReleased(0, Keys[cfg.Interaction.ScrollUp])) then
                                    if (value.Display < #value.Options) then
                                        value.Display = value.Display + 1
                                    end
                                end
                        
                                if (IsControlJustReleased(2, 242) or IsDisabledControlJustReleased(2, 242)) or (IsControlJustReleased(0, Keys[cfg.Interaction.ScrollDown]) or IsDisabledControlJustReleased(0, Keys[cfg.Interaction.ScrollDown])) then
                                    if (value.Display > 1) then
                                        value.Display = value.Display - 1
                                    end
                                end

                                if IsControlJustPressed(0, Keys[value.Options[value.Display].key]) and not KeyHold then
                                    KeyHold = true
                                    SendNUIMessage({
                                        action = 'buttonClick',
                                    })
                                elseif not IsControlPressed(0, Keys[value.Options[value.Display].key]) and KeyHold then
                                    KeyHold = false
                                    SendNUIMessage({
                                        action = 'buttonReset',
                                    })
                                end

                                closestDistance = distance
                                closestEntity = {
                                    x = screenXClosest, 
                                    y = screenYClosest,
                                    id = name,
                                    Type = value.isMultiple,
                                    Display = value.Display,
                                    option = value.Options[value.Display],
                                    scroll = (#value.Options > 1),
                                    up = (value.Display < #value.Options),
                                    down = (value.Display > 1)
                                }
                            end
                            table.insert(onScreenEntities, {
                                x = screenX, 
                                y = screenY,
                                scale = scale
                            })
                        end
                    elseif value.isMultiple then
                        for i, v in ipairs(Data[name].Options) do
                            if not value.Options[i].Display then value.Options[i].Display = 1 end

                            local entity_coords = GetOffsetFromEntityInWorldCoords(value.Handler, v.offset.target.x, v.offset.target.y, v.offset.target.z)
                            local distance = #(player_coords - entity_coords)

                            if distance <= value.Distance then
                                local isOnScreen, screenX, screenY = GetScreenCoordFromWorldCoord(entity_coords.x, entity_coords.y, entity_coords.z)
                                local scale = math.max(0.5, 1.0 - (distance / value.Distance) * (1.0 - 0.5))

                                if isOnScreen and distance < closestDistance and (screenX > 0.37 and screenX < 0.63) and (screenY > 0.25 and screenY < 0.75) then
                                    local offset = GetOffsetFromEntityInWorldCoords(value.Handler, v.offset.label.x, v.offset.label.y, v.offset.label.z)
                                    local isOnScreenClosest, screenXClosest, screenYClosest = GetScreenCoordFromWorldCoord(offset.x, offset.y, offset.z)

                                    if (IsControlJustReleased(2, 241) or IsDisabledControlJustReleased(2, 241)) or (IsControlJustReleased(0, Keys[cfg.Interaction.ScrollUp]) or IsDisabledControlJustReleased(0, Keys[cfg.Interaction.ScrollUp])) then
                                        if (value.Options[i].Display < #value.Options[i]) then
                                            value.Options[i].Display = value.Options[i].Display + 1
                                        end
                                    end
                            
                                    if (IsControlJustReleased(2, 242) or IsDisabledControlJustReleased(2, 242)) or (IsControlJustReleased(0, Keys[cfg.Interaction.ScrollDown]) or IsDisabledControlJustReleased(0, Keys[cfg.Interaction.ScrollDown])) then
                                        if (value.Options[i].Display > 1) then
                                            value.Options[i].Display = value.Options[i].Display - 1
                                        end
                                    end

                                    if IsControlJustPressed(0, Keys[value.Options[i][value.Options[i].Display].key]) and not KeyHold then
                                        KeyHold = true
                                        SendNUIMessage({
                                            action = 'buttonClick',
                                        })
                                    elseif not IsControlPressed(0, Keys[value.Options[i][value.Options[i].Display].key]) and KeyHold then
                                        KeyHold = false
                                        SendNUIMessage({
                                            action = 'buttonReset',
                                        })
                                    end

                                    closestDistance = distance
                                    closestEntity = {
                                        x = screenXClosest, 
                                        y = screenYClosest,
                                        id = name,
                                        Type = value.isMultiple,
                                        Display = value.Options[i].Display,
                                        Index = i,
                                        option = value.Options[i][value.Options[i].Display],
                                        scroll = (#value.Options[i] > 1),
                                        up = (value.Options[i].Display < #value.Options[i]),
                                        down = (value.Options[i].Display > 1)
                                    }
                                end
                                table.insert(onScreenEntities, {
                                    x = screenX, 
                                    y = screenY,
                                    scale = scale
                                })
                            end
                        end
                    end
                end
            end
        end

        if closestEntity then
            delay = renderTargetDelay
            SendNUIMessage({
                action = 'updateClosestTarget',
                display = true,
                entity = closestEntity
            })
        else 
            SendNUIMessage({
                action = 'updateClosestTarget',
                display = false
            })
        end
        
        if #onScreenEntities > 0 then
            delay = renderTargetDelay
            SendNUIMessage({
                action = 'updateTarget',
                display = true,
                entities = onScreenEntities
            })
        else
            SendNUIMessage({
                action = 'updateTarget',
                display = false
            })
        end

        Wait(delay)
    end
end)

RegisterNUICallback('progressSuccess', function(data, cb)
    if data.type then
        Data[data.entity].Options[data.index][data.id].action()
    else
        Data[data.entity].Options[data.id].action()
    end
    cb(true)
end)