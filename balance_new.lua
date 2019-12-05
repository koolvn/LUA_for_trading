function main()
   local a=75 -- процент ГО
   t_id = AllocTable()
   AddColumn(t_id, 1, 'Balance', true,QTABLE_STRING_TYPE ,20)
   AddColumn(t_id, 2, 'ГО %', true,QTABLE_STRING_TYPE ,10)
   CreateWindow(t_id)
   SetWindowCaption(t_id, "Balance")
   SetWindowPos(t_id, 0, 100, 200, 70)
   
   li=InsertRow(t_id, -1)
   b_old=0


   
running = true   
   
while running do
			if getNumberOf("futures_client_limits") > 0 then
            local item = getItem("futures_client_limits",0)
            n = item.cbplused
            m = item.cbplplanned  
            v = item.varmargin	
            k = item.ts_comission
            b=n+m+v+k
			end
            math.round = function(num, idp)  -- округление до указанного знака
            local mult = 10^(idp or 0)
            return math.floor(num * mult + 0.5) / mult
            end
            
            g = math.round((b/n*100), 2) -- коэффициент ГО с огруглением до сотых
			
            q = QTABLE_DEFAULT_COLOR
		
			SetCell(t_id, li, 1, tostring(b),0)
			SetCell(t_id, li, 2, tostring(g),0)
			if b<b_old then 
				SetColor(t_id, li, 1, RGB(255,187,187), RGB(0,0,0), RGB(0,0,0), RGB(0,0,0))
			elseif b>b_old then  
				SetColor(t_id, li, 1, RGB(205,255,205), RGB(0,0,0), RGB(0,0,0), RGB(0,0,0))
			end	

            if (b/n*100)<a then 
				SetColor(t_id, li, 2, RGB(255,187,187), RGB(0,0,0), RGB(0,0,0), RGB(0,0,0))
			elseif (b/n*100)>a then  
				SetColor(t_id, li, 2, RGB(205,255,205), RGB(0,0,0), RGB(0,0,0), RGB(0,0,0))
			end	
            
			sleep(1000)
			b_old=b
			end	
end


function OnStop()
DestroyTable(t_id)
running = false
end