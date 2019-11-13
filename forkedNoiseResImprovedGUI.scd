s.boot;

({

'...Allocating Busses...'.postln;
	~bus = Bus.audio(s, 2); // declares stereo ~bus, first 2 available
	~bus2 = Bus.audio(s, 2); // declares stereo ~bus, second 2 available
	s.sync;

'...Declaring SynthDefs...'.postln;
(
(
SynthDef.new(\noise, {
	var sig;
	sig = PinkNoise.ar(10);
	Out.ar(~bus, sig);
}).add;
);

(
SynthDef.new(\filt, {
	arg freq = 440, qFact = 0.0005, subVol = 5;
	var sig;
	sig = In.ar(~bus);
	sig = BPF.ar(sig, freq, 0.0005);
	sig = Resonz.ar(sig, freq, qFact, subVol);
	sig = sig*3;
	Out.ar(~bus2, sig);
}).add;
);

(// Def for Granulation, Delay, and Verb of ~bus2, FX!!!
		SynthDef.new(\effects, {
			arg dens = 8, grainSize = 0.5, delayTime, feedback = 10, vol3 = 0, vol5 = 0, dryVol = 0, shift = 1, disp = 0.01;
			var sig, sigDry, trig;
			sig = In.ar(~bus2, 2); //audio sig from ~bus2
	        sigDry = sig;
	        sigDry = sigDry*dryVol;
			trig = Dust.kr(dens); //random dust, with density of "8"
			sig = GrainIn.ar(2, trig, grainSize, sig); //granulator
			sig = CombL.ar(sig, 5, delayTime.lag(1), feedback);
	        sig = PitchShift.ar(sig, 0.2, shift, disp);
			sig = FreeVerb.ar(sig, 0.7, 0.8);
	        sig = sig+sigDry;
			// sig = Pan2.ar(sig, 0);
			Out.ar(0, sig);
	        Out.ar(1, sig);
		}).add;
	);
);

s.sync;

'...Managing GUI...'.postln;
( //  all GUI / views
Window.closeAll;
w = Window.new("controls", Rect(5000, 5000, 500, 550));
w.front;
w.alwaysOnTop = true;
w.background = Color.new(0, 0.6, 0.8, 1);
~title = StaticText(w, Rect(150, 1, 500, 50))
.string_("Noise Resonator")
.font_(Font("Helvetica", 25));

// views for freq 1 ****************************************************

~knobFreqOne = Knob(w, Rect(10, 50, 50, 50))
.action_({
	arg obj;
	var freqOne;
	freqOne = obj.value.linexp(0, 1, 100, 1000);
	if(
		y.isPlaying,
		{y.set(\freq, freqOne)
	});

~oneNumberBox.value_(obj.value.linexp(0, 1, 100, 1000));
});

~oneNumberBox = NumberBox(w, Rect(10, 300, 50, 20))
.value_(100)
.clipLo_(100)
.clipHi_(1000)
.decimals_(2)
.action_({
	arg obj;
	~knobFreqOne.valueAction_(obj.value.linexp(100, 1000, 0, 1))
});

~freqOneText = StaticText.new(w, Rect(6, 100, 50, 50))
	.string = "Freq 1";

~freqOneVolSlider = Slider(w, Rect(10, 150, 35, 100))
.action_({
	arg obj;
	var freqOneVol;
	freqOneVol = obj.value;
	if( y.isPlaying,
		{y.set(\subVol, freqOneVol)
	});
});

// views for Freq 2 ****************************************************

~knobFreqTwo = Knob(w, Rect(140, 50, 50, 50))
.action_({
	arg obj;
	var freqTwo;
	freqTwo = obj.value.linexp(0 , 1, 100, 1000);
	if(
		z.isPlaying,
		{z.set(\freq, freqTwo)
	});

~twoNumberBox.value_(obj.value.linexp(0, 1, 100, 1000));
});

~twoNumberBox = NumberBox(w, Rect(140, 300, 50, 20))
.value_(100)
.clipLo_(100)
.clipHi_(1000)
.decimals_(2)
.action_({
	arg obj;
	~knobFreqTwo.valueAction_(obj.value.linexp(100, 1000, 0, 1))
});

~freqTwoText = StaticText.new(w, Rect(140, 100, 50, 50))
	.string = "Freq 2";

~freqTwoVolSlider = Slider(w, Rect(140, 150, 35, 100))
.action_({
	arg obj;
	var freqTwoVol;
	freqTwoVol = obj.value;
	if(z.isPlaying,
	{z.set(\subVol, freqTwoVol)
	});
});
// views for Freq 3 ****************************************************

~knobFreqThree = Knob(w, Rect(300, 50, 50, 50))
.action_({
	arg obj;
	var freqThree;
	freqThree = obj.value.linexp(0 , 1, 100, 1000);
	if(
		a.isPlaying,
		{a.set(\freq, freqThree)
	});

~threeNumberBox.value_(obj.value.linexp(0, 1, 100, 1000));
});

~threeNumberBox = NumberBox(w, Rect(300, 300, 50, 20))
.value_(100)
.clipLo_(100)
.clipHi_(1000)
.decimals_(2)
.action_({
	arg obj;
	~knobFreqThree.valueAction_(obj.value.linexp(100, 1000, 0, 1))
});

~freqThreeText = StaticText.new(w, Rect(300, 100, 50, 50))
	.string = "Freq 3";

~freqThreeVolSlider = Slider(w, Rect(300, 150, 35, 100))
.action_({
	arg obj;
	var freqThreeVol;
	freqThreeVol = obj.value;
	if(a.isPlaying,
	{a.set(\subVol, freqThreeVol)
	});
});

// views for Freq 4 ****************************************************

~knobFreqFour = Knob(w, Rect(420, 50, 50, 50))
.action_({
	arg obj;
	var freqFour;
	freqFour = obj.value.linexp(0 , 1, 100, 1000);
	if(
		b.isPlaying,
		{b.set(\freq, freqFour)
	});

~fourNumberBox.value_(obj.value.linexp(0, 1, 100, 1000));
});

~fourNumberBox = NumberBox(w, Rect(420, 300, 50, 20))
.value_(100)
.clipLo_(100)
.clipHi_(1000)
.decimals_(2)
.action_({
	arg obj;
	~knobFreqFour.valueAction_(obj.value.linexp(100, 1000, 0, 1))
});

~freqFourText = StaticText.new(w, Rect(420, 100, 50, 50))
	.string = "Freq 4";

~freqFourVolSlider = Slider(w, Rect(420, 150, 35, 100))
.action_({
	arg obj;
	var freqFourVol;
	freqFourVol = obj.value;
	if(b.isPlaying,
	{b.set(\subVol, freqFourVol)
	});
});

// views for Effects Control *************************************************

~knobDryVol = Knob(w, Rect(420, 400, 50, 50))  //dry volume knob
.action_({
	arg obj;
	var dryVolContr;
	dryVolContr = obj.value;
	if(
		m.isPlaying,
		{m.set(\dryVol, dryVolContr)
	});
});

~dryVolumeText = StaticText.new(w, Rect(415, 450, 100, 50))
	.string = "Dry Volume";

~knobSize = Knob(w, Rect(180, 400, 50, 50))
.action_({
	arg obj;
	var grainSize;
	grainSize = obj.value.linexp(0, 1, 0.01, 2); //scales value from default (0.- 1.) to more approapriate range (0.01 - 2)
	if(                                          //if Synth d is playing, set arg grain size to ~knobSize value
		m.isPlaying,
		{m.set(\grainSize, grainSize)
	});
});

~gSizeText = StaticText.new(w, Rect(175, 450, 100, 50))
	.string = "Grain Size";

~knobDelayTime = Knob(w, Rect(20, 400, 50, 50)) //delay time knob
.action_({
	arg obj;
	var delayTimeContr;
	delayTimeContr = obj.value.linexp(0, 1, 0.1, 2); //.linexp sets to more appropraite range - 0.1s to 2s
	if(
		m.isPlaying,
		{m.set(\delayTime, delayTimeContr)
	});
});

~dTimeText = StaticText.new(w, Rect(10, 450, 100, 50))
	.string = "Delay Time";

~knobFeedback = Knob(w, Rect(100, 400, 50, 50))
.action_({
	arg obj;
	var feedbackContr;
	feedbackContr = obj.value.linexp(0, 1, 1, 20); // more apprpraite fb range
	if(
		m.isPlaying,
		{m.set(\feedback, feedbackContr)
	});
});

~fbkText = StaticText.new(w, Rect(95, 450, 100, 50))
	.string = "Feedback";

~knobShift = Knob(w, Rect(260, 400, 50, 50))
.action_({
	arg obj;
	var shiftContr;
	shiftContr = obj.value.linexp(0, 1, 1, 4); // more apprpraite fb range
	if(
		m.isPlaying,
		{m.set(\shift, shiftContr)
	});
});

~pitchShiftText = StaticText.new(w, Rect(255, 450, 100, 50))
	.string = "Pitch Shift";

~knobDisp = Knob(w, Rect(340, 400, 50, 50))
.action_({
	arg obj;
	var dispContr;
	dispContr = obj.value.linexp(0, 1, 0.01, 10); // more apprpraite fb range
	if(
		m.isPlaying,
		{m.set(\disp, dispContr)
	});
});

~displacementText = StaticText.new(w, Rect(335, 450, 100, 50))
	.string = "Pitch Disp";

);
s.sync;

// Synths in Action **********************************************************************

'...Calling Synths...'.postln;
	(
( // Noise Synth
x = Synth.new(\noise,
	addAction: 'addToHead')
);

( // Synth One
y = Synth.new(\filt,
	[
	\freq, ~knobFreqOne.value.linexp(0, 1, 100, 1000),
	\subVol, ~freqOneVolSlider.value
	],
	addAction:'addToTail').register;
);

( // Synth Two
z = Synth.new(\filt,
	[
	\freq, ~knobFreqTwo.value.linexp(0, 1, 100, 1000),
	\subVol, ~freqTwoVolSlider.value
	],
	addAction:'addToTail').register
);

( //Synth Three
a = Synth.new(\filt,
	[
	\freq, ~knobFreqThree.value.linexp(0, 1, 100, 1000),
	\subVol, ~freqThreeVolSlider.value
	],
	addAction:'addToTail').register
);

( //Synth Four
b = Synth.new(\filt,
	[
	\freq, ~knobFreqFour.value.linexp(0, 1, 100, 1000),
	\subVol, ~freqFourVolSlider.value
	],
	addAction:'addToTail').register
);

(// effects Synth
m = Synth.new(\effects,
	[
		\dryVol, ~knobDryVol.value,
		\grainsize, ~knobSize.value.linexp(0, 1, 0.01, 2),
		\delayTime, ~knobDelayTime.value.linexp(0, 1, 0.1, 2),
		\feedback, ~knobFeedback.value.linexp(0, 1, 1, 20),
		\shift, ~knobShift.value.linexp(0, 1, 1, 4),
		\disp, ~knobDisp.value.linexp(0, 1, 0.01, 10),
	], addAction:'addToTail').register;
	);
);
	s.sync;
	s.plotTree;
	s.meter;
}.fork(AppClock);
)

s.freeAll
