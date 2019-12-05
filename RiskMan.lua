--/*������������� ���������*/
R=0.5 								-- ������������ ���� �� ���� � % �� ��������
P=6									-- ������� ������� ������� � % �� ��������
DC="13:59:59" 						-- ����� �������� ��������
EC="18:44:59" 						-- ����� ��������� ��������
WPx=0 								-- ��������� ���� �� ��� �
WPy=0 								-- ��������� ���� �� ��� Y
Wh=100 								-- ������ ����
Ww=300 								-- ������ ����

ol = getItem("futures_client_limits",0).cbplimit 	-- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin 	-- ������������ �����
nd = getItem("futures_client_limits",0).accruedint 	-- ����������� �����
pl = vm+nd 											-- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 					-- P/L � ���������
risk = ol*0.01*R 									-- ������� ����

function VA() 										--/*���������*/
ol = getItem("futures_client_limits",0).cbplimit 	-- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin 	-- ������������ �����
nd = getItem("futures_client_limits",0).accruedint 	-- ����������� �����
pl = vm+nd 											-- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 					-- P/L � ���������
risk = ol*0.01*R 									-- ������� ����
end

function main()
run=true
Risk=false 							-- ���� ���������� �������� �����
Profit=false 						-- ���� ���������� �������� �������
CreateTable()
VA()
str = "Script started"
log(str)
str = "���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)"
message ("���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)")
log(str)
	while run do -- ����
	VA()
	OnClearing()
	sleep(1)
	SetCell(t_id, 1, 0, tostring(plp))
	SetCell(t_id, 1, 1, tostring(pl))
		if (plp<=-R and Risk==false) then
			message ("���������� �������� �����!!!\nP/L: " ..pl.." �.( "..plp.." %)",3)
			OnRisk()
		end
		
		if (plp>=P and Profit==false) then
			message ("��������� ������� ���� �� �������! ����������! ��� �����!\nP/L: "..pl.." �.( "..plp.." %)",2)
			OnProfit()
		end
	CheckRP()
	if IsWindowClosed(t_id)==true then -- ��������� ������� ���� ������� ��� ���
		run=false
	end
	end
sleep(1)
end


function OnRisk() 					-- ��� ���������� �������� �����
str = "���������� �������� �����!!! P/L: " ..pl.." �.( "..plp.." %)"
log(str)
Risk=true
sleep(1000)
end

function OnProfit() 				-- ��� ���������� �������� �����
str = "��������� ������� ���� �� �������! P/L: "..pl.." �.( "..plp.." %)"
log(str)
Profit=true
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
 file = io.open(getScriptPath().."\\RiskManLog.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OpPo() 					-- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ �������
BuyVol=0
SellVol=0
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do 
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then -- ���� ������ ������� �� ����� ���� ��
            if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then -- ���� ������� ������ ������� > 0, �� ������� ������� ������� (BUY)
			IsBuy = true;
			BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;	-- ���������� ����� � ������� BUY				
      else   -- ����� ������� �������� ������� (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); -- ���������� ����� � ������� SELL
      end;
   end;
end;
end

function OnClearing()				-- �� ��������
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

function CreateTable()														-- ������ ���� �������
	w_id = AllocTable() 														-- �������� ��������� id ��� ��������
	
		-- ��������� ��������
		AddColumn(w_id, 0, "Stop Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 1, "Take Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 2, "�������������", true, QTABLE_INT_TYPE, 25)
   	t = CreateWindow(w_id) 															-- ������� �������
	SetWindowCaption(w_id, SEC_CODE.." RiskMan v.0.2") 							-- ��� �������� ����
	InsertRow(w_id, 1)																	-- ��������� ������
	InsertRow(w_id, 2)
	SetWindowPos(w_id, 0, 0, 425, 90) 											-- ���������� ��������� ����
	SetCell(w_id, 1, 0, "N/A")
	SetCell(w_id, 1, 1, "N/A")
	SetCell(w_id, 1, 2, "N/A")
	sleep(1)
end

function CheckRP()
	if Risk==true and plp>-R then
		message("����������, �� �������, ����")
		str="����������, �� �������, ����... P/L: "..pl.."("..plp.." %)"
		log(str)
		Risk=false
	end
	
	if Profit==true and plp<P then
		message("�� � ������? ���� ���������?\n������� ������� �������, ������!")
		str="����� ������ ������� �������. P/L: "..pl.."("..plp.." %)"
		log(str)
		Profit=false
	end
end

function OnStop()
str="Script stopped by user"
log(str)
run = false
end
 
 function SelfCost()
	for i = 0,getNumberOf("TRADES") - 1 do
		if getItem("TRADES", i).sec_code==SEC_CODE then
			razmer=getItem("TRADES",i).qty			--���������� ������ �������
			if CheckBit(getItem("TRADES",i).flags, 2) == 1 then --����� ����������� �������� �������
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