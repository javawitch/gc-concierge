print('[gc-concierge] → client.lua starting')

if type(Config) ~= 'table' then
    error('[gc-concierge] FATAL: Config.lua not loaded or Config is nil!')
else
    print('[gc-concierge] Config loaded OK')
end

print('[gc-concierge] → client.lua starting')
if type(lib) ~= 'table' then
    error('[gc-concierge] FATAL: ox_lib not loaded! Did you include @ox_lib/init.lua before client.lua?')
end
print('[gc-concierge] lib OK, continuing…')


local ESX = nil
Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
    if Config.Debug then print('[concierge] ESX initialized') end
end)

-- REGISTER CONTEXT MENU ------------------------------------------------

lib.registerContext({
    id    = 'concierge_menu',
    title = 'Concierge',
    options = (function()
        if Config.Debug then
            print(('[concierge] registering %d Q&A options'):format(#Config.QAs))
        end
        local opts = {}
        for _, qa in ipairs(Config.QAs) do
            table.insert(opts, {
                title    = qa.question,
                onSelect = function()
                    if Config.Debug then
                        print(('[concierge] selected question: %s'):format(qa.question))
                    end
                    lib.notify({
                        title       = qa.question,
                        description = qa.answer,
                        type        = 'inform'
                    })
                    if Config.Debug then
                        print(('[concierge] displayed answer: %s'):format(qa.answer))
                    end
                end
            })
        end
        return opts
    end)()
})

-- SPAWN PED & ATTACH TARGET ---------------------------------------------

Citizen.CreateThread(function()
    local model  = Config.Concierge.model
    local coords = Config.Concierge.coords

    -- load ped model
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(10)
    end
    if Config.Debug then print(('[concierge] model loaded: %s'):format(model)) end

    -- spawn ped
    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if Config.Debug then
        print(('[concierge] spawned ped at %.2f, %.2f, %.2f'):format(coords.x, coords.y, coords.z))
    end

    -- add ox_target interaction
    exports.ox_target:addLocalEntity(ped, {
        {
            name     = 'concierge_menu_target',
            icon     = 'fas fa-concierge-bell',
            label    = 'Talk to Concierge',
            onSelect = function()
                if Config.Debug then print('[concierge] opening context menu') end
                lib.showContext('concierge_menu')
            end
        }
    })
    if Config.Debug then print('[concierge] ox_target option added') end
end)