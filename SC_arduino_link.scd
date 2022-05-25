s.reboot;

s.latency=0.2;

SerialPort.devices;
~port = SerialPort.new("COM3", 115200);

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


SynthDef(\bass, { arg freq = 440, amp = 0.5, gate = 1;
	var snd, env, oscfreq, output;
	oscfreq = {freq * LFNoise2.kr(0.5).range(0.98, 1.02)}!3;
	snd = Splay.ar(LFSaw.ar(oscfreq));
	env = Env.adsr(0.7, 4, 0, 0.1).kr(doneAction:2, gate: gate);
	snd = snd;
	output = LPF.ar(snd, (env*freq) + 2*freq);
	Out.ar(0, output*amp);
}).add;


SynthDef(\pluck, {arg outbus=0, freq=440, filter=3, amp=1,coef=0.5,dur=2,legato=1,mix=0,pan=0, gate = 1, mixrev=0, room = 0.8;
	var pluck,moog,noteOff,out;
	pluck =	Pluck.ar(PinkNoise.ar,1,0.2,freq.reciprocal,dur*legato,coef);
	moog = MoogFF.ar(pluck, (freq*filter),2);
	out = SelectX.ar(mix,[LPF.ar(pluck,2500),moog]);
	out = FreeVerb.ar(out, mixrev, room);
	out = out * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
	Out.ar(outbus, Pan2.ar(out * amp,pan));
}).add;


e= Array.new(7);
e.add(Scale.ionian.degrees);
e.add(Scale.dorian.degrees);
e.add(Scale.phrygian.degrees);
e.add(Scale.lydian.degrees);
e.add(Scale.mixolydian.degrees);
e.add(Scale.aeolian.degrees);
e.add(Scale.locrian.degrees);
e.add(Scale.minor.degrees);

~array = Array.new(15);
~array.add(-1);
~volumePluck = 0;
~volumeBass = 0;
~reverb = 0;
~mode = 0; // 0: Ionian, 1: Dorian, ... , 6: locrian, 7: melodic minor

Pdefn(\noteseq, Pseq(~array, inf));
Pdefn(\harpVolumePluck, ~volumePluck);
Pdefn(\harpVolumeBass, ~volumeBass);
Pdefn(\reverb, ~reverb);

Pdef(\plucked, Pbind(\tempo, 40,\instrument, \pluck, \note, Pdefn(\noteseq), \dur, 12, \amp, Pdefn(\harpVolumePluck), \delt, 0.3, \dect, 0.6, \mixrev, Pdefn(\reverb)));
Pdef(\sawBass, Pbind(\tempo, 40,\instrument, \bass, \note, Pdefn(\noteseq), \dur, 24, \ctranspose, -24, \amp, Pdefn(\harpVolumeBass)));

)


(
/////////////////////////////////////////////// ROUTINE ////////////////////////////////////////////////

~charArray = [0];
~flag = 0;
~oldVal1 = 0;
~flag0 = 0;
~flag1 = 0;
~flag2 = 0;
~flag3 = 0;
~flag4 = 0;
~flag5 = 0;
~flag6 = 0;
~getValues = Routine.new(
	{ var ascii;
		{ ascii = ~port.read.asAscii;
			if(ascii.isDecDigit,{
				~charArray.add(ascii.digit)});

			if(ascii == $a,{
				~val1= ~charArray.convertDigits;
				~val1.postln;
				ascii.postln;
				~charArray = [0];
			});
			if(ascii == $b,{
				~val2 = ~charArray.convertDigits;
				~val2.postln;
				ascii.postln;
				~charArray = [0];

			});
			if(ascii == $c,{
				~val3 = ~charArray.convertDigits;
				~val3.postln;
				ascii.postln;
				~charArray = [0];
				if (((~val1 > 143) && (~val1 < 160)),{
					switch(~val1,
						144, {
							for(0, 6, {
								arg i;
								if ((~array[i] == e[~mode][~val1%144]), {~flag0 = 1});
							});
							if ((~flag0 == 0), {
								if ((~array[0] == -1),{
									~array.removeAt(0);
									~array.add(e[~mode][~val1%144]);
									Pdefn(\noteseq, Pseq(~array, inf));
									Pdef(\plucked).play;
									Pdef(\sawBass).play;
								},{
									~array.add(e[~mode][~val1%144]);
									Pdef(\plucked).resume;
									Pdef(\sawBass).resume;
								});
							});
							~flag0 = 0;
						},
						145, {
							for(0, 6, {
								arg i;
								if ((~array[i] == e[~mode][~val1%144]), {~flag1 = 1});
							});
							if ((~flag1 == 0), {
								if ((~array[0] == -1),{
									~array.removeAt(0);
									~array.add(e[~mode][~val1%144]);
									Pdefn(\noteseq, Pseq(~array, inf));
									Pdef(\plucked).play;
									Pdef(\sawBass).play;
								},{
									~array.add(e[~mode][~val1%144]);
									Pdef(\plucked).resume;
									Pdef(\sawBass).resume;
								});
							});
							~flag1 = 0;
						},
						146, {
							for(0, 6, {
								arg i;
								if ((~array[i] == e[~mode][~val1%144]), {~flag2 = 1});
							});
							if ((~flag2 == 0), {
								if ((~array[0] == -1),{
									~array.removeAt(0);
									~array.add(e[~mode][~val1%144]);
									Pdefn(\noteseq, Pseq(~array, inf));
									Pdef(\plucked).play;
									Pdef(\sawBass).play;
								},{
									~array.add(e[~mode][~val1%144]);
									Pdef(\plucked).resume;
									Pdef(\sawBass).resume;
								});
							});
							~flag2 = 0;
						},
						147, {
							for(0, 6, {
								arg i;
								if ((~array[i] == e[~mode][~val1%144]), {~flag3 = 1});
							});
							if ((~flag3 == 0), {
								if ((~array[0] == -1),{
									~array.removeAt(0);
									~array.add(e[~mode][~val1%144]);
									Pdefn(\noteseq, Pseq(~array, inf));
									Pdef(\plucked).play;
									Pdef(\sawBass).play;
								},{
									~array.add(e[~mode][~val1%144]);
									Pdef(\plucked).resume;
									Pdef(\sawBass).resume;
								});
							});
							~flag3 = 0;
						},
						148, {
							for(0, 6, {
								arg i;
								if ((~array[i] == e[~mode][~val1%144]), {~flag4 = 1});
							});
							if ((~flag4 == 0), {
								if ((~array[0] == -1),{
									~array.removeAt(0);
									~array.add(e[~mode][~val1%144]);
									Pdefn(\noteseq, Pseq(~array, inf));
									Pdef(\plucked).play;
									Pdef(\sawBass).play;
								},{
									~array.add(e[~mode][~val1%144]);
									Pdef(\plucked).resume;
									Pdef(\sawBass).resume;
								});
							});
							~flag4 = 0;
						},
						149, {
							~volumePluck = ~val2/255;
							~volumeBass = ~val2/700;
							Pdefn(\harpVolumePluck, ~volumePluck);
							Pdefn(\harpVolumeBass, ~volumeBass);
							~volumePluck.postln;  //DEBUG
							~volumeBass.postln;  //DEBUG
					});
				},{
					if (((~val1 > 127) && (~val1 < 144)), {
						switch(~val1,
							128,{
								for(0, 6, {
									arg i;
									if ((~array[i] == e[~mode][~val1%128]), {~array.removeAt(i)});
								});
								if ((~array[0] == nil), {
									~array.add(-1);
									Pdef(\plucked).pause;
									Pdef(\sawBass).pause;
								});

							},
							129,{
								for(0, 6, {
									arg i;
									if ((~array[i] == e[~mode][~val1%128]), {~array.removeAt(i)});
								});
								if ((~array[0] == nil), {
									~array.add(-1);
									Pdef(\plucked).pause;
									Pdef(\sawBass).pause;
								});

							},
							130,{
								for(0, 6, {
									arg i;
									if ((~array[i] == e[~mode][~val1%128]), {~array.removeAt(i)});
								});
								if ((~array[0] == nil), {
									~array.add(-1);
									Pdef(\plucked).pause;
									Pdef(\sawBass).pause;
								});

							},
							131,{
								for(0, 6, {
									arg i;
									if ((~array[i] == e[~mode][~val1%128]), {~array.removeAt(i)});
								});
								if ((~array[0] == nil), {
									~array.add(-1);
									Pdef(\plucked).pause;
									Pdef(\sawBass).pause;
								});

							},
							132, {
								for(0, 6, {
									arg i;
									if ((~array[i] == e[~mode][~val1%128]), {~array.removeAt(i)});
								});
								if ((~array[0] == nil), {
									~array.add(-1);
									Pdef(\plucked).pause;
									Pdef(\sawBass).pause;
								});
							},
							133, {
								~volumePluck = 0;
								~volumeBass = 0;
								Pdefn(\harpVolumePluck, ~volumePluck);
								Pdefn(\harpVolumeBass, ~volumeBass);
						});
					});
				});
				(' ').postln;
				(' ').postln;
			});
	}.loop;}
).play;
)

~getValues.stop;


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


