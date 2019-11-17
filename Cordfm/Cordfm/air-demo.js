//
// air-demo.js
// libhypno
//
// Created by Jacob Sologub on 16 Oct 2019 4:20:00pm
// Copyright © 2019 Jacob Sologub. All rights reserved.

import { Asset, Time, TimeRange, Clip, Transform } from 'hypno';
import * as coreimage from 'hypno/coreimage';
import { Image, Filter, Kernel } from 'hypno/coreimage';

const cameraAsset = argv [1] [0];
const musicAsset = new Asset ("./music-loop.mp3");
const overlayAsset = new Asset ("./hypno-logo.mp4");
const lightAsset = new Asset ("./light-leaks.mp4");

Time.timescale = 30;
const musicDuration = Time.convertScale (musicAsset.duration);
const clipDuration = new Time (musicDuration.value / 8);

const TrackIDs = {
    Camera: "camera",
    Logo: "logo",
    Light: "light",
    Music: "music"
};

const lightTrack = composition.track (TrackIDs.Light);
const lightClip = lightAsset.clip (TimeRange (new Time (0), new Time (clipDuration.value * 4)));

lightTrack.add (lightClip);
lightTrack.add (lightClip);

const logoTrack = composition.track (TrackIDs.Logo);
logoTrack.add (overlayAsset.clip (TimeRange (new Time (0), clipDuration)), new Time (clipDuration.value * 7));

const cameraTrack = composition.track (TrackIDs.Camera);
const infos = [
    { timeRange: new TimeRange (new Time (0), new Time (clipDuration.value / 2)), shouldScale: true },
    { timeRange: new TimeRange (new Time (30), new Time (clipDuration.value / 2)), shouldScale: true },
    { timeRange: new TimeRange (new Time (0), clipDuration), shouldScale: false },
    { timeRange: new TimeRange (new Time (30 * 2), new Time (clipDuration.value)), shouldScale: false },
];

for (const i of [0, 1, 2, 3, 1, 0, 3, 2]) {
    const info = infos [i % infos.length];
    const clip = cameraAsset.clip (info.timeRange);
    cameraTrack.add (info.shouldScale ? clip.scaled (clipDuration) : clip);
}

const musicTrack = composition.track (TrackIDs.Music, "audio");
musicTrack.add (musicAsset.clip (TimeRange (new Time (0), new Time (clipDuration.value * 8))));

composition.frameDuration = new Time (1, 60);

composition.renderSize = cameraAsset.size;

composition.render = function (context) {
    const instruction = context.instruction;
    const instructionProgress = (instruction.time.value / instruction.timeRange.duration.value);
    const pulse = instructionProgress - Math.trunc (instructionProgress);

    let frameA = context.frames [TrackIDs.Camera];
    let frameB = frameA.clone();

    if (instruction.index % 2 == 1  && instruction.index < 7 && (pulse >= 0.46 && pulse < 0.76)) {
        const s = 1.0 + easeOutQuad ((pulse - 0.46) * 5);
        const tx = -(s - 1.0) * (cameraAsset.width / 2);
        const ty = -(s - 1.0) * (cameraAsset.height / 2);

        const t1 = Transform.scale (s, s).concatenated (Transform.translation (tx, ty));
        frameB = frameB.transformed (t1);

        const brightness = -0.25 + Math.pow ((pulse - 0.46) * 5, 2.0);
        const colorFilter = new Filter (coreimage.ColorControls, {
            inputBrightness: brightness,
            inputImage: frameB
        });
        
        frameB = colorFilter.apply();

        const screen = new Filter (coreimage.MinimumCompositing, {
            inputBackgroundImage: frameB,
            inputImage: frameA
        });

        frameA = screen.apply();
    }

    const colorFilter = new Filter (coreimage.CIColorControls, {
        inputSaturation: 0.0,
        inputContrast: 1.25,
        inputBrightness: -0.1,
        inputImage: frameA
    });

    frameA = colorFilter.apply();

    let lightFrame = scaleAndFillFrame (context.frames [TrackIDs.Light]);

    const screen = new Filter (coreimage.ScreenBlendMode, {
        inputBackgroundImage: frameA,
        inputImage: lightFrame
    });

    frameA = screen.apply();

    if (instruction.index == 7 ) {
        const s = 1.5;
        const tx = -(s - 1.0) * (cameraAsset.width / 2);
        const ty = -(s - 1.0) * (cameraAsset.height / 2);

        const t1 = Transform.scale (s, s).concatenated (Transform.translation (tx, ty));
        frameA = frameA.transformed (t1);

        if (instructionProgress < 0.25) {
            const colorFilter = new Filter (coreimage.ColorControls, {
                inputBrightness: 0.0 - instructionProgress,
                inputImage: frameA
            });

            frameA = colorFilter.apply();
        }
        else {
            const colorFilter = new Filter (coreimage.CIColorControls, {
                inputBrightness: -0.25,
                inputImage: frameA
            });

            frameA = colorFilter.apply();
        }

        let logoFrame = scaleAndFillFrame (context.frames [TrackIDs.Logo]);

        const screen = new Filter (coreimage.ScreenBlendMode, {
            inputBackgroundImage: frameA,
            inputImage: logoFrame
        });

        frameA = screen.apply();
    }

    const warpKernel = new Kernel ("./warp.cikernel");

    if (instruction.index == 2) {
        frameA = warpKernel.apply (frameA, easeOutQuad (instructionProgress), 0.53, 1.0);
    }
    else if (instruction.index == 7) {
        frameA = warpKernel.apply (frameA, easeOutQuad (instructionProgress), 24.67, 1.5);
    }

    context.frames [TrackIDs.Camera] = frameA;
};

function easeOutQuad (t) { return t * (2 - t) }
function easeInOutQuad (t) { return t < .5 ? 2 * t * t : -1 + (4 - 2 * t) * t }

function scaleAndFillFrame (frameToScale) {
    if (frameToScale.size.y != cameraAsset.size.y) {
        const scale = cameraAsset.size.y / frameToScale.size.y;
        const t1 = Transform.scale (scale, scale);

        const newW = frameToScale.size.x * scale;
        const newH = frameToScale.size.y * scale;
        const newX = (cameraAsset.size.x - newW) * 0.5;
        const newY = (cameraAsset.size.y - newH) * 0.5;

        const t2 = Transform.translation (newX, newY);
        return frameToScale.transformed (Transform.concat (t1, t2));
    }

    return frameToScale;
}
