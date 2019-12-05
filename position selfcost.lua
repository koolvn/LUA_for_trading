SEC_CODE="BRX6" 												-- ��� ���������
CLIENT_CODE="4100MSV" 									-- ����
CLASS_CODE="SPBFUT"

function main()
run=true
CreateTable()
	while run do
		
		CheckStop()
		OnClearing()
			if IsWindowClosed(w_id)==true then -- ��������� ������� ���� ������� ��� ���
				run=false
			end
	sleep(10)
	end
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
							local minAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMIN").param_value)
							PriceOfStop=tostring(minAP)
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
							TakePrice=math.ceil((PositionPrice-(profit/(SEC_STEP_PRICE*SellVol))*SEC_PRICE_STEP)*100)/100	-- ���� ��������� ����-�������
							local maxAP=tonumber(getParamEx(CLASS_CODE, SEC_CODE, "PRICEMAX").param_value)
							PriceOfStop=tostring(maxAP)
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



function OnStop()
	run=false
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\TESTER.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function CreateTable()														-- ������ ���� �������
	w_id = AllocTable() 														-- �������� ��������� id ��� ��������
	
		-- ��������� 2 ��������
		AddColumn(w_id, 0, "Stop Price", true, QTABLE_INT_TYPE, 25)
		AddColumn(w_id, 1, "Take Price", true, QTABLE_INT_TYPE, 25)
		
   	t = CreateWindow(w_id) 															-- ������� �������
	SetWindowCaption(w_id, SEC_CODE.." AutoStop v.0.1") 							-- ��� �������� ����
	InsertRow(w_id, 1)																	-- ��������� ������
	InsertRow(w_id, 2)
	SetWindowPos(w_id, 0, 0, 345, 75) 											-- ���������� ��������� ����
	SetCell(w_id, 1, 0, "N/A")
	SetCell(w_id, 1, 1, "N/A")
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