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
-- # A very simple multi-threading/multi tasking mechanism for 
-- # the ESP8266 chip-set.
-- # This is one of the first very experimental implementation with very limited
-- # experience on how the actual ESP8266 SDK run-time system works.
-- # The paradigm for this implementation is as follows:
-- # - The treading scheduler is globally initiated by a "scheduler=create_schduler()" call.
-- #   NOTE: That the handle name needs to be "scheduler" and needs to be global! 
-- # - The main thread calls all the functions needed for the application func1(..); func2(..) ..
-- #   and each of these functions threads it self (creating an own thread) by calling:
-- #   pid=handle.detach(), where pid is the global thread identifier.
-- # - To start the thread scheduling scheduler.start_scedule() should be called from a non thread
-- #   context.
-- #   NOTE: After calling scheduler.start_schedule the non thread context must terminate and leave
-- #   control to the ESP/MCU OS, although asynchronous callbacks to the non thread context is allowed,
-- #   eg. tmr.alarm().
-- # - Now all detatched functions/threads will start to execute one by one from the job queue,
-- #   there is no automatic thread dispatching - but as threads consumes CPU cycles, they need
-- #   to give access to the scheduler at regular intervals by calling: "scheduler.schedule().
-- #   This will yield access to other threads to be scheduled.
-- # - Threads terminating or otherwise crashing without previous explicit call of scheduler.kill(pid)
-- #   will cause panic and reboot!
-- #
-- # Methods:
-- # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- # 
-- #   scheduler=create_scheduler()
-- #   -------------------------
-- #   Description: Creates a system wide thread scheduler
-- #   Parameters: none
-- #   Returns: A system wide handle for any further thread manipulation, this handle must be assigned 
-- #   to the global "scheduler" variable. 
-- #
-- #   pid=scheduler.detach(function())
-- #   --------------------------------
-- #   Description: Detaches the function to a multi-tasking scheduled thread
-- #   Parameters: function to be run as a multitasking thread
-- #   Returns: The PID UUID
-- #
-- #   scheduler.schedule()
-- #   --------------------
-- #   Description: From within a detached thread - forces a new scheduling 
-- #   among threads waiting for execution. This is currently the only way to yield
-- #   execution time to other threads and ESP8266/MCU OS and must be called regulary - 
-- #   ultimately failure to do so will cause the watchdog to reboot the system.'  
-- #   Parameters: None
-- #   Returns: 0 is success, all others failure
-- #
-- #   pid=scheduler.my_pid()
-- #   ----------------------
-- #   Description: Get current running PID UUID
-- #   Parameters: None
-- #   Returns: The PID UUID for the currently running process
-- #
-- #   result=scheduler.kill(pid)
-- #   --------------------------
-- #   Description: Kill a thread with pid UUID
-- #   Parameters: pid UUID for the process to kill
-- #   Returns: doesn't return at all if success, returns with a value <> 0 or nil when failed 
-- #   as for example if the pid UUID does not exist, or otherwise.
-- #
-- #   mutex(function)
-- #   ---------------
-- #   Description: The function provided to the mutex call will be handled as an atom and will
-- #   not be entered by other threads/OS functions until released/returned. This is a placeholder,
-- #   Real implementation is still pending ESP 8266/NodeMCU multi-core/hardware thread support.
-- #   Parameters: The function that needs to run as an atom
-- #   Returns: The return code of the atom
-- #
-- #   reboot() - Depricated - not supported!
-- #   --------------------------------------
-- #   -
-- #
-- #   IMPORTANT CONSIDERATIONS!
-- #   -------------------------
-- #   - OS asynch callback considerations:
-- #     Thread library calls, referencing the scheduler handler must not be called from ESP8266/MCU/LUA
-- #     asynchronous call-backs as they do not run in a defined thread context (allthough they run in a 
-- #     defined function/stack context). Doing this will break the scheduler and will at the best create
-- #     a scheduler PANIC, at worst undefined behaviour!
-- #
-- #     Following setup is not supported
-- #      tmr.alarm(1, 1000, function()
-- #        scheduler.schedule()
-- #      end)
-- #
-- #     Instead construct something like this:
-- #     tmr.alarm(1, 1000, function()
-- #       timeout=1
-- #     end)
-- #     if (timeout == 1) then 
-- #       timeout=0
-- #       scheduler.schedule()
-- #     end
-- #
-- #  - Memory consumption
-- #    o All comments needs to be removed before downloading to ESP8266/NodeMCU in
-- #      order to make it compile to LUA Byte code - for memory reasons.
-- #    o The code needs to be compiled to LUA Byte code, i.e after having downloaded 
-- #      it to the device - perform "node.compile("threads.lua")
-- ##############################################################################

-- ##############################################################################
-- # TODO:
-- # =====
-- # - As always - memory consumption tuning - maybe adding this as a native ESP8266/MCU
-- #   native c library.
-- #
-- # - Much more testing - and especially around if the scheduler explicitly needs to
-- #   give runtime to the background nodemcu/ESP8266SDK run-time system - which it seems!?
-- #
-- # - Rebase to a new timer shim library - abstracting away the hardware timer Id's 
-- #   and potential collisions with timer Ids - resulting in unpredictable results.
-- #
-- # - Adding som simple measures for thread priority.
-- #   The idea right now is to add an argument to schedule - scheduler.schedule(prio)
-- #   which puts the job behind all prio jobs + 1 unprio job.
-- ##############################################################################

function mutex(mutex_func)
    local result = mutex_func()
    return result
  end

  function inTable(tbl, item)
    for key, value in pairs(tbl) do
      if (value == item) then
        return key
      end
    end
    return false
  end
  
  function create_scheduler()
    local self = {job_queue={}, killed_current_job=0}

    local sched=coroutine.create (function()
      while true do
        tmr.wdclr()
--      print("Heap reamining is", node.heap())
        mutex(function()
          prev_pid=table.remove(self.job_queue, 1)
          if (self.killed_current_job == 1 or (prev_pid ~= nil and coroutine.status(prev_pid) ~= "dead")) then
            self.killed_current_job=0
            table.insert(self.job_queue, prev_pid)
          else
            print("PANIC!!! PID", prev_pid, "has unexpecedly died - rebooting")
            node.restart()
          end
--        VVV Strange that semicolon is needed when last char is "]" VVV
          next_pid=self.job_queue[1];
        end)
--      print("Scheduling out PID", prev_pid)
--      print("Scheduling in PID", next_pid)
        if (next_pid == nil) then
          print("No more threads to schedule, exiting scheduler....")
          break
        end
        coroutine.resume(next_pid)
        coroutine.yield(sched)
      end
      return 0
    end)

    local function start_schedule()
      print("Starting scheduler", sched)
      tmr.alarm(1,100,1,function() 
        coroutine.resume(sched)
      end)
    end

    local function detach(detach_func)
      local new_pid=coroutine.create(detach_func)
      print("Detaching PID", new_pid)
      mutex(function()
        table.insert(self.job_queue, new_pid)
      end)
      return new_pid
    end

    local function kill(pid)
      mutex(function()
        local kill_job_index=inTable(self.job_queue, pid)
        if (kill_job_index ~= nil) then
          if (kill_job_index == 1 ) then
            self.killed_current_job=1
          end
          table.remove(self.job_queue, kill_job_index)
        end
      end)
      if (kill_job_index == nil) then
        return 1
      end
    end

    local function my_pid()
      return coroutine.running()
    end

    local function schedule()
--    print("Yielding", my_pid())
      coroutine.yield(my_pid())
      return 0
    end
    
    return {start_schedule=start_schedule,
            detach=detach,
            my_pid=my_pid,
            schedule=schedule,
            kill=kill}
  end
