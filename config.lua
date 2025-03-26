Config = {}

Config.DepartmentName = "Los Santos Police Department"
Config.LogoUrl = "img/pd_logo.png" -- Path relative to the html folder
Config.AdminRanks = {4, 5} -- Job grades that can add items to the armory

Config.Armories = {
    [1] = {
        ped = "s_m_y_cop_01", -- Ped choice
        pedlocation = vector3(463.26354980469, -996.32135009766, 31.838496780396), -- Ped location
        pedheading = 4.64, -- Ped heading (the way the ped is looking.)
        pedanim = {
            dict = 'amb@world_human_cop_idles@male@base',
            anim = 'base'
        },
        pedSettings = {
            SetEntityInvincible = true,
            SetBlockingOfNonTemporaryEvents = true,
            FreezeEntityPosition = true
        },
        ArmoryItems = {
            ['police'] = { -- if you the same items to grade 0 and 1 it will show them double, so add whatever in the grade 0 if you want them in 1 as grade 1 will have grade 0 items.
                [0] = {
                    {name = 'WEAPON_G22', label = 'Service Pistol .40', price = 100, description = 'Standard issue service pistol'},
                    {name = 'ammo-40', label = '.40 ammo', price = 2, description = 'Ammunition for .40 caliber weapons'},
                    {name = 'WEAPON_STUNGUN', label = 'Non-Lethal', price = 25, description = 'Non-lethal taser for subduing suspects'},
                    {name = 'handcuffs', label = 'Handcuffs', price = 10, description = 'Standard issue restraints'},
                    {name = 'handcuffkey', label = 'Handcuff Key', price = 5, description = 'Key for unlocking handcuffs'},
                    {name = 'radio', label = 'Radio', price = 50, description = 'Police radio for communication'},
                    {name = 'vestplate_police', label = 'Armor Plate', price = 50, description = 'Ballistic plate for body armor'},
                    {name = 'vest_police', label = 'Armor Vest', price = 100, description = 'Standard issue body armor'},
                },
                [1] = {
                    {name = 'spikestrip', label = 'Spike Strip', price = 250, description = 'Deployable spike strip for stopping vehicles'},
                    {name = 'WEAPON_PISTOL_MK2', label = 'Service Weapon 9mm', price = 250, description = 'Advanced service pistol'},
                    {name = 'ammo-9', label = '9mm ammo', price = 2, description = 'Ammunition for 9mm weapons'},
                },
                [2] = {
                },
                [3] = {
                },
                [4] = {
                    {name = 'WEAPON_DD11_B', label = 'DD11 Ar15', price = 550, description = 'Tactical rifle for high-risk situations'},
                    {name = 'rifle_ammo', label = 'Rifle Ammo', price = 4, description = 'Ammunition for rifle weapons'},
                },
            },
            ['sheriff'] = { -- if you the same items to grade 0 and 1 it will show them double, so add whatever in the grade 0 if you want them in 1 as grade 1 will have grade 0 items.
            [0] = {
                {name = 'WEAPON_G22', label = 'Service Pistol .40', price = 100, description = 'Standard issue service pistol'},
                {name = 'ammo-40', label = '.40 ammo', price = 2, description = 'Ammunition for .40 caliber weapons'},
                {name = 'WEAPON_STUNGUN', label = 'Non-Lethal', price = 25, description = 'Non-lethal taser for subduing suspects'},
                {name = 'handcuffs', label = 'Handcuffs', price = 10, description = 'Standard issue restraints'},
                {name = 'handcuffkey', label = 'Handcuff Key', price = 5, description = 'Key for unlocking handcuffs'},
                {name = 'radio', label = 'Radio', price = 50, description = 'Police radio for communication'},
                {name = 'vestplate_police', label = 'Armor Plate', price = 50, description = 'Ballistic plate for body armor'},
                {name = 'vest_police', label = 'Armor Vest', price = 100, description = 'Standard issue body armor'},
            },
            [1] = {
                {name = 'spikestrip', label = 'Spike Strip', price = 250, description = 'Deployable spike strip for stopping vehicles'},
                {name = 'WEAPON_PISTOL_MK2', label = 'Service Weapon 9mm', price = 250, description = 'Advanced service pistol'},
                {name = 'ammo-9', label = '9mm ammo', price = 2, description = 'Ammunition for 9mm weapons'},
            },
            [2] = {
            },
            [3] = {
            },
            [4] = {
                {name = 'WEAPON_DD11_B', label = 'DD11 Ar15', price = 550, description = 'Tactical rifle for high-risk situations'},
                {name = 'rifle_ammo', label = 'Rifle Ammo', price = 4, description = 'Ammunition for rifle weapons'},
            },
        }
        }
    }
}
