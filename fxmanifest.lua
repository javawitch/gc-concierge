lua54 'yes'

fx_version 'cerulean'
game 'gta5'

author 'Git Cute Scripts'
description 'Concierge script using ox_lib and ox_target'
version '1.0.1'      -- bumped version

dependency 'es_extended'
dependency 'ox_lib'
dependency 'ox_target'

shared_scripts {
    'config.lua',  
}

client_scripts {
    '@ox_lib/init.lua',
    '@ox_target/init.lua',
    'client.lua',
}