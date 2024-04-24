
ESX = nil
if exports['es_extended'] then
    ESX = exports['es_extended']:getSharedObject()
else
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end
local players = {}
local function any(t, predicate)
    for _, v in ipairs(t) do if predicate(v) then return true end end
    return false
end
local function findPlayer(identifier)
    for _, p in ipairs(players) do if p.identifier == identifier then return p end end
    return nil
end
local function filter(t, predicate)
    local result = {}
    for _, v in ipairs(t) do if predicate(v) then table.insert(result, v) end end
    return result
end
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, result in ipairs(MySQL.Sync.fetchAll('SELECT identifier, firstname, lastname, job FROM users')) do
        local xPlayer, serverId, phone = ESX.GetPlayerFromIdentifier(result.identifier)
        if xPlayer then serverId = xPlayer.source 
            phone = exports["lb-phone"]:GetEquippedPhoneNumber(serverId)
        end
        print(serverId, phone)
        local player = {
            identifier = result.identifier,
            name = result.firstname .. ' ' .. result.lastname,
            job = result
                .job,
            serverId = serverId,
            phone = phone
        }
        table.insert(players, player)
    end
end)
AddEventHandler('esx:playerLoaded', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if not any(players, function(p) return p.identifier == xPlayer.identifier end) then
        table.insert(players,
            { identifier = xPlayer.identifier, name = xPlayer.getName(), job = xPlayer.getJob().name, serverId = source })
    end
end)
RegisterNetEvent('esx:setJob', function(src, job)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local found = findPlayer(xPlayer.identifier)
    if found then
        found.job = job.name
    end
end)
ESX.RegisterServerCallback('lb-businessapp:getEmployees', function(src, cb)
    if #players == 0 then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or xPlayer.job.name == 'unemployed' then return end
    local employees = filter(players, function(p) return p.job == xPlayer.job.name end)
    cb(employees)
end)
RegisterNetEvent('lb-businessapp:saveContact', function(data)
    if type(data.fname) ~= 'string' or type(data.lname) ~= 'string' or type(data.number) ~= 'string' then return end
    local srcNumber = exports["lb-phone"]:GetEquippedPhoneNumber(source)
    exports["lb-phone"]:AddContact(srcNumber, { firstname = data.fname, lastname = data.lname, number = data.number })
end)
