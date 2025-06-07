-- client.lua

-- CONFIGURATION --------------------------------------------------------

local conciergeModel    = 's_m_m_linecook'     -- ped model
local conciergeCoords   = vector4(227.07, -809.02, 30.54, 68)  -- x,y,z,heading

-- Question & Answer table
local QAs = {
    { question = "What services do you offer?", answer = "We offer room booking, transportation arrangements, and city tours." },
    { question = "How do I become a member?",    answer = "Simply fill out the membership form at City Hall and pay the annual fee." },
    { question = "When is check-out time?",       answer = "Check-out is at 11:00 AM daily. Late check-out may incur extra charges." },
    { question = "Can I change my reservation?", answer = "Yes — modifications up to 24 hours before your stay are free of charge." },
    -- add as many Q&A pairs here as you like
}

-- ESX INIT (if you need ESX functions)
local ESX = nil
Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)


-- CREATE THE CONTEXT MENU ------------------------------------------------

lib.registerContext({
    id    = 'concierge_menu',
    title = 'Concierge',
    options = (function()
        local opts = {}
        for _, qa in ipairs(QAs) do
            table.insert(opts, {
                title       = qa.question,
                description = nil,
                onSelect    = function()
                    lib.notify({
                        title       = qa.question,
                        description = qa.answer,
                        type        = 'inform'
                    })
                end
            })
        end
        return opts
    end)()
})


-- SPAWN THE PED AND REGISTER TARGET ---------------------------------------

Citizen.CreateThread(function()
    -- load model
    local hash = GetHashKey(conciergeModel)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(10)
        end
    end

    -- spawn
    local ped = CreatePed(4, hash,
        conciergeCoords.x, conciergeCoords.y, conciergeCoords.z,
        conciergeCoords.w, false, true
    )
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- attach ox_target interaction
    exports.ox_target:addLocalEntity(ped, {
        {
            name    = 'concierge_menu_target',
            icon    = 'fas fa-concierge-bell',
            label   = 'Talk to Concierge',
            onSelect = function()
                lib.showContext('concierge_menu')
            end
        }
    })
end)