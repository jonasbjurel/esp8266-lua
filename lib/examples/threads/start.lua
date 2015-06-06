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
-- # This is a brief example code intended to show how to use the threads 
-- # library
-- ##############################################################################

init_func=loadfile("threads_example.lua")
if (init_func ~= nil) then
  init_func()
else
  init_func=loadfile("threads_example.lc")
  if (init_func ~= nil) then
    init_func()
  else
    print("No init function available to run")
  end
end




