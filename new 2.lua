-- Пытается открыть файл в режиме "чтения/записи"
   f = io.open(getScriptPath().."\\Result.txt","r+");
   -- Если файл не существует
   if f == nil then 
      -- Создает файл в режиме "записи"
      f = io.open(getScriptPath().."\\Result.txt","w"); 
      -- Закрывает файл
      f:close();
      -- Открывает уже существующий файл в режиме "чтения/записи"
      f = io.open(getScriptPath().."\\Result.txt","r+");
   end;
   -- Записывает в файл 2 строки
   f:write("!"); -- "\n" признак конца строки
   -- Сохраняет изменения в файле
   
   function log( str ) --LOG
 local file = io.open(getScriptPath().."\\log.txt", "a")
 local d = os.date("*t")
 file:write( os.date('%Y-%m-%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function restart() --Рестарт скрипта
	run=false
	sleep(1000)
	run=true
	str="Script restarted"
	log (str)
	sleep(1000)
end
end

function OpPo() -- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
   -- ЕСЛИ строка по нужному инструменту И чистая позиция не равна нулю ТО
   if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then
      -- ЕСЛИ текущая чистая позиция > 0, ТО открыта длинная позиция (BUY)
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then 
         IsBuy = true;
         BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;	-- Количество лотов в позиции BUY				
      else   -- ИНАЧЕ открыта короткая позиция (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); -- Количество лотов в позиции SELL
      end;
   end;
end;