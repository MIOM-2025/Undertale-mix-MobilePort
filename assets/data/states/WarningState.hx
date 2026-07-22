import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.MusicBeatState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxAxes;
import funkin.backend.utils.NativeAPI;

var hintShader = new CustomShader("hintText");

function new() {
    // 进入场景立即隐藏帧率（每次都会执行）
    Framerate.debugMode = 0;

    // 首次运行弹窗，之后不再弹出
    if (FlxG.save.data.FRTS == null) {
        var msg = "非常感谢你游玩我们UNDERTALE MIX的模组移植\n这款移植我打磨了很久，希望你能在哔哩哔哩上的原视频给我一键三连\n本次移植使用一种比较新颖的移植方法\n舍弃了虚拟按键，直接用滑动和手指点击来进行任意的操作\n希望你能获得更好的游戏体验\n如有bug，请在Github上提交建议:\nhttps://github.com/MIOM-2025/Undertale-mix-MobilePort\n或者QQ加群反馈:1067373835\n\nThank you very much for playing our UNDERTALE MIX mod port.\nThis port has been polished for a long time. I hope you can give me a triple-kudos on the original video on Bilibili.\nThis port uses a relatively novel porting method.\nVirtual buttons are abandoned, and you can perform any operation directly by sliding and tapping with your fingers.\nI hope you can get a better gaming experience.\nIf there are bugs, please submit suggestions on Github:\nhttps://github.com/MIOM-2025/Undertale-mix-MobilePort\nOr join the QQ group to report: 1067373835";
        NativeAPI.showMessageBox('Hey!!!', msg);
        FlxG.save.data.FRTS = true;
        FlxG.save.flush();
    }
}

// ---------- 第一屏动画变量 ----------
var miomImages:Array<FunkinSprite> = null;
var hfImages:Array<FunkinSprite> = null;
var hfCharTexts:Array<FlxText> = null;
var cneImage:FunkinSprite = null;
var cyImage:FunkinSprite = null;

// HF 文本参数
var hfTextContent:String = "Haxeflixel";
var hfTextFont:String = "nokiafc22.ttf";
var hfTextSize:Int = 65;
var hfTextColors:Array<Int> = [0xFF00CC33, 0xFFFFCC33, 0xFFFF3366, 0xFF3333FF, 0xFF00CCFF];
var hfTextSpacing:Float = 100;
var hfTextOffsetX:Float = 0;
var hfTextOffsetY:Float = -20;
var hfTextBorderSize:Int = 2;
var hfTextStartScale:Float = 1.0;
var hfTextTargetScale:Float = 0.4;
var charSpacing:Float = 0;

var hfImageStartScale:Float = 0.15;
var hfImageTargetScale:Float = 0.05 * 1.5;

// MIOM 移动参数
var miomMoveUpDistance:Float = 100;
var miomMoveUpDuration:Float = 2;

// HF 目标偏移
var hfImageTargetYOffset:Float = -60;
var hfCharFinalYOffset:Float = 0;
var hfTextHfSpacing:Float = 5;
var cneHfSpacing:Float = 100;

// CY 动画参数
var cyStartScale:Float = 0.01;
var cyTargetScale:Float = 0.05;
var cyStartAlpha:Float = 0;
var cyTargetAlpha:Float = 1;
var cyStartRotation:Float = -45;
var cyTargetRotation:Float = 0;
var cyAnimationDelay:Float = 0.2;
var cyAnimationDuration:Float = 0.8;

// 彩虹滚动
var rainbowTimer:FlxTimer = null;
var rainbowInterval:Float = 0.05;
var rainbowOffset:Int = 0;
var rainbowActive:Bool = false;
var startBlackWhiteTime:Float = 1.0;

// 其他
var hfMoveDelay:Float = 0.8;          // 延长一点，颜色切换稍慢
var cneImageDelay:Float = 0.4;

// -----------------------------------------

function postCreate() {
    vhs = new CustomShader('vhs');
    vhs.range = 0.01;
    vhs.noiseQuality = 10.0;
    vhs.noiseIntensity = 0.0005;
    vhs.offsetIntensity = 0.002;
    vhs.colorOffsetIntensity = 0.32;
    chromatic = new CustomShader("ChromaticAbberation");
    chromatic.amount = 0;
    FlxG.camera.addShader(vhs);
    FlxG.camera.addShader(chromatic);

    disclaimer.visible = false;
    disclaimer.kill();
    titleAlphabet.visible = false;

    // 创建 MIOM 图片（4张）
    miomImages = [];
    var imageNames = ["MIOMPT/MIOM/MIOM1", "MIOMPT/MIOM/MIOM2", "MIOMPT/MIOM/MIOM3", "MIOMPT/MIOM/MIOM4"];
    for (i in 0...imageNames.length) {
        var image = new FunkinSprite().loadGraphic(Paths.image(imageNames[i]));
        add(image);
        image.scale.set(0, 0);
        image.antialiasing = true;
        image.alpha = 0;
        image.updateHitbox();
        miomImages.push(image);
    }

    // 创建 HF 图片（5张）
    hfImages = [];
    var hfImageNames = ["MIOMPT/HF/HF0", "MIOMPT/HF/HF1", "MIOMPT/HF/HF2", "MIOMPT/HF/HF3", "MIOMPT/HF/HF4"];
    for (i in 0...hfImageNames.length) {
        var image = new FunkinSprite().loadGraphic(Paths.image(hfImageNames[i]));
        add(image);
        image.scale.set(hfImageStartScale, hfImageStartScale);
        image.antialiasing = true;
        image.alpha = 0;
        image.updateHitbox();
        hfImages.push(image);
    }

    // 创建 CNE 图片
    cneImage = new FunkinSprite().loadGraphic(Paths.image('MIOMPT/CNE LOGO/cne'));
    add(cneImage);
    cneImage.scale.set(0.5, 0.5);
    cneImage.antialiasing = true;
    cneImage.alpha = 0;
    cneImage.updateHitbox();

    // 创建 CY 图片
    cyImage = new FunkinSprite().loadGraphic(Paths.image('MIOMPT/CY/CY'));
    add(cyImage);
    cyImage.scale.set(cyStartScale, cyStartScale);
    cyImage.antialiasing = true;
    cyImage.alpha = cyStartAlpha;
    cyImage.angle = cyStartRotation;
    cyImage.visible = false;
    cyImage.updateHitbox();

    // 开始 HF 动画
    startHFImagesAnimation();
}

// ========== HF 动画 ==========
function startHFImagesAnimation() {
    var screenWidth = FlxG.width;
    var screenHeight = FlxG.height;

    // 计算字符宽度
    hfCharTexts = [];
    var charWidths:Array<Float> = [];
    var totalCharWidth:Float = 0;
    for (i in 0...hfTextContent.length) {
        var char = hfTextContent.charAt(i);
        var tempText = new FlxText(0, 0, 0, char);
        tempText.setFormat(Paths.font(hfTextFont), hfTextSize, 0xFFFFFFFF);
        var charWidth = tempText.width;
        charWidths.push(charWidth);
        totalCharWidth += charWidth;
        if (i < hfTextContent.length - 1) totalCharWidth += charSpacing;
        tempText.destroy();
    }

    var hfImage = hfImages[0];
    var hfImageWidth = hfImage.width;
    var totalWidth = hfImageWidth + hfTextSpacing + totalCharWidth;
    var hfGroupStartX = (screenWidth - totalWidth) / 2;
    var hfGroupStartY = screenHeight / 2;

    var imageLeft = hfGroupStartX;
    var imageTop = hfGroupStartY - hfImage.height / 2;
    var textLeft = hfGroupStartX + hfImageWidth + hfTextSpacing + hfTextOffsetX;

    // 创建每个字符文本
    var currentX = textLeft;
    for (i in 0...hfTextContent.length) {
        var char = hfTextContent.charAt(i);
        var charText = new FlxText(0, 0, 0, char);
        charText.alpha = 0;
        charText.scale.set(hfTextStartScale, hfTextStartScale);
        charText.updateHitbox();
        charText.x = currentX;
        charText.y = hfGroupStartY - charText.height / 2 + hfTextOffsetY;
        currentX += charWidths[i];
        if (i < hfTextContent.length - 1) currentX += charSpacing;
        add(charText);
        hfCharTexts.push(charText);
    }

    // 设置 HF 图片位置
    for (i in 0...hfImages.length) {
        var image = hfImages[i];
        image.x = imageLeft;
        image.y = imageTop;
    }

    // 依次显示 HF 图片和字符颜色（播放音效同步）
    var totalImages = 5;
    var intervalTime = hfMoveDelay / totalImages;
    for (i in 0...hfImages.length) {
        var image = hfImages[i];
        new FlxTimer().start(i * intervalTime, function(timer:FlxTimer) {
            image.alpha = 1;
            var textColor = hfTextColors[i];
            for (charText in hfCharTexts) {
                charText.setFormat(Paths.font(hfTextFont), hfTextSize, textColor);
                charText.antialiasing = true;
            }
            if (i == 0) {
                FlxG.sound.play(Paths.sound('HF'), 1, false);
                for (charText in hfCharTexts) charText.alpha = 1;
            }
        });
    }

    new FlxTimer().start(hfMoveDelay, function(timer:FlxTimer) {
        startHFMoveAndScaleAnimation();
    });
}

function startHFMoveAndScaleAnimation() {
    var screenWidth = FlxG.width;
    var screenHeight = FlxG.height;

    var hfImage = hfImages[0];
    var originalImageWidth = hfImage.frameWidth;
    var originalImageHeight = hfImage.frameHeight;

    var hfTargetScale = hfImageTargetScale;
    var hfScaledWidth = originalImageWidth * hfTargetScale;
    var hfScaledHeight = originalImageHeight * hfTargetScale;

    var cneImageWidth = cneImage.frameWidth;
    var cneImageHeight = cneImage.frameHeight;
    var cneScale = 0.5;
    var cneScaledWidth = cneImageWidth * cneScale;
    var cneScaledHeight = cneImageHeight * cneScale;

    var totalWidth = cneScaledWidth + cneHfSpacing + hfScaledWidth;
    var centerX = screenWidth / 2;
    var cneTargetX = centerX - totalWidth / 2;
    var hfTargetX = cneTargetX + cneScaledWidth + cneHfSpacing;

    var targetImageY = screenHeight - 150 + hfImageTargetYOffset;
    var hfTargetY = targetImageY - hfScaledHeight / 2;
    var hfCenterY = hfTargetY + hfScaledHeight / 2;
    var cneTargetY = hfCenterY - cneScaledHeight / 2;

    // CY 图片位置
    var cyTargetX = hfTargetX - 50;
    var cyTargetY = (hfTargetY + hfScaledHeight) - (hfScaledHeight / 2);
    var cyImageWidth = cyImage.frameWidth;
    var cyImageHeight = cyImage.frameHeight;
    var cyScaledWidth = cyImageWidth * cyTargetScale;
    var cyScaledHeight = cyImageHeight * cyTargetScale;
    cyTargetX -= cyScaledWidth / 2;
    cyTargetY -= cyScaledHeight / 2;
    cyImage.x = cyTargetX + cyImageWidth/2 * cyTargetScale;
    cyImage.y = cyTargetY + cyImageHeight/2 * cyTargetScale;
    cyImage.visible = true;
    cyImage.scale.set(cyStartScale, cyStartScale);
    cyImage.alpha = cyStartAlpha;
    cyImage.angle = cyStartRotation;
    cyImage.updateHitbox();

    new FlxTimer().start(cyAnimationDelay + 0.2, function(timer:FlxTimer) {
        FlxTween.tween(cyImage.scale, {x: cyTargetScale, y: cyTargetScale}, cyAnimationDuration, {ease: FlxEase.circOut});
        FlxTween.tween(cyImage, {alpha: cyTargetAlpha}, cyAnimationDuration, {ease: FlxEase.circOut});
        FlxTween.tween(cyImage, {angle: cyTargetRotation}, cyAnimationDuration, {ease: FlxEase.circOut});
    });

    cneImage.x = cneTargetX;
    cneImage.y = cneTargetY + 20;
    cneImage.alpha = 0;
    new FlxTimer().start(cneImageDelay, function(timer:FlxTimer) {
        FlxTween.tween(cneImage, {y: cneTargetY, alpha: 1}, 0.8, {ease: FlxEase.quartOut});
    });

    new FlxTimer().start(0.1, function(timer:FlxTimer) {
        startMIOMUpwardAnimation();
    });

    for (i in 0...hfImages.length) {
        var image = hfImages[i];
        var currentWidth = originalImageWidth * hfImageStartScale;
        var currentHeight = originalImageHeight * hfImageStartScale;
        var targetX = hfTargetX + (hfScaledWidth - currentWidth) / 2;
        var targetY = hfTargetY + (hfScaledHeight - currentHeight) / 2;
        FlxTween.tween(image.scale, {x: hfTargetScale, y: hfTargetScale}, 1.0, {ease: FlxEase.quartOut});
        FlxTween.tween(image, {x: targetX, y: targetY}, 1.0, {ease: FlxEase.quartOut});
    }

    if (hfCharTexts != null && hfCharTexts.length > 0) {
        startRainbowScroll();

        var firstChar = hfCharTexts[0];
        var lastChar = hfCharTexts[hfCharTexts.length - 1];
        var textWidth = (lastChar.x + lastChar.width) - firstChar.x;
        var targetTextWidth = textWidth * hfTextTargetScale;

        var hfBottomY = hfTargetY + hfScaledHeight;
        var hfTextTargetY = hfBottomY + hfTextHfSpacing;
        var hfCenterX = hfTargetX + hfScaledWidth / 2;
        var targetTextX = hfCenterX - targetTextWidth / 2;

        var firstCharX = firstChar.x;
        for (i in 0...hfCharTexts.length) {
            var charText = hfCharTexts[i];
            var originalCharWidth = charText.width / hfTextStartScale;
            var originalCharHeight = charText.height / hfTextStartScale;
            var targetCharWidth = originalCharWidth * hfTextTargetScale;
            var targetCharHeight = originalCharHeight * hfTextTargetScale;

            var currentCharX = charText.x;
            var currentCharY = charText.y;
            var charOffsetX = currentCharX - firstCharX;
            var targetCharX = targetTextX + (charOffsetX * hfTextTargetScale);
            var currentCharWidth = originalCharWidth * hfTextStartScale;
            var currentCharHeight = originalCharHeight * hfTextStartScale;
            var targetCharXFinal = targetCharX + (targetCharWidth - currentCharWidth) / 2;
            var targetCharYFinal = hfTextTargetY + hfCharFinalYOffset;

            FlxTween.tween(charText.scale, {x: hfTextTargetScale, y: hfTextTargetScale}, 1.0, {ease: FlxEase.quartOut});
            FlxTween.tween(charText, {x: targetCharXFinal, y: targetCharYFinal}, 1.0, {ease: FlxEase.quartOut});
        }

        new FlxTimer().start(startBlackWhiteTime, function(timer:FlxTimer) {
            changeCharsToBlackWhite();
        });
    }
}

// ========== MIOM 向上动画 ==========
function startMIOMUpwardAnimation() {
    var sequence = [0, 3, 2, 1];
    var centerX = FlxG.width / 2;
    var centerY = FlxG.height / 2;

    for (i in 0...sequence.length) {
        var imageIndex = sequence[i];
        var image = miomImages[imageIndex];

        new FlxTimer().start(i * 0.1, function(timer:FlxTimer) {
            var originalWidth = image.frameWidth;
            var originalHeight = image.frameHeight;
            var targetScale = 0.2;
            var scaledWidth = originalWidth * targetScale;
            var scaledHeight = originalHeight * targetScale;

            var targetX = centerX - scaledWidth / 2;
            var targetY = centerY - scaledHeight / 2;

            var offsetX = 0, offsetY = 0;
            switch(imageIndex) {
                case 0: offsetX = -10; offsetY = -10;
                case 1: offsetX = 10;  offsetY = -10;
                case 2: offsetX = -10; offsetY = 10;
                case 3: offsetX = 10;  offsetY = 10;
            }

            var startX = targetX + offsetX;
            var startY = targetY + offsetY;
            image.x = startX;
            image.y = startY;
            image.alpha = 0;

            var upTargetY = startY - miomMoveUpDistance;
            var currentCenter = {x: startX + scaledWidth/2, y: startY + scaledHeight/2};
            var targetCenter = {x: centerX, y: centerY - miomMoveUpDistance};

            FlxTween.tween(currentCenter, {x: targetCenter.x, y: targetCenter.y}, miomMoveUpDuration, {
                ease: FlxEase.quartOut,
                onUpdate: function(tween:FlxTween) {
                    var currentScale = image.scale.x;
                    var currentScaledWidth = originalWidth * currentScale;
                    var currentScaledHeight = originalHeight * currentScale;
                    image.x = currentCenter.x - currentScaledWidth/2;
                    image.y = currentCenter.y - currentScaledHeight/2;
                    image.updateHitbox();
                }
            });

            FlxTween.tween(image.scale, {x: 0.2, y: 0.2}, 1, {ease: FlxEase.quartOut});
            new FlxTimer().start(0.2, function(timer:FlxTimer) {
                FlxTween.tween(image, {alpha: 1}, 0.5, {ease: FlxEase.linear});
            });

            new FlxTimer().start(1.0, function(timer2:FlxTimer) {
                startImageFlash(image, i);
            });
        });
    }
}

function startImageFlash(image:FunkinSprite, seqIndex:Int) {
    new FlxTimer().start(seqIndex * 0.03, function(timer:FlxTimer) {
        if (seqIndex == 3) {
            new FlxTimer().start(1.0, function(timer2:FlxTimer) {
                startFadeOutAndEnterGame();
            });
        }
    });
}

// ========== 最终淡出并进入游戏 ==========
function startFadeOutAndEnterGame() {
    for (image in miomImages) {
        FlxTween.tween(image, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});
    }
    for (image in hfImages) {
        FlxTween.tween(image, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});
    }
    for (charText in hfCharTexts) {
        FlxTween.tween(charText, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});
    }
    if (cneImage != null) FlxTween.tween(cneImage, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});
    if (cyImage != null) FlxTween.tween(cyImage, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});

    new FlxTimer().start(0.8, function(timer:FlxTimer) {
        goToTitle();
    });
}

// ========== 辅助函数 ==========
function startRainbowScroll() {
    if (rainbowTimer != null) {
        rainbowTimer.destroy();
        rainbowTimer = null;
    }
    rainbowActive = true;
    rainbowOffset = 0;
    rainbowTimer = new FlxTimer();
    rainbowTimer.start(rainbowInterval, function(timer:FlxTimer) {
        if (!rainbowActive) {
            rainbowTimer.destroy();
            rainbowTimer = null;
            return;
        }
        for (i in 0...hfCharTexts.length) {
            var charText = hfCharTexts[i];
            var colorIndex = (rainbowOffset - i) % hfTextColors.length;
            if (colorIndex < 0) colorIndex += hfTextColors.length;
            var textColor = hfTextColors[colorIndex];
            charText.setFormat(Paths.font(hfTextFont), hfTextSize, textColor);
            charText.antialiasing = true;
        }
        rainbowOffset++;
        return rainbowInterval;
    }, 0);
}

function changeCharsToBlackWhite() {
    rainbowActive = false;
    if (rainbowTimer != null) {
        rainbowTimer.destroy();
        rainbowTimer = null;
    }
    for (i in 0...hfCharTexts.length) {
        var charText = hfCharTexts[i];
        new FlxTimer().start(i * 0.05, function(timer:FlxTimer) {
            charText.setFormat(Paths.font(hfTextFont), hfTextSize, 0xFF000000);
            charText.borderStyle = FlxTextBorderStyle.OUTLINE;
            charText.borderSize = hfTextBorderSize;
            charText.borderColor = 0xFFFFFFFF;
            charText.antialiasing = true;
        });
    }
}

// ========== 更新循环 ==========
var __timer:Float = 0;
function update(elapsed:Float) {
    __timer += elapsed;
    vhs.iTime = FlxG.game.ticks / 1000;

    if (controls.ACCEPT || FlxG.mouse.justPressed) {
        FlxG.camera.visible = false;
        goToTitle();
    }

    if (FlxG.keys.justPressed.F)
        FlxG.fullscreen = !FlxG.fullscreen;
}

// ========== 清理 ==========
function destroy() {
    if (rainbowTimer != null) {
        rainbowTimer.destroy();
        rainbowTimer = null;
    }
    if (miomImages != null) {
        for (image in miomImages) if (image != null) image.destroy();
        miomImages = null;
    }
    if (hfImages != null) {
        for (image in hfImages) if (image != null) image.destroy();
        hfImages = null;
    }
    if (hfCharTexts != null) {
        for (charText in hfCharTexts) if (charText != null) charText.destroy();
        hfCharTexts = null;
    }
    if (cneImage != null) { cneImage.destroy(); cneImage = null; }
    if (cyImage != null) { cyImage.destroy(); cyImage = null; }
}