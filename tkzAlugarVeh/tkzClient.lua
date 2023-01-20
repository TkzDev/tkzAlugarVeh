local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())

---- [ VARIAVEIS  ] -----
vehicleSpawnado = false

---- [ TABLES  ] -----
local locPegarVehicle = {
	[1] = { 73.34, -1027.25, 29.48 } -- CDS AONDE VAI FICAR O BLIP PARA SOLICITAR O VEÍCULO (X,Y,Z)
}
local spawnVehicle = {
	[1] = { 76.25,-1033.61,29.46,249.84 } -- CDS AONDE VAI SPAWNAR O VEÍUCLO (X,Y,Z,H)
}

---- [ THREAD DE ALUGAR  ] -----

Citizen.CreateThread(function()
    while true do
        local tkz = 1000
        for k,v in pairs(locPegarVehicle) do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped),v[1],v[2],v[3],true)
            tkz = 1
            if distance < 3 then
                DrawText3D(v[1],v[2],v[3],"~w~Pressione ~r~[E] ~w~Para alugar um veículo")
                if IsControlJustPressed(0,46) then
                    if vSERVER.pagarTaxa() then
                        spawnarVeh()
                        vehicleSpawnado = true
                        guardarVehicle()
                    end
                end
            end
        end
        Citizen.Wait(tkz)
    end
end)

---- [ FUNÇÃO DE GERAR VEÍCULO ] -----

function spawnarVeh()
    local checkslot = 1
    mhash = GetHashKey('faggio')
    while not HasModelLoaded(mhash) do
        RequestModel(mhash)
        Citizen.Wait(1)
    end

    if HasModelLoaded(mhash) then

        for k,v in pairs(spawnVehicle) do
            if checkslot ~= -1 then
                nveh = CreateVehicle(mhash,v[1],v[2],v[3]+0.5,v[4],true,false)
                SetVehicleIsStolen(nveh,false)
                SetVehicleNeedsToBeHotwired(nveh,false)
                SetVehicleOnGroundProperly(nveh)
                SetVehicleNumberPlateText(nveh,vRP.getRegistrationNumber())
                SetEntityAsMissionEntity(nveh,true,true)
                SetVehRadioStation(nveh,"OFF")
                vSERVER.vehicleLock()
                SetModelAsNoLongerNeeded(mhash)
                return true,VehToNet(nveh) 
            end
        end
    end
end

---- [ FUNÇÃO DE GUARDAR VEÍCULO ] -----

function guardarVehicle()
    Citizen.CreateThread(function()
        while true do
            local tkz = 1000
            for k,v in pairs(locPegarVehicle) do
                if vehicleSpawnado then
                    tkz = 1
                    local ped = PlayerPedId()
                    local tkzin = table.unpack(GetEntityCoords(veh))
                    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh))
                    drawTxt("~w~Pressione ~r~[F7] ~w~Para guardar o veículo",4,0.2,0.93,0.50,255,255,255,180)
                    if IsControlJustPressed(0,168) then
                        print(nveh)
                        DeleteVehicle(nveh)
                        vehicleSpawnado = false
                    end
                end
            end
            Citizen.Wait(tkz)
        end
    end)
end

---- [ DRAWTXT DE TEXTO ] -----

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end