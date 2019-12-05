function main()
CLASS_CODE="SPBFUT"
SEC_CODE="BRH6"
CLIENT_CODE="SPBFUT00aya"
t_id=tostring(os.time())
Risk=true
UpLimitUsed=false 	--флаг достижени€ верхнего лимита
BotLimitUsed=false 	--флаг достижени€ нижнего лимита
run=true
while run==true do
	sleep(100)
	STOPTRADE()
end
end

function STOPTRADE()  --¬ыставл€ет максимально возможное кол-во за€вок на покупку и продажу по мин. возм. цене и по пакс. возм. цене

	maxAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMAX").param_value) 
	minAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMIN").param_value)
	
local	Tmax = {
	["CLASSCODE"]=CLASS_CODE,
    ["SECCODE"]=SEC_CODE,
	["ACTION"]="NEW_ORDER",
	["ACCOUNT"]=CLIENT_CODE,
	["CLIENT_CODE"]="RiskManMax",
	["TYPE"]="L",
	["OPERATION"]="S",
	["QUANTITY"]="1",
	["PRICE"]=tostring(maxAP),
	["EXPIRY_DATE"]="TODAY",
	["TRANS_ID"]=t_id,
	["COMMENT"]="Tmax"
	}
local	 Tmin = {
	["CLASSCODE"]=CLASS_CODE,
    ["SECCODE"]=SEC_CODE,
	["ACTION"]="NEW_ORDER",
	["ACCOUNT"]=CLIENT_CODE,
	["CLIENT_CODE"]="RiskManMin",
	["TYPE"]="L",
	["OPERATION"]="B",
	["QUANTITY"]="1",
	["PRICE"]=tostring(minAP),
	["EXPIRY_DATE"]="TODAY",
	["TRANS_ID"]=t_id,
	["COMMENT"]="Tmin"
	}
	if Risk==true and UpLimitUsed==false then
		sendTransaction(Tmax)
	end
	if Risk==true and BotLimitUsed==false then
		sendTransaction(Tmin)
	end
end

function OnTransReply(trans_reply) -- ѕри достижении лимита по выставленным за€вкам, включает флаг достижени€ лимита

	if trans_reply.status > 3 and trans_reply.brokerref=="RiskManMax" then
		UpLimitUsed=true
	end
	if trans_reply.status > 3 and trans_reply.brokerref=="RiskManMin" then
		BotLimitUsed=true
	end
	if UpLimitUsed==true and BotLimitUsed==true then
	Risk=false
	end
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\lololo.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OnStop()
run=false
local T = {
	["CLASSCODE"]=CLASS_CODE,
    ["SECCODE"]=SEC_CODE,
	["ACTION"]="KILL_ALL_FUTURES_ORDERS",
	["ACCOUNT"]=CLIENT_CODE,
	["CLIENT_CODE"]="RiskManMin",
	["TRANS_ID"]="666"
	}
	sendTransaction(T)
end