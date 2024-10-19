fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'Mileage-based vehicle breakdown system for ESX&QBCore'
version 'v0.7.0-beta'

shared_script 'config.lua'
client_script 'client.lua'
server_script {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

shared_script '@ox_lib/init.lua'