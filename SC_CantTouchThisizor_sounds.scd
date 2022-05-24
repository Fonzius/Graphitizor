s.boot;


//////////////////////////////////////// DRUMS //////////////////////////////////////////////////

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


//////////////////////////////////////// SYNTHS //////////////////////////////////////////////////


(
SynthDef("bass", { arg freq = 440, amp = 0.5, gate = 1;
	var snd, env, oscfreq, output;
	oscfreq = {freq * LFNoise2.kr(0.5).range(0.98, 1.02)}!3;
	snd = Splay.ar(LFSaw.ar(oscfreq, mul: amp));
	env = Env.adsr(0.7, 4, 0, 0.1).kr(doneAction:2, gate: gate);
	snd = snd;
	output = LPF.ar(snd, (env*freq) + 2*freq);
	Out.ar(0, output);
	}).add;
)

(
SynthDef(\rhodey_sc, {
    |
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    // all of these range from 0 to 1
    vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1
    |
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

    // using the doneAction: 2 on the other envs can create clicks (bc of the linear curve maybe?)
    snd = snd * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;
)

Synth.new(\rhodey_sc)

(
SynthDef(\moogpluck, {arg outbus=0, freq=440, filter=3, amp=1,coef=0.5,dur=2,legato=1,mix=0,pan=0;
	var pluck,moog,noteOff,out;
	pluck =	Pluck.ar(PinkNoise.ar,1,0.2,freq.reciprocal,dur*legato,coef);
	moog = MoogFF.ar(pluck, (freq*filter),2);
	out = SelectX.ar(mix,[LPF.ar(pluck,2500),moog]);
	noteOff = DetectSilence.ar(out,doneAction:2);
	Out.ar(outbus, Pan2.ar(out,pan));
}).add;
)

(
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
)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

(
SynthDef(\violin, {
	| midinote=60, gate=1, amp=0.25 |
	var env = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction:2);
	var sig = VarSaw.ar(
		midinote.midicps,
		width:LFNoise2.kr(1).range(0.2, 0.8)*SinOsc.kr(5, Rand(0.0, 1.0)).range(0.7,0.8))*0.25;
	sig = sig * env * amp;
	Out.ar(0, sig!2);
}).add;
)

(
synth = SynthDef(\luce, {
	|out = 0, freq = 440, amp = 0, amount = 24|
	var snd;

	snd = Resonz.ar( Saw.ar(freq), amount, 0.2 ); // Change this mul: variable if you want to increase the max amplitude of the synth, but go easy on it because you could easily harm your ears !

	Out.ar(out, Pan2.ar(snd, 0, amp));
}).play;
)

(
SynthDef(\MoaningDialogue, {
	|rateL = 0.2, rateR = 0.3, freq = 2, feedback = 50, mul = 1 , lpfreq = 2500|
	Out.ar(0,
		FreeVerb.ar(
			BLowPass.ar(
				SinOscFB.ar(
					LFDNoise1.kr([rateL, rateR], freq), feedback;
				, mul),
				lpfreq,
				0.2
			),
			0.3,
			0.0
		)
	)}
).add
)

(
SynthDef(\SoundCheck, {|seconds = 7|
	var sin1 = SinOsc.kr([110, 90], 0, [440, 330]);
	var sin2 = SinOsc.kr(1, 0, 5, 105);
	var sinModDepth = SinOsc.kr(0.01, 0, 10) * SinOsc.ar(0.00033, 0, 1000); //Magic number for 7 seconds
	var sinMod = (sin1 + sin2) * sinModDepth;
	var ampMod = SinOsc.kr(0.1, 0, 0.5, 1) * SinOsc.kr(1, 0, 0.5, 1);
	var sinLine = SinOsc.ar(Line.kr(40, 10, seconds););
	var sum = SinOsc.ar(sinMod, 0, ampMod).distort;
	var comb1 = (CombL.ar(sum, 0.01, 0.005, 1) + sum) * sinLine;
	var comb2 = (comb1 + (CombL.ar(comb1, 0.008, 0.007, 0.5) * 0.4));
	var clip1 = comb2.clip2(1) * 0.8;
	var env = EnvGen.ar(Env.linen(0.1, seconds - 0.2, 0.1), doneAction:2);
	var output = (clip1 * SinOsc.ar(40) * SinOsc.ar(456)) * env;
	Out.ar(0, output * 0.5);
}).add;
)

(
SynthDef("spacey", { arg freq, amp;
	var snd, env;
	env = Env.perc(level: amp).kr(2);
	snd = LFSaw.ar(freq: freq, mul: env);
	snd = RLPF.ar(
		in: snd,
		freq: LFNoise1.kr(2).range(500, 20000),
		rq: 0.2
	);
	Out.ar(0, snd);
}).add;
)

(
SynthDef(\fm7_timpani,
{
    arg  note = 60,out_bus=0,amp=0.5,sustain = 2,release = 0.5,cutoff = 10000,rq = 1,pan = 0,lfo_speed = 5,lfo_amp = 0;
	var ctls, mods, chans,out,pitch,gate,

        envAmp1,envAmp2,envAmp3,envAmp4,envAmp5,envAmp6,env1,
		envEnv1,envEnv2,envEnv3,envEnv4,envEnv5,envEnv6,envAmp,envEnv,lfo;

        gate = Trig1.kr(1, sustain + release);

		envEnv1 = Env.new([0 ,1.0 ,0 ,0 ,0], [0.0008 ,sustain ,0.0 ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp1 = EnvGen.kr(envEnv1,gate,doneAction: 0);

		envEnv2 = Env.new([0 ,0.3535 ,0 ,0 ,0], [0.0005 ,0.0829 ,0.0 ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp2 = EnvGen.kr(envEnv2,gate,doneAction: 0);
        envEnv3 = Env.new([0 ,0.2985 ,0.029 ,0 ,0], [0.0005 ,0.0136 ,sustain ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		//envEnv3 = Env.new([0 ,0.2985 ,0.029 ,0 ,0], [0.0005 ,0.0136 ,12.8286 ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp3 = EnvGen.kr(envEnv3,gate,doneAction: 0);
        envEnv4 = Env.new([0 ,0.6332 ,0.0797 ,0 ,0], [0.0006 ,2.057 ,sustain ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		//envEnv4 = Env.new([0 ,0.6332 ,0.0797 ,0 ,0], [0.0006 ,2.057 ,37.2485 ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp4 = EnvGen.kr(envEnv4,gate,doneAction: 0);

		envEnv5 = Env.new([0.0 ,0.1151 ,0.0 ,0.0 ,0.0], [0.0003 ,1.0517 ,0.0 ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp5 = EnvGen.kr(envEnv5,gate,doneAction: 0);

		envEnv6 = Env.new([0.0 ,0.1055 ,0.0 ,0.0 ,0.0], [0.0004 ,215.6751 ,0.0 ,0.0], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp6 = EnvGen.kr(envEnv6,gate,doneAction: 0);

        envEnv = Env.new([0,1,1,0], [0.0001,sustain,release],[0,0,0]);
		envAmp = EnvGen.kr(envEnv,gate,doneAction:2);

		lfo = LFTri.kr(lfo_speed);
		lfo = LinLin.ar(lfo, 0, 1, lfo_amp.neg.midiratio  , lfo_amp.midiratio);


        pitch = note.midicps;

   ctls = [
		    [0.5 * 1 * (pitch  + ((7-7)/32))* lfo, 0, envAmp1],

		    [0.5 * 1 * (pitch  + ((10-7)/32))* lfo , 0, envAmp2],

		    [0.5 * 1.36 * (pitch  + ((4-7)/32))* lfo , 0, envAmp3],

		    [0.5 * 1.75 * (pitch  + ((7-7)/32))* lfo , 0, envAmp4],

		    [0.5 * 1 * (pitch  + ((7-7)/32))* lfo , 0, envAmp5],

		    [0.5 * 1.56 * (pitch  + ((7-7)/32))* lfo, 0, envAmp6]
	];

	mods = [
		[0, 12.5664, 12.5664, 0, 12.5664, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 12.5664, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 12.5664],
		[0, 0, 0, 0, 0, 5.5418]
	];
	chans = [0, 1, 2, 3, 4, 5];
	out = FM7.ar(ctls, mods).slice(chans) * -12.dbamp;
	out = Mix.new([
		(out[0] * 1),
		(out[1] * 0),
		(out[2] * 0),
		(out[3] * 0),
		(out[4] * 0),
		(out[5] * 0),
	]);
	out = RLPF.ar(out,cutoff,rq);
	Out.ar(out_bus,Pan2.ar(out,pan,amp));
}).add;
)


Synth(\fm7_timpani);
Synth(\fm7_timpani,[\sustain,5,\release,0.1,\amp,0.5,\lfo_speed,5,\lfo_amp,0.05]);


(
SynthDef(\tar, {
	|
	out = 0, in = 0, inscale = 1.0, freq = 440, bw = 1.03, amp = 0.5
	pos = 0.1,
	hc1 = 1, hc3 = 30, hfreq = 3000,
	vc1 = 1, vc3 = 30, vfreq = 3000
	|
	var inp, jawari, snd;
	// Input audio -- may be a pluck impulse (chikari) or audio (tarafdar)
	inp = In.ar(in, 1) * inscale;
	// Jawari (bridge) simulation. This is the heart of Ronan's model.
	// Violins and guitars have vertical bridges. The jawari is flat, and this causes the tar to buzz against the jawari.
	// Physically, end of the string coming in contact the bridge causes the string to shorten.
	// We assume that the audio output is a reasonable approximation of how much contact the string has with the bridge.
	// So we shorten the DWG (by adjusting its frequency) according to its own audio output.
	jawari = LocalIn.ar(1);
	// Make the jawari control rate
	jawari = A2K.kr(jawari);
	// Make the jawari affect the freq exponentially
	jawari = jawari.linexp(-1, 1, bw.reciprocal, bw);
	// The string itself has horizontal and vertical planes, which we simulate with two different DWGPlucked instances
	snd = [
		DWGPlucked.ar(freq * jawari, pos: pos, c1: hc1, c3: hc3, inp: LPF.ar(inp, hfreq)),
		DWGPlucked.ar(freq * jawari, pos: pos, c1: vc1, c3: vc3, inp: LPF.ar(inp, vfreq))
	].sum;
	LocalOut.ar(snd);
	Out.ar(out, snd * amp);
}).add;

SynthDef(\pluckImpulse, {
	|out = 0, t_trig = 0, amp = 0.3|
	Out.ar(out, PinkNoise.ar * EnvGen.kr(Env.perc(0.01, 0.02), t_trig) * amp);
}).add;

// Useful for testing. For programmatic usage use \pluckImpulse
SynthDef(\mousePluck, {
	|out = 0, num = 0, amp = 0.3|
	var m = MouseY.kr(0, 8);
	var trig = (num <= m) & (m < (num + 1)) * MouseButton.kr(0, 1, 0);
	Out.ar(out, HPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.03, 0.5), trig) * amp);
}).add;

SynthDef(\sitar, {
	|out = 0, chikari = 0, tarafdar = 0, dry = 0.5, wet = 0.5, amp = 0.5|
	var snd = In.ar(chikari, 1) * dry;
	var lfo;
	snd = snd + (In.ar(tarafdar, 1) * wet);
	// Dumb gourd model. I randomly picked lope only transitions to the release node when released. Examples are below. Tfreqs/bws/amps.
	// Please let me know if you have some estimates of the resonances of a real sitar gourd.
	snd = snd + BPF.ar(snd, [90, 132, 280], [1.3, 0.9, 1.4], [0.9, 0.6, 0.7]).sum;
	snd = Pan2.ar(GVerb.ar(0.3*snd, roomsize:1, damping:0.7), 0, amp);
	Out.ar(out, snd);
}).add;
)








