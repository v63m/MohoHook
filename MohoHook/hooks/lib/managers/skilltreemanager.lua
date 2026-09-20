if HT:getSetting("enable_skill_points_hack") and HT:getSetting("skill_points_total_amount") then
    HT.Player:skillPointsHackHook()
end
