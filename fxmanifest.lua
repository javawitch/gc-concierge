-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'ESX Concierge script using ox_lib and ox_target'
version '1.0.1'      -- bumped version

dependency 'es_extended'
dependency 'ox_lib'
dependency 'ox_target'

shared_scripts {
    'config.lua',   -- load your config first
}

client_scripts {
    '@ox_lib/init.lua',    -- ← ensure ox_lib sets up `lib`
    '@ox_target/init.lua', -- ← ensure ox_target registers its exports
    'client.lua',          -- ← now it’s safe to use lib.registerContext, etc.
}