s.reboot;
s.latency=0;

SerialPort.devices;
~port = SerialPort.new("COM3", 115200);

(
~charArray = [0];
~flag = 0;
~oldVal1 = 0;
~getValues = Routine.new(
	{ var ascii;
		{ ascii = ~port.read.asAscii;
			ascii.postln;
			/*if(ascii == $z,{
				// ascii.postln;
				~flag = 0;
				~val0 = ~val1;
			});*/
			if(ascii.isDecDigit,{
				~charArray.add(ascii.digit)});
			//~charArray.postln;
			if(ascii == $a,{
				~val1= ~charArray.convertDigits;
				// ~val1.postln;
				// ascii.postln;
				~charArray = [0];
			});
			if(ascii == $b,{
				~val2 = ~charArray.convertDigits;
				// ~val2.postln;
				// ascii.postln;
				~charArray = [0];

			});
			if(ascii == $c,{
				~val3 = ~charArray.convertDigits;
				// ~val3.postln;
				// ascii.postln;
				~charArray = [0];
				if (((~flag==0) && (~val1 > 143) && (~val1 < 160)),{
					switch(~val1,
						144, {a = Synth.new(\kick)},
						145, {b = Synth.new(\snare)},
						146, {c = Synth.new(\clap)},
						147, {d = Synth.new(\hihat)}
					);
					~flag = 1;
				},{
					if(((~val1 > 127) && (~val1 < 144)), {
						~flag = 0;
					});
				});

			});

	}.loop;}
).play;
)

~getValues.stop;

(

//////////////////////////////////////// SYNTHDEFS Block /////////////////////////////////////////

SynthDef(\kick, {
    |out = 0, pan = 0, amp = 2|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08]));
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


SynthDef(\snare, {
    |out = 0, pan = 0, amp = 0.9|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;


SynthDef(\hihat, {
    |out = 0, pan = 0, amp = 0.9|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap, {
    |out = 0, amp = 0.9, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;
)

Synth(\kick);
Synth(\snare);
Synth(\hihat);
Synth(\clap);



// (
// ~control = Routine.new(
// 	{
// 		{
// 			if (((~val1 > 143) && (~val1 < 160)),{
// 				a = Synth.new(\kick);// cmd = 0x9* -> noteOn
// 			});
// 			0.01.wait;
// 		}.loop;
// 	}
// ).play;
// )
//
// ~control.stop;


