s.reboot;
SerialPort.devices;
~port = SerialPort.new();

(
~charArray = [ ];
~getValues = Routine.new(
	{ var ascii;
		{ ascii = ~port.read.asAscii;
			if(ascii == $z,{
				~flag = 0;
				~val0 = ~val1;
			});
			if(ascii.isDecDigit,{
				~charArray.add(ascii)});
			if(ascii == $a,{
				~val1= ~charArray.collect(_.digit).convertDigits;
				~charArray = [ ];
			});
			if(ascii == $b,{
				~val2 = ~charArray.collect(_.digit).convertDigits;
				~charArray = [ ];

			});
			if(ascii == $c,{
				~val3 = ~charArray.collect(_.digit).convertDigits;
				~charArray = [ ];
				~flag = 1;
			});
	}.loop;}
).play;
)

if (~val1 == 144,{


(
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;
)


a = Synth.newPaused(\kick);

a.run(true);


(