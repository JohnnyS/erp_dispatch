local calls = {}

function GetDispatchCalls() return calls end
exports('GetDispatchCalls', GetDispatchCalls) -- exports['erp_dispatch']:GetDispatchCalls()

RegisterNetEvent("dispatch:svNotify")
AddEventHandler("dispatch:svNotify", function(data)
	local newId = #calls + 1
	calls[newId] = data
    calls[newId]['source'] = source
    calls[newId]['callId'] = newId
    calls[newId]['units'] = {}
    calls[newId]['responses'] = {}
    calls[newId]['time'] = os.time() * 1000
    TriggerClientEvent('dispatch:clNotify', -1, data, newId, source)
    --print(json.encode(data))
    if data['dispatchCode'] == '911' or data['dispatchCode'] == '311' or data['dispatchCode'] == '10-99' then
        TriggerClientEvent('erp-dispatch:setBlip', -1, data['dispatchCode'], vector3(data['origin']['x'], data['origin']['y'], data['origin']['z']), newId)
    end
end)

AddEventHandler("dispatch:addUnit", function(callid, player, cb)
    if calls[callid] then

        if #calls[callid]['units'] > 0 then
            for i=1, #calls[callid]['units'] do
                if calls[callid]['units'][i]['cid'] == player.identifier then
                    cb(#calls[callid]['units'])
                    return
                end
            end
        end
	local callsign = exports['erp_mdt']:GetCallsign(player.identifier)
        if player.job.name == 'police' then
            table.insert(calls[callid]['units'], { cid = player.identifier, fullname = player.name, job = 'Police', callsign = callsign[1].callsign	})
        elseif player.job.name == 'ambulance' then
            table.insert(calls[callid]['units'], { cid = player.identifier, fullname = player.name, job = 'EMS', callsign = callsign[1].callsign })
        elseif player.job.name == 'cmmc' then
            table.insert(calls[callid]['units'], { cid = player.identifier, fullname = player.name, job = 'EMS', callsign = callsign[1].callsign })
        end

        cb(#calls[callid]['units'])
    end
end)

AddEventHandler("dispatch:removeUnit", function(callid, player, cb)
    if calls[callid] then
        if #calls[callid]['units'] > 0 then
            for i=1, #calls[callid]['units'] do
                if calls[callid]['units'][i]['cid'] == player.identifier then
                    table.remove(calls[callid]['units'], i)
                end
            end
        end
        cb(#calls[callid]['units'])
    end    
end)

AddEventHandler("dispatch:sendCallResponse", function(player, callid, message, time, cb)
    if calls[callid] then
        table.insert(calls[callid]['responses'], {
            name = player.name,
            message = message,
            time = time
        })
        local player = calls[callid]['source']
        if GetPlayerPing(player) > 0 then
            TriggerClientEvent('dispatch:getCallResponse', player, message)
        end
        cb(true)
    else
        cb(false)
    end    
end)

RegisterCommand('togglealerts', function(source, args, user)
	local source = source
	local job = ESX.GetPlayerFromId(source).job
	if job.name == 'police' or job.name == 'ambulance' or job.name == 'pa' or job.name == 'cmmc' then
		TriggerClientEvent('erp-dispatch:manageNotifs', source, args[1])
	end
end)

RegisterNetEvent('erp-dispatch:gunshotAlert')
AddEventHandler('erp-dispatch:gunshotAlert', function(sentCoords, isAuto, isCop)
    TriggerClientEvent('erp-dispatch:gunshotAlert', -1, sentCoords, isAuto, isCop)
end)

RegisterNetEvent('erp-dispatch:combatAlert')
AddEventHandler('erp-dispatch:combatAlert', function(sentCoords)
    TriggerClientEvent('erp-dispatch:combatAlert', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:armedperson')
AddEventHandler('erp-dispatch:armedperson', function(sentCoords)
    TriggerClientEvent('erp-dispatch:armedperson', -1, sentCoords)
end)

-- VANGELICOS
RegisterNetEvent('rcrp-dispatch:servervangelicos')
AddEventHandler('rcrp-dispatch:servervangelicos', function(sentCoords)
    TriggerClientEvent('rcrp-dispatch:VangelicosBlip', -1, sentCoords)
end)

--Store Robberies
RegisterNetEvent('rcrp-dispatch:serverStoreRobberies')
AddEventHandler('rcrp-dispatch:serverStoreRobberies', function(sentCoords)
    TriggerClientEvent('rcrp-dispatch:StoreRobberiesBlip', -1, sentCoords)
end)

--Bank Robbery
RegisterNetEvent('rcrp-dispatch:ServerBankRobbery')
AddEventHandler('rcrp-dispatch:ServerBankRobbery', function(sentCoords)
    TriggerClientEvent('rcrp-dispatch:BankRobberyBlip', -1, sentCoords)
end)

--Car Thief
RegisterNetEvent('rcrp-dispatch:ChopShopBlip')
AddEventHandler('rcrp-dispatch:ChopShopBlip', function(sentCoords)
    TriggerClientEvent('rcrp-dispatch:ChopShopBlip', -1, sentCoords)
end)

--SSDrugs
RegisterNetEvent('rcrp-dispatch:DrugReportsBlip')
AddEventHandler('rcrp-dispatch:DrugReportsBlip', function(sentCoords)
    TriggerClientEvent('rcrp-dispatch:DrugReportBlip', -1, sentCoords)
end)

-- rcrp-dispatch:houserobbery
RegisterNetEvent('rcrp-dispatch:houserobbery')
AddEventHandler('rcrp-dispatch:houserobbery', function(sentCoords)
    TriggerClientEvent('rcrp-dispatch:houserobberyblip', -1, sentCoords)
end)







--Custom Shit

function getCaller(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	return xPlayer.getName()
end

ESX.RegisterServerCallback('rcrp:getCharData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local identifier = xPlayer.getIdentifier()
	MySQL.Async.fetchAll('SELECT firstname, lastname, phone_number FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(results)
		cb(results[1])
	end)
end)

AddEventHandler('rcrp-playerdownalert', function(dispatchCode, firstStreet, gender, priority, origin, dispatchMessage, name, number, job, information)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('dispatch:svNotify', {
        dispatchCode = dispatchCode,
        firstStreet = firstStreet,
        gender = gender,
        priority = priority,
        origin = origin,
        dispatchMessage = dispatchMessage,
        name = getCaller(source),
        number =  plyData['phone_number'],
        job = {"police","ambulance"},
        information = msg
    })

end)














RegisterNetEvent('erp-dispatch:vehiclecrash')
AddEventHandler('erp-dispatch:vehiclecrash', function(sentCoords)
    TriggerClientEvent('erp-dispatch:vehiclecrash', -1, sentCoords)
end)

-- erp-dispatch:banktruck

RegisterNetEvent('erp-dispatch:banktruck')
AddEventHandler('erp-dispatch:banktruck', function(sentCoords)
    TriggerClientEvent('erp-dispatch:banktruck', -1, sentCoords)
end)

-- erp-dispatch:art

RegisterNetEvent('erp-dispatch:art')
AddEventHandler('erp-dispatch:art', function(sentCoords)
    TriggerClientEvent('erp-dispatch:art', -1, sentCoords)
end)


RegisterNetEvent('erp-dispatch:g6')
AddEventHandler('erp-dispatch:g6', function(sentCoords)
    TriggerClientEvent('erp-dispatch:g6', -1, sentCoords)
end)


RegisterNetEvent('erp-dispatch:carboosting')
AddEventHandler('erp-dispatch:carboosting', function(sentCoords, vehicle, alert)
    TriggerClientEvent('erp-dispatch:carboosting', -1, sentCoords, vehicle, alert)
end)

RegisterNetEvent('erp-dispatch:yachtheist')
AddEventHandler('erp-dispatch:yachtheist', function(sentCoords)
    TriggerClientEvent('erp-dispatch:yachtheist', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:vehicletheft')
AddEventHandler('erp-dispatch:vehicletheft', function(sentCoords)
    TriggerClientEvent('erp-dispatch:vehicletheft', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:blip:jailbreak')
AddEventHandler('erp-dispatch:blip:jailbreak', function(sentCoords)
    TriggerClientEvent('erp-dispatch:blip:jailbreak', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:drugsale')
AddEventHandler('erp-dispatch:drugsale', function(sentCoords)
    TriggerClientEvent('erp-dispatch:drugsale', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:officerAlert')
AddEventHandler('erp-dispatch:officerAlert', function(pos, name)
    TriggerClientEvent('erp-dispatch:officerAlert', -1, pos, name, source)
end)

--[[ Officer downs ]]

RegisterNetEvent('erp-dispatch:policealertA')
AddEventHandler('erp-dispatch:policealertA', function(sentCoords)
    TriggerClientEvent('erp-dispatch:policealertA', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:policealertB')
AddEventHandler('erp-dispatch:policealertB', function(sentCoords)
    TriggerClientEvent('erp-dispatch:policealertB', -1, sentCoords)
end)

CreateThread(function()
    while true do
        Wait(3600000) -- 1 hour
        calls = {}
    end
end)

RegisterNetEvent('erp-dispatch:emsalertA')
AddEventHandler('erp-dispatch:emsalertA', function(sentCoords)
    TriggerClientEvent('erp-dispatch:emsalertA', -1, sentCoords)
end)

RegisterNetEvent('erp-dispatch:emsalertB')
AddEventHandler('erp-dispatch:emsalertB', function(sentCoords)
    TriggerClientEvent('erp-dispatch:emsalertB', -1, sentCoords)
end)

