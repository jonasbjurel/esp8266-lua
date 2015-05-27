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
-- # This is a brief example code intended to show how to use the threads 
-- # library
-- ##############################################################################

require "threads"

  function do_somethings_always ()
    a=scheduler.detach(function ()
      print("Thread A detached", a, "From thread A: I will do usefull things until I get killed by someone")
      local cnt=0
      while (true) do
--        print ("I'm here", cnt)
        tmr.delay(10000)
        scheduler.schedule()
        cnt=cnt+1
        if (cnt == 10) then 
          print("From thread A: doing something useful, as usual")
          cnt=0
        end 
      end
    end)
  end
  
  function do_otherthings_forawhile ()
    b=scheduler.detach(function ()
      print("Thread B detached", b, "From thread B: I will do 10 other useful things - I dont bother to do more")
      local cnt1=0
      local cnt2=0
      while (true) do
        tmr.delay(10000)
        scheduler.schedule()
        cnt1=cnt1+1
        if (cnt1 == 10) then
          cnt1=0
          cnt2=cnt2+1
          print("From thread B: doing another thing useful, I will only do it for", 11-cnt2, "more times")
          if (cnt2 == 10) then
            print("From thread B: I'm done, no more things to do for me - good bye")
            scheduler.kill(scheduler.my_pid())
          end
        end
      end
    end)
  end

  function do_asyncronous_things ()
    scheduler.detach(function ()
      print("From thread C: Doing needed asychronous things every 500 ms")
      tmr.alarm(4, 500, 1, function()
        print("From thread C: Got a asynchronous timeout after 500 ms, now doing what I have to do")
      end)
      while (true) do
        scheduler.schedule()
      end
    end)
  end

  function do_badthings ()
    d=scheduler.detach(function ()
      print("Thread D detached", d, "From thread D: Im the bad thread, I will bring the whole system down by dioing bad things in a minute")   
      local timeout=0
      tmr.alarm(6, 60000, 0, function()
        timeout=1
      end)
      while (true) do
        if (timeout == 1) then
          print("From thread D: OUPS... I have been caught!, this will lead to system reboot!")
          print("To do this, I unpredictably broke out from the thread loop without calling threads:kill()")
          print("The same result would had been at hand if my thread had crashed:")
          print("for examble by reference unreferenced values:")
          print("data=unreferenced.sub_unreferenced.sub_sub_unreferenced")
          print("or otherwise")
          break
        end
        scheduler.schedule()
      end
    end)
  end

  scheduler=create_scheduler()
  do_somethings_always()
  do_otherthings_forawhile()
  do_asyncronous_things()
  do_badthings()
  scheduler.start_schedule()
  tmr.alarm(3,1000,1,function()
    print("MCU/LUA Background environment got execution time ..................................")
  end)
