-- ##############################################################################
-- # Copyright (c) 2015 Jonas Bjurel and others as listed below:
-- # jonasbjurel@hotmail.com 
-- #
-- # All rights reserved. This program and the accompanying materials
-- # are made available under the terms of the Apache License, Version 2.0
-- # which accompanies this distribution, and is available at
-- # http://www.apache.org/licenses/LICENSE-2.0
-- ##############################################################################

-- ##############################################################################
-- # Description: An lightweight async timer id helper implementation
-- # to coordinate the platform an application usage of timer/interupt Id's
-- # Methods:
-- # --------
-- # timer:create_timers() - create a global timer helper context
-- # Input args: -
-- # Returns: Global handler for the timer helper
-- # Description: Creates a global timer helper object
-- #
-- # timer:alloc_timer()
-- # Input args: -
-- # Returns: Global timer/interupt id 
-- # Description: Allocates a global timer id. to be used for asynch timer calls 
-- # like tmr.alarm(timer_id,...)
-- #
-- # timer:free_timer(timer_id)
-- # Input args: timer id
-- # Returns: 0 if successful, others if not
-- # Description: De-allocates a timer id previously allocated by timer:alloc_timer.
-- #
-- # Usage example:
-- # alarm=create_timers()
-- # timer_id=alarm.alloc_timer()
-- # tmr.alarm(timer_id, timeout, 0 function()
-- #   print("One and the only timeout for this time, releasing the timer to others")
-- #   alarm.free_timer(timer_id)
-- # end)
-- #
-- ##############################################################################

-- ##############################################################################
-- TODO:
-- ##############################################################################

require "common"

  function create_timers ()
    --Timer id 2,5 & 6 is used by the system by the system
    local self = {timers={0,1,2,3,4,5,6}, idle_timers={0,1,2,3,4,5,6}}

    local function alloc_timer ()
      timer_id=table.remove(self.idle_timers)
--    DEBUG
--    print("A new timer id:", timer_id, "is allocated")
      return timer_id
    end

    local function free_timer (timer_id)
--    DEBUG
--    if (inTable(self.idle_timers, timer_id) == false and inTable(self.timers, timer_id) ~= false) then  
        table.insert(self.idle_timers,timer_id)
--      print("A timer id:", timer_id, "is freed")
        return 0
--    else
--      print("PANIC! A timer:", timer_id, "was released while it was already in the idle list or it wasn't a valid timer for this platform:")
--      print("Rebooting.......")
--      node.restart()
--      return nil
--    end
--    END DEBUG
    end
    
    return {alloc_timer=alloc_timer,
            free_timer=free_timer}
  end
