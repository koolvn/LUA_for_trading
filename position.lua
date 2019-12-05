function main()
run=true
trans_id = os.time()      							-- Текущие дата и время в секундах хорошо подходят для уникальных номеров транзакций
ACCOUNT = "SPBFUT00740" 							-- Код счета
CC = "SPBFUT"      									-- Код класса
SC = "BRH6"        									-- Код инструмента
LP=tonumber(getParamEx(CC, SC, "LAST").param_value) -- Цена последней сделки
OpPo()
end

function OpPo() 					-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции
BuyVol=0
SellVol=0
	for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do 
		if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then -- ЕСЛИ чистая позиция не равна нулю ТО
			if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then -- ЕСЛИ текущая чистая позиция > 0, ТО открыта длинная позиция (BUY)
				IsBuy = true;
				BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet	-- Количество лотов в позиции BUY				
				SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code		-- Код фьючерсного контракта
				message("Поза в "..SC.." Объёмом "..BuyVol.." лот")
			else   -- ИНАЧЕ открыта короткая позиция (SELL)
				IsSell = true;
				SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet) 	-- Количество лотов в позиции SELL
				SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code					-- Код фьючерсного контракта
				message("Поза в "..SC.." Объёмом "..SellVol.." лот")
			end
		end
	end
end

function Trade(Type)
   --Получает ID транзакции
   trans_id = trans_id + 1;
 -- Получает ШАГ ЦЕНЫ ИНСТРУМЕНТА
   SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value
   local Price = 0;
   local Operation = '';
   --Устанавливает цену и операцию, в зависимости от типа сделки и от класса инструмента
   if Type == 'BUY' then
      if CLASS_CODE ~= 'QJSIM' and CLASS_CODE ~= 'TQBR' then Price = getParamEx(CLASS_CODE, SEC_CODE, 'offer').param_value + 10*SEC_PRICE_STEP;end; -- по цене, завышенной на 10 мин. шагов цены
      Operation = 'B';
   else
      if CLASS_CODE ~= 'QJSIM' and CLASS_CODE ~= 'TQBR' then Price = getParamEx(CLASS_CODE, SEC_CODE, 'bid').param_value - 10*SEC_PRICE_STEP;end; -- по цене, заниженной на 10 мин. шагов цены
      Operation = 'S';
   end;
   -- Заполняет структуру для отправки транзакции
   local Transaction={
      ['TRANS_ID']   = tostring(trans_id),
      ['ACTION']     = 'NEW_ORDER',
      ['CLASSCODE']  = CLASS_CODE,
      ['SECCODE']    = SEC_CODE,
      ['OPERATION']  = Operation, -- операция ("B" - buy, или "S" - sell)
      ['TYPE']       = 'M', -- по рынку (MARKET)
      ['QUANTITY']   = '1', -- количество
      ['ACCOUNT']    = ACCOUNT,
      ['PRICE']      = tostring(Price),
      ['COMMENT']    = 'Простой MA-робот'
   }
   -- Отправляет транзакцию
   sendTransaction(Transaction);
   end
   