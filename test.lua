SEC_CODE="BRJ6"
lot=2
selfcost=0
mult=1
function main()
CreateTable()
SelfCost()
SetCell(w_id, 1, 2, tostring(selfcost))
end

function CreateTable()														-- ������ ���� �������
	w_id = AllocTable() 														-- �������� ��������� id ��� ��������
	
		-- ��������� ��������
		AddColumn(w_id, 0, "Stop Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 1, "Take Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 2, "�������������", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(w_id) 															-- ������� �������
	SetWindowCaption(w_id, SEC_CODE.." AutoStop v.0.1") 							-- ��� �������� ����
	InsertRow(w_id, 1)																	-- ��������� ������
	InsertRow(w_id, 2)
	SetWindowPos(w_id, 0, 0, 425, 90) 											-- ���������� ��������� ����
	SetCell(w_id, 1, 0, "N/A")
	SetCell(w_id, 1, 1, "N/A")
	SetCell(w_id, 1, 2, "N/A")
	sleep(1)
end


function CheckBit(flags, bit)
   -- ���������, ��� ���������� ��������� �������� �������
   if type(flags) ~= "number" then error("��������������!!! Checkbit: 1-� �������� �� �����!"); end;
   if type(bit) ~= "number" then error("��������������!!! Checkbit: 2-� �������� �� �����!"); end;
   local RevBitsStr  = ""; -- ������������ (����� �������) ��������� ������������� ��������� ������������� ����������� ����������� ����� (flags)
   local Fmod = 0; -- ������� �� �������
   local Go = true; -- ���� ������ �����
   while Go do
      Fmod = math.fmod(flags, 2); -- ������� �� �������
      flags = math.floor(flags/2); -- ��������� ��� ��������� �������� ����� ������ ����� ����� �� �������
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- ��������� ������ ������� �� �������
      if flags == 0 then Go = false; end; -- ���� ��� ��������� ���, ��������� ����
   end;
   -- ���������� �������� ����
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;

function SelfCost()
	for i = 0,getNumberOf("TRADES") - 1 do
		if getItem("TRADES", i).sec_code==SEC_CODE then
			razmer=getItem("TRADES",i).qty			
			if CheckBit(getItem("TRADES",i).flags, 2) == 1 then 
				lot=lot-razmer				
				mult=-1				
			else 
				lot=lot+razmer				
				mult=1
			end
			cost=getItem("TRADES",i).price*mult
			selfcost=(selfcost+cost)/lot
			str="SelfCost "..selfcost.." lot "..lot.." cost "..cost.." razmer "..razmer
				log(str)
		end
	end
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\TEST.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end