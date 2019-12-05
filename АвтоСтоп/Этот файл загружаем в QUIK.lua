local bit = require"bit"

dofile ("C:\\ClassesC\\class.luac")
dofile ("C:\\ClassesC\\Window.luac")
dofile ("C:\\ClassesC\\Helper.luac")
dofile ("C:\\ClassesC\\Trader.luac")
dofile ("C:\\ClassesC\\Transactions.luac")
dofile ("C:\\ClassesC\\Settings.luac")
dofile ("C:\\ClassesC\\Security.luac")


trader ={}
trans={}
helper={}
s={}

security={}
is_run = true

working = false


Second=0
PredSecond=0
Waiter=0

 local hID=0
 

 window={}
function OnInit(path)


trader = Trader()
trader:Init(path)


trans= Transactions()
trans:Init()

s=Settings()
s:Init()
s:Load(trader.Path)


helper= Helper()
helper:Init()


security=Security()
security:Init(s.classcode,s.code)


end


function OnBuy()
    if working  then
      trans:order(s.code,s.classcode,"B",s.client,s.depo,tostring(security.last+20*security.minStepPrice),s.lot)
	end 
	 
end

function OnSell()
 if working  then
      trans:order(s.code,s.classcode,"S",s.client,s.depo,tostring(security.last-20*security.minStepPrice),s.lot)
	end 
end

function OnBuyStair()
    if working  then
	    i=1
		trans:killAllOrdersByClient(s.code,s.classcode,s.client)
	    while i<=tonumber(s.StepNumber) do
        trans:order(s.code,s.classcode,"B",s.client,s.depo,tostring(security.last-i*tonumber(s.StepSize)),s.lot)
		i=i+1
		end
	end 
	 
end


function OnSellStair()
    if working  then
	    i=1
		trans:killAllOrdersByClient(s.code,s.classcode,s.client)
	    while i<=tonumber(s.StepNumber) do
        trans:order(s.code,s.classcode,"S",s.client,s.depo,tostring(security.last+i*tonumber(s.StepSize)),s.lot)
		i=i+1
		end
	end 
	 
end


function OnStart()

		


window:InsertValue("�������",tostring(trader:GetCurrentPosition(s.code,s.client)))
s:Load(trader.Path)
end








function OnStop(s)

 window:Close()
 is_run = false
end 



function OnParam( class, sec )

    if is_run == false  then
        return
    end
	 trans:CalcDateForStop()
	
	
	if Waiter~=0 and Second~=PredSecond then
	     Waiter=Waiter+1
	     if Waiter>4 then
		 Waiter=0
		 end
	end
	PredSecond=Second
	
    if (tostring(sec) == s.code)  then
	helper:writeInFile("D:\\3.txt",s.classcode)
	security:Update()
    window:InsertValue("����",tostring(security.last))
	end
	
	
end


function OnDepoLimit(dlimit)

 s:Load(trader.Path)
  if (working==false) then
  return
  end
  
  position=tonumber(window:GetValue("�������"))

   if working and security.STATUS=="���������"  and ((dlimit.limit_kind==2 and s.TypeLimit=="T2") or (dlimit.limit_kind==0 and s.TypeLimit=="T0")) then
  
     if s.PoseCombo=="Lots" then
     curPosition=dlimit.currentbal/tonumber(security.lotSize)
	 --message("Lots "..tostring(curPosition).." "..tostring(dlimit.currentbal).." "..tostring(security.lotSize),1)
     end
	 
	 if s.PoseCombo=="Stocks" then
     curPosition=dlimit.currentbal
	-- message("Stocks "..tostring(curPosition).." "..tostring(dlimit.currentbal).." "..tostring(security.lotSize),1)
     end
	   
     window:InsertValue("�������",tostring(curPosition))
	 
     if dlimit.sec_code==s.code  and security.lotSize~=0  then

	  if ((curPosition>position and curPosition>0) or (curPosition<position and curPosition<0) or dlimit.currentbal==0) then
  
	 
  	if (curPosition~=position) then
     trans:killAllStopOrdersByClient(s.code,s.classcode,s.client)
	 end
	 message(tostring(trader:findEnterPrice(s.code)),1)
	message("Position changed to "..tostring(curPosition),1)
	window:InsertValue("�������",tostring(curPosition))
    window:InsertValue("����",tostring(trader:findEnterPrice(s.code)))

	 
	 if dlimit.currentbal>0 then
	   message("Set Stop ",1)
	   SetSellStops()
	 end
	 if dlimit.currentbal<0 then
	   message("Set Stop ",1)
	   SetBuyStops()
	 end
	
	 
	 
	 end 	 
	 end
	 end 
end 


function OnFuturesClientHolding(fut_pos)
 s:Load(trader.Path)
  if (working==false) then
  return
  end
 
  position=tonumber(window:GetValue("�������"))
   
     if fut_pos.seccode==s.code and security.STATUS=="���������" then
	 if fut_pos.trdaccid ==s.client then
	 window:InsertValue("�������",tostring(fut_pos.totalnet))
	 if ((fut_pos.totalnet>tonumber(position) and fut_pos.totalnet>0) or (fut_pos.totalnet<tonumber(position) and fut_pos.totalnet<0) or fut_pos.totalnet==0) then
 	
 	 if (fut_pos.totalnet~=tonumber(position)) then
     trans:killAllStopOrdersByClient(s.code,s.classcode,s.client)
	 end 

     message("Position changed to "..tostring(fut_pos.totalnet),1)
	 window:InsertValue("�������",tostring(fut_pos.totalnet))
     window:InsertValue("����",tostring(trader:findEnterPrice(s.code)))


	 
	 if fut_pos.totalnet>0 then 
	    
	     message("Set Stop ",1)
	     SetSellStops()
	 end
	 if fut_pos.totalnet<0 then
	     message("Set Stop ",1)
	    SetBuyStops()
	 end
	
	 
	 end
	 end
	 end
	
	 
end

function SetBuyStops()

	    position=tonumber(window:GetValue("�������"))

        minStepPrice=security.minStepPrice
	    stopLevel=0
		takeLevel=0
	    stopLevel2=0
		typeOfPoint=""
		entry_price=tonumber(window:GetValue("����"))
		
		
        if s.StopType=="Points" then
		stopLevel=entry_price+s.stop
		takeLevel=entry_price-s.take
	    stopLevel2=entry_price+s.stop+s.slip
		typeOfPoint="PRICE_UNITS"
		end
		 
	    if s.StopType=="Percents" then
		stopLevel= math.floor(entry_price*(1+s.stop/100)/minStepPrice)*minStepPrice
		takeLevel=math.floor(entry_price*(1-s.take/100)/minStepPrice)*minStepPrice
	    stopLevel2=math.floor(entry_price*(1+s.stop/100+s.slip/100)/minStepPrice)*minStepPrice
		typeOfPoint="PERCENTS"
		end
	
		window:InsertValue("����",tostring(takeLevel))
		window:InsertValue("����",tostring(stopLevel))
		if stopLevel~=0 then
		  if s.TypeOrder=="Stop+Trailing" then
	       trans:StopPlusTakeProfit(s.client,s.depo,"B",stopLevel2,takeLevel,stopLevel,s.Offset,typeOfPoint,s.slip,typeOfPoint,-position,s.code,s.classcode,trans.dateForStop)
		  end 
		
		  if s.TypeOrder=="Stop+Take" then
		    trans:BindedStop(s.client,s.depo,"B",stopLevel2,stopLevel,takeLevel,-position,s.code,s.classcode)
		  end
		end  
		  

end

function SetSellStops()
         position=tonumber(window:GetValue("�������"))
		
        minStepPrice=security.minStepPrice
	    stopLevel=0
		takeLevel=0
	    stopLevel2=0
		typeOfPoint=""
		entry_price=tonumber(window:GetValue("����"))
		
        if s.StopType=="Points" then
		stopLevel=entry_price-s.stop
		takeLevel=entry_price+s.take
	    stopLevel2=entry_price-s.stop-s.slip
		typeOfPoint="PRICE_UNITS"
		end
		
	     if s.StopType=="Percents" then
		stopLevel= math.floor(entry_price*(1-s.stop/100)/minStepPrice)*minStepPrice
		takeLevel=math.floor(entry_price*(1+s.take/100)/minStepPrice)*minStepPrice
	    stopLevel2=math.floor(entry_price*(1-s.stop/100-s.slip/100)/minStepPrice)*minStepPrice
		typeOfPoint="PERCENTS"
		-- message(tostring(stopLevel2),1)
		end
		
		window:InsertValue("����",tostring(takeLevel))
		window:InsertValue("����",tostring(stopLevel))
		
		if stopLevel~=0		 then
          if s.TypeOrder=="Stop+Trailing" then
		    trans:StopPlusTakeProfit(s.client,s.depo,"S",stopLevel2,takeLevel,stopLevel,s.Offset,typeOfPoint,s.slip,typeOfPoint,position,s.code,s.classcode,trans.dateForStop)
	      end
		  if s.TypeOrder=="Stop+Take" then
		 -- message(tostring(stopLevel2),1)
		 -- message(tostring(s.slip),1)
		 -- message(tostring(takeLevel),1)
		  
		    trans:BindedStop(s.client,s.depo,"S",stopLevel2,stopLevel,takeLevel,position,s.code,s.classcode)
		  end
	    end
		
end




function OnTransReply(trans_reply)

helper:AppendInFile("TransLog",trans_reply["result_msg"].." \n")

end 

local f_cb = function( t_id,  msg,  par1, par2)
x=GetCell(window.hID, par1, par2) 

if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="Buy �� �����" then
message("Buy",1)
OnBuy()
end
end

if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="Sell �� �����" then
message("Sell",1)
OnSell()
end
end

if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="Buy ��������" then
message("Buy ��������",1)
OnBuyStair()
end
end

if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="������� ������" then
message("�������",1)
trans:killAllOrdersByClient(s.code,s.classcode,s.client)
end
end

if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="Sell ��������" then
message("Sell ��������",1)
OnSellStair()
end
end


if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="�����" then
OnStart()
message("�����",1)
window:SetValueWithColor("�����","���������","Red")
working=true
end
end

if x~=nil then
if (msg==QTABLE_LBUTTONDBLCLK) and x["image"]=="���������" then

message("���������",1)
window:SetValueWithColor("���������","�����","Green")
working=false
end
end




if (msg==QTABLE_CLOSE)  then
 window:Close()
 is_run = false
 message("����",1)
end


end 

function main()


window = Window()
window:Init("�������� 3 �� kbrobot.ru",{'A','B'})
window:AddRow({"���","����"},"")
window:AddRow({s.code,"0"},"Grey")
window:AddRow({"�������","����"},"")
window:AddRow({"",""},"Grey")
window:AddRow({"����","����"},"")
window:AddRow({"",""},"Grey")
window:AddRow({"",""},"")
window:AddRow({"Buy �� �����",""},"Green")
window:AddRow({"Sell �� �����",""},"Red")
window:AddRow({"",""},"")
window:AddRow({"Buy ��������",""},"Green")
window:AddRow({"Sell ��������",""},"Red")
window:AddRow({"������� ������",""},"Grey")
window:AddRow({"",""},"")
window:AddRow({"�����",""},"Green")
window:AddRow({"",""},"")

SetTableNotificationCallback (window.hID, f_cb)


 
while is_run do
sleep(100)
end
end















