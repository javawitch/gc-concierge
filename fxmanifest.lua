-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'

author 'Git Cute Scripts'
description 'Concierge script using ox_lib and ox_target'
version '1.0.0'

dependency 'es_extended'
dependency 'ox_lib'
dependency 'ox_target'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client.lua',
}
