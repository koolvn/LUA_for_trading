function main()
   CreateTable()
end
function CreateTable()
   -- �������� ��������� id ��� ��������
   t_id = AllocTable()
   -- ��������� 5 �������
   AddColumn(t_id, 0, "������� P/L, %", true, QTABLE_INT_TYPE, 25)
   AddColumn(t_id, 1, "������� P/L, ���.", true, QTABLE_INT_TYPE, 25)
   SetCell(t_id,1,0)
   -- ������� �������
   t = CreateWindow(t_id)
   -- ������������� ���������	
   SetWindowCaption(t_id, "RiskMan v.0.1")
   -- ��������� ������
   InsertRow(t_id, -1)
end;