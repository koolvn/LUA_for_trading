-- SuperScalp.lua, © hismatullin.h@gmail.com, xsharp.ru
-- с возможностями полного протоколирования действий программы.
local ver = '1.4'	--	06.03.2016
local lastPos = 0
local lastPrice = 0
local string_gmatch=string.gmatch
local string_find=string.find
local string_sub=string.sub
local string_len=string.len
local string_format=string.format
local math_modf=math.modf
local SeaGreen=12713921		--	RGB(193, 255, 193)
local RosyBrown=12698111	--	RGB(255, 193, 193)
local logFile
local trades = {} -- Таблица_01 - получили сделку
local _trades = {} -- временная таблица наших сделок для отлова дублей в QUIK ver. 7.1.0
local orders = {}	--	Таблица заявок
local scriptPath = getScriptPath()
local Terminal_Version=getInfoParam('VERSION')
local function versionLess(ver1,ver2)
	local begin,ver_1=0
	for ver_2 in string_gmatch(ver2,'%d+') do
		_,begin,ver_1=string_find(ver1,'(%d+)',begin+1)
		if ver_1~=ver_2 then return not ver_1 or ver_1+0<ver_2+0 end
	end
	return false
end
local  v = '6.17'
local table_insert
local table_remove
local table_concat
if versionLess(Terminal_Version,v ) then
	table_insert=table.insert
	table_remove=table.remove
	table_concat=table.concat
else	
	table_insert=table.sinsert
	table_remove=table.sremove
	table_concat=table.sconcat
end
-----

local dc = QTABLE_DEFAULT_COLOR

local testQuik = true -- подписка на OnTransReply, OnTrade, OnOrder
--local testQuik = false -- без подписки

function firm_id()
  for i = 0, getNumberOf("money_limits") - 1 do
    local row = getItem("money_limits", i)
    if row ~= nil and row.firmid ~= nil then
      local ss = tostring(string_sub(row.firmid, 2, 2))
      if ss == "C" or ss == "R" or ss == "B" then
        return tostring(row.firmid)
      end
    end
  end
  return nil
end

local is_forts = true
--настройки
function getInitParameter()
	if is_forts then
		account = 'SPBFUT00b69'
		classCode = 'SPBFUT'
		secCode = 'SRH6'
		OpenSlippage = 50
	else
		account="NL0011100043"
		ClientCode = "99914"
		classCode = 'QJSIM'
		secCode = 'SBER'
		OpenSlippage = 0.5
		firm_id = firm_id()
		message('firm_id = '..firm_id)
	end
	workSize = 5	-- рабочий размер
	logFileName1 = 'logFile1.txt'	-- файл для укороченного протоколирования коллбэков
	logFileName2 = 'logFile2.txt'	-- файл для печати всех полей коллбэков
end
--

function isModule(modname)
	if not package.loaded[modname] then	-- Если модуль modname не загружен ранее
		for i, v in ipairs(package.loaders) do
			local loader = v(modname)
			if type(loader) == 'function' then
				package.preload[modname] = loader
				return true
			end
		end
	end
end
--
local modname = "socket.socket"
local isSocket
local _mes
if isModule(modname) then
	isSocket = require(modname)
else	
	_mes = modname..' отсутствует!'; message(_mes,3)
end


function getHRTime()
	-- возвращает время с милисекундами или без них, в зависимости от наличия socket.socket
	if isSocket then 
		local now = socket.gettime() 
		return string_format("%s,%03d",os.date("%X",now),select(2,math_modf(now))*1000)
	else 
		return os.date("%X", os.time()) 
	end
end
--

function event_callback_tblH(t_id, msg, par1, par2)
	if msg == QTABLE_LBUTTONDOWN then	-- нажата левая кнопка мыши
		local mes = ''
		lastPos = futures_position()
		local status = tonumber(getParamEx(classCode, secCode,"status").param_value)
		if status ~= 1 or par1 == 1 then -- если бумага не торгуется, заявку не подаем
			Highlight(t_id, par1, par2, RosyBrown, dc, 500)		-- подсветка, RosyBrown
			if status ~= 1 then
				mes = 'Ошибка: клиринг!'
				message(mes); io_log(mes);
			end
			return
		end
		Highlight(t_id, par1, par2, SeaGreen, dc, 500)		-- подсветка SeaGreen
		if par1 == 2 and par2 == 1 then
			if lastPos < 0 then
				mes = secCode..'; нажато: купить, '..-lastPos
				Buy(classCode, secCode, -lastPos, 'CloseShort')
			elseif 	lastPos == 0 then
				mes = secCode..'; нажато: купить, '..workSize
				Buy(classCode, secCode, workSize, 'OpenLong')
			else
				mes = secCode..'; нажато: купить. Мы в лонгах, не покупаем!'
			end
		elseif par1 == 2 and par2 == 2 then	-- продать, левая кнопка
			if lastPos > 0 then
				mes = secCode..'; нажато: продать, '..lastPos
				Sell(classCode, secCode, lastPos, 'CloseLong')
			elseif 	lastPos == 0 then
				mes = secCode..'; нажато: продать, '..workSize
				Sell(classCode, secCode, workSize, 'OpenShort')
			else
				mes = secCode..'; нажато: продать. Мы в шортах, не продаем!'
			end
		elseif par1 == 2 and par2 == 3 then	-- закрыть позиции
			if lastPos > 0 then
				mes = secCode..'; нажато: закрыть лонги, '..lastPos
				Sell(classCode, secCode, lastPos, 'CloseAll')
			elseif 	lastPos < 0 then
				mes = secCode..'; нажато: закрыть шорты, '..-lastPos
				Buy(classCode, secCode, -lastPos, 'CloseAll')
			else
				mes = secCode..'; нажато: закрыть. Нет позиций для закрытия!'
			end
		elseif par1 == 3 and par2 == 1 then
			if lastPos < 0 then
				mes = secCode..'; нажато: купить-, '..-lastPos
				BuyBid(classCode, secCode, -lastPos, 'CloseShort')
			elseif 	lastPos == 0 then
				BuyBid(classCode, secCode, workSize, 'OpenLong')
				mes = secCode..'; нажато: купить-, '..workSize
			else
				mes = secCode..'; нажато: купить-. Мы в лонгах, не покупаем!'
			end
		elseif par1 == 3 and par2 == 2 then
			if lastPos > 0 then
				SellOffer(classCode, secCode, lastPos, 'CloseLong')
				mes = secCode..'; нажато: продать+, '..lastPos
			elseif 	lastPos == 0 then
				SellOffer(classCode, secCode, workSize, 'OpenShort')
				mes = secCode..'; нажато: продать+, '..workSize
			else
				mes = secCode..'; нажато: продать+. Мы в шортах, не продаем!'
			end
		elseif par1 == 3 and par2 == 3 then
			mes = secCode..'; нажато: Снять все заявки!'
			KillOrders()
		end
		message(mes); io_log(mes);
	elseif msg == QTABLE_CLOSE then
		OnStop()
	end	
end
--

QTable ={}
QTable.__index = QTable
-- Создать и инициализировать экземпляр таблицы QTable
function QTable.new()
	local t_id = AllocTable()
	if t_id ~= nil then
		q_table = {}
		setmetatable(q_table, QTable)
		q_table.t_id=t_id
		q_table.caption = ""
		q_table.created = false
		q_table.curr_col=0
		-- таблица с описанием параметров столбцов
		q_table.columns={}
		return q_table
	else
		return nil
	end
end
tblH = QTable:new() -- для ручной торговли
--

function get_trans_id()
	local s = tostring(os.clock())
	local x, g = string_find(s, "(%d+)")
	s = string_sub(s, g + 2)
	for i = 1, 3 - string_len(s) do
		s = "0" .. s
	end
	return os.date("%H%M%S") .. s
end
--

function send_order(client, class, seccode, account, operation, quantity, price)
	local trans_id = get_trans_id()
	local trans_params = {
		CLASSCODE = class,
		CLIENT_CODE = client,
		SECCODE = seccode,
		ACCOUNT = account,
		TYPE = new_type,
		TRANS_ID = trans_id,
		OPERATION = operation,
		QUANTITY = tostring(quantity),
		PRICE = tostring(price),
		ACTION = "NEW_ORDER"
		}
	return sendTransaction(trans_params)
end
--

function Buy(classCode, secCode, size, action)
	local best_offer = getParamEx(classCode, secCode, "offer").param_value
	local buyPrice = best_offer + (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "B", size, buyPrice)
	if string_len(res) ~= 0 then
		local mes = 'Ошибка: '..res..', '.. action..', '..secCode..', '.."B"..', '..size..', price='..buyPrice
		message(mes,3); io_log(mes);
	end
end
--

function Sell(classCode, secCode, size, action)
	local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local sellPrice = best_bid - (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "S", size, sellPrice)
	if string_len(res) ~= 0 then
		local mes = 'Ошибка: '..res..', '.. action..', '..secCode..', '.."S"..', '..size..', price='..sellPrice
		message(mes,3); io_log(mes);
	end
end
--

function BuyBid(classCode, secCode, size, action)
	local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local buyPrice = best_bid - (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "B", size, buyPrice)
	if string_len(res) ~= 0 then
		local mes = 'Ошибка: '..res..', '.. action..', '..secCode..', '.."B"..', '..size..', price='..buyPrice
		message(mes,3); io_log(mes);
	end
end
--

function SellOffer(classCode, secCode, size, action)
	local best_offer = getParamEx(classCode, secCode, "offer").param_value
	local sellPrice = best_offer + (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "S", size, sellPrice)
	if string_len(res) ~= 0 then
		local mes = 'Ошибка: '..res..', '.. action..', '..secCode..', '.."S"..', '..size..', price='..sellPrice
		message(mes,3); io_log(mes);
	end
end
--

function KillOrders()
	local NumberOf = getNumberOf("orders")
	for i = 0, NumberOf - 1 do
		local ord = getItem("orders", i)
		if ord.sec_code == secCode and ord.account == account  then
			local order_flag = get_order_status(ord.flags)
			if order_flag.status == "active" then
				trans_id = get_trans_id()
				local trans_params = {
						["CLASSCODE"] = classCode,
						["TRANS_ID"] = trans_id,
						["ACTION"] = "KILL_ORDER",
						["ORDER_KEY"] = tostring(ord.order_num)
						}
				local res =  sendTransaction(trans_params)
				if 0 < string_len(res) then
					local mes = 'Ошибка: '..res
					message(mes,3); io_log(mes);
				end
			end
		end
	end
end
--

function HandleBS()
	local t = tblH.t_id
	AddColumn(t, 1, 'Бумага', true,QTABLE_CACHED_STRING_TYPE,12)
	AddColumn(t, 2, 'ТЧП', true,QTABLE_STRING_TYPE,12)
	AddColumn(t, 3, 'Цена послед.', true,QTABLE_STRING_TYPE,17)
	CreateWindow(t)
	SetWindowCaption(t, "SuperScalp "..ver)	--SetWindowCaption(t, "Scalper:"..account)
	SetWindowPos(t, 0, 100, 250, 120)
	local li=InsertRow(t, -1)
	SetCell(t, li, 1, secCode)
	SetCell(t, li, 2, lastPos)
	SetCell(t, li, 3, '7503')	--Ожидание
	local li=InsertRow(t, -1)
	SetCell(t, li, 1, 'Купить')
	SetCell(t, li, 2, 'Продать')
	SetCell(t, li, 3, 'Закрыть')
	local li=InsertRow(t, -1)
	SetCell(t, li, 1, 'купить —')
	SetCell(t, li, 2, 'продать +')
	SetCell(t, li, 3, 'Снять все')
	SetTableNotificationCallback(t,event_callback_tblH)
end
--

--прочитать ТТП и вытащить ТЧП.
function futures_position()
	if is_forts then
		local count=getNumberOf("futures_client_holding") --Позиции по клиентским счетам (фьючерсы)
		for i=0,count-1, 1 do
			local row=getItem("futures_client_holding",i)
			if row.trdaccid~=nil then
				local seccode=row.sec_code		--Код фьючерсного контракта, "Инструмент"
				local totn=row.totalnet			--Текущие чистые позиции	"ТЧП"
				if seccode == secCode then
					return totn
				end
			end
		end
	else
		local t = getDepoEx(firm_id, ClientCode, secCode, account, 0)
		if t then
			local T = t.currentbal
			SetCell(tblH.t_id, 1, 2, tostring(T))
			positionColor(T)
			return T
		end
	end
	return 0
end
--

function positionColor(tot)
	if tot>0 then
		SetColor(tblH.t_id,1,2, SeaGreen, dc, dc, dc)	-- подсветка SeaGreen
	elseif tot<0 then
		SetColor(tblH.t_id,1,2, RosyBrown, dc, dc, dc)	-- подсветка, RosyBrown
	else	
		SetColor(tblH.t_id,1,2,dc, dc, dc, dc)
	end 
end
--

function get_order_status(flags)
  local rt = {}
  local band = bit.band
  local tobit = bit.tobit
  if band(tobit(flags), 1) ~= 0 and band(tobit(flags), 2) == 0 then
    rt.status = "active"
  elseif band(tobit(flags), 1) == 0 and band(tobit(flags), 2) ~= 0 then
    rt.status = "cancelled"
  elseif band(tobit(flags), 1) == 0 and band(tobit(flags), 2) == 0 then
    rt.status = "filled"
  else
    rt.status = "unknown"
  end
  if band(tobit(flags), 4) ~= 0 then
    rt.operation = "S"
  else
    rt.operation = "B"
  end
  return rt
end
--

--запись лога с текущим простым временем
function io_log(str)
	local file, err = io.open(logFile, "a")
	assert(file, "Ошибка записи "..logFile..", \n"..str)
	local str0 = getHRTime()	-- время с миллисекундами
	str0 = str0..'; '.. str
	file:write(str0 .. "\n")
	file:flush()
	file:close()
	return true
end
--

if testQuik then
	-- 2.2.17 - Функция вызывается терминалом QUIK при получении ответа на транзакцию пользователя.
	function OnTransReply(reply)
		if reply.account == account then
			if running then
				local mes =  reply.sec_code..'; OnTrans, o_n '..reply.order_num..', '..tostring(reply.price)..' x '..
				tostring(reply.quantity)..', t_id = '..reply.trans_id
				message(mes); io_log(mes);
			end
			toLog(scriptPath..'\\'..logFileName2,reply, 'reply')
		end
	end
	-- 2.2.3 Функция вызывается терминалом QUIK при получении сделки.
	function OnTrade(trade)
		if trade.account == account then	-- только если заявка из нашего счета - 01.11.2014
			if running then
				if not _trades[trade.trade_num] then
					local mes = trade.sec_code..'; OnTrade, 1, o_n = '..trade.order_num..', t_n = '..trade.trade_num..' ('..trade.price..'x'..trade.qty..')'
					message(mes); io_log(mes);
					_trades[trade.trade_num] = true  -- Добавим в очередь
					_trades[trade.tradenum] = 1
					table_insert(trades,trade)
				else	
					_trades[trade.tradenum] = _trades[trade.tradenum] + 1
					local mes = trade.sec_code..'; OnTrade, '.._trades[trade.tradenum]..', o_n = '..trade.order_num..', t_n = '..trade.trade_num..' ('..trade.price..'x'..trade.qty..')'
					message(mes); io_log(mes);
				end
				toLog(scriptPath..'\\'..logFileName2,trade, 'trade')
			end
		end
	end
	--2.2.4	OnOrder	Функция вызывается терминалом QUIK при получении новой заявки или при изменении параметров существующей заявки.
	function OnOrder(order)
		if order.account == account then
			local order_flag = get_order_status(order.flags)
			local op = order_flag.operation
			local mes = order.sec_code..'; OnOrder, '..op.. ', o_n = '..order.order_num..' ('..order.price..'x'..order.qty.."), t_id = "..order.trans_id..', flag = '..order.flags..", "..order.brokerref..", balance = "..order.balance..', '..order_flag.status
			io_log(mes)
			toLog(scriptPath..'\\'..logFileName2,order, 'order')
		end	
	end
end
--

function toLog(file_path,value,txt)
	-- запись в файл параметра value
	-- value может быть числом, строкой или таблицей
	-- file_path  -  путь к файлу
	-- файл открывается на дозапись и закрывается после записи строки
	local now = getHRTime()	-- c мс
	if file_path~=nil and value~=nil then
		local lf, err = io.open(file_path, "a")
		assert(lf, "Ошибка записи "..file_path..", \n")
		if lf~=nil then
			lf:write(txt.."\n")
			if type(value)=="string" or type(value)=="number" then
				lf:write(now.." "..value.."\n")
			elseif type(value)=='boolean' then
				lf:write(now.." "..tostring(value).."\n")
			elseif type(value)=="table" then
				lf:write(now.."\n"..table2string(value).."\n")
			end
			lf:flush()
			if io.type(lf)=="file" then	lf:close() end
		end
	end
end
--

function table2string(table)
	local k,v,str=0,0,""
	for k,v in pairs(table) do
		if type(v)=="string" or type(v)=="number" then
			str=str..k.."="..v..';\n'	--  в 1
			--str=str..k.."="..v..'; '	--  в 2
		elseif type(v)=="table"then
			str=str..k.."={\n"..table2string(v).."};\n"
		elseif type(v)=="function" or type(v)=='boolean' then
			str=str..k..'='..tostring(v)..';\n'
		end
	end
	return str
end
--

-- 2.2.8	OnFuturesClientHolding
-- Функция вызывается терминалом QUIK при изменении позиции по срочному рынку.
function OnFuturesClientHolding(tab)
	local sec_code = tab.sec_code
	local totalnet = tab.totalnet
	if running and sec_code == secCode then -- выбираем нужную нам бумагу
		local t= tonumber(totalnet)
		if t ~= nil then
			SetCell(tblH.t_id, 1, 2, tostring(totalnet), totalnet)
			positionColor(t)
		end
	end
end
--
-- 2.2.5  Функция вызывается терминалом QUIK при получении изменений текущей позиции по счету.
-- (ТОЛЬКО ДЛЯ БРОКЕРА).
function OnAccountBalance(acc_bal)
	if acc_bal.sec_code==secCode then
		local t= acc_bal.currentpos
		if t ~= nil then
			SetCell(tblH.t_id, 1, 2, tostring(t))
			positionColor(t)
		end
	end
end

--	2.2.18	OnParam
--	Функция вызывается терминалом QUIK при изменении текущих параметров.
function OnParam(class, seccode)
	if seccode == secCode then -- выбираем нужную нам бумагу
		local lp = tonumber(getParamEx(class, seccode, "last").param_value)
		if lp > lastPrice then
			Highlight(tblH.t_id, 1, 3, SeaGreen, dc, 1000)		-- подсветка мягкий, зеленый
			lastPrice = lp	-- цена последней сделки
			SetCell(tblH.t_id, 1, 3, tostring(lastPrice))
		elseif lp < lastPrice then
			Highlight(tblH.t_id, 1, 3, RosyBrown, dc, 1000)		-- подсветка
			lastPrice = lp
			SetCell(tblH.t_id, 1, 3, tostring(lastPrice))
		end
	end	
end
--

-- 2.2.24 OnStop
-- Функция вызывается терминалом QUIK при остановке скрипта из диалога управления и при
-- закрытии терминала QUIK.
function OnStop()
	local mes = 'Stop SuperScalp.'
	message(mes); io_log(mes);
	running = false
	DestroyTable(tblH.t_id)
end
--

-- 2.2.25 OnInit
-- Функция вызывается терминалом QUIK перед вызовом функции main().
function OnInit()
	getInitParameter()
	logFile = scriptPath..'\\'..logFileName1
	local mes = 'Start SuperScalp '..ver..', QUIK '..Terminal_Version
	message(mes); io_log(mes);
	running = true
	HandleBS()
	lastPos = futures_position()
	SetCell(tblH.t_id, 1, 2, tostring(lastPos))
	positionColor(lastPos)
end
--

-- 2.2.26 main
-- Функция, реализующая основной поток выполнения в скрипте.
function main()
	while running do
		sleep(1000)
		if not is_forts then
			local t = getDepoEx(firm_id, ClientCode, secCode, account, 0)
			local T = t.currentbal
			SetCell(tblH.t_id, 1, 2, tostring(T))
			positionColor(T)
		end
		
	end
end