--[[В терминале должно быть открыто окно "Таблицы" -> "Таблица всех сделок",
в котором должно быть настроено отображение нужных инструментов
(правой кнопкой мыши в окне -> "Редактировать таблицу")
]]
function main()
SEC_CODE="BRV6" -- Нужный инструмент
run=true
SELLVOL=1
BUYVOL=1
WPx=0 								-- Положение окна по оси Х
WPy=0 								-- Положение окна по оси Y
Wh=100 								-- Высота окна
Ww=300 								-- Ширина окна
CreateTable()
SetTableNotificationCallback(t_id, event_callback_message)
	while run do
		local TOTAL=BUYVOL+SELLVOL
		Bp=math.ceil(((BUYVOL*100)/TOTAL)*100)/100
		Sp=math.ceil(((SELLVOL*100)/TOTAL)*100)/100
		SetCell(t_id, 1, 0, tostring(Bp).." %")
		SetCell(t_id, 1, 1, tostring(Sp).." %")
		Green()
		Red()
		sleep(1)
		if IsWindowClosed(t_id)==true then -- Проверяет открыто окно скрипта или нет, если нет, то останавливает скрипт
			run=false
		end
	end
end

function OnStop()
run=false
end

function OnAllTrade(alltrade)
   -- Если сделка по инструменту, то
   if alltrade.sec_code == SEC_CODE then
      -- создает строку информации о сделке			
      local QTY = tostring(alltrade.qty)
	  local BS = tostring(alltrade.flags); -- "1" - ПРОДАЖА, "2" - КУПЛЯ

	  if BS=="1" then
		SELLVOL=SELLVOL+QTY
	  else
		BUYVOL=BUYVOL+QTY
	  end	
   end
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\balance.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function CreateTable()				-- Создаёт окно скрипта
	t_id = AllocTable() 													-- Получает доступный id для создания
		-- Добавляет 2 колоноки
		AddColumn(t_id, 0, "Покупки", true, QTABLE_INT_TYPE, 25)
		AddColumn(t_id, 1, "Продажи", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(t_id) 													-- Создает таблицу
	SetWindowCaption(t_id, "Баланс по ленте "..SEC_CODE) 					-- Даёт название окна
	InsertRow(t_id, -1)														-- Добавляет строку
	SetWindowPos(t_id, WPx, WPy, Ww, Wh) 									-- Выстваляет положение окна
	sleep(1)
end

function event_callback_message(t_id, msg, par1, par2) -- Сбрасывает счётчик, при нажатии на любое значение в таблице окна
	if msg == QTABLE_LBUTTONUP and par1 == 1 and par2 == 1 or par2 == 0 then
		SELLVOL=1
		BUYVOL=1
	end
end

function Red()
   		if Sp>=55 then
			SetColor(t_id, 1, 1, RGB(255,150,150), RGB(0,0,0), RGB(255,150,150), RGB(0,0,0))
		else
			SetColor(t_id, 1, 1, RGB(255,255,255), RGB(0,0,0), RGB(255,255,255), RGB(0,0,0))
		end
end

function Green()
	if Bp>=55 then
		SetColor(t_id, 1, 0, RGB(150,200,150), RGB(0,0,0), RGB(150,200,150), RGB(0,0,0))
	else
		SetColor(t_id, 1, 0, RGB(255,255,255), RGB(0,0,0), RGB(255,255,255), RGB(0,0,0))
	end
end