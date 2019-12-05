R=2 																			-- ������������ ���� �� ���� � % �� ��������
P=6																			-- ������� ������� ������� � % �� ��������
ol = getItem("futures_client_limits",0).cbplimit 				-- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin 			-- ������������ �����
nd = getItem("futures_client_limits",0).accruedint 			-- ����������� �����
pl = vm+nd 															-- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 								-- P/L � ���������
risk = ol*0.01*R 														-- ������� ���� � ������
profit = ol*0.01*P														-- ������� ������ � ������

DCs="13:59:59" 						-- ����� ������ �������� ��������
DCf="14:04:59"							-- ����� ��������� �������� ��������
ECs="18:44:59" 						-- ����� ������ ��������� ��������
ECf="18:59:59" 						-- ����� ��������� ��������� ��������

StopPlaced = false
Clearing = false

CLASS_CODE="SPBFUT"
SEC_CODE="BRJ6"
CLIENT_CODE="SPBFUT00aya"
SEC_STEP_PRICE = getParamEx(CLASS_CODE, SEC_CODE, "STEPPRICE").param_value 				-- �������� ��������� ���� ����
SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value		-- �������� ��� ����

lot=0
selfcost=0

function main()
run=true
CreateTable()
	while run do
	SelfCost()
	SetCell(w_id, 1, 2, tostring(selfcost))
		if Clearing==false then 
			OpPo()
		end
		CheckStop()
		OnClearing()
			if IsWindowClosed(w_id)==true then -- ��������� ������� ���� ������� ��� ���
				KillStop()
				run=false
			end
	sleep(1)
	end
end

function OnClearing()				-- �� ��������

	if (getInfoParam("SERVERTIME")== DCs or getInfoParam("SERVERTIME")== ECs) then
			Clearing=true
			sleep(2000)
			KillStop()
	end
	
	if (getInfoParam("SERVERTIME")== DCf or getInfoParam("SERVERTIME")== ECf) then
			SEC_STEP_PRICE = getParamEx(CLASS_CODE, SEC_CODE, "STEPPRICE").param_value 				-- �������� ��������� ���� ����
			SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value		-- �������� ��� ����
			Clearing=false
			sleep(2000)
	end
		
end

function AutoTS()
local minAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMIN").param_value)
local maxAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMAX").param_value)


local T = {
		["ACTION"]="NEW_STOP_ORDER";
		["STOP_ORDER_KIND"]="TAKE_PROFIT_AND_STOP_LIMIT_ORDER";
		["TRANS_ID"]=tostring(os.time());
		["CLASSCODE"]=CLASS_CODE;
		["SECCODE"]=SEC_CODE;
		["ACCOUNT"]=CLIENT_CODE;
		["CLIENT_CODE"]="RiskMan";
		["OPERATION"]=Operation;
		["QUANTITY"]=QTY;
		["STOPPRICE2"]=tostring(StopPrice);							-- ���� ��������� ���� ������
		["PRICE"]=tostring(minAP);								-- Limit order price
		["STOPPRICE"]=tostring(TakePrice);								-- ���� ��������� ����-�������
		["OFFSET"]=tostring(5*SEC_PRICE_STEP);		-- ������
		["OFFSET_UNITS"]="PRICE_UNITS"; 
		["SPREAD"]=tostring(10*SEC_PRICE_STEP);		-- �������� �����
		["SPREAD_UNITS"]="PRICE_UNITS";
		["MARKET_TAKE_PROFIT"]="NO";
		["EXPIRY_DATE"]="TODAY";
		["MARKET_STOP_LIMIT"]="NO"
	}
	
	sendTransaction(T)
	
	sleep(500)
end

function OpPo() 	-- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ �������
	for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do		
			if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then 														-- ���� ������� ������ ������� > 0, �� ������� ������� ������� (BUY)			
					local BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet											-- ���������� ����� � ������� BUY				
					local SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code												-- ��� ����������� ���������
					local PositionPrice = getItem("FUTURES_CLIENT_HOLDING",i).avrposnprice							-- ���� �������� �������
						if SC==SEC_CODE and QTY~=tostring(BuyVol) and StopPlaced==false then					-- ���� ������� �������� ������� � ���� �� ���������, �� ���������� ����
							I=i -- ���������� ����� ������ ������ �������
							Operation="S"					
							QTY=tostring(BuyVol)
							StopPrice=math.ceil((PositionPrice-(risk/(SEC_STEP_PRICE*BuyVol))*SEC_PRICE_STEP)*100)/100		-- ���� ��������� ���� ������
							TakePrice=math.ceil((PositionPrice+(profit/(SEC_STEP_PRICE*BuyVol))*SEC_PRICE_STEP)*100)/100	-- ���� ��������� ����-�������
							SetCell(w_id, 1, 0, tostring(StopPrice))
							SetCell(w_id, 1, 1, tostring(TakePrice))
							local StopMoney=math.ceil((PositionPrice-StopPrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*BuyVol*100)/100
							SetCell(w_id, 2, 0, tostring(StopMoney))
							local TakeMoney=math.ceil((TakePrice-PositionPrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*BuyVol*100)/100
							SetCell(w_id, 2, 1, tostring(TakeMoney))
							AutoTS()						
						end
					if SC==SEC_CODE and QTY~=tostring(BuyVol) and StopPlaced==true then
						KillStop()						
					end						
			else   -- ����� ������� �������� ������� (SELL)
					local SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet) 						-- ���������� ����� � ������� SELL
					local SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code											-- ��� ����������� ���������
					local PositionPrice = getItem("FUTURES_CLIENT_HOLDING",i).avrposnprice  						-- ���� �������� �������
						if SC==SEC_CODE and QTY~=tostring(SellVol) and StopPlaced==false then 				-- ���� ������� �������� ������� � ���� �� ���������, �� ���������� ����
							I=i -- ���������� ����� ������ ������ �������
							Operation="B"
							QTY=tostring(SellVol)
							StopPrice=math.ceil((PositionPrice+(risk/(SEC_STEP_PRICE*SellVol))*SEC_PRICE_STEP)*100)/100		-- ���� ��������� ���� ������
							TakePrice=math.ceil((PositionPrice-(profit/(SEC_STEP_PRICE*SellVol))*SEC_PRICE_STEP)*100)/100		-- ���� ��������� ����-�������						
							SetCell(w_id, 1, 0, tostring(StopPrice))
							SetCell(w_id, 1, 1, tostring(TakePrice))
							local StopMoney=math.ceil((StopPrice-PositionPrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*SellVol*100)/100
							SetCell(w_id, 2, 0, tostring(StopMoney))
							local TakeMoney=math.ceil((PositionPrice-TakePrice)/SEC_PRICE_STEP*SEC_STEP_PRICE*SellVol*100)/100
							SetCell(w_id, 2, 1, tostring(TakeMoney))
							AutoTS()
						end
					if SC==SEC_CODE and QTY~=tostring(SellVol) and StopPlaced==true then
						KillStop()						
					end
			end
		end
	
sleep(500)
end

function KillStop()
local KO= {
				["TRANS_ID"]=tostring(os.time()),

                ["CLASSCODE"]=CLASS_CODE,

                ["SECCODE"]=SEC_CODE,

                ["ACTION"]="KILL_STOP_ORDER",                   

                ["STOP_ORDER_KEY"]=tostring(a_num)

            }
			
	sendTransaction(KO)
sleep(500)
StopPlaced=false
end

function OnStop()
	KillStop()
	run=false
end

function OnStopOrder(stop_order)
	 a_num=stop_order.order_num
	 StopPlaced=true
end

function CheckStop()
	if I~=nil and getItem("FUTURES_CLIENT_HOLDING",I).totalnet == 0 and StopPlaced==true then
		KillStop()
	end
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\TESTER.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
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
			local razmer=getItem("TRADES",i).qty
			if CheckBit(trade.flags, 2) == 1 then 
				lot=lot-razmer
				local mult=-1
			else 
				lot=lot+razmer
				local mult=1
			end
			local cost=getItem("TRADES",i).price*mult
			selfcost=(selfcost+cost)/lot
		end
	end
end