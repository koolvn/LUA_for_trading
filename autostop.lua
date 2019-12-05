
PS=false -- Флаг наличия открытой позиции
function main()
OpenedPositions(...)
end
function OnStop()
end
function OpenedPositions() 					-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции
	for i=0, getNumberOf("FUTURES_CLIENT_HOLDING") do
		a=getItem("FUTURES_CLIENT_HOLDING",i).sec_code
		b=getItem("FUTURES_CLIENT_HOLDING",i).totalnet
		message (a.." = "..b)
	end
end