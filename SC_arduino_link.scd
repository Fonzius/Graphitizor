s.reboot;
s.latency=0.2;
SerialPort.devices;
~port = SerialPort.new("COM3", 115200);

(

//////////////////////////////////////// SYNTHDEFS Block /////////////////////////////////////////
SynthDef(\silence, {
	|gate = 1|
	var env, snd;
	~processing.sendMsg("/drumBeat", "drumOn");
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


// Not techno but sounds good to me
SynthDef(\hihat, {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

// SynthDef(\hihat, {
// 	|out = 0, pan = 0, amp = 0.9|
// 	var click, clickAmp;
// 	var noise, noiseAmp;
// 	var snd;
//
//
// 	noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
// 	noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;
// 	snd = noise;
// 	Out.ar(out, Pan2.ar(snd, pan, amp));
// }).add;


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

    Out.ar(out, snd*amp);
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

SynthDef("synth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 0.7, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;


~processing = NetAddr("127.0.0.1", 12000);

~array = Array.new(15);
~array.add(-1);

~volumeHigh = 0.3;
~volumeMedium = 1;
~volumeLow = 0.3;
~drumVol = 0.5;

~beat = 20;

~kickSeq  = [Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4)];
~snareSeq = [Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4)];
~hihatSeq = [Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4)];
~clapSeq  = [Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4), Rest(4)];

~pitchHigh = 12;
~pitchMedium = 0;
~pitchLow = -24;

Pdefn(\inst1, \rhodes);
Pdefn(\inst2, \pluck);
Pdefn(\inst3, \bass);

Pdefn(\harpVolumeHigh, ~volumeHigh);
Pdefn(\harpVoluMemedium, ~volumeMedium);
Pdefn(\harpVolumeLow, ~volumeLow);
Pdefn(\drumVolume, ~drumVol);

Pdefn(\harpBeat, ~beat);

Pdefn(\seqKick,  Pseq(~kickSeq, inf));
Pdefn(\seqSnare, Pseq(~snareSeq, inf));
Pdefn(\seqHihat, Pseq(~hihatSeq, inf));
Pdefn(\seqClap,  Pseq(~clapSeq, inf));

Pdefn(\highPitch, ~pitchHigh);
Pdefn(\mediumPitch, ~pitchMedium);
Pdefn(\lowPitch, ~pitchLow);

////////////////////////////////////////// Definition of PBINDs ////////////////////////////////////////////

Pdef(\high, Pbind(\tempo, Pdefn(\harpBeat) ,\instrument, Pdefn(\inst1), \note, Pdefn(\noteseq), \dur, 2, \ctranspose, Pdefn(\highPitch), \amp, Pdefn(\harpVolumeHigh)));

Pdef(\medium, Pbind(\tempo, Pdefn(\harpBeat) ,\instrument, Pdefn(\inst2), \note, Pdefn(\noteseq), \dur, 4, \ctranspose, Pdefn(\mediumPitch), \amp, Pdefn(\harpVolumeMedium)));

Pdef(\low, Pbind(\tempo, Pdefn(\harpBeat) ,\instrument, Pdefn(\inst3), \note, Pdefn(\noteseq), \dur, 8, \ctranspose, Pdefn(\lowPitch), \amp, Pdefn(\harpVolumeLow)));

Pdef(\drumKick, Pbind(\tempo, Pdefn(\harpBeat), \instrument, \kick, \dur, Pdefn(\seqKick), \amp, Pdefn(\drumVolume)));
Pdef(\drumSnare, Pbind(\tempo, Pdefn(\harpBeat), \instrument, \snare, \dur, Pdefn(\seqSnare), \amp, Pdefn(\drumVolume)));
Pdef(\drumHihat, Pbind(\tempo, Pdefn(\harpBeat), \instrument, \hihat, \dur, Pdefn(\seqHihat), \amp, Pdefn(\drumVolume)));
Pdef(\drumClap, Pbind(\tempo, Pdefn(\harpBeat), \instrument, \clap, \dur, Pdefn(\seqClap), \amp, Pdefn(\drumVolume)));
)



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
							~beat = ~val2/11;
							Pdefn(\harpBeat, ~beat);
						},
						146, {/*vol batteria*/},
						147, {
							~volumeMedium = ~val2/255;
							~volumeLow = ~val2/700;
							Pdefn(\harpVolumeMedium, ~volumeMedium);
							Pdefn(\harpVolumeLow, ~volumeLow);
							~volumeMedium.postln;  //DEBUG
							~volumeLow.postln;  //DEBUG
							~processing.sendMsg("/harpVolume", ~val2);
						},
						148, {
							///////Pitch/////

						}
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
								~beat = 1;
								Pdefn(\harpBeat, ~beat);
							}
						);
					});
				});
				(' ').postln;
				(' ').postln;
			});
	}.loop;}
).play;

/////////////////////////////////////////////////////  OSC messages ///////////////////////////////////////////////

OSCdef(\DrumLength, {
	arg msg;
	if ((~kickSeq.size > (u)), {
		for (~kickSeq.size-1, u, {
			arg i;
			~kickSeq.removeAt(i);
			~snareSeq.removeAt(i);
			~hihatSeq.removeAt(i);
			~clapSeq.removeAt(i);
			Pdefn(\seqKick,  Pseq(~kickSeq, inf));
			Pdefn(\seqSnare, Pseq(~snareSeq, inf));
			Pdefn(\seqHihat, Pseq(~hihatSeq, inf));
			Pdefn(\seqClap,  Pseq(~clapSeq, inf));
		});
	});
	if ((~kickSeq.size < (u)), {
		for (~kickSeq.size, u, {
			arg i;
			~kickSeq.add(Rest(4));
			~snareSeq.add(Rest(4));
			~hihatSeq.add(Rest(4));
			~clapSeq.add(Rest(4));
			Pdefn(\seqKick,  Pseq(~kickSeq, inf));
			Pdefn(\seqSnare, Pseq(~snareSeq, inf));
			Pdefn(\seqHihat, Pseq(~hihatSeq, inf));
			Pdefn(\seqClap,  Pseq(~clapSeq, inf));
		});
	});
}, "/seqLenght");

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
////////////////////////////////////////// Prove per Pbind //////////////////////////////////
(
Pdefn(\noteseq, Pseq([0, 2, 4, 5], inf));

Pdef(\high).play;
Pdef(\medium).play;
Pdef(\low).play;
)
(
Pdef(\drumKick).play;
Pdef(\drumSnare).play;
Pdef(\drumHihat).play;
Pdef(\drumClap).play;

)
(
~kickSeq  = [4, Rest(4), Rest(4), 4, Rest(4), 4, Rest(4), Rest(4)];
~snareSeq = [Rest(4), 4, 4, Rest(4), Rest(4), Rest(4), 4, Rest(4)];
~hihatSeq = [Rest(4), 4, 4, Rest(4), Rest(4), 4, Rest(4), Rest(4)];
~clapSeq  = [Rest(4), Rest(4), Rest(4), Rest(4), 4, Rest(4), Rest(4), 4];

Pdefn(\seqKick,  Pseq(~kickSeq, inf));
Pdefn(\seqSnare, Pseq(~snareSeq, inf));
Pdefn(\seqHihat, Pseq(~hihatSeq, inf));
Pdefn(\seqClap,  Pseq(~clapSeq, inf));
)

/////////////////////////////////////////////////////////////////////////////////////////////



(
OSCdef(\DrumLength, {
	arg msg;
	if ((~kickSeq.size > (u)), {
		for (~kickSeq.size-1, u, {
			arg i;
			~kickSeq.removeAt(i);
			~snareSeq.removeAt(i);
			~hihatSeq.removeAt(i);
			~clapSeq.removeAt(i);
			Pdefn(\seqKick,  Pseq(~kickSeq, inf));
			Pdefn(\seqSnare, Pseq(~snareSeq, inf));
			Pdefn(\seqHihat, Pseq(~hihatSeq, inf));
			Pdefn(\seqClap,  Pseq(~clapSeq, inf));
		});
	});
	if ((~kickSeq.size < (u)), {
		for (~kickSeq.size, u, {
			arg i;
			~kickSeq.add(Rest(4));
			~snareSeq.add(Rest(4));
			~hihatSeq.add(Rest(4));
			~clapSeq.add(Rest(4));
			Pdefn(\seqKick,  Pseq(~kickSeq, inf));
			Pdefn(\seqSnare, Pseq(~snareSeq, inf));
			Pdefn(\seqHihat, Pseq(~hihatSeq, inf));
			Pdefn(\seqClap,  Pseq(~clapSeq, inf));
		});
	});
}, "/seqLenght");
)
