function main()
ol = getItem("futures_client_limits",0).cbplimit 			-- Лимит открытия, т.е. сумма денег на начало дня
GO = getParamEx("SPBFUT","BRH6","BUYDEPO").param_value 		-- ГО покупателя
katleta = math.floor(ol/GO)									-- Макс. кол-во лот на всю катлету
DC="160402" 												-- Время дневного клиринга
EC="210002" 												-- Время вечернего клиринга
MC="120002"													-- Время утреннего клиринга

message("На всю катлету можно купить  "..katleta.." лотов BRH6",1)
run=true

while run do
	OnClearing()
	sleep(1000)
end

end
function log(str) --LOG
		file = io.open(getScriptPath().."\\МаксГО.txt", "a")
		d = os.date("*t")
		file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
		file:close()
end

function OnClearing()
	if (os.date("%H%M%S")== DC or os.date("%H%M%S")== EC or os.date("%H%M%S")==MC) then
		message("На всю катлету можно купить  "..katleta.." лотов по BRH6",1)
		str="На всю катлету можно купить  "..katleta.." лотов по BRH6"
		log(str)
	end
end
	
function OnStop()
	run=false
end