import funkin.savedata.FunkinSave;

// 玩家修改的设置（仅歌曲解锁后生效）
var userScrollSpeed:Float = 1;
var scrollType:String = 'multiplicative';
var healthGainMult:Float = 1;
var healthLossMult:Float = 1;
var missInstaKill:Bool = false;
var botplayEnabled:Bool = false;

var songExists:Bool = false;
var botplayLoaded:Bool = false;
var middleScrollLoaded:Bool = false;    // MiddleScroll 脚本加载标记

function create() {
    var songName = PlayState.SONG.meta.name;
    songExists = FunkinSave.getSongHighscore(songName, 'normal').date != null;

    if (songExists) {
        var prefix = songName + '_';

        if (Reflect.hasField(FlxG.save.data, prefix + 'gameScrollType'))
            scrollType = Reflect.field(FlxG.save.data, prefix + 'gameScrollType');
        else
            scrollType = 'multiplicative';

        if (Reflect.hasField(FlxG.save.data, prefix + 'gameScrollSpeed'))
            userScrollSpeed = Reflect.field(FlxG.save.data, prefix + 'gameScrollSpeed');
        else
            userScrollSpeed = 1;

        if (Reflect.hasField(FlxG.save.data, prefix + 'gameHealthGainMult'))
            healthGainMult = Reflect.field(FlxG.save.data, prefix + 'gameHealthGainMult');
        else
            healthGainMult = 1;

        if (Reflect.hasField(FlxG.save.data, prefix + 'gameHealthLossMult'))
            healthLossMult = Reflect.field(FlxG.save.data, prefix + 'gameHealthLossMult');
        else
            healthLossMult = 1;

        if (Reflect.hasField(FlxG.save.data, prefix + 'missInstaKill'))
            missInstaKill = Reflect.field(FlxG.save.data, prefix + 'missInstaKill');
        else
            missInstaKill = false;

        if (Reflect.hasField(FlxG.save.data, prefix + 'botplay'))
            botplayEnabled = Reflect.field(FlxG.save.data, prefix + 'botplay');
        else
            botplayEnabled = false;
    }
}

function postCreate() {
    // ===== MiddleScroll 全局生效，不依赖歌曲解锁 =====
    if (FlxG.save.data.middleScroll != null && FlxG.save.data.middleScroll && !middleScrollLoaded) {
        importScript("data/scripts/MiddleScroll");
        middleScrollLoaded = true;
    }

    // ===== Botplay 仍然仅歌曲解锁后生效 =====
    if (songExists) {
        if (scrollType == 'multiplicative') {
            scrollSpeed *= userScrollSpeed;
        } else {
            scrollSpeed = userScrollSpeed;
        }

        if (botplayEnabled && !botplayLoaded) {
            importScript("data/scripts/botplay");
            botplayLoaded = true;
        }
    }
}

function onPlayerHit(e) {
    if (!songExists) return;
    e.healthGain *= healthGainMult;
}

function onPlayerMiss(e) {
    if (!songExists) return;

    if (missInstaKill) {
        health = PlayState.opponentMode ? 2 : 0;
    }
    e.healthGain *= healthLossMult;
}

function onEvent(e) {
    if (!songExists) return;

    if (e.event.name == 'Scroll Speed Change' && scrollType == 'constant') {
        e.cancel();
        if (eventsTween.get('scrollSpeedTween') != null) {
            eventsTween.get('scrollSpeedTween').cancel();
        }
        scrollSpeed = userScrollSpeed;
    }
}