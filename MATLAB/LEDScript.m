devices = daq.getDevices;
s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1', 0,'Voltage');
s.Rate = 5000;
outputSingleScan(s,2)