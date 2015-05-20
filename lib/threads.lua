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
-- # - The treading scheduler is globally initiated by a "handle=create_schduler()" call 
-- # - The main thread calls all the functions needed for the application func1(..); func2(..) ..
-- #   and each of these functions threads it self (creating an own thread) by calling:
-- #   pid=handle.detach(), where pid is the global thread identifier.
-- # - Once all needed threads are created, the main thread calls handle.start_scedule(),
-- #   this should be the last thing to do in the main thread before exiting to the OS.
-- # - Now all detatched functions/threads will start to execute one by one from the job queue,
-- #   there is no automatic thread dispatching - but as threads consumes CPU cycles, they need
-- #   to give access to the scheduler at regular intervals by calling: "handler.schedule().
-- #   This will yield access to other threads to be scheduled.
-- # - Threads terminating or otherwise crashing without previous explicit call of handle.kill(pid)
-- #   will cause panic and reboot!
-- #
-- # Methods:
-- # 
-- #   handle=create_scheduler()
-- #   -------------------------
-- #   Description: Creates a system wide thread scheduler
-- #   Parameters: none
-- #   Returns: A system wide handle for any further thread manipulation
-- #
-- #   pid=handle.detach(function())
-- #   -----------------------------
-- #   Description: Detaches the function to a multi-tasking scheduled thread
-- #   Parameters: function to be run as a multitasking thread
-- #   Returns: The PID UUID
-- #
-- #   handle.schedule()
-- #   -----------------
-- #   Description: From within a detached thread - forces a new scheduling 
-- #   among threads waiting for execution; NOTE: this is currently the only way to yield
-- #   execution time to other threads and must be called regulary - ultimately failure to do
-- #   so will caus the watchdog to reboot the system.  
-- #   Parameters: None
-- #   Returns: 0 is success, all others failure
-- #
-- #   pid=handle.my_pid()
-- #   -------------------
-- #   Description: Get current running PID
-- #   Parameters: None
-- #   Returns: The PID for the currently running process
-- #
-- #   handle.kill(pid)
-- #   ----------------
-- #   Description: Kill a thread with UUID: PID
-- #   Parameters: PID for the process to kill
-- #   Returns: 0 is success, all others failure
-- #
-- #   mutex(function)
-- #   ---------------
-- #   Description: The function provided to the mutex call will be handled as an atom and will
-- #   not be entered by other threads/OS functions until released/returned. This is a placeholder,
-- #   Real implementation is still pending ESP 8266/NodeMCU multi-core/hardware thread support.
-- #   Parameters: The function that needs to run as an atom
-- #   Returns: The return code of the atom
-- #
-- #   reboot()
-- #   --------
-- #   Description: Safely reboots the unit.
-- #   Parameters: -
-- #   Returns: -
-- ##############################################################################

-- ##############################################################################
-- # TODO:
-- # ----
-- # - As always - memory consumption tuning
-- #
-- # - Much more testing - and especially around if the scheduler explicitly needs to
-- #   give runtime to the background nodemcu/ESP8266SDK run-time system - which it seems!?
-- #
-- # - Adding semaphores: 
-- #   Consumer method: unstructured_data=semaphore_wait(timeout) - blocking 
-- #   (but no spin until time-out or message from any one (semaphore_assert)
-- #   Producer method: semaphore_assert(PID, blocking, unstructured_data)
-- #   sending a semaphore to PID with data, if blockig=1 - no spin blocking/synchronizing 
-- #   until received by consumer; if blocking=0, async delivery of semaphore and data.
-- #
-- # - Adding thread priority - absolute priority
-- #   A number of questions though - what is the detectable criteria for a non runnable absolute
-- #   priority thread?
-- ##############################################################################

function mutex(mutex_func)
    local result = mutex_func()
    return result
  end

  function reboot()
    print("Trying to use native platform reboot mechanism")
    node.restart()
    tmr.delay(5000000)
    print("Now going harsh with the watchdog method")
    while (true) do
    end
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
    local self = {job_queue={}}

    local sched=coroutine.create (function()
      while true do
        tmr.wdclr()
        print("Heap reamining is", node.heap())
        mutex(function()
          prev_pid=table.remove(self.job_queue, 1)
          if (prev_pid ~= nil and coroutine.status(prev_pid) ~= "dead") then
            table.insert(self.job_queue, prev_pid)
          else
            print("PANIC PID", prev_pid, "has unexpecedly died - rebooting")
            reboot()
          end
--          VVV Strange that semicolon is needed when last char is "]" VVV
          next_pid=self.job_queue[1];
        end)
        print("Scheduling out PID", prev_pid)
        print("Scheduling in PID", next_pid)
        if (next_pid == nil) then
          print("No more threads to schedule, exiting scheduler....")
          break
        end
        coroutine.resume(next_pid)
      end
      return 0
    end)

    local function start_schedule()
      print("Starting scheduler", sched)
      coroutine.resume(sched)
    end

    local function detach(detach_func)
      local new_pid=coroutine.create(detach_func)
      print("Detaching PID", new_pid)
      mutex(function()
        table.insert(self.job_queue, new_pid)
      end)
      return 0
    end

    local function kill(pid)
      mutex(function()
        kill_job_index=inTable(self.job_queue, pid)
        if (kill_job_index ~= nil) then
          table.remove(self.job_queue, kill_job_index)
        end
      end)
      if (kill_job_index == nil) then
        return 1
      else
        return 0
      end
    end

    local function my_pid()
      return coroutine.running()
    end

    local function schedule()
      print("Yielding", my_pid())
      coroutine.yield(my_pid())
      return 0
    end
    
    return {start_schedule=start_schedule,
            detach=detach,
            my_pid=my_pid,
            schedule=schedule,
            kill=kill}
  end