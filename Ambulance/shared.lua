Config = {


    NBHealPourDegatMarche = 159, -- si il a moins de 159 de vie alors la démarche seras actif et permanante.
	NBHealPourNODegatMarche = 160, 
    TenuObligatoirePourOpenMenu = true, 
    TimeDeath = 1,
    Position = {
        Coffre = vector3(306.81, -601.49, 43.28),
        Boss = vector3(334.7721, -594.2678, 43.2840),
        Vestiaire = vector3(301.37, -599.16, 43.28),
        Garage = vector3(297.84, -602.71, 43.30),
    },

    Position2 = {
        SpawnVehicle = vector3(289.92, -591.997, 43.30),
        SpawnHelico = vector3(351.65, -588.35, 74.16),
        DeleteVeh = vector3(296.2195, -609.0278, 43.1469),
    },

    HeadingVehSpawn = 333.85,
    HeadingPed = 344.66,

    Hospital = {
        RespawnNord = vector3(26.38, 6356.33, 31.23),
        RespwanSud = vector3(310.85, -580.31, 43.28),
        Pos3 = vector3(310.85, -580.31, 43.28),
    },
    Logs = {
        ReanimationEMS = "https://discord.com/api/webhooks/937434595488571453/lhsqeMOHpzDResrRWchbOPN-YUgbriWL9vCywnjv9Q06kp1IHiZrDRCKK2NDgNdx3Met",
        RespawnHospital = "https://discord.com/api/webhooks/937434595488571453/lhsqeMOHpzDResrRWchbOPN-YUgbriWL9vCywnjv9Q06kp1IHiZrDRCKK2NDgNdx3Met",
        Revive = "https://discord.com/api/webhooks/937434595488571453/lhsqeMOHpzDResrRWchbOPN-YUgbriWL9vCywnjv9Q06kp1IHiZrDRCKK2NDgNdx3Met",
        ReviveAll = "https://discord.com/api/webhooks/937434595488571453/lhsqeMOHpzDResrRWchbOPN-YUgbriWL9vCywnjv9Q06kp1IHiZrDRCKK2NDgNdx3Met",
    },

    AutorizedGroupRevive = {
        ["user"] = false,
        ["mod"] = true, 
        ["admin"] = true, 
        ["superadmin"] = true,
        ["_dev"] = true
    },

    PriceReanimation = 50, -- Prix que la pesonne paieras quand elle sera réanimé
    Remuneration = 100, -- Somme que l'EMS recois après une réanimation
    PriceDefibirlateur = 500,
    Accounts = {
        ["money"] = "money" -- Aller voir dans le config de votre es_extented
    },

    Blips = {
        Position = vector3(310.85, -580.31, 43.28),
        Name = "Hopital",
        Sprite = 61
    },

    Marker = {
        Notif = "Appuyez pour intéragir",
    },


    Garage = {
        ["ambulance"] = {
            type = "car",
            label = "Camion Ambulance",
            plate = "AMBU",
        },
        ["polmav"] = {
            type = "hélico",
            label = "Hélicoptère",
            plate = "AMBU",
        },
    },

}

