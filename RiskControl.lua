--/*������������� ���������*/
R=2 											-- ������������ ���� �� ���� � % �� ��������
RW=R-0.2									-- �������������� � ������� � ������������� ����� �� ����
P=6												-- ������� ������� ������� � % �� ��������
DC="13:59:59" 						-- ����� �������� ��������
EC="18:44:59" 						-- ����� ��������� ��������
WPx=0 										-- ��������� ���� �� ��� �
WPy=0 										-- ��������� ���� �� ��� Y
Wh=100 									-- ������ ����
Ww=350 									-- ������ ����

ol = getItem("futures_client_limits",0).cbplimit 				-- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin 			-- ������������ �����
nd = getItem("futures_client_limits",0).accruedint 			-- ����������� �����
pl = vm+nd 																			-- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 										-- P/L � ���������
risk = ol*0.01*R 																	-- ������� ����

function VA() 										--/*���������*/
ol = getItem("futures_client_limits",0).cbplimit 				-- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin 			-- ������������ �����
nd = getItem("futures_client_limits",0).accruedint 			-- ����������� �����
pl = vm+nd 																			-- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 										-- P/L � ���������
risk = ol*0.01*R 																	-- ������� ����
end

function main()
run=true
Risk=false 								-- ���� ���������� �������� �����
Profit=false 							-- ���� ���������� �������� �������
RiskWarningFlag=false			-- ���� ���������� ��������������
CreateTable()
VA()
str = "Script started"
log(str)
str = "����� �������� "..ol.."�.".." ���� �� ����: "..risk.."�.".." ������� P/L: "..pl.."�. ("..plp.." %)"
message ("���� �� ����: "..risk.."�.".." ������� P/L: "..pl.."�. ("..plp.." %)")
log(str)
	while run do -- ����
	VA()
	OnClearing()
	sleep(1)
	SetCell(t_id, 1, 0, tostring(plp))
	SetCell(t_id, 1, 1, tostring(pl))
		if (plp<=-RW and RiskWarningFlag==false) then
			message ("��������!\nP/L: " ..pl.." �.( "..plp.." %)",3)
			RiskWarning()
		end
		
		if (plp<=-R and Risk==false) then
			message ("���������� �������� �����!!!\nP/L: " ..pl.." �.( "..plp.." %)",3)
			OnRisk()
		end

		if (plp>=P and Profit==false) then
			OnProfit()
		end
	CheckRP()
	if IsWindowClosed(t_id)==true then -- ��������� ������� ���� ������� ��� ���
		str="Script stopped by user"
		log(str)
		run=false
	end
	end
sleep(1)
end

function RiskWarning() 					-- ��� ���������� ������ ��������������
str = "��������!  P/L: " ..pl.." �.( "..plp.." %)"
log(str)
RiskWarningFlag=true
sleep(1000)
end

function OnRisk() 					-- ��� ���������� �������� �����
str = "���������� �������� �����!!! P/L: " ..pl.." �.( "..plp.." %)"
log(str)
Risk=true
sleep(1000)
end

function OnProfit() 				-- ��� ���������� �������� �����
OpPo()
	if BuyVol~=0 or SellVol~=0 then
			OP="���� �������� �������"
		else OP=" "
	end
str = "��������� ������� ���� �� �������! P/L: "..pl.." �.( "..plp.." %) "..OP..""
log(str)
Profit=true
message ("��������� ������� ���� �� �������! ����������! ������ 50% ������� � ��� �����!\nP/L: "..pl.." �.( "..plp.." %)",2)
sleep(1000)
end

function OnDisconnected()			-- ��� ����������
str="Disconnected. P/L: "..pl.." �.( "..plp.." %)"
   log(str)
end

function OnConnected()				-- ��� �����������
sleep(10)
str="Connected. P/L: "..pl.." �.( "..plp.." %)"
log(str)
message("���� �� ����: "..risk.." �.".."\n������� P/L: "..pl.." �. ("..plp.." %)",2)
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\RiskConLog.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OpPo() 																													-- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ �������
BuyVol=0
SellVol=0
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then 							-- ���� ������ ������� �� ����� ���� ��
            if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then 							-- ���� ������� ������ ������� > 0, �� ������� ������� ������� (BUY)
			IsBuy = true;
			BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;							-- ���������� ����� � ������� BUY
      else  																																	-- ����� ������� �������� ������� (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); 			-- ���������� ����� � ������� SELL
      end;
   end;
end;
end

function OnClearing()																														-- �� ��������
	if (getInfoParam("SERVERTIME")== DC or getInfoParam("SERVERTIME")== EC) then
			if Risk==false then RR=""
			else
			RR="���� �� ���� ��������"
			end
				if Profit==false then PP=""
				else
				PP="��� ������!\n�� ��� ������� ���� ������ �� �������!"
				end
		message("�������:\n������� P/L: "..pl.." �. ("..plp.." %)\n"..RR..PP.."")
		str="����������� P/L: "..pl.." �. ("..plp.." %)\n"..RR..PP..""
		log(str)
		sleep(1000)
		Risk=false
		Profit=false
	end
end

function CreateTable()																									-- ������ ���� �������
	t_id = AllocTable() 																									-- �������� ��������� id ��� ��������
		-- ��������� 2 ��������
		AddColumn(t_id, 0, "������� P/L, %", true, QTABLE_INT_TYPE, 25)
		AddColumn(t_id, 1, "������� P/L, ���.", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(t_id) 																							-- ������� �������
	SetWindowCaption(t_id, "RiskControl") 																	-- ��� �������� ����
	InsertRow(t_id, -1)																									-- ��������� ������
	SetWindowPos(t_id, WPx, WPy, Ww, Wh) 																-- ���������� ��������� ����
	sleep(1)
end

function CheckRP()															-- ��������� ����/�������
	if RiskWarningFlag==true and plp>-RW then
		message("�� �������, ����")
		str="�������, ����... P/L: "..pl.."("..plp.." %)"
		log(str)
		RiskWarningFlag=false
	end
	
	if Profit==true and plp<P then
		message("����������!\n������� ������� �������!")
		str="����� ������ ������� �������. P/L: "..pl.."("..plp.." %)"
		log(str)
		Profit=false
	end
end

function OnStop()
run = false
str="Script stopped by user"
log(str)
end

