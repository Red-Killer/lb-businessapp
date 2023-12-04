ESX = nil
local UserTable = {}
if exports['es_extended'] ~= nil then
    ESX = exports['es_extended']:getSharedObject()
else
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end


local cooldown = {}
local cooldownTime = 30 -- cooldown in seconds

local cache = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        UserTable = MySQL.Sync.fetchAll('SELECT identifier, firstname, lastname, job FROM users')
    end
end)

RegisterNetEvent('lb-businessapp:addUserTable', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local isListed = false
    for _, result in pairs(UserTable) do
        if result.identifier == xPlayer.identifier then
            isListed = true
        end
    end

    if not isListed then
        local data = {
            identifier = xPlayer.identifier,
            firstname = xPlayer.firstname,
            lastname = xPlayer.lastname,
            job = xPlayer.getJob().name
        }
        table.insert(UserTable, data)
        print("added new player to usertable with id: " .. xPlayer.source)
    end
    
end)

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
    
    for _, result in pairs(UserTable) do
        local xTarget = ESX.GetPlayerFromIdentifier(result.identifier)
        local serverId = nil

        if xTarget ~= nil then 
            serverId = xTarget.source
        end

        if  result.job == xJob.name then
        
            local phone = exports["lb-phone"]:GetEquippedPhoneNumber(serverId)

            local employee = {
                name = result.firstname .. " " .. result.lastname,
                serverId = serverId,
                phone = phone
            }
            table.insert(employees, employee)
        end
        
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

RegisterNetEvent('esx:setJob', function(src, job, lastJob)
    local xPlayer = ESX.GetPlayerFromId(src)
    for _, result in pairs(UserTable) do
        if result.identifier == xPlayer.identifier then
            result.job = job.name
        end
    end
end)
