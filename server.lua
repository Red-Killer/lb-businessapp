ESX = nil

if exports['es_extended'] ~= nil then
    ESX = exports['es_extended']:getSharedObject()
else
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end


local cooldown = {}
local cooldownTime = 30 -- cooldown in seconds

local cache = {}


ESX.RegisterServerCallback('lb-businessapp:getEmployees', function(src, cb)
    local employees = {}
    if cooldown[src] == nil then
        cooldown[src] = os.time()
    else
        if os.time() - cooldown[src] >= cooldownTime then
            cooldown[src] = nil
            cache[src] = nil
        else
            if cache[src] ~= nil then
                cb(cache[src])
            end

            return
        end
    end
    
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer == nil then return end

    local xJob = xPlayer.getJob()
    if xJob.name == 'unemployed' or xJob.name == 'offduty' then cb(employees) return end
    

    local result = ESX.GetExtendedPlayers("job", xJob.name)

    for _, xTarget in pairs(result) do
        local serverId = nil

        if xTarget ~= nil then 
            serverId = xTarget.source
        end

        local phone = exports["lb-phone"]:GetEquippedPhoneNumber(serverId)

        local employee = {
            name = xTarget.getName(),
            serverId = serverId,
            phone = phone
        }

        table.insert(employees, employee)
    end

    cache[src] = employees
    cb(employees)
end)

RegisterNetEvent('lb-businessapp:saveContact', function(data)
    if data.fname == nil or data.lname == nil or data.number == nil then return end
    if type(data.fname) ~= 'string' or type(data.lname) ~= 'string' or type(data.number) ~= 'string' then return end
    
    local src = source
    local srcNumber = exports["lb-phone"]:GetEquippedPhoneNumber(src)

    exports["lb-phone"]:AddContact(srcNumber, { firstname = data.fname, lastname = data.lname, number = data.number })
end)