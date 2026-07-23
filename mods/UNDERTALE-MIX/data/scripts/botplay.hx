import funkin.ui.FunkinText;
import flixel.tweens.FlxTweenType;
import flixel.text.FlxTextBorderStyle;
import Reflect;

public static var HUDcam:HudCamera;
public var botplayV = null;          // 保留原有用途（控制 HUD 等）
public var botplayA:Bool = true;     // 新增标识，供 switch 脚本检测 botplay 模式

var botText:FunkinText;
var firsttime = 1;
var animationStarted:Bool = false;

// 统一管理所有不需要点击的箭头类型（保留但本次未使用）
var ignoredNoteTypes:Array<String> = ["Hurt Note"];

// 根据 opponentMode 动态获取当前应控制的音轨（0=敌方，1=玩家）
function getTargetStrumLine():StrumLine {
    return PlayState.opponentMode ? strumLines.members[0] : strumLines.members[1];
}

function postCreate() {
    FlxG.cameras.add(HUDcam = new HudCamera(), false);
    HUDcam.bgColor = 0x00000000;
    HUDcam.downscroll = downscroll;
    HUDcam.visible = false;

    botText = new FunkinText(0, 200, FlxG.width, "Botplay");
    botText.alignment = "center";
    botText.cameras = [HUDcam];
    botText.setFormat(Paths.font("DTM-Mono.ttf"), 35, 0xFFFFFF);
    botText.borderStyle = FlxTextBorderStyle.OUTLINE;
    botText.borderColor = 0xFF000000;
    botText.borderSize = 2;
    botText.antialiasing = true;
    botText.alpha = 0;
    add(botText);

    // 获取目标音轨
    var targetLine = getTargetStrumLine();
    
    // 设置所有 strum 为 cpu 模式（自动按压动画）
    targetLine.forEach(function(obj:Strum) {
        obj.cpu = true;
    });

    // 注册 onNoteUpdate 事件
    targetLine.onNoteUpdate.add(function(event) {
        event.cancel();
        var sl = targetLine; // 直接使用外部变量
        var isIgnored:Bool = (ignoredNoteTypes.indexOf(event.note.noteType) != -1);

        if (isIgnored) {
            if (event.__autoCPUHit && event.note.strumTime < sl.__updateNote_songPos) {
                event.note.tooLate = true;
            }
        } else {
            if (event.__updateHitWindow) {
                event.note.canBeHit = (event.note.strumTime > sl.__updateNote_songPos - (PlayState.instance.hitWindow * event.note.latePressWindow)
                    && event.note.strumTime < sl.__updateNote_songPos + (PlayState.instance.hitWindow * event.note.earlyPressWindow));

                if (event.note.strumTime < sl.__updateNote_songPos - PlayState.instance.hitWindow && !event.note.wasGoodHit)
                    event.note.tooLate = true;
            }

            if (event.__autoCPUHit && !event.note.avoid && !event.note.wasGoodHit && event.note.strumTime < sl.__updateNote_songPos) {
                PlayState.instance.goodNoteHit(sl, event.note);
            }

            if (event.note.wasGoodHit && event.note.isSustainNote && event.note.strumTime + (event.note.sustainLength) < sl.__updateNote_songPos) {
                deleteNote(event.note);
                return;
            }

            if (event.strum == null) return;
            if (event.__reposNote) event.strum.updateNotePosition(event.note);
            if (event.note.isSustainNote)
                event.note.updateSustain(event.strum);
        }
    });

    // 注册 onHit 事件（按压动画）
    targetLine.onHit.add(function(event) {
        event.preventStrumGlow();
        if (event.note.__strum != null && event.note.__strum.press != null) {
            try { event.note.__strum.press(event.note.strumTime - (event.note.isSustainNote ? (event.note.nextSustain != null ? 0 : Conductor.crochet / 6.1) : (event.note.nextNote.isSustainNote ? 0 : Conductor.crochet / 6.1))); } catch (e:Dynamic) {}
        } else {
            trace("Error: __strum or press method is not defined.");
        }
    });
}

function update(elapsed:Float) {
    if (botplayV) HUDcam.visible = true;
    if (!botplayV) HUDcam.visible = false;
    HUDcam.zoom = camHUD.zoom;
    HUDcam.angle = camHUD.angle;
    var shouldShow = (inst.time > 0);
    HUDcam.visible = shouldShow;
    if (HUDcam.visible && !animationStarted) {
        animationStarted = true;
        FlxTween.tween(botText, {alpha: 1}, 1, {
            type: FlxTweenType.PINGPONG,
            ease: FlxEase.sineInOut
        });
    }
}

function onInputUpdate(event) {
    event.cancel(); // 屏蔽玩家输入（按键无效）
}

function onPlayerMiss(event) {
    if (event.score != null) event.score = 0;
}

function onPlayerHit(event) {
    if (event.score != null) event.score = 0;
}