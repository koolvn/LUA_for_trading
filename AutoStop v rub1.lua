SEC_CODE="BRZ6" 								-- Код контракта
CLIENT_CODE="4100MSV" 							-- Счёт
risk = "2000" 														-- Риск на сделку в рублях
profit = "5000"														-- Профит на сделку в рублях

DCs="13:59:59" 						-- Время начала дневного клиринга
DCf="14:04:59"						-- Время окончания дневного клиринга
ECs="18:44:59" 						-- Время начала вечернего клиринга
ECf="18:59:59" 						-- Время окончания вечернего клиринга
StopPlaced = false
Clearing = false
CLASS_CODE="SPBFUT"
SEC_STEP_PRICE = getParamEx(CLASS_CODE, SEC_CODE, "STEPPRICE").param_value 			-- Получает стоимость шага цены
SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value		-- Получает шаг цены
QTY="0"
function main()
run=true
CreateTable()
	while run do
		if Clearing==false then 
			OpPo()
		end
		CheckStop()
		OnClearing()
			if IsWindowClosed(w_id)==true then -- Проверяет открыто окно скрипта или нет
				KillStop()
				run=false
			end
	sleep(10)
	end
end

function OnClearing()				-- На клиринге
	sleep(20)
end

function AutoTS()

local T = {
		["ACTION"]="NEW_STOP_ORDER";
		["STOP_ORDER_KIND"]="TAKE_PROFIT_AND_STOP_LIMIT_ORDER";
		["TRANS_ID"]=tostring(os.time());
		["CLASSCODE"]=CLASS_CODE;
		["SECCODE"]=SEC_CODE;
		["ACCOUNT"]=CLIENT_CODE;
		["CLIENT_CODE"]="RiskMan";
		["OPERATION"]=Operation;
		["QUANTITY"]=QTY;
		["STOPPRICE2"]=tostring(StopPrice);							-- Цена активации стоп заявки
		["PRICE"]=PriceOfStop;												-- Limit order price
		["STOPPRICE"]=tostring(TakePrice);								-- Цена активации тейк-профита
		["OFFSET"]=tostring(5*SEC_PRICE_STEP);		-- Отступ
		["OFFSET_UNITS"]="PRICE_UNITS"; 
		["SPREAD"]=tostring(10*SEC_PRICE_STEP);		-- Защитный спред
		["SPREAD_UNITS"]="PRICE_UNITS";
		["MARKET_TAKE_PROFIT"]="NO";
		["EXPIRY_DATE"]="TODAY";
		["MARKET_STOP_LIMIT"]="NO"
	}
	
	sendTransaction(T)
	
	sleep(500)
end

function OpPo() 	-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции
	for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do		
			if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then 														-- ЕСЛИ текущая чистая позиция > 0, ТО открыта длинная позиция (BUY)			
					local BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet											-- Количество лотов в позиции BUY				
					local SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code												-- Код фьючерсного контракта
					local PositionPrice = getItem("FUTURES_CLIENT_HOLDING",i).avrposnprice							-- Цена открытия позиции
						if SC==SEC_CODE and QTY~=tostring(BuyVol) and StopPlaced==false then					-- ЕСЛИ найдена заданная позиция и стоп НЕ выставлен, то выставляет стоп
							I=i -- Запоминает номер строки нужной позиции
							Operation="S"					
							QTY=tostring(BuyVol)
							StopPrice=math.ceil((PositionPrice-(risk/(SEC_STEP_PRICE*BuyVol))*SEC_PRICE_STEP)*100)/100		-- Цена активации стоп заявки
							TakePrice=math.ceil((PositionPrice+(profit/(SEC_STEP_PRICE*BuyVol))*SEC_PRICE_STEP)*100)/100	-- Цена активации тейк-профита
							local minAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMIN").param_value)
							PriceOfStop=tostring(minAP)
							SetCell(w_id, 1, 0, tostring(StopPrice))
							SetCell(w_id, 1, 1, tostring(TakePrice))
							local StopMoney=math.ceil((PositionPrice-StopPrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*BuyVol*100)/100
							SetCell(w_id, 2, 0, tostring(StopMoney))
							local TakeMoney=math.ceil((TakePrice-PositionPrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*BuyVol*100)/100
							SetCell(w_id, 2, 1, tostring(TakeMoney))
							AutoTS()						
						end
					if SC==SEC_CODE and QTY~=tostring(BuyVol) and StopPlaced==true then
						KillStop()				
					end						
			else   -- ИНАЧЕ открыта короткая позиция (SELL)
					local SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet) 						-- Количество лотов в позиции SELL
					local SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code											-- Код фьючерсного контракта
					local PositionPrice = getItem("FUTURES_CLIENT_HOLDING",i).avrposnprice  						-- Цена открытия позиции
						if SC==SEC_CODE and QTY~=tostring(SellVol) and StopPlaced==false then 				-- ЕСЛИ найдена заданная позиция и стоп НЕ выставлен, то выставляет стоп
							I=i -- Запоминает номер строки нужной позиции
							Operation="B"
							QTY=tostring(SellVol)
							StopPrice=math.ceil((PositionPrice+(risk/(SEC_STEP_PRICE*SellVol))*SEC_PRICE_STEP)*100)/100		-- Цена активации стоп заявки
							TakePrice=math.ceil((PositionPrice-(profit/(SEC_STEP_PRICE*SellVol))*SEC_PRICE_STEP)*100)/100	-- Цена активации тейк-профита
							local maxAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMAX").param_value)
							PriceOfStop=tostring(maxAP)
							SetCell(w_id, 1, 0, tostring(StopPrice))
							SetCell(w_id, 1, 1, tostring(TakePrice))
							local StopMoney=math.ceil((StopPrice-PositionPrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*SellVol*100)/100
							SetCell(w_id, 2, 0, tostring(StopMoney))
							local TakeMoney=math.ceil((PositionPrice-TakePrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*SellVol*100)/100
							SetCell(w_id, 2, 1, tostring(TakeMoney))
							AutoTS()
						end
					if SC==SEC_CODE and QTY~=tostring(SellVol) and StopPlaced==true then
						KillStop()
					end
			end
	end
	
sleep(500)
end

function KillStop()
local KO= {
				["TRANS_ID"]=tostring(os.time()),

                ["CLASSCODE"]=CLASS_CODE,

                ["SECCODE"]=SEC_CODE,

                ["ACTION"]="KILL_STOP_ORDER",                   

                ["STOP_ORDER_KEY"]=tostring(a_num)

            }
			
	sendTransaction(KO)
sleep(500)
StopPlaced=false
end

function OnStop()
	KillStop()
	run=false
end

function OnStopOrder(stop_order)
	 a_num=stop_order.order_num
	 StopPlaced=true
end

function CheckStop()
	if I~=nil and getItem("FUTURES_CLIENT_HOLDING",I).totalnet == 0 and StopPlaced==true then
		KillStop()
	end
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\TESTER.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function CreateTable()														-- Создаёт окно скрипта
	w_id = AllocTable() 														-- Получает доступный id для создания
	
		-- Добавляет 2 колоноки
		AddColumn(w_id, 0, "Stop Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 1, "Take Price", true, QTABLE_INT_TYPE, 25)
		
   	t = CreateWindow(w_id) 															-- Создает таблицу
	SetWindowCaption(w_id, SEC_CODE.." AutoStop v.0.1") 							-- Даёт название окна
	InsertRow(w_id, 1)																	-- Добавляет строку
	InsertRow(w_id, 2)
	SetWindowPos(w_id, 0, 0, 345, 75) 											-- Выстваляет положение окна
	SetCell(w_id, 1, 0, "N/A")
	SetCell(w_id, 1, 1, "N/A")
	sleep(1)
end

function CheckBit(flags, bit)
   -- Проверяет, что переданные аргументы являются числами
   if type(flags) ~= "number" then error("Предупреждение!!! Checkbit: 1-й аргумент не число!"); end;
   if type(bit) ~= "number" then error("Предупреждение!!! Checkbit: 2-й аргумент не число!"); end;
   local RevBitsStr  = ""; -- Перевернутое (задом наперед) строковое представление двоичного представления переданного десятичного числа (flags)
   local Fmod = 0; -- Остаток от деления
   local Go = true; -- Флаг работы цикла
   while Go do
      Fmod = math.fmod(flags, 2); -- Остаток от деления
      flags = math.floor(flags/2); -- Оставляет для следующей итерации цикла только целую часть от деления
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- Добавляет справа остаток от деления
      if flags == 0 then Go = false; end; -- Если был последний бит, завершает цикл
   end;
   -- Возвращает значение бита
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;