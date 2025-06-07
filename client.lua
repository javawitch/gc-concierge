-- client.lua

-- SAFEGUARD: make sure Config and lib are loaded
if type(Config) ~= 'table' then
    error('[gc-concierge] Config not found!')
end
if type(lib) ~= 'table' then
    error('[gc-concierge] ox_lib (lib) not found!')
end

-- ESX via exports (best practice)
local ESX = exports['es_extended']:getSharedObject()

-- REGISTER CONTEXT (once ESX & lib are up)
Citizen.CreateThread(function()
    -- build up the options table
    local opts = {}
    for i, qa in ipairs(Config.QAs) do
        opts[i] = {
            id          = ('concierge_q%d'):format(i),
            title       = qa.question,
            description = qa.answer,         -- shows under the question
            onSelect    = function()
                if Config.Debug then
                    print(('[concierge] answered: %s'):format(qa.answer))
                end
                lib.notify({
                    title       = qa.question,
                    description = qa.answer,
                    type        = 'inform'
                })
            end
        }
    end

    lib.registerContext({
        id      = 'concierge_menu',
        title   = 'Concierge',
        options = opts
    })

    if Config.Debug then
        print(('[concierge] registered %d options'):format(#opts))
    end
end)

-- SPAWN PED & ATTACH TARGET (unchanged) -------------------------------
Citizen.CreateThread(function()
    local model, coords = Config.Concierge.model, Config.Concierge.coords

    -- load ped model
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end

    -- spawn ped
    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- attach ox_target interaction
    exports.ox_target:addLocalEntity(ped, {{
        name     = 'concierge_menu_target',
        icon     = 'fas fa-concierge-bell',
        label    = 'Talk to Concierge',
        onSelect = function()
            if Config.Debug then print('[concierge] opening context menu') end
            lib.showContext('concierge_menu')
        end
    }})

    if Config.Debug then
        print(('[concierge] spawned ped & attached target at %.2f, %.2f')
            :format(coords.x, coords.y))
    end
end)