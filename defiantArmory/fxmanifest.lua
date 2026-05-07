fx_version 'cerulean'
game 'gta5'

name 'defiantArmory'
author 'Antigravity'
description 'Standalone High-Performance Tactical Armory'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/armory.css',
    'html/utils.js',
    'html/armory.js',
    'html/img/*.png'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'ox_target',
    'ox_inventory'
}
