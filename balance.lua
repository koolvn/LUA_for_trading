--[[� ��������� ������ ���� ������� ���� "�������" -> "������� ���� ������",
� ������� ������ ���� ��������� ����������� ������ ������������
(������ ������� ���� � ���� -> "������������� �������")
]]
function main()
SEC_CODE="BRV6" -- ������ ����������
run=true
SELLVOL=1
BUYVOL=1
WPx=0 								-- ��������� ���� �� ��� �
WPy=0 								-- ��������� ���� �� ��� Y
Wh=100 								-- ������ ����
Ww=300 								-- ������ ����
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
		if IsWindowClosed(t_id)==true then -- ��������� ������� ���� ������� ��� ���, ���� ���, �� ������������� ������
			run=false
		end
	end
end

function OnStop()
run=false
end

function OnAllTrade(alltrade)
   -- ���� ������ �� �����������, ��
   if alltrade.sec_code == SEC_CODE then
      -- ������� ������ ���������� � ������			
      local QTY = tostring(alltrade.qty)
	  local BS = tostring(alltrade.flags); -- "1" - �������, "2" - �����

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

function CreateTable()				-- ������ ���� �������
	t_id = AllocTable() 													-- �������� ��������� id ��� ��������
		-- ��������� 2 ��������
		AddColumn(t_id, 0, "�������", true, QTABLE_INT_TYPE, 25)
		AddColumn(t_id, 1, "�������", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(t_id) 													-- ������� �������
	SetWindowCaption(t_id, "������ �� ����� "..SEC_CODE) 					-- ��� �������� ����
	InsertRow(t_id, -1)														-- ��������� ������
	SetWindowPos(t_id, WPx, WPy, Ww, Wh) 									-- ���������� ��������� ����
	sleep(1)
end

function event_callback_message(t_id, msg, par1, par2) -- ���������� �������, ��� ������� �� ����� �������� � ������� ����
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