-- Hier nun die Somfy App
--if adc.force_init_mode(adc.INIT_ADC)
--then
--  node.restart()
--  return -- don't bother continuing, the restart is scheduled
--end

print("Somfy App gestartet")

local btn_release = gpio.HIGH
local btn_press = gpio.LOW

local selectsave = 1

local modeawning_1 = 1
local modeawning_2 = 2
local modeshutter_1 = 3
local modeshutter_2 = 4
local modeled = 5

local button_up = 4
local button_down = 4
local button_my = 4
local button_select = 4
local button_prg = 4


-- gpio.mode(button_up, gpio.OUTPUT)
-- gpio.mode(button_down, gpio.OUTPUT)
-- gpio.mode(button_my, gpio.OUTPUT)
gpio.mode(button_select, gpio.OUTPUT)
-- gpio.mode(button_prg, gpio.OUTPUT)

local function do_somfy_select_one()
   gpio.write(button_select, btn_press)
   tmr.delay(500 * US_TO_MS)
   gpio.write(button_select, btn_release)
   tmr.delay(500 * US_TO_MS)
   selectsave = selectsave + 1
   if selectsave == 6 then
      selectsave = 1
   end
end
-- Read Select Status
if file.exists("somfly.select") then
    print("somfly.select gefunden")
    if file.open("somfly.select", "r") then
      selectsave = file.readline()
      file.close()
    end    
end

-- gpio.write(BLUE_LED, status)

local api = nil
if api == nil then
   api = require('api32')
         .create({
                auth = {
                     user = 'somfyuser',
                     pwd  = 'somsec'
                }
            })
         .on_get('/info', function(jreq) 
                return {
                       message = 'Hello world'
                }
         end)
         .on_get('/select', function()
                if status == gpio.LOW then
                   status = gpio.HIGH
                else
                   status = gpio.LOW
                end
                gpio.write(button_select, status)
                return {
                    device = 'Blue LED',
                    status = status
                }
         end)
end
