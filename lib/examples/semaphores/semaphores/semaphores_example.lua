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
-- # This is a brief example code intended to show how to use the semaphores 
-- # library
-- ##############################################################################

require "threads"
require "semaphores"

  function producer ()
    prod_pid=scheduler.detach(function()
    print("Producer thread", prod_pid)
      local cnt=0
      local time_out=1
      while (true) do
        if (time_out == 1) then
            print("Now sending a producer semaphore from", prod_pid, "to", transit_pid)
            print("producer semaphore.assert result:", semaphore.assert_semaphore(transit_pid, 1, {"From producer", "I have produced", cnt, "semaphores"}))
          time_out=0
          cnt=cnt+1
          tmr.alarm(4, 10000, 0, function()
            time_out=1
          end)
        end
        scheduler.schedule()
      end
    end)
  end

 function transit ()
    transit_pid=scheduler.detach(function()
      print("Transit thread", transit_pid)
      while (true) do
        print("Waiting for transit semaphore")
        local result=semaphore.wait_semaphore(0)
        print("Got a transit semaphore from", result[1], "with the following data:", result[2][1], result[2][2], result[2][3], result[2][4])
        print("Now sending a transit semaphore from", transit_pid, "to", consume_pid, "with non blocking option")
        table.insert(result[2], 2, "via transit")
        print("Transit semaphore.assert result:", semaphore.assert_semaphore(consume_pid, 0, result[2]))        
      end
    end)
  end
  
  function consumer ()
    consume_pid=scheduler.detach(function()
      print("Consumer thread", consume_pid)
      while (true) do
        print("Waiting for consume semaphore with time-out option")
        local result=semaphore.wait_semaphore(1000)
        if (result ~=nil) then
          print("Got a consume semaphore from", result[1], "with the following data:", result[2][1], result[2][2], result[2][3], result[2][4], result[2][5])
        else
          print("Waiting for consume semaphore timed-out, trying again")
        end
      end 
    end)
  end

  scheduler=create_scheduler()
  semaphore=create_semaphore()
  producer()
  transit()
  consumer()
  scheduler.start_schedule()
