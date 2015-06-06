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
-- # A very simple semaphore implementation for ESP8266/NondeMCU/LUA requiring the 
-- # thread implementation found at: https://github.com/jonasbjurel/esp8266-lua 
-- # This is one of the first very experimental implementation with very limited
-- # experience on how the actual ESP8266 SDK run-time system works.
-- # The paradigm for this implementation is as follows:
-- # - The common resources for the Semaphore implementation is globally initiated by calling
-- #   "handle=create_semaphore()".
-- # - Semaphores serves two purposes:
-- #   o Synchronization across threads
-- #   o Communication between threads
-- # - Semaphore producer mechanisms
-- #   A producer of a semaphore issues a "handle.assert_semaphore(to_pid, block, data)
-- #   o Where "to_pid" is the pid UUID to which the semaphore is addressed
-- #   o Where "block" defines if the call will be blocking/yet (non spinning, but yielding runtime to
-- #     other threads) until the addresse has recieved the message, or if the call will be returning 
-- #     immediatly and asynchronously deliver the semaphore message (in this case not for synchronization 
-- #     purposes, but only for message delivery.
-- #   o Where "data" is any arbitrary can be sent from the semaphore issuer to the semaphore receiver.
-- #
-- # - Semaphore receiver mechanisms
-- #   A receiver of a semaphore issues a result=wait_semaphore(timeout)
-- #   This is a blocking call (not yet spinning, but yielding runtime to other threads) with a time-out 
-- #   option.
-- #   o Where timeout defines a optional time-out:
-- #     > if set to "0" the call will block until a a semaphore is received
-- #     > if set to <> "0" the call will block until a a semaphore is received or if the timeout value 
-- #       defined has expired. There is currently no call-back method for semaphores defined so to catch 
-- #       a semaphore after a timeout has happend - a new "wait_semaphore(timeout)" call must be issued.
-- #   o The result of the call is:
-- #     > "nil" - The call has timed out
-- #     > {pid, data} - where "pid" indicates the pid UUID thread from which the semaphore was sent and
-- #       data provides a reference to any arbitrary data (type) provided by the semaphore issuer.
-- #
-- # Methods:
-- # 
-- #   handle=create_semaphore()
-- #   -------------------------
-- #   Description: Creates a system wide semaphore handler
-- #   Parameters: none
-- #   Returns: A system wide handle for any further semaphore handling
-- #
-- #   result=handle.assert_semaphore(to_pid, block, data)
-- #   ---------------------------------------------------
-- #   Sends a semaphore from current running thread context to "to_pid" UUID, passing arbtrary data 
-- #   structures in "data"
-- #   Arguments: 
-- #   - "to_pid" defines the receiving pid UUID.
-- #   - "block":
-- #     o 0 - will make the call immediately delivering the message asynchronously
-- #     o 1 - will make the call block (non spinning) until the receiver has received th semaphore
-- #   - "data" - an arbitrary data structure to be delivered to the semaphore receiver    
-- #   Returns: (result)
-- #   - "nil" if the destination pid UUID does not exist - failure!
-- #   - "0" if successful
-- #
-- #   result=handle.wait_semaphore(timeout)
-- #   -------------------------------------
-- #   Call to wit for a semaphore from anyone, timeout defines the timeout value in (ms) until the call
-- #   returns no matter what.
-- #   Arguments: 
-- #   - "timeout" defines the timeout until the call returns no matter what:
-- #     o 0 - will make the call blocking (non spinning) until any semaphore is received.
-- #     o <> 0 - will make the call return after a semaphore is received or if timeout (ms) occurs.
-- #   Returns: (result)
-- #   - "nil" if time-out and no semaphore received
-- #   - {pid, data} if semaphore received 
-- #     o "pid" UUID - the sending pid/UUID
-- #     o "data" - any data sent from semaphore issuer
-- #
-- #   IMPORTANT CONSIDERATIONS!
-- #   -------------------------
-- #   - OS asynch callback considerations:
-- #     semaphores library calls, referencing the scheduler handler must not be called from ESP8266/MCU/LUA
-- #     asynchronous call-backs as they do not run in a defined thread context (allthough they run in a 
-- #     defined function/stack context). Doing this will break the scheduler and will at the best create
-- #     a scheduler PANIC, at worst undefined behaviour!
-- #
-- #     Following setup is not supported
-- #      tmr.alarm(1, 1000, function()
-- #       assert_semaphore(to_pid, block, data)
-- #      end)
-- #
-- #     Instead construct something like this:
-- #     tmr.alarm(1, 1000, function()
-- #       timeout=1
-- #     end)
-- #     if (timeout == 1) then 
-- #       timeout=0
-- #       assert_semaphore(to_pid, block, data)
-- #     end
-- #
-- #  - Memory consumption
-- #    o All comments needs to be removed before downloading to ESP8266/NodeMCU in
-- #      order to make it compile to LUA Byte code - for memory reasons.
-- #    o The code needs to be compiled to LUA Byte code, i.e after having downloaded 
-- #      it to the device - perform "node.compile("threads.lua")


-- ##############################################################################
-- # TODO:
-- # ----
-- # - As always - memory consumption tuning
-- #
-- # - Adding thread priority - absolute priority
-- #   A number of questions though - what is the detectable criteria for a non runnable absolute
-- #   priority thread?
-- #
-- # - Rebase to a new timer shim library - abstracting away the hardware timer Id's 
-- #   and potential collisions with timer Ids - resulting in unpredictable results.
-- ##############################################################################

require "threads"

  function create_semaphore()
    local self = {semaphores={}}

    local function wait_semaphore(timeout)
      local to_pid=scheduler.my_pid()
      local timer_exit=0
      if (timeout ~= 0) then
        tmr.alarm(6, timeout, 0, function()
          timer_exit=1
        end)
      end
      repeat
        scheduler.schedule()
        if (self.semaphores.to_pid == nil) then
          from_pid=nil
        else
          from_pid=table.remove(self.semaphores.to_pid.queue, 1)
        end
      until (timer_exit ~= 0 or from_pid ~= nil)
      if (from_pid ~= nil) then
        data=self.semaphores.to_pid.from_pid.data
        self.semaphores.to_pid.from_pid=nil
        if (self.semaphores.to_pid.queue[1] == nil) then
          self.semaphores.to_pid=nil
        end
        return {from_pid, data}
      else
        return nil
      end
    end

    function assert_semaphore(to_pid, block, data)
      local from_pid=scheduler.my_pid()
      if (self.semaphores.to_pid == nil) then
         self.semaphores.to_pid={}
         self.semaphores.to_pid.queue={}
      end
      if (self.semaphores.to_pid.from_pid == nil) then
        self.semaphores.to_pid.from_pid={}
        self.semaphores.to_pid.from_pid.data=data
        table.insert(self.semaphores.to_pid.queue, from_pid)
        if (block == 1) then
          repeat
            scheduler.schedule()
          until (self.semaphores.to_pid == nil or self.semaphores.to_pid.from_pid == nil)
        end
        return 0
      else
        return nil
      end
    end   
    
    return {wait_semaphore=wait_semaphore,
            assert_semaphore=assert_semaphore}
  end
