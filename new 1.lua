--/*НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ*/
R=2 								-- Максимальный риск на день в % от депозита
P=6									-- Целевая дневная прибыль в % от депозита
DC="155958" 						-- Время дневного клиринга
EC="204458" 						-- Время вечернего клиринга


function VA() 										--/*ПЕРЕМЕНЫЕ*/
ol = getItem("futures_client_limits",0).cbplimit 	-- Лимит открытия, т.е. сумма денег на начало дня
vm = getItem("futures_client_limits",0).varmargin 	-- Вариационная маржа
nd = getItem("futures_client_limits",0).accruedint 	-- Накопленный доход
pl = vm+nd 											-- Текущий профит/лосс
plp = math.ceil(pl/ol*10000)/100 					-- P/L в процентах
risk = ol*0.01*R 									-- Дневной риск
end

function main()
run=true
Risk=false 							-- Флаг достижения дневного риска
Profit=false 						-- Флаг достижения дневного профита
VA()
str = "Script started"
log(str)
str = "Риск на день: "..risk.." р.".." Текущий P/L: "..pl.." р. ("..plp.." %)"
message("Риск на день: "..risk.." р.".." Текущий P/L: "..pl.." р. ("..plp.." %)")
log(str)
	while run do
	VA()
	OnClearing()
		if (plp<=-R and Risk==false) then
			message ("ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!!\nP/L: " ..pl.." р.( "..plp.." %)",3)
			OnRisk()
		end
		
		if (plp>=P and Profit==false) then
			message ("Достигута дневная цель по прибыли! Поздравляю! Иди гуляй!\nP/L: "..pl.." р.( "..plp.." %)",2)
			OnProfit()
		end
	end
sleep(1000)
end


function OnRisk() 					-- При достижении дневного риска
str = "ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! P/L: " ..pl.." р.( "..plp.." %)"
log(str)
Risk=true
	if (os.date("%H%M%S")== DC or os.date("%H%M%S")== "210002") then
		Risk=false
	end
sleep(1000)
end

function OnProfit() 				-- При достижении дневного риска
str = "Достигута дневная цель по прибыли! P/L: "..pl.." р.( "..plp.." %)"
log(str)
Profit=true
	if (os.date("%H%M%S")== "160402" or os.date("%H%M%S")== "210002") then
		Profit=false
	end
sleep(1000)
end	

function OnDisconnected()			-- При отключении
str="Disconnected. P/L: "..pl.." р.( "..plp.." %)"
   log(str)
end

function OnConnected()				-- При подключении
sleep(15000)
str="Connected. P/L: "..pl.." р.( "..plp.." %)"
log(str)
message("Риск на день: "..risk.." р.".."\nТекущий P/L: "..pl.." р. ("..plp.." %)",2)
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\RiskManLog.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OpPo() 					-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции
BuyVol=0
SellVol=0
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do 
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then -- ЕСЛИ чистая позиция не равна нулю ТО
            if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then -- ЕСЛИ текущая чистая позиция > 0, ТО открыта длинная позиция (BUY)
			IsBuy = true;
			BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;	-- Количество лотов в позиции BUY				
      else   -- ИНАЧЕ открыта короткая позиция (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); -- Количество лотов в позиции SELL
      end;
   end;
end;
end

function OnClearing()				-- На клиринге
	if (os.date("%H%M%S")== DC or os.date("%H%M%S")== "EC") then
		message("Текущий P/L: "..pl.." р. ("..plp.." %)")
		str="Клиринговый P/L: "..pl.." р. ("..plp.." %)"
		log(str)
		sleep(1000)
	end
end

function OnStop()
str="Script stopped by user"
   log(str)
run = false
 end