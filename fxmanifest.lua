fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'Mileage-based vehicle breakdown system for ESX&QBCore'
version 'v0.7.81-beta'

shared_script 'config.lua'
client_script 'client.lua'
server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/*'
}

shared_script '@ox_lib/init.lua'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/styleanimations.css',
    -- 'nui/styleformal.css',
    'nui/script.js',
    'nui/img/*',
    'nui/sounds/*',
}
