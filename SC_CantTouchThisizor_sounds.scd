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

SynthDef(\snare, {
    |out = 0, pan = 0, amp = 0.3|
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
    |out = 0, pan = 0, amp = 0.3|
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
    |out = 0, amp = 0.5, pan = 0, dur = 1|
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

(
var base;

base = Pbind(\amp, 0.3);

Ppar([
    Pbindf(
        base,
        \instrument, Pseq([\kick, \snare, \kick, \kick, \snare], inf),
        \dur, Pseq([4, 3, 3, 2, 4], inf)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\hihat, 16), Pn(\clap, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    )
]).play(TempoClock(2.3 * 4));
)



//////////////////////////////////////////////////////////////////////////




(
{ | dur = 0.15, atk = 0.005, amp = 1 |
	SinOsc.ar(
		EnvGen.ar( Env(
			NamedControl.kr(\freq_l, [2960, 70, 90]),
			NamedControl.kr(\freq_d, [0.07, 0.2]),
			NamedControl.kr(\freq_c, [-13, -1]),
		) ),
		mul:amp * EnvGen.ar(
			Env.perc( atk, dur - atk, curve: NamedControl.kr(\amp_c, [-1, 6])),
			doneAction: 2
		);
	) ! 2;
}.asSynthDef.name_("kick").add;

{ | atk = 0.01, dur = 0.15, freq = 50, amp=0.8 |
	BPF.ar(LFSaw.ar(freq), freq, 2, mul: EnvGen.kr( Env.perc( atk, dur-atk, amp, 6 ), doneAction: 2 )) ! 2;
}.asSynthDef.name_("bass").add;

{ | dur = 0.15, freq = 50, amp = 0.8, index = 10 |
	PMOsc.ar(freq, freq + 5, index, mul: amp * EnvGen.kr( Env.triangle( dur ), doneAction: 2 )) ! 2;
}.asSynthDef.name_("bazz").add;
)


(
Ppar([
	/*Pbind(*[
		instrument: \kick,
		delta: 1,
		dur: Pfunc({ thisThread.clock.beatDur }) / 4,
		amp: Pseq([
			Pseq([1], 16),
			Pseq([0.8, 1], 8),
			Pseq([1], 16),
			Pseq([0.8, 0.8, 0.9, 1], 8)
		], inf) * 0.8,
		freq_l: Pstutter(Prand(2.pow((1..4)),inf), Pseq([
			`[2960,70,90],
			`[1260,60,110],
			`[4360,60,120]
		],inf))
	]),*/
	Pbind(*[
		instrument: \bass,
		delta: 1/4,
		dur: Pkey(\delta) * Pfunc({ thisThread.clock.beatDur }),
		freq: Pseq([70, 50,60,70], inf),
		amp:0.6
	]),
	Pbind(*[
		instrument: \bazz,
		delta: 1/4,
		dur: Pkey(\delta) * Pfunc({ thisThread.clock.beatDur }),
		freq: Pseq([100,50,60,40], inf),
		amp:0.2
	])
]).play(TempoClock(156/60), quant:[1])
)

// kick from above?
(
Pbind(*[
	instrument: \kick,
	delta: Pseq(Array.geom(540, 1, 1.015).reciprocal.reverse),
	dur: Pkey(\delta) * Pfunc({ thisThread.clock.beatDur }),
	atk: Pkey(\dur) / 6,
        amp: 0.8
]).play;
)