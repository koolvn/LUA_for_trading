--/*НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ*/
R=2 								-- Максимальный риск на день в % от депозита
P=6 								-- Целевая дневная прибыль в % от депозита

function VA() 										--/*ПЕРЕМЕНЫЕ*/
ol = getItem("futures_client_limits",0).cbplimit 	-- Лимит открытия, т.е. сумма денег на начало дня
vm = getItem("futures_client_limits",0).varmargin 	-- Вариационная маржа
nd = getItem("futures_client_limits",0).accruedint 	-- Накопленный доход
pl = vm+nd 											-- Текущий профит/лосс
plp = math.ceil(pl/ol*10000)/100 					-- P/L в процентах
risk = ol*0.01*R 									-- Дневной риск
opc = getItem("futures_client_holding",0).totalnet 	-- Кол-во открытых позиции
fut = getItem("futures_client_holding",0).sec_code 	-- Код контракта

end

function main()
run=true
VA()
message("Риск на день: "..risk.." р.".." Текущий P/L: "..pl.." р. ("..plp.." %)",2)
str = "Script started"
log(str)
str = "Риск на день: "..risk.." р.".." Текущий P/L: "..pl.." р. ("..plp.." %)"
log(str)
	while run do
	VA()
			if plp<=-R then
			if opc ~= 0 then 
			message ("ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! Есть открытые позиции!",3)
			str = "ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! Есть открытые позиции! P/L: "..pl.."( "..plp.." %"
			log(str)
			else
			message ("ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! P/L: " ..pl.."( "..plp.." %",3)
			str = "ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! P/L: " ..pl.."( "..plp.." %"
			log(str)
			end
		run=false
		else
			if plp>=P then
				if opc ~= 0 then 
				message ("Достигута дневная цель по прибыли! Есть открытые позиции! P/L: "..pl.." р.( "..plp.." %)",2)
				str = "Достигута дневная цель по прибыли! Есть открытые позиции! P/L: "..pl.." р.( "..plp.." %)"
				log(str)
				else
				message ("Достигута дневная цель по прибыли! Поздравляю! Иди гуляй! P/L: "..pl.." р.( "..plp.." %)",1)
				str = "Достигута дневная цель по прибыли! Поздравляю! Иди гуляй! P/L: "..pl.." р.( "..plp.." %)"
				log(str)
				end
			run=false
			else
			end
		end
	sleep(1000)
		
	end
end

function OnDisconnected()
str="Disconnected. P/L: "..pl.." р.( "..plp.." %)"
   log(str)
end

function OnConnected()
str="Connected. P/L: "..pl.." р.( "..plp.." %)"
   log(str)
end

function log(str) --LOG
 file = io.open(getScriptPath().."\\RiskManLog.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OnStop()
str="Script stopped by user"
   log(str)
run = false
 end