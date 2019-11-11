s.boot; // boot server first!

({
'...Allocating Busses...'.postln;
	~bus = Bus.audio(s, 2); // declares stereo ~bus, first 2 available
	~bus2 = Bus.audio(s, 2); // declares stereo ~bus, second 2 available
	s.sync;
'...Declaring SynthDefs...'.postln;
	(//Def for input signal
		SynthDef.new(\sigin, {
			arg dryVol = 0.5;
			var sig, sigDry;
			sig = SoundIn.ar(0!2); //sound comes in through interface, multichannel expansion
			sigDry = SoundIn.ar(0!2, dryVol); // for a way to mix in Dry sig
			Out.ar(~bus, sig);
			Out.ar(0, sigDry); //sends to reg output
		}).add;
	);
	( //Def for pitch shift up factor of a third
		SynthDef.new(\pitch1, {
			arg vol = 1;
			var sig;
			sig = In.ar(~bus, 2); //audio signal in from ~bus
			sig = PitchShift.ar(sig, 0.2, 1.25, mul:vol);//shift signal up 1.25
			Out.ar(~bus2, sig); //send to ~bus2 for FX
		}).add;
	);
	(//Def for pitch shift up factor of a fifth, uncommented bc functionality is same as Synth b
		SynthDef.new(\pitch2, {
			arg vol = 1;
			var sig;
			sig = In.ar(~bus, 2);
			sig = PitchShift.ar(sig, 0.2, 1.50, mul:vol); //only difference from other pitch shift synth, up 1.5 this time
			Out.ar(~bus2, sig);
		}).add;
	);
	(// Def for Granulation, Delay, and Verb of ~bus2, FX!!!
		SynthDef.new(\grainandpitch, {
			arg dens = 8, grainSize = 0.5, delayTime, feedback = 10;
			var sig, trig;
			sig = In.ar(~bus2, 2); //audio sig from ~bus2
			trig = Dust.kr(dens); //random dust, with density of "8"

			sig = GrainIn.ar(2, trig, grainSize, sig); //granulator

			sig = CombL.ar(sig, 5, delayTime.lag(1), feedback);
			sig = FreeVerb.ar(sig, 0.7, 0.8);
			sig = Pan2.ar(sig, LFNoise1.ar(15)); //random panning
			Out.ar(0, sig);
		}).add;
	);
	s.sync;
'...Managing GUI...'.postln;
( //  all GUI / views
Window.closeAll;
w = Window.new("controls", Rect(5000, 5000, 530, 200));
w.front;
w.alwaysOnTop = true;
w.background = Color.new(0, 0.6, 0.8, 1);
~title = StaticText(w, Rect(10, 1, 500, 50))
.string_("Control Interface - Granular Pitch Shifter")
.font_(Font("Helvetica", 25));

~knobSize = Knob(w, Rect(10, 50, 50, 50))
.action_({
	arg obj;
	var grainSize;
	grainSize = obj.value.linexp(0, 1, 0.01, 2); //scales value from default (0.- 1.) to more approapriate range (0.01 - 2)
	if(                                          //if Synth d is playing, set arg grain size to ~knobSize value
		d.isPlaying,
		{d.set(\grainSize, grainSize)
	});
});

~grainSizeText = StaticText.new(w, Rect(6, 100, 100, 100))
	.string = "Grain Size";

~knobVolb = Knob(w, Rect(100, 50, 50, 50))  //volume knob for 3rd pitch shift!
.action_({
	arg obj;
	var volContr;
	volContr = obj.value;
	if(
		b.isPlaying,
		{b.set(\vol, volContr)
	});
});

~thirdShiftText = StaticText.new(w, Rect(84, 100, 100, 100))
	.string = "P.Shift 3rd Vol";

~knobVolc = Knob(w, Rect(200, 50, 50, 50))  //volume knob for 5th pitch shift!
.action_({
	arg obj;
	var vol5Contr;
	vol5Contr = obj.value;
	if(
		c.isPlaying,
		{c.set(\vol, vol5Contr)
	});
});

~fifthShiftText = StaticText.new(w, Rect(185, 100, 100, 100))
	.string = "P.Shift 5th Vol";

~knobDryVol = Knob(w, Rect(450, 50, 50, 50))  //dry volume knob
.action_({
	arg obj;
	var dryVolContr;
	dryVolContr = obj.value;
	if(
		a.isPlaying,
		{a.set(\dryVol, dryVolContr)
	});
});

~dryVolumeText = StaticText.new(w, Rect(443, 100, 100, 100))
	.string = "Dry Volume";

~knobDelayTime = Knob(w, Rect(365, 50, 50, 50)) //delay time knob
.action_({
	arg obj;
	var delayTimeContr;
	delayTimeContr = obj.value.linexp(0, 1, 0.1, 2); //.linexp sets to more appropraite range - 0.1s to 2s
	if(
		d.isPlaying,
		{d.set(\delayTime, delayTimeContr)
	});
});

~delayTimeText = StaticText.new(w, Rect(361, 100, 100, 100))
     .string = "Delay Time";

~knobFeedback = Knob(w, Rect(285, 50, 50, 50))
.action_({
	arg obj;
	var feedbackContr;
	feedbackContr = obj.value.linexp(0, 1, 1, 20); // more apprpraite fb range
	if(
		d.isPlaying,
		{d.set(\feedback, feedbackContr)
	});
});

~feedbackText = StaticText.new(w, Rect(285, 100, 100, 100))
		.string = "Feedback";
);
	s.sync;
'...Calling Synths...'.postln;
	( //Synth for input signal
		a = Synth.new(\sigin,
			[\dryVol, ~knobDryVol.value]).register;
	);
	( //Synth for pitch shift up by a third
		b = Synth.new(\pitch1,
			[\vol, ~knobVolb.value // vol knob control set
		],addAction:'addToTail').register;
	);
	(//Synth for pitch shift up by fifth
		c = Synth.new(\pitch2,
			[\vol, ~knobVolc.value //5th p. shift vol knob
		], addAction:'addToTail').register;
	);
	( // d = Synth for "grainandpitch" def
		d = Synth.new(\grainandpitch,
	[\grainsize, ~knobSize.value.linexp(0, 1, 0.01, 2),   //all knobs for FX controls, Grain Size, Delay Time, Feedback
	 \delayTime, ~knobDelayTime.value.linexp(0, 1, 0.1, 2),
	 \feedback, ~knobFeedback.value.linexp(0, 1, 1, 20),
		], addAction:'addToTail').register;
	);
	s.sync;
	s.plotTree;
	s.meter;
}.fork(AppClock)
)//here!