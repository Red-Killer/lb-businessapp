local QBCore = exports['qb-core']:GetCoreObject()


local cooldown = {}
local cooldownTime = 30 -- cooldown in seconds

local cache = {}


QBCore.Functions.CreateCallback('lb-businessapp:getEmployees', function(src, cb)
    if cooldown[src] == nil then
        cooldown[src] = os.time()
    else
        if os.time() - cooldown[src] >= cooldownTime then
            cooldown[src] = nil
        else
            if cache[src] ~= nil then
                cb(cache[src])
            end

            return
        end
    end
    
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if xPlayer == nil then return end

    local xJob = xPlayer.PlayerData.job
    if xJob.name == 'unemployed' then return end
    
    local employees = {}

    local result = MySQL.Sync.fetchAll('SELECT * FROM players WHERE job = @job', {
        ['@job'] = xJob.name
    })

    for i=1, #result, 1 do
        local xTarget = QBCore.Functions.GetPlayerByCitizenId(result[i].identifier)
        local serverId = nil

        if xTarget ~= nil then 
            serverId = xTarget.source
        end

        local phone = exports["lb-phone"]:GetEquippedPhoneNumber(serverId or result[i].identifier)

        local employee = {
            name = result[i].firstname .. ' ' .. result[i].lastname,
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