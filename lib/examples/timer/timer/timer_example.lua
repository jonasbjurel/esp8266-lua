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
-- # DESCRIPTION:
-- # This is a brief example code intended to show how to use the timer 
-- # library
-- ##############################################################################

require "timer"

  function start_timer (timer)
    print("Timer id is", timer)
    tmr.alarm(timer, 1000, 1, function()
      print("timer id:", timer, "running")
    end)
  end
   
  start_timers=1
  timers={}
  cnt=0
  alarm=create_timers()
  timer2=alarm.alloc_timer()
  print("Starting up all available timers from scratch")
  tmr.alarm(timer2, 10000, 1, function()

--  DEBUG only working with debug option
--  if (cnt == 4) then
--    print("Commiting suicide - releasing a non valid timer 911")
--    alarm.free_timer(911)
--  end
    
    if (start_timers == 1) then
      timer1=alarm.alloc_timer()
      if (timer1 ~= nil) then
        print("Starting timer", timer1)
        start_timer(timer1)
        table.insert(timers, timer1)
      else
        print("No more timers available, will start to remove timers")
        start_timers=0
      end
    end
    if (start_timers == 0) then
      timer1=table.remove(timers)
      if (timer1 ~= nil) then
        print("Stopping timer", timer1)
        tmr.stop(timer1)
        alarm.free_timer(timer1)
      else
        print("All timers stopped, starting up timers")
        cnt=cnt+1
        start_timers=1
      end
    end
  end)
