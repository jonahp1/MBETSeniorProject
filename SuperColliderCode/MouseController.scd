s.boot

({
	'Buffer Allocation and Bus Assign'.postln;
	b = Buffer.alloc(s, 2048);
	s.sync;
	~bus1 = Bus.audio(s, 2);
	s.sync;

	'Declaring SynthDefs'.postln;
(
SynthDef.new(\wt, {
	var sig, env, amps, wt;
	sig = SinOsc.ar(MouseX.kr(100, 1000, 1));
	Out.ar(~bus1, sig);
}).add;
);

(// Def for Granulation, Delay, and Verb of ~bus1
SynthDef.new(\grainandpitch, {
	arg dens = 8, grainSize = 0.05, delayTime = 1;
	var sig, trig;
	sig = In.ar(~bus1, 2);
	trig = Dust.kr(dens);
	sig = PitchShift.ar(sig, 0.2, 1.25);
	sig = PitchShift.ar(sig, 0.2, 1.5);
	sig = GrainIn.ar(2, trig, MouseY.kr(0.01, 1), sig);
	sig = CombL.ar(sig, 5, delayTime, 1);
	sig = FreeVerb.ar(sig, 0.7, 0.8);
	sig = Pan2.ar(sig, LFNoise1.ar(15));
	Out.ar(0, sig);
	Out.ar(1, sig);
}).add;
);

s.sync;

	'Calling Synths'.postln;

h = Synth.new(\wt);

(
i = Synth.new(\grainandpitch,
addAction: 'addToTail');
);

s.sync;

	'Pulling Up Tree and Meter'.postln;

s.plotTree;
s.meter;

}.fork(AppClock);
)

(
h.free;
i.free
); // free WT Mouse

s.freeAll
