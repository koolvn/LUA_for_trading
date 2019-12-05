function main()
message()
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