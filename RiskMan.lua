--/*НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ*/
R=0.5 								-- Максимальный риск на день в % от депозита
P=6									-- Целевая дневная прибыль в % от депозита
DC="13:59:59" 						-- Время дневного клиринга
EC="18:44:59" 						-- Время вечернего клиринга
WPx=0 								-- Положение окна по оси Х
WPy=0 								-- Положение окна по оси Y
Wh=100 								-- Высота окна
Ww=300 								-- Ширина окна

ol = getItem("futures_client_limits",0).cbplimit 	-- Лимит открытия, т.е. сумма денег на начало дня
vm = getItem("futures_client_limits",0).varmargin 	-- Вариационная маржа
nd = getItem("futures_client_limits",0).accruedint 	-- Накопленный доход
pl = vm+nd 											-- Текущий профит/лосс
plp = math.ceil(pl/ol*10000)/100 					-- P/L в процентах
risk = ol*0.01*R 									-- Дневной риск

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
CreateTable()
VA()
str = "Script started"
log(str)
str = "Риск на день: "..risk.." р.".." Текущий P/L: "..pl.." р. ("..plp.." %)"
message ("Риск на день: "..risk.." р.".." Текущий P/L: "..pl.." р. ("..plp.." %)")
log(str)
	while run do -- Цикл
	VA()
	OnClearing()
	sleep(1)
	SetCell(t_id, 1, 0, tostring(plp))
	SetCell(t_id, 1, 1, tostring(pl))
		if (plp<=-R and Risk==false) then
			message ("ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!!\nP/L: " ..pl.." р.( "..plp.." %)",3)
			OnRisk()
		end
		
		if (plp>=P and Profit==false) then
			message ("Достигута дневная цель по прибыли! Поздравляю! Иди гуляй!\nP/L: "..pl.." р.( "..plp.." %)",2)
			OnProfit()
		end
	CheckRP()
	if IsWindowClosed(t_id)==true then -- Проверяет открыто окно скрипта или нет
		run=false
	end
	end
sleep(1)
end


function OnRisk() 					-- При достижении дневного риска
str = "ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! P/L: " ..pl.." р.( "..plp.." %)"
log(str)
Risk=true
sleep(1000)
end

function OnProfit() 				-- При достижении дневного риска
str = "Достигута дневная цель по прибыли! P/L: "..pl.." р.( "..plp.." %)"
log(str)
Profit=true
sleep(1000)
end	

function OnDisconnected()			-- При отключении
str="Disconnected. P/L: "..pl.." р.( "..plp.." %)"
   log(str)
end

function OnConnected()				-- При подключении
sleep(10)
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
	if (getInfoParam("SERVERTIME")== DC or getInfoParam("SERVERTIME")== EC) then
			if Risk==false then RR=""
			else
			RR="Риск на день исчерпан"
			end
				if Profit==false then PP=""
				else
				PP="ИДИ ГУЛЯТЬ!\nТЫ УЖЕ ПОЛУЧИЛ СВОЙ ПРОФИТ НА СЕГОДНЯ!"
				end
		message("Клиринг:\nТекущий P/L: "..pl.." р. ("..plp.." %)\n"..RR..PP.."")
		str="Клиринговый P/L: "..pl.." р. ("..plp.." %)\n"..RR..PP..""
		log(str)
		sleep(1000)
		Risk=false
		Profit=false
	end
end

function CreateTable()														-- Создаёт окно скрипта
	w_id = AllocTable() 														-- Получает доступный id для создания
	
		-- Добавляет колоноки
		AddColumn(w_id, 0, "Stop Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 1, "Take Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 2, "Себестоимость", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(w_id) 															-- Создает таблицу
	SetWindowCaption(w_id, SEC_CODE.." RiskMan v.0.2") 							-- Даёт название окна
	InsertRow(w_id, 1)																	-- Добавляет строку
	InsertRow(w_id, 2)
	SetWindowPos(w_id, 0, 0, 425, 90) 											-- Выстваляет положение окна
	SetCell(w_id, 1, 0, "N/A")
	SetCell(w_id, 1, 1, "N/A")
	SetCell(w_id, 1, 2, "N/A")
	sleep(1)
end

function CheckRP()
	if Risk==true and plp>-R then
		message("Поздравляю, ты отбился, йоба")
		str="Поздравляю, ты отбылся, йоба... P/L: "..pl.."("..plp.." %)"
		log(str)
		Risk=false
	end
	
	if Profit==true and plp<P then
		message("Ну и нафига? Мало заработал?\nОстатки прибыли сохрани, утырок!")
		str="Начал терять целевую прибыль. P/L: "..pl.."("..plp.." %)"
		log(str)
		Profit=false
	end
end

function OnStop()
str="Script stopped by user"
log(str)
run = false
end
 
 function SelfCost()
	for i = 0,getNumberOf("TRADES") - 1 do
		if getItem("TRADES", i).sec_code==SEC_CODE then
			razmer=getItem("TRADES",i).qty			--запоминает размер позиции
			if CheckBit(getItem("TRADES",i).flags, 2) == 1 then --узнаёт направление открытой позиции
				lot=lot-razmer				
				mult=-1				
			else 
				lot=lot+razmer				
				mult=1
			end
			cost=getItem("TRADES",i).price*mult
			selfcost=(selfcost+cost)/lot
			str="SelfCost "..selfcost.." lot "..lot.." cost "..cost.." razmer "..razmer
				log(str)
		end
	end
end