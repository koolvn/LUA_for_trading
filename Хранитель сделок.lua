Run = true; -- ���� ������ ����� � main

DataFolder = ''; -- ������ ���� � ����� "������(c)quikluacsharp.ru"
TradesFiles = {};-- ������ ������������ ������

function OnInit()
   -- �������� ������ ���� � ����� "������(c)quikluacsharp.ru"
   DataFolder = getWorkingFolder()..'\\������(c)quikluacsharp.ru\\';
   -- ������� ����� �� ���� ��������� ������
   CreateAccountsFolders();
   -- ���������� ��� ����� �� ���������� ������ �� ������� "������" � �����
   CheckAndSaveTerminalTrades();
end;

function main()
   while Run do      
      sleep(1);
   end;   
end;

-- ������� �������� �� ���� ��������� ������
function CreateAccountsFolders()
   -- ���������� ��� �����
   for i=0, getNumberOf("trade_accounts")-1 do
      -- �������� ����� �����
      local Account = getItem("trade_accounts", i).trdaccid;
      -- �������� ����
      local Path = '"'..DataFolder..Account..'\\"';
      -- ���� ������� �� ����������
      if os.execute('cd '..Path) == 1 then
         -- ������� �������
         os.execute('mkdir '..Path); 
      end;
   end;
end;

-- ��������� �������� �� ������ ������ � ���� �������
function CheckTradeInFile(trade)
   -- �������� ���� � ����� ����������� � ����� ��������� �����
   local PathAccountSec = DataFolder..trade.account..'\\'..trade.sec_code..'.csv';
   -- �������� ������� ���� �������� ����������� � ������ "������"
   local TradesFile = io.open(PathAccountSec,"r");
   -- ���� ���� �� ����������, �� ������ �� ��������
   if TradesFile == nil then return false;
   else -- ���� ���� ����������
      -- �������� ������ �����
      local FileIndex = trade.account..'_'..trade.sec_code;
      -- ���� ���� ��� �� ������ ��� �����������
      if TradesFiles[FileIndex] == nil then
         -- ��������� ���� �������� ����������� � ������ "�����������"
         TradesFiles[FileIndex] = io.open(PathAccountSec,"a+");
      end;
      -- ���������� ������ �����
      local Count = 0; -- ������� �����
      for line in TradesFile:lines() do
         Count = Count + 1;
         if Count > 1 and line ~= "" then
            -- ���� ������ ������ ���������, �� ������ ��������
            local i = 0;
            for str in line:gmatch("[^;^\n]+") do
               i = i + 1;
               if i == 3 and tonumber(str) == trade.trade_num then
                  TradesFile:close();
                  return true; 
               end;
            end;
         end;      
      end;
   end;
   TradesFile:close();
   return false;
end;
-- ���������� ��� ����� �� ���������� ������ �� ������� "������" � �����
function CheckAndSaveTerminalTrades()
   local trade = nil;
   -- ���������� ��� ������ � ������� "������"
   for i=0,getNumberOf("trades")-1,1 do      
      trade = getItem ("trades", i);
      -- ���� ������ ������ ��� �� �������� � ���� �������
      if not CheckTradeInFile(trade) then        
         -- ��������� ������ � ���� �������
         AddTradeInFile(trade);
      end;
   end;
end;
-- ��������� ����� ������ � ���� �������
function AddTradeInFile(trade)
   local DateTime = trade.datetime;
   local Date = tonumber(DateTime.year);
   local month = tostring(DateTime.month);
   if #month == 1 then Date = Date.."0"..month; else Date = Date..month; end;
   local day = tostring(DateTime.day);
   if #day == 1 then Date = Date.."0"..day; else Date = Date..day; end;
   Date = tonumber(Date);
   local Time = "";
   local hour = tostring(DateTime.hour);
   if #hour == 1 then Time = Time.."0"..hour; else Time = Time..hour; end;
   local minute = tostring(DateTime.min);
   if #minute == 1 then Time = Time.."0"..minute; else Time = Time..minute; end;
   local sec = tostring(DateTime.sec);
   if #sec == 1 then Time = Time.."0"..sec; else Time = Time..sec; end;
   Time = tonumber(Time);
   -- ���� ������ ������, ������� ���� �� 1 ���� ������
   if Time < 90000 then
      local seconds = os.time(DateTime);
      seconds = seconds + 24*60*60;
      DateTime = os.date("*t",seconds);
      Date = tonumber(DateTime.year);
      month = tostring(DateTime.month);
      if #month == 1 then Date = Date.."0"..month; else Date = Date..month; end;
      day = tostring(DateTime.day);
      if #day == 1 then Date = Date.."0"..day; else Date = Date..day; end;
      Date = tonumber(Date);
   end;
   local Operation = "";
   if CheckBit(trade.flags, 2) == 1 then Operation = "S"; else Operation = "B"; end;
   
   -- ��������� ������ � ������
   local Trade = {};
   Trade.Account = trade.account;
   Trade.Sec_code = trade.sec_code;
   Trade.Num = trade.trade_num;
   Trade.Date = Date;
   Trade.Time = Time;
   Trade.Operation = Operation;
   Trade.Qty = tonumber(trade.qty);
   Trade.Price = tonumber(trade.price);
   Trade.Hint = "����: "..Trade.Account.."_�����: "..trade.trade_num.."_����: ";
   if #day == 1 then Trade.Hint = Trade.Hint.."0"..day.."/"; else Trade.Hint = Trade.Hint..day.."/"; end;
   if #month == 1 then Trade.Hint = Trade.Hint.."0"..month.."/"..DateTime.year; else Trade.Hint = Trade.Hint..month.."/"..DateTime.year; end;
   if #hour == 1 then Trade.Hint = Trade.Hint.."_�����: 0"..hour..":"; else Trade.Hint = Trade.Hint.."_�����: "..hour..":"; end;
   if #minute == 1 then Trade.Hint = Trade.Hint.."0"..minute..":"; else Trade.Hint = Trade.Hint..minute..":"; end;
   if #sec == 1 then Trade.Hint = Trade.Hint.."0"..sec; else Trade.Hint = Trade.Hint..sec; end;
   Trade.Hint = Trade.Hint.."_����������: "..trade.qty;
   Trade.Hint = Trade.Hint.."_����: "..trade.price;
   
   -- �������� ���� � ����� ����������� � ����� ��������� �����
   local PathAccountSec = DataFolder..Trade.Account..'\\'..Trade.Sec_code..'.csv';
   local FileIndex = Trade.Account..'_'..Trade.Sec_code;
   -- ���� ���� ��� �� ������, ��� �� ����������
   if TradesFiles[FileIndex] == nil then
      -- �������� ������� ���� �������� ����������� � ������ "�����������"
      TradesFiles[FileIndex] = io.open(PathAccountSec,"a+");
      -- ���� ���� �� ����������, �� ������ �� ��������
      if TradesFiles[FileIndex] == nil then 
         -- ������� ���� � ������ "������"
         TradesFiles[FileIndex] = io.open(PathAccountSec,"w");
         -- ��������� ����
         TradesFiles[FileIndex]:close();
         -- ��������� ��� ������������ ���� � ������ "�����������"
         TradesFiles[FileIndex] = io.open(PathAccountSec,"a+");
      end;
   end;
   -- ������ � ������ �����
   TradesFiles[FileIndex]:seek("set",0);
   -- ���� ���� ������
   if TradesFiles[FileIndex]:read() == nil then
      -- ��������� ������ ����������
      TradesFiles[FileIndex]:write("����;��� ������;����� ������;���� ������;����� ������;��������;����������;����;����� ���������", "\n");
   end;
   -- ������ � ����� �����
   TradesFiles[FileIndex]:seek("end",0);
   -- ���������� ������ � ����
   TradesFiles[FileIndex]:write(Trade.Account..";"..Trade.Sec_code..";"..Trade.Num..";"..Trade.Date..";"..Trade.Time..";"..Trade.Operation..";"..Trade.Qty..";"..Trade.Price..";"..Trade.Hint, "\n");TradesFiles[FileIndex]:flush();
end;

function OnTrade(trade)
   -- ���� ������ ������ ��� �� �������� � ���� �������
	if not CheckTradeInFile(trade) then        
		-- ��������� ������ � ���� �������
		AddTradeInFile(trade);
	end;
end;

function OnStop()
   -- ��������� ��� �����
   for key,Handle in pairs(TradesFiles) do
      if Handle ~= nil then Handle:close(); end;
   end;
   Run = false;
end;

-- ������� ���������� �������� ���� (����� 0, ��� 1) ��� ������� bit (���������� � 0) � ����� flags, ���� ������ ���� ���, ���������� nil
function CheckBit(flags, bit)
   -- ���������, ��� ���������� ��������� �������� �������
   if type(flags) ~= "number" then error("������!!! Checkbit: 1-� �������� �� �����!"); end;
   if type(bit) ~= "number" then error("������!!! Checkbit: 2-� �������� �� �����!"); end;
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