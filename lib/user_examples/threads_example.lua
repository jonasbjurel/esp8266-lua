-- ##############################################################################
-- # Copyright (c) 2015 Jonas Bjurel and others as listed below:
-- # jonas.bjurel@hotmail.com 
-- #
-- # All rights reserved. This program and the accompanying materials
-- # are made available under the terms of the Apache License, Version 2.0
-- # which accompanies this distribution, and is available at
-- # http://www.apache.org/licenses/LICENSE-2.0
-- ##############################################################################

-- ##############################################################################
-- # DESCRIPTION:
-- # This is a brief example code intended to show how to use the threads library
-- ##############################################################################

require "threads"

 function do_something ()
    scheduler.detach(function ()
      while (true) do
        print("Doing something useful as always")
        scheduler.schedule()
      end
    end)
--    return 0
  end

  function do_anotherthing ()
    scheduler.detach(function ()
      local cnt=0
      while (true) do
        cnt=cnt+1
        if (cnt == 10) then 
          scheduler.kill(scheduler.my_pid())
        end
        print("Doing anotherthing useful for the", cnt, "time")
        scheduler.schedule()
      end
    end)
  end

  function do_badthings ()
    scheduler.detach(function ()
      local cnt=0
      while (true) do
        cnt=cnt+1
        if (cnt == 20) then
          print("OUPS .... I have been caught ........................!!!!!!!!!!!!!!!!!!!!!!")
          break
        end
        print("Doing very dirty things for the", cnt, "time, when will I be discovered")
        scheduler.schedule()
      end
    end)
  end

  scheduler=create_scheduler()
  do_something()
  do_anotherthing()
  do_badthings()
  scheduler.start_schedule()
  while (true) do
    print("Am I ever scheduled???????????????????????????????")
  end
