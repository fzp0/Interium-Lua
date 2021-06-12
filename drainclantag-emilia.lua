local a1 = 0
local a2 = 0
local a3 =
{
  [0]  =  "Golden ticket",
  [1]  =  "golden star",
  [2]  =  "Black heart",
  [3]  =  "like Jafar",
  [4]  =  "Night call",
  [5]  =  "Ecco park",
  [6]  =  "Rain falls",
  [7]  =  "from my charms",
  [8]  =  "Trash star",
  [9]  =  "beat the odds",
  [10]  =  "Night crawl", 
  [11]  =  "for my job",
  [12]  =  "Moon rock",
  [13]  =  "its from Mars",
  [14]  =  "Silver teeth",
  [15]  =  "like Im Jaws",
}

-- i really never saw all anim this tag & i think its wrong animation

function drain()
    if (Utils.IsLocal()) then
        if (a1 < GetTickCount()) then     
            a2 = a2 + 1
            if (a2 > 15) then
                a2 = 0
            end
            Utils.SetClantag(a3[a2])
            a1 = GetTickCount() + 1300
        end  
    end
end
Hack.RegisterCallback("PaintTraverse", drain)
