
function timer()
  value=adc.read(0)
  print("ADC", value)
  m:publish("/esp/battery",tostring(value),0,0,mqtt_puback)
end

--mqtt connection is ready, check for mail
function mqtt_connect(client)
  print("Connected to MQTT broker")
  tmr.alarm(0, 60000, tmr.ALARM_AUTO, timer)
end

--callback if mqtt connection fails
function mqtt_fail(client, reason)
  print("MQTT broker connection failed reason: "..reason)
  sleep()
end

--wifi status callback
function wifi_status(previous_state)
  --when we get an ip connect to mqtt broker
  if wifi.sta.status()==wifi.STA_GOTIP then
    print("Got IP.")
    print("Connect to MQTT server.")
    m:connect("192.168.0.106", 1883, 0, mqtt_connect, 
                                        mqtt_fail)
  else --else we have an error -> sleep and try again
    print("Wifi connection error, status "..wifi.sta.status().." previous "..previous_state)
    sleep()
  end
end

wifi.sta.eventMonReg(wifi.STA_GOTIP,wifi_status)
wifi.sta.eventMonStart()
m=mqtt.Client("MailESP", 120)
if wifi.sta.getip()~=nil then
  m:connect("192.168.0.106", 1883, 0, mqtt_connect, 
                                      mqtt_fail)
else
  print("no ip")
end
