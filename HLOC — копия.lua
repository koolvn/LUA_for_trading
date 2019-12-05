Settings = {
	Name = "HLOC",
	line = {
	
	--Hi
	{
		Name = "HI",
		Color = RGB(0, 0, 255),
		Type = TYPE_DASH,
		Width = 1
	},
	--Low
	{
		Name = "Low",
		Color = RGB(0, 0, 255),
		Type = TYPE_DASH,
		Width = 1
	},
	--Open
	{
		Name = "Open",
		Color = RGB(0, 255, 0),
		Type = TYPE_DASH,
		Width = 1
	},
	--Close
	{
		Name = "Close",
		Color = RGB(0, 255, 0),
		Type = TYPE_DASH,
		Width = 1
	}
  }
}

function Init()	
	return 4
end



function OnCalculate(index)
	local High, Low, Open, Close
	
	if index < 12 then
		High = H(index)
		Low = L(index)
		Open = O(index)
		Close = C(index)
		
		
		pOpen = Open
		pClose = Close
		pHigh = High
		pLow = Low
		
		cHigh = H(index)
		cLow = L(index)
		
		return High, Low, Open, Close	
	end
	
	--если день тот же, получаем Hi Low
	if tonumber(T(index).day) == tonumber(T(index-1).day) then
		cHigh = math.max(cHigh, H(index))
		if cLow == 0 or L(index) == 0 then
			cLow = math.max(cLow, L(index))
		else
			cLow = math.min(cLow, L(index))
		end		
		
		Open = pOpen
		Close = pClose
		High = pHigh
		Low = pLow
		
	else --начался новый день		
		
		Open = pOpen
		Close = C(index-1)
		High = cHigh
		Low = cLow
		
		pOpen = O(index)
		pClose = Close
		pHigh = cHigh
		pLow = cLow
		
		cHigh = H(index)
		cLow = L(index)
	end  
  
	return High, Low, Open, Close
end