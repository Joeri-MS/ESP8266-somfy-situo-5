-- Set ADC in right mode
if adc.force_init_mode(adc.INIT_ADC)
then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

print("Somfy App gestartet")
local US_TO_MS = 1000
local btn_release = gpio.HIGH
local btn_press = gpio.LOW

local modeawning_1 = 1
local modeawning_2 = 2
local modeshutter_1 = 3
local modeshutter_2 = 4
local modeled = 5
local maxawning_sec = 39
local maxshutter_sec = 30

local button_up = 7
local button_down = 6
local button_my = 5
local button_select = 8
local button_prg = 1

gpio.mode(button_up, gpio.OUTPUT)
gpio.mode(button_down, gpio.OUTPUT)
gpio.mode(button_my, gpio.OUTPUT)
gpio.mode(button_select, gpio.OUTPUT)
gpio.mode(button_prg, gpio.OUTPUT)
gpio.write(button_up, btn_release)
gpio.write(button_down, btn_release)
gpio.write(button_my, btn_release)
gpio.write(button_select, btn_release)
gpio.write(button_prg, btn_release)

local function do_somfy_action(somfymode, somfyaction)
-- "on", "off", "extendfull", "retractfull", "extend10", "retract10", "half", "my"
   if somfyaction == 'on' or somfyaction == 'retractfull' then
      gpio.write(button_up, btn_press)
      tmr.delay(300 * US_TO_MS)
      gpio.write(button_up, btn_release)
      tmr.delay(200 * US_TO_MS)
   elseif somfyaction == 'off' or somfyaction == 'extendfull' then   
      gpio.write(button_down, btn_press)
      tmr.delay(300 * US_TO_MS)
      gpio.write(button_down, btn_release)
      tmr.delay(200 * US_TO_MS)
   elseif somfyaction == 'extend10' then
      gpio.write(button_down, btn_press)
      tmr.delay(300 * US_TO_MS)
      gpio.write(button_down, btn_release)
      if somfymode == 'sunblind' then
         tmr.delay(1000 * US_TO_MS * maxawning_sec / 10)
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
      elseif somfymode == 'shutter' then
         tmr.delay(1000 * US_TO_MS * maxshutter_sec / 10)
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
      end
      gpio.write(button_my, btn_release)
      tmr.delay(200 * US_TO_MS)
   elseif somfyaction == 'retract10' then
      gpio.write(button_up, btn_press)
      tmr.delay(300 * US_TO_MS)
      gpio.write(button_up, btn_release)
      if somfymode == 'sunblind' then
         tmr.delay(1000 * US_TO_MS * maxawning_sec / 10)
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
      elseif somfymode == 'shutter' then
         tmr.delay(1000 * US_TO_MS * maxshutter_sec / 10)
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
      end
      gpio.write(button_my, btn_release)
      tmr.delay(200 * US_TO_MS)
   elseif somfyaction == 'half' then
      if somfymode == 'led' then
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_my, btn_release)
         tmr.delay(200 * US_TO_MS)
      elseif somfymode == 'sunblind' then
         gpio.write(button_down, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_down, btn_release)
         tmr.delay(1000 * US_TO_MS * maxawning_sec )
         tmr.delay(500 * US_TO_MS)
         gpio.write(button_up, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_up, btn_release)
         tmr.delay(1000 * US_TO_MS * maxawning_sec / 2 )
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_my, btn_release)
         tmr.delay(200 * US_TO_MS)
      elseif somfymode == 'shutter' then
         gpio.write(button_down, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_down, btn_release)
         tmr.delay(1000 * US_TO_MS * maxshutter_sec )
         tmr.delay(500 * US_TO_MS)
         gpio.write(button_up, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_up, btn_release)
         tmr.delay(1000 * US_TO_MS * maxshutter_sec / 2 )
         gpio.write(button_my, btn_press)
         tmr.delay(300 * US_TO_MS)
         gpio.write(button_my, btn_release)
         tmr.delay(200 * US_TO_MS)
      end
   elseif somfyaction == 'my' then
      gpio.write(button_my, btn_press)
      tmr.delay(300 * US_TO_MS)
      gpio.write(button_my, btn_release)
      tmr.delay(200 * US_TO_MS)
   end
end

local function do_somfy_select_one(selectsave)
   local selectedled = 0
   gpio.write(button_select, btn_press)
   tmr.delay(200 * US_TO_MS)
   gpio.write(button_select, btn_release)
   tmr.delay(500 * US_TO_MS)

   while true do
      gpio.write(button_select, btn_press)
      tmr.delay(200 * US_TO_MS)
      gpio.write(button_select, btn_release)
      tmr.delay(500 * US_TO_MS)
      if adc.read(0) <= 800 then
         selectedled = selectedled + 1
      else
         selectedled = 0
      end
      if selectedled == 2 then
         break
      end
   end
   if selectsave == 1 then
      return
   end
   for i = 1, selectsave - 1 do
      gpio.write(button_select, btn_press)
      tmr.delay(200 * US_TO_MS)
      gpio.write(button_select, btn_release)
      tmr.delay(500 * US_TO_MS)
   end
end

local api = nil
if api == nil then
   api = require('api32')
         .create({
                auth = {
                     user = 'somfyuser',
                     pwd  = 'somsec'
                }
            })
         .on_get('/info', function() 
                return {
                       message = 'Somfy RestAPI',
                       help = [ '/adctest -> ADC Volt Level anzeigen',
                                '/select -> Kanal auswaehlen, Parameter: selmode: 1-5',
                                '/action -> Etwas ausfuehren, Parameter: target: [ "sunblindright", "sunblindleft", "shutterleft", "shutterright", "light"], action: "on", "off", "extendfull", "retractfull", "extend10", "retract10", "half", "my"',
                                '/my -> Einfach die my-Taste bei derzeitigen Kanal' ],
                       status = 'ok'
                }
            end)
         .on_get('/my', function()
         -- Taste my ohne Kanalwechsel vorher
                    gpio.write(button_my, btn_press)
                    tmr.delay(200 * US_TO_MS)
                    gpio.write(button_my, btn_release)
                    tmr.delay(500 * US_TO_MS)
                return {
                    status = 'ok'
                }
            end)
         .on_get('/adctest', function()
         -- Testausgabe vom ADC Volt level
                return {
                    adcvolt = adc.read(0),
                    status = 'ok'
                }
            end)
         .on_post('/select', function(jreq)
         -- Auswahl des Kanals                
                if jreq == nil or jreq.selmode == nil then
                    return {
                       status = 'ERROR'
                    }
                end
                do_somfy_select_one(jreq.selmode)
                return {
                    selected = jreq.selmode,
                    status = 'ok'
                }
            end)
         .on_post('/action', function(jreq)
         -- Hier werden alle Aktionen wie rauf/runter/an/aus... verarbeitet
                if jreq == nil or jreq.target == nil or jreq.action == nil then
                    return {
                       status = 'ERROR'
                    }
                end
                for key, value in pairs(jreq.target) do
                   if value == 'sunblindright' then
                      do_somfy_select_one(modeawning_1)
                      do_somfy_action('sunblind', jreq.action)
                   elseif value == 'sunblindleft' then
                      do_somfy_select_one(modeawning_2)
                      do_somfy_action('sunblind', jreq.action)
                   elseif value == 'shutterright' then
                      do_somfy_select_one(modeshutter_1)
                      do_somfy_action('suhher', jreq.action)
                   elseif value == 'shutterleft' then
                      do_somfy_select_one(modeshutter_2)
                      do_somfy_action('shutter', jreq.action)
                   elseif value == 'light' then
                      do_somfy_select_one(modeled)
                      do_somfy_action('led', jreq.action)
                   end
                end
                return {
                    target = jreq.target,
                    action = jreq.action,
                    status = 'ok'
                }
            end)
end
