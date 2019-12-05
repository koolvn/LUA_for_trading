--/*������������� ���������*/
R=2 								-- ������������ ���� �� ���� � % �� ��������
P=6									-- ������� ������� ������� � % �� ��������
DC="155958" 						-- ����� �������� ��������
EC="204458" 						-- ����� ��������� ��������


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
VA()
str = "Script started"
log(str)
str = "���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)"
message("���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)")
log(str)
	while run do
	VA()
	OnClearing()
		if (plp<=-R and Risk==false) then
			message ("���������� �������� �����!!!\nP/L: " ..pl.." �.( "..plp.." %)",3)
			OnRisk()
		end
		
		if (plp>=P and Profit==false) then
			message ("��������� ������� ���� �� �������! ����������! ��� �����!\nP/L: "..pl.." �.( "..plp.." %)",2)
			OnProfit()
		end
	end
sleep(1000)
end


function OnRisk() 					-- ��� ���������� �������� �����
str = "���������� �������� �����!!! P/L: " ..pl.." �.( "..plp.." %)"
log(str)
Risk=true
	if (os.date("%H%M%S")== DC or os.date("%H%M%S")== "210002") then
		Risk=false
	end
sleep(1000)
end

function OnProfit() 				-- ��� ���������� �������� �����
str = "��������� ������� ���� �� �������! P/L: "..pl.." �.( "..plp.." %)"
log(str)
Profit=true
	if (os.date("%H%M%S")== "160402" or os.date("%H%M%S")== "210002") then
		Profit=false
	end
sleep(1000)
end	

function OnDisconnected()			-- ��� ����������
str="Disconnected. P/L: "..pl.." �.( "..plp.." %)"
   log(str)
end

function OnConnected()				-- ��� �����������
sleep(15000)
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
	if (os.date("%H%M%S")== DC or os.date("%H%M%S")== "EC") then
		message("������� P/L: "..pl.." �. ("..plp.." %)")
		str="����������� P/L: "..pl.." �. ("..plp.." %)"
		log(str)
		sleep(1000)
	end
end

function OnStop()
str="Script stopped by user"
   log(str)
run = false
 end