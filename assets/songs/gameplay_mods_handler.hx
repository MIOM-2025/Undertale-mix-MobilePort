import funkin.savedata.FunkinSave;

// 玩家修改的设置
var userScrollSpeed:Float = 1;
var scrollType:String = 'multiplicative';
var healthGainMult:Float = 1;
var healthLossMult:Float = 1;
var missInstaKill:Bool = false;

var songExists:Bool = false;

function create() {
    var songName = PlayState.SONG.meta.name;
    songExists = FunkinSave.getSongHighscore(songName, 'normal').date != null;

    if (songExists) {
        // 读取当前歌曲的专属设置（字段名为 "歌曲名_变量名"）
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
    }
    // 如果歌曲未解锁，所有设置维持默认值（已在变量声明时设定）
}

function postCreate() {
    if (!songExists)
        return;

    if (scrollType == 'multiplicative') {
        scrollSpeed *= userScrollSpeed;
    } else {
        scrollSpeed = userScrollSpeed;
    }
}

function onPlayerHit(e) {
    if (!songExists)
        return;
    e.healthGain *= healthGainMult;
}

function onPlayerMiss(e) {
    if (!songExists)
        return;

    if (missInstaKill) {
        health = PlayState.opponentMode ? 2 : 0;
    }
    e.healthGain *= healthLossMult;
}

function onEvent(e) {
    if (!songExists)
        return;

    if (e.event.name == 'Scroll Speed Change' && scrollType == 'constant') {
        e.cancel();
        // 取消可能存在的缓动动画
        if (eventsTween.get('scrollSpeedTween') != null) {
            eventsTween.get('scrollSpeedTween').cancel();
        }
        scrollSpeed = userScrollSpeed;
    }
}