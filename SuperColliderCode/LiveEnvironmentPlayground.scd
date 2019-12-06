//basics ==================================================================================

s.boot;

//fork zone ==================================================================================
({
	'Allocating Busses'.postln;
	(~bus = Bus.audio(s, 2));
	s.sync;
	'Declaring SynthDefs'.postln;
(
SynthDef.new(\chordaldrone, {
	arg freq = 100, freqTrd = 200, freqUp = 300, atk = 0.5, seg2 = 0.3, rel = 0.5, detune=0.2, rate = 5, cfhzmin=0.1, cfhzmax=0.3, cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2;
	var sig, sigTrd, sigUp, sigBus, env;
	sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);
	env = EnvGen.kr(Env(
		[0, 0.8, 0.5, 0],
		[atk, seg2, rel],
	), doneAction: 2);
	sigBus = sig;
	sigBus = sigBus*env;
	Out.ar(~bus, sigBus);
	Out.ar(0, sigBus);
}).add;
);

(
SynthDef.new(\sineDroner, {
	arg freq = 100, freqTrd = 200, freqUp = 300, atk = 2, rel = 1;
	var sig, sigTrd, sigUp, sigBus, env;
	// sig = SinOsc.ar(freq);
	sig = SinOsc.ar(exprand(200, 500).postln);
	sigTrd = SinOsc.ar(freq*(exprand(1.25, 1.5).postln));
	sigUp = SinOsc.ar(freq*(exprand(2, 2.5).postln));
	sigBus = sig+sigTrd+sigUp*0.3;
	env = EnvGen.kr(Env(
		[0, 0.8, 0.5, 0],
		[atk, 0.3, rel],
	), doneAction: 2);
	sigBus = sigBus*env;
	sigBus = Pan2.ar(sigBus, 0);
	Out.ar(~bus, sigBus);
	Out.ar(0, sigBus);
}).add;
);

(
SynthDef.new(\phaseMod, {
	arg freq = 400, modfreq = 100, filt = 500, atk = 1, rel = 1;
	var sig, env;
	sig = PMOsc.ar(freq, modfreq)!2;
	env = EnvGen.kr(Env(
		[0, 0.05, 0],
		[atk, rel],
	), doneAction: 2);
	sig = sig*env;
	sig = LPF.ar(sig, filt);
	sig = HPF.ar(sig, 25);
Out.ar(0, sig);
Out.ar(~bus, sig);
}).add;
);

(
SynthDef.new(\strongPluck, {
	arg maxDelTim = 0.2, delTim = 0.2, speed = 10, amp = 0.5;
	var sig;
	sig = Pluck.ar(WhiteNoise.ar(0.4), LFNoise0.kr(speed), maxDelTim, delTim, 15, 0.7, mul:2);
	sig = Pan2.ar(sig, 0);
	sig = sig*amp;
	Out.ar(~bus, sig);
}).add;
);

(
SynthDef.new(\FX, {
	arg delTime = 3, fdBack = 15, shiftDepth = 2, shiftDisp = 0.1;
	var sig;
	sig = In.ar(~bus, 2);
	sig = PitchShift.ar(sig, 0.2, shiftDepth, shiftDisp);
	sig = CombL.ar(sig, 5, delTime.lag(10), fdBack);
	sig = FreeVerb.ar(sig, 0.5, 0.5, 0.5);
	sig = HPF.ar(sig, 50);
	Out.ar(0, sig);
}).add;
);

s.sync;

f = Synth.new(\FX);

s.sync;

s.plotTree;
s.meter;

}.fork(AppClock);
) // run here for initiation ==================================================================================

// Patts ==================================================================================

// Saw Chord Drone =================================================================================

(
Pdef(\chordaldrone,

	Pbind(
	\instrument, \chordaldrone,
		\dur, Pwhite(4.5,7.0, inf),
	\midinote, Pxrand([
		[23, 35, 54, 63, 64],
		// [45, 52, 54, 59, 61, 64],
		[28, 40, 47, 56, 59, 63]+5,
		[42, 52, 57, 61, 63]-12,
	], inf),
	\detune, Pexprand(0.05, 0.2, inf),
	\cfmin, 100,
	\cfmax, 1500,
	\rqmin, Pexprand(0.01, 0.15, inf),
	\atk, Pwhite(2.0, 2.5, inf),
	\rel, Pwhite(6.5, 10.0, inf),
	\ldb, 6,
	\amp, 0.2,

)).stop;
)

// saw filt hits ==================================================================================

(
Pdef(\bip,

	Pbind(
	\instrument, \chordaldrone,
	\dur, Prand([1,0,5], inf),
	\freq, Prand([1/2, 2.3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5, 1, 2, 4], inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008, 1.025, inf),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 1,
	\out, 0,
)).stop;
)

//phase mod ==================================================================================

(
Pdef(\phaseDef,

	Pbind(
	\instrument, \phaseMod,
	\modfreq, 40,
	\midinote, Pxrand([42, 52, 57, 61, 63]+3, inf),
	\dur, Pwhite(0.1, 1, inf),
	\atk, Pwhite(2.5, 4, inf),
	//\midinote, Prand([74, 67], inf),
	\filt, 500,
	\rel, Pwhite(3, 5, inf),

)).stop;
)

// Sine Whelm =============================================================================

(
Pdef(\sineWhelm,

    Pbind(
	\instrument, \sineDroner,
	\atk, Pwhite(2, 5, inf),
	\freq, Prand([100, 200, 300], inf),
	\rel, Pwhite(2, 5, inf),

)).stop;
)

//statics ==================================================================================

//plucked string ==================================================================================

(
a = Synth.new(\strongPluck, [
	\maxDelTim, 440.reciprocal,
	\delTim, 440.reciprocal,
	\speed, 1
]
)) // here

a.set(\maxDelTim, 220.reciprocal, \amp, 0.1)
a.set(\delTim, exprand(0.002, 0.02).postln)
a.set(\maxDelTim, 400.reciprocal, \speed, 20)

a.free

// fx edits ==================================================================================

(f.set(\delTime, 0.1, \fdBack, 10))
f.set(\shiftDepth, 3)
f.set(\shiftDisp, 0.1)

