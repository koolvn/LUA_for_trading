--/*НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ*/
R=2 											-- Максимальный риск на день в % от депозита
RW=R-0.2									-- Предупреждение о подходе к максимальному риску на день
P=6												-- Целевая дневная прибыль в % от депозита
DC="13:59:59" 						-- Время дневного клиринга
EC="18:44:59" 						-- Время вечернего клиринга
WPx=0 										-- Положение окна по оси Х
WPy=0 										-- Положение окна по оси Y
Wh=100 									-- Высота окна
Ww=350 									-- Ширина окна

ol = getItem("futures_client_limits",0).cbplimit 				-- Лимит открытия, т.е. сумма денег на начало дня
vm = getItem("futures_client_limits",0).varmargin 			-- Вариационная маржа
nd = getItem("futures_client_limits",0).accruedint 			-- Накопленный доход
pl = vm+nd 																			-- Текущий профит/лосс
plp = math.ceil(pl/ol*10000)/100 										-- P/L в процентах
risk = ol*0.01*R 																	-- Дневной риск

function VA() 										--/*ПЕРЕМЕНЫЕ*/
ol = getItem("futures_client_limits",0).cbplimit 				-- Лимит открытия, т.е. сумма денег на начало дня
vm = getItem("futures_client_limits",0).varmargin 			-- Вариационная маржа
nd = getItem("futures_client_limits",0).accruedint 			-- Накопленный доход
pl = vm+nd 																			-- Текущий профит/лосс
plp = math.ceil(pl/ol*10000)/100 										-- P/L в процентах
risk = ol*0.01*R 																	-- Дневной риск
end

function main()
run=true
Risk=false 								-- Флаг достижения дневного риска
Profit=false 							-- Флаг достижения дневного профита
RiskWarningFlag=false			-- Флаг достижения предупреждения
CreateTable()
VA()
str = "Script started"
log(str)
str = "Лимит открытия "..ol.."р.".." Риск на день: "..risk.."р.".." Текущий P/L: "..pl.."р. ("..plp.." %)"
message ("Риск на день: "..risk.."р.".." Текущий P/L: "..pl.."р. ("..plp.." %)")
log(str)
	while run do -- Цикл
	VA()
	OnClearing()
	sleep(1)
	SetCell(t_id, 1, 0, tostring(plp))
	SetCell(t_id, 1, 1, tostring(pl))
		if (plp<=-RW and RiskWarningFlag==false) then
			message ("ВНИМАНИЕ!\nP/L: " ..pl.." р.( "..plp.." %)",3)
			RiskWarning()
		end
		
		if (plp<=-R and Risk==false) then
			message ("ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!!\nP/L: " ..pl.." р.( "..plp.." %)",3)
			OnRisk()
		end

		if (plp>=P and Profit==false) then
			OnProfit()
		end
	CheckRP()
	if IsWindowClosed(t_id)==true then -- Проверяет открыто окно скрипта или нет
		str="Script stopped by user"
		log(str)
		run=false
	end
	end
sleep(1)
end

function RiskWarning() 					-- При достижении уровня предупреждения
str = "Внимание!  P/L: " ..pl.." р.( "..plp.." %)"
log(str)
RiskWarningFlag=true
sleep(1000)
end

function OnRisk() 					-- При достижении дневного риска
str = "ПРЕВЫШЕНИЕ ДНЕВНОГО РИСКА!!! P/L: " ..pl.." р.( "..plp.." %)"
log(str)
Risk=true
sleep(1000)
end

function OnProfit() 				-- При достижении дневного риска
OpPo()
	if BuyVol~=0 or SellVol~=0 then
			OP="Есть открытые позиции"
		else OP=" "
	end
str = "Достигута дневная цель по прибыли! P/L: "..pl.." р.( "..plp.." %) "..OP..""
log(str)
Profit=true
message ("Достигута дневная цель по прибыли! Поздравляю! Выведи 50% прибыли и иди гуляй!\nP/L: "..pl.." р.( "..plp.." %)",2)
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
 file = io.open(getScriptPath().."\\RiskConLog.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OpPo() 																													-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции
BuyVol=0
SellVol=0
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then 							-- ЕСЛИ чистая позиция не равна нулю ТО
            if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then 							-- ЕСЛИ текущая чистая позиция > 0, ТО открыта длинная позиция (BUY)
			IsBuy = true;
			BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;							-- Количество лотов в позиции BUY
      else  																																	-- ИНАЧЕ открыта короткая позиция (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); 			-- Количество лотов в позиции SELL
      end;
   end;
end;
end

function OnClearing()																														-- На клиринге
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

function CreateTable()																									-- Создаёт окно скрипта
	t_id = AllocTable() 																									-- Получает доступный id для создания
		-- Добавляет 2 колоноки
		AddColumn(t_id, 0, "Текущий P/L, %", true, QTABLE_INT_TYPE, 25)
		AddColumn(t_id, 1, "Текущий P/L, руб.", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(t_id) 																							-- Создает таблицу
	SetWindowCaption(t_id, "RiskControl") 																	-- Даёт название окна
	InsertRow(t_id, -1)																									-- Добавляет строку
	SetWindowPos(t_id, WPx, WPy, Ww, Wh) 																-- Выстваляет положение окна
	sleep(1)
end

function CheckRP()															-- Проверяет Риск/Прибыль
	if RiskWarningFlag==true and plp>-RW then
		message("Ты отбился, йоба")
		str="Отбился, йоба... P/L: "..pl.."("..plp.." %)"
		log(str)
		RiskWarningFlag=false
	end
	
	if Profit==true and plp<P then
		message("ОСТАНОВИСЬ!\nСОХРАНИ остатки прибыли!")
		str="Начал терять целевую прибыль. P/L: "..pl.."("..plp.." %)"
		log(str)
		Profit=false
	end
end

function OnStop()
run = false
str="Script stopped by user"
log(str)
end

