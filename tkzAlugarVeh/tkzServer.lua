local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)
vCLIENT = Tunnel.getInterface(GetCurrentResourceName())

---- [ FUNÇÃO DE GERAR REQUEST DE PAGAMENTO  ] -----
function src.pagarTaxa()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local requestTaxa = vRP.request(source,"Você deseja alugar um veíuclo por <b>$"..vRP.format(2500).."</b> dólares ?",60)
        if requestTaxa then
            vRP.tryFullPayment(user_id,2500)
            TriggerClientEvent('Notify',source,"sucesso","Você alugou uma veíuclo")
            return true
        else
            TriggerClientEvent('Notify',source,"negado","Você não possui dinheiro")
            return false
        end
    end
end