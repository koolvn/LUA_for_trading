function main()
message()
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