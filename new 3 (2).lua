function main()
   CreateTable()
end
function CreateTable()
   -- Получает доступный id для создания
   t_id = AllocTable()
   -- Добавляет 5 колонок
   AddColumn(t_id, 0, "Текущий P/L, %", true, QTABLE_INT_TYPE, 25)
   AddColumn(t_id, 1, "Текущий P/L, руб.", true, QTABLE_INT_TYPE, 25)
   SetCell(t_id,1,0)
   -- Создает таблицу
   t = CreateWindow(t_id)
   -- Устанавливает заголовок	
   SetWindowCaption(t_id, "RiskMan v.0.1")
   -- Добавляет строку
   InsertRow(t_id, -1)
end;