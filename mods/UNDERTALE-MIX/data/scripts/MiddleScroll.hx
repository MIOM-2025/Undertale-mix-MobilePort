// MiddleScroll.hx
// 居中滚动脚本，实时更新位置，支持对方模式自动交换

function postCreate() {
    // 初始化时设置一次位置，确保其他脚本能看到正确的初始坐标
    updateStrumPositions();
}

function update(elapsed:Float) {
    // 每帧强制更新位置，防止被其他脚本覆盖
    updateStrumPositions();
}

function updateStrumPositions() {
    // 安全检查
    if (PlayState == null) return;
    if (strumLines == null || strumLines.members == null) return;

    var opponentMode = PlayState.opponentMode;

    // 获取玩家与对手的 strum 数组
    var playerStrumLine = strumLines.members[0];
    var opponentStrumLine = strumLines.members[1];

    if (playerStrumLine == null || opponentStrumLine == null) return;

    // 根据对方模式决定谁在中间谁在两侧
    var centerStrumLine = opponentMode ? playerStrumLine : opponentStrumLine;
    var sideStrumLine   = opponentMode ? opponentStrumLine : playerStrumLine;

    // 居中的 strum 排列
    var i = 0;
    for (s in centerStrumLine) {
        s.x = -278 + (160 * 0.7) * i + 50 + (FlxG.width / 2);
        i++;
    }

    // 两侧的 strum 排列
    i = 0;
    for (s in sideStrumLine) {
        if (i < 2) {
            s.x = 82 + i * 112;
        } else {
            s.x = FlxG.width - 309 + (i - 2) * 112;
        }
        i++;
    }
}