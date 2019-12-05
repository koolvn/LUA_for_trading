function main()
run=true

while run do
for i=0,getNumberOf("stop_orders")-1 do
  stop_order = getItem("stop_orders", i)
	if CheckBit(stop_order.flags,0)==1 then
	str=stop_order.brokerref 
	log(str)
		if stop_order.brokerref =="RiskMan" then
			message("≈сть активный стоп")
			run=false			
		end
	end
end
sleep (10)
end


end

function OnStop()
run=false
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\TransREPLY.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function CheckBit(flags, bit)
   -- ѕровер€ет, что переданные аргументы €вл€ютс€ числами
   if type(flags) ~= "number" then error("ѕредупреждение!!! Checkbit: 1-й аргумент не число!"); end;
   if type(bit) ~= "number" then error("ѕредупреждение!!! Checkbit: 2-й аргумент не число!"); end;
   local RevBitsStr  = ""; -- ѕеревернутое (задом наперед) строковое представление двоичного представлени€ переданного дес€тичного числа (flags)
   local Fmod = 0; -- ќстаток от делени€
   local Go = true; -- ‘лаг работы цикла
   while Go do
      Fmod = math.fmod(flags, 2); -- ќстаток от делени€
      flags = math.floor(flags/2); -- ќставл€ет дл€ следующей итерации цикла только целую часть от делени€
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- ƒобавл€ет справа остаток от делени€
      if flags == 0 then Go = false; end; -- ≈сли был последний бит, завершает цикл
   end;
   -- ¬озвращает значение бита
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;