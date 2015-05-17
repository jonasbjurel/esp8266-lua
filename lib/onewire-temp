-- ##############################################################################
-- # Copyright (c) 2015 Jonas Bjurel.
-- # jonas.bjurel@hotmail.com
-- # All rights reserved. This program and the accompanying materials
-- # are made available under the terms of the Apache License, Version 2.0
-- # which accompanies this distribution, and is available at
-- # http://www.apache.org/licenses/LICENSE-2.0
-- ##############################################################################

-- ##############################################################################
-- # Description: A onewire temperature sensor library for ESP8266 nodemcu lua systems
-- # Methods:
-- # - sensors=discover_onewire_temp() 
-- #   returns a table of all awailable onewire temperature sensor adresses
-- # - owt=create_onewire_temp(address) 
-- #   Creates a one wire temp sensor object (handle)
-- # - owt.read_temp(callback_func)
-- #   Order to read the temperature, will be returned to callback fuction "callback_func(temp)"
-- # - owt.cyclic_read_temp(period, callback_func(temp))
-- #   Order to cyclicaly read the temperature, will reapetadly be returned to callback fuction 
-- #   "callback_func(temp)", period is defined in seconds, period=0 ceases the periodic poll
-- # - owt.hysteres_read_temp(hysteres_temp, period, callback_func)
-- #   Order to report on temperature changes exceeding the hysteresis, will be returned to callback 
-- #   fuction "callback_func(temp)" once the temperature has changed with "hysteresis_temp" in degrees 
-- #   from the start of the call, period: period in seconds for which the temp hysteresis check is performed.
-- ##############################################################################

-- ##############################################################################
-- TODO:
-- Not finished, Lib needs to be completed
-- Callbacks must be completed and return read values instead of print()
-- Memory consumption must be analyzed and optimized
-- ##############################################################################

-- ##############################################################################
-- Below definitions should be generalized per project set-up
gpio = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[14]=5,[15]=8,[16]=0}
pwm_dac_pin=gpio[0];
onewire_pin=gpio[2];
onewire_temp_family={0x10,0x28}
-- ##############################################################################

-- ##############################################################################
-- Below functions should be generalized
  function inTable(tbl, item)
    for key, value in pairs(tbl) do
      if value == item then return key end
    end
    return false
  end
-- ##############################################################################

  function discover_onewire_temp ()
    local address = {}
    ow.setup(onewire_pin)
    count = 0
-- vvv Needs to be redsigned for multitasking - soft real time vvv
    repeat
      count = count + 1
      addr = ow.reset_search(onewire_pin)
      addr = ow.search(onewire_pin)
      if (addr ~= nil and inTable(onewire_temp_family, addr:byte(1)) ~= false) then
        crc = ow.crc8(string.sub(addr,1,7))
        if (crc == addr:byte(8)) then
          table.insert(address,addr)
	      end
      end
-- vvv Once multitasking ´soft real-time is implemented, watchdog timer should not need to be reset vvv
      tmr.wdclr()
    until((addr ~= nil) or (count > 100))
    return address
  end

  function create_onewire_temp (onewire_temp_address)
    local self = {address = onewire_temp_address}

    co = coroutine.create(function(address)
      ow.reset(onewire_pin)
      ow.select(onewire_pin, address)
      ow.write(onewire_pin, 0x44, 1)
      time2continue = tmr.now()+10000
      repeat

        coroutine.yield(co)

      until (tmr.now() > time2continue)
      present = ow.reset(onewire_pin)
      ow.select(onewire_pin, address)
      ow.write(onewire_pin,0xBE,1)  
      data = nil
      data = string.char(ow.read(onewire_pin))
      for i = 1, 8 do
        coroutine.yield(co)
        data = data .. string.char(ow.read(onewire_pin))
      end
      print(data:byte(1,9))
      crc = ow.crc8(string.sub(data,1,8))
      if (crc == data:byte(9)) then
        t = (data:byte(1) + data:byte(2) * 256) * 625
        t1 = t / 10000
        print("Temperature= ",t1, " Centigrade")
      else
        print("CRC error")
      end
      end)

--  Ultimate goal: local read_temp = function (callback(temp))
    local read_temp = function ()
      tmr.alarm(0, 1, 0, function() 
-- ##############################################################################
-- This soft realtime logic needs to be generalized
        tmr.alarm(1, 100, 1, function() 
          if (coroutine.status(co) == "suspended") then
            coroutine.resume(co) 
          else
            if (coroutine.status(co) == "dead") then
              tmr.stop(1)
            end
          end
        end)
        coroutine.resume(co, self.address)
-- ##############################################################################
      end)
      return 0
    end

    cyclic_read_temp = function(period, callback)
--    To be written
    end

    local hysteres_read_temp = function (hysteres, period, callback)
--    To be written
    end

    return {
      read_temp = read_temp,
      cyclic_read_temp = cyclic_read_temp,
      hysteres_read_temp = hysteres_read_temp
    }
  end

-- ##############################################################################
-- Main example
temp_address = discover_onewire_temp ()
tmp1=create_onewire_temp(temp_address[1])
-- print("T", tmp1.read_temp(function(temp) print("Result temp:",temp) end))
print("T", tmp1.read_temp())
print(node.heap())
-- ##############################################################################
