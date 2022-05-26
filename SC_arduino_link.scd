s.reboot;
s.latency=0.2;
SerialPort.devices;
~port = SerialPort.new("COM3", 115200);

(

//////////////////////////////////////// SYNTHDEFS Block /////////////////////////////////////////
SynthDef(\silence, {
	|gate = 1|
	var env, snd;
	env = Env.adsr(0.5, 3, 1, 0.2).kr(doneAction:2, gate: gate);
	snd = 0 * env;
	Out.ar([0,1], snd);
}).add;


SynthDef(\kick, {
    |out = 0, pan = 0, amp = 2|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;


    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08]));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
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

    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
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


    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;
    snd = noise;
    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;


SynthDef(\clap, {
    |out = 0, amp = 0.9, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

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
	var snd, envAmp, envFreq, oscfreq, output;
	oscfreq = {freq * LFNoise2.kr(0.5).range(0.98, 1.02)}!3;
	snd = Splay.ar(LFSaw.ar(oscfreq));
	envFreq = Env.adsr(0.7, 4, 0, 0.1).kr(doneAction:2, gate: gate);
	envAmp = Env.adsr(0.5, 3, 1, 0.2).kr(doneAction:2, gate: gate);
	output = LPF.ar(envAmp*snd, (envFreq*freq) + 1.2*freq);
	Out.ar([0,1], output * amp);
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


SynthDef(\rhodes, {
    |out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    // all of these range from 0 to 1
    vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1|
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    lfoSpeed = lfoSpeed * 12;

    freq = freq * 2;

    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));

    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);

    snd = snd/2 * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;


SynthDef(\bup, {
	arg out=0,freq=440,ffreq=440,famp=1,fq=1,
	    fatk = 0.01, fdec = 0.1,
	    aatk = 0.01, adec = 0.1,
	    amp=0.5,gate=1, len=0.2,lag=0.1;

	var synth,ampEnv,filtEnv;

	filtEnv = EnvGen.kr(
		       Env.adsr(fatk,fdec,releaseTime:0.05),
                       gate,
		       freq*famp,
		       ffreq);
	ampEnv = EnvGen.kr(
		       Env.adsr(aatk,adec,releaseTime:0.05),
		       gate,
                       doneAction:2);
	synth = Mix.new([
		LFSaw.ar(Lag.kr([freq*2,freq],lag),[0,pi],amp),
		LFTri.ar(Lag.kr([freq,freq*2],lag),[pi,0],amp)
	]);
	synth = Pan2.ar(synth) * ampEnv;
	synth = RLPF.ar(synth,filtEnv,fq);
	Out.ar(out,synth);
}).add;



SynthDef(\violin, {
	| midinote=60, gate=1, amp=0.25 |
	var env = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction:2);
	var sig = VarSaw.ar(
		midinote.midicps,
		width:LFNoise2.kr(1).range(0.2, 0.8)*SinOsc.kr(5, Rand(0.0, 1.0)).range(0.7,0.8))*0.25;
	sig = sig * env * amp;
	Out.ar(0, sig!2);
}).add;




SynthDef(\MoaningDialogue, {
	|rateL = 0.2, rateR = 0.3, freq = 2, feedback = 50, mul = 1 , lpfreq = 2500, gate = 1|
	var env;
	env = Env.adsr(0.1, 3, 1, 0.1).kr(doneAction:2, gate: gate);
	Out.ar(0,
		FreeVerb.ar(
			BLowPass.ar(
				SinOscFB.ar(
					LFDNoise1.kr([rateL, rateR], freq), feedback;
				, mul),
				lpfreq,
				0.2,
				env
			),
			0.3, // dry/wet
			0.0 //room
		)
	)}
).add;





~processing = NetAddr("127.0.0.1", 12000);
~array = Array.new(15);
~array.add(-1);

~volumeMedium = 1;
~volumeLow = 0.5;

Pdefn(\harpVolumeHigh, ~volumeMedium);
Pdefn(\harpVoluMemedium, ~volumeMedium);
Pdefn(\harpVolumeLow, ~volumeLow);

//Pdefn(\inst1, \rhodes);
Pdefn(\inst2, \pluck);
Pdefn(\inst3, \bass);

Pdefn(\time, 8);

//Pdef(\high, Pbind(\tempo, Pdefn(\time) ,\instrument, Pdefn(\inst1), \note, Pdefn(\noteseq), \dur, 4, \ctranspose, 12, \amp, Pdefn(\harpVolumeHigh)));

Pdef(\medium, Pbind(\tempo, Pdefn(\time) ,\instrument, Pdefn(\inst2), \note, Pdefn(\noteseq), \dur, 3, \amp, Pdefn(\harpVolumeMedium)));

Pdef(\low, Pbind(\tempo, Pdefn(\time) ,\instrument, Pdefn(\inst3), \note, Pdefn(\noteseq), \dur, 4, \ctranspose, -24, \amp, Pdefn(\harpVolumeLow)));

)

//
// Pdefn(\noteseq, Pseq([0,1,2], inf));
// Pdef(\high).play


(
/////////////////////////////////////////////// ROUTINE ////////////////////////////////////////////////
~charArray = [0];
~flag = 0;
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
							for(0, 12, {
								arg i;
								if ((~array[i] == ~val2), {~flag = 1; ~array.postln;});
							});
							~flag.postln;
							if ((~flag == 0), {
								if ((~array[0] == -1),{
									~array.removeAt(0);
									~array.add(~val2);
									Pdefn(\noteseq, Pseq(~array, inf));
									//Pdef(\high).play;
									Pdef(\medium).play;
									Pdef(\low).play;
								},{
									~array.add(~val2);
									Pdefn(\noteseq, Pseq(~array, inf));
								});
							});
							~flag = 0;
						},
						145, {
							Pdefn(\time, ~val2/11);
						},/*
						146, {/*vol batteria*/},
						147, {
							~volumeMedium = ~val2/255;
							~volumeLow = ~val2/700;
							Pdefn(\harpVolumeMedium, ~volumeMedium);
							Pdefn(\harpVolumeLow, ~volumeLow);
							~volumeMedium.postln;  //DEBUG
							~volumeLow.postln;  //DEBUG
							~processing.sendMsg("/harpVolume", ~val2);
						}
*/

					);
				},{
					if (((~val1 > 127) && (~val1 < 144)), {
						switch(~val1,
							128,{
								if((~array.size == 1), {
									~array.put(0, -1);
									Pdef(\medium).pause;
									Pdef(\low).pause;
								},{for(0, 12, {
									arg i;
									if ((~array[i] == ~val2), {
										~array.removeAt(i);
										Pdefn(\noteseq, Pseq(~array, inf));
									});
								});
								});/*,
							133, {
								~volumePluck = 0;
								~volumeBass = 0;
								Pdefn(\harpVolumePluck, ~volumePluck);
								Pdefn(\harpVolumeBass, ~volumeBass);
								~processing.sendMsg("/harpVolume", ~val2);
								}*/
							},
							129, {
								Pdefn(\time, 1);
							}
						);
					});
				});
				(' ').postln;
				(' ').postln;
			});
	}.loop;}
).play;


// OSCdef(\snap, {
// 	arg msg;
// 	msg[1].postln;
// 	switch(msg[1],
// 		0, {Pdefn(\firstDef, \violin)},
// 		1, {Pdefn(\firstDef, \bup)},
// 		2, {Pdefn(\secondDef, \bup)},
// 		3, {Pdefn(\firstDef, \hihat)},
// 		4, {Pdefn(\secondDef, \pluck)},
// 		5, {Pdefn(\firstDef, \bass)}
// 	);
// }, "/snapped");

)

~getValues.stop;

NetAddr.localAddr
Synth(\kick);
Synth(\snare);
Synth(\hihat);
Synth(\clap);


Pdefn(\inst3, \bup)

Pbind(\instrument, \rhodes, 