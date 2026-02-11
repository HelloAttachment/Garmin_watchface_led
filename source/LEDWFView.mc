import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.SensorHistory;
import Toybox.Math;

class LEDWFView extends WatchUi.WatchFace {
    // LED点的大小和间距
    private var _dotSize as Number = 5;
    private var _dotSpacing as Number = 5;   // 垂直间距
    private var _dotHSpacing as Number = 6;  // 水平间距（比垂直大，避免左右连在一起）

    // 颜色定义
    private var _ledOn as Number = 0xFFFFFF;      // 亮白色 - LED亮
    private var _ledOff as Number = 0x333333;     // 浅灰色 - LED灭
    private var _bgColor as Number = 0x000000;    // 黑色背景

    // 心形点阵尺寸
    private var _heartCols as Number = 5;
    private var _heartRows as Number = 4;

    // 心形点阵模式 (5列 x 4行) - 每行用位掩码表示
    private var _heartPattern as Array<Number> = [10, 31, 14, 4];

    // 心率数字点阵尺寸 (3列 x 5行)
    private var _tinyDigitCols as Number = 3;
    private var _tinyDigitRows as Number = 5;

    // 心率数字点阵模式 (3列 x 5行) - 每行用位掩码表示
    private var _tinyDigitPatterns as Array<Array<Number> > = [
        [7, 5, 5, 5, 7],  // 0
        [2, 6, 2, 2, 7],  // 1
        [7, 1, 7, 4, 7],  // 2
        [7, 1, 7, 1, 7],  // 3
        [5, 5, 7, 1, 1],  // 4
        [7, 4, 7, 1, 7],  // 5
        [7, 4, 7, 5, 7],  // 6
        [7, 1, 1, 1, 1],  // 7
        [7, 5, 7, 5, 7],  // 8
        [7, 5, 7, 1, 7]   // 9
    ];

    // 笑脸点阵尺寸 (9列 x 9行)
    private var _faceCols as Number = 9;
    private var _faceRows as Number = 9;

    // 笑脸 - 身体电量充足 (>= 60)
    private var _faceHappy as Array<Number> = [124, 130, 297, 257, 257, 325, 313, 130, 124];

    // 平脸 - 身体电量一般 (25-59)
    private var _faceNeutral as Array<Number> = [124, 130, 297, 257, 257, 257, 313, 130, 124];

    // 难过脸 - 身体电量低 (< 25)
    private var _faceSad as Array<Number> = [124, 130, 297, 257, 257, 313, 325, 130, 124];

    // 数字点阵宽高
    private var _digitCols as Number = 6;   // 6列
    private var _digitRows as Number = 12;  // 12行

    // 字母点阵宽高
    private var _letterCols as Number = 4;  // 4列
    private var _letterRows as Number = 5;   // 5行

    // 字母点阵模式 (4列 x 5行) - 每行用位掩码表示
    private var _letterPatterns as Array<Array<Number> > = [
        [9, 15, 9, 9, 9],     // M
        [6, 9, 9, 9, 6],      // O
        [9, 13, 11, 9, 9],    // N
        [15, 6, 6, 6, 6],     // T
        [9, 9, 9, 9, 6],      // U
        [15, 8, 14, 8, 15],   // E
        [9, 9, 11, 13, 9],    // W
        [14, 9, 9, 9, 14],    // D
        [9, 9, 15, 9, 9],     // H
        [15, 8, 14, 8, 8],    // F
        [14, 9, 14, 12, 9],   // R
        [15, 4, 4, 4, 15],    // I
        [7, 8, 6, 1, 14],     // S
        [6, 9, 15, 9, 9],     // A
        [14, 9, 14, 8, 8],    // P
    ];

    // 数字点阵模式 (6列 x 12行) - 每行用位掩码表示
    private var _digitPatterns as Array<Array<Number> > = [
        [63, 63, 51, 51, 51, 51, 51, 51, 51, 51, 63, 63],  // 0
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],              // 1
        [63, 63, 3, 3, 3, 63, 63, 48, 48, 48, 63, 63],      // 2
        [63, 63, 3, 3, 3, 63, 63, 3, 3, 3, 63, 63],         // 3
        [51, 51, 51, 51, 51, 63, 63, 3, 3, 3, 3, 3],        // 4
        [63, 63, 48, 48, 48, 63, 63, 3, 3, 3, 63, 63],      // 5
        [63, 63, 48, 48, 48, 63, 63, 51, 51, 51, 63, 63],   // 6
        [63, 63, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],             // 7
        [63, 63, 51, 51, 51, 63, 63, 51, 51, 51, 63, 63],   // 8
        [63, 63, 51, 51, 51, 63, 63, 3, 3, 3, 63, 63]       // 9
    ];

    // 小数字点阵模式 (4列 x 5行) - 每行用位掩码表示
    private var _smallDigitPatterns as Array<Array<Number> > = [
        [6, 9, 9, 9, 6],      // 0
        [6, 14, 6, 6, 15],    // 1
        [6, 9, 3, 6, 15],     // 2
        [6, 9, 3, 9, 6],      // 3
        [11, 11, 15, 3, 3],   // 4
        [15, 8, 14, 1, 14],   // 5
        [6, 9, 14, 9, 6],     // 6
        [15, 1, 3, 6, 6],     // 7
        [6, 9, 6, 9, 6],      // 8
        [6, 9, 7, 1, 14]      // 9
    ];

    // 图标资源
    private var _fireIcon as BitmapResource or Null = null;
    private var _stepIcon as BitmapResource or Null = null;

    // Pre-computed screen dimensions
    private var _screenWidth as Number = 0;
    private var _screenHeight as Number = 0;

    // 上一秒位置（用于 onPartialUpdate 清除旧点）
    private var _prevSec as Number or Null = null;

    // 缓存冒号和心形位置（供 onPartialUpdate 使用）
    private var _colonX as Number = 0;
    private var _colonY as Number = 0;
    private var _heartDrawX as Number = 0;
    private var _heartDrawY as Number = 0;

    // Pre-computed marquee coordinates (60 points, absolute screen positions)
    private var _marqueeX = new [60];
    private var _marqueeY = new [60];

    // Pre-computed pie chart offsets from center (24 points)
    private var _pieCWDx = new [24];
    private var _pieCWDy = new [24];
    private var _pieCCWDx = new [24];
    private var _pieCCWDy = new [24];
    private var _pieRadius as Number = 0;

    // 一周运动缓存（避免每帧遍历历史记录）
    private var _weeklyActivityCache as Array<Boolean> = [false, false, false, false, false, false, false] as Array<Boolean>;
    private var _cachedDay as Number = -1;  // 缓存对应的日期，用于日期变更时刷新

    // 星期名称（避免每帧分配）
    private var _weekdayNames as Array<String> = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    // 活动数据缓存（避免每帧分配新数组）[steps, stepGoal, calories, calorieGoal]
    private var _activityCache as Array<Number> = [0, 10000, 0, 2000];

    // Layout fine-tuning offsets (named constants replacing magic numbers)
    private var _adjWeekdayX as Number = 85;   // weekday X position adjustment
    private var _adjBbYPad as Number = 10;     // body battery Y padding
    private var _adjAmpmX as Number = -5;      // AM/PM X fine-tune
    private var _adjAmpmY as Number = -10;     // AM/PM Y fine-tune
    private var _adjAmpmGap as Number = 5;     // gap between A/P and M letters
    private var _adjPieCenterY as Number = 10; // pie chart center Y offset
    private var _adjPieX as Number = 20;       // pie chart X offset from heart

    function initialize() {
        WatchFace.initialize();
        loadSettings();
    }

    // 从设置中加载颜色
    function loadSettings() as Void {
        var color = Application.Properties.getValue("ForegroundColor");
        if (color != null && color instanceof Number) {
            _ledOn = color as Number;
        }
    }

    function onLayout(dc as Dc) as Void {
        loadSettings();
        _fireIcon = WatchUi.loadResource(Rez.Drawables.FireIcon) as BitmapResource;
        _stepIcon = WatchUi.loadResource(Rez.Drawables.StepIcon) as BitmapResource;
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
        if (_screenWidth >= 416) {
            _dotSize = 6;
            _dotSpacing = 6;
            _dotHSpacing = 7;
        } else if (_screenWidth >= 280) {
            _dotSize = 5;
            _dotSpacing = 5;
            _dotHSpacing = 6;
        } else {
            _dotSize = 4;
            _dotSpacing = 4;
            _dotHSpacing = 5;
        }
        precomputeCoordinates();
        refreshWeeklyActivityCache();
    }

    // Pre-compute all trigonometric coordinates to avoid Math.sin/cos in onUpdate
    function precomputeCoordinates() as Void {
        // Marquee: 60 points around screen edge
        var centerX = _screenWidth / 2;
        var centerY = _screenHeight / 2;
        var marqueeRadius = centerX - _dotSize - 2;
        for (var s = 0; s < 60; s++) {
            var angle = (s * 6 - 90) * Math.PI / 180.0;
            _marqueeX[s] = centerX + (marqueeRadius * Math.cos(angle)).toNumber();
            _marqueeY[s] = centerY + (marqueeRadius * Math.sin(angle)).toNumber();
        }

        // Pie charts: 24 points, both clockwise and counter-clockwise
        _pieRadius = _dotSpacing * 4;
        for (var i = 0; i < 24; i++) {
            var cwAngle = (i * 15 - 90) * Math.PI / 180.0;
            _pieCWDx[i] = (_pieRadius * Math.cos(cwAngle)).toNumber();
            _pieCWDy[i] = (_pieRadius * Math.sin(cwAngle)).toNumber();

            var ccwAngle = (-i * 15 - 90) * Math.PI / 180.0;
            _pieCCWDx[i] = (_pieRadius * Math.cos(ccwAngle)).toNumber();
            _pieCCWDy[i] = (_pieRadius * Math.sin(ccwAngle)).toNumber();
        }
    }

    // 绘制一个LED点（只绘制亮的点）
    function drawDot(dc as Dc, x as Number, y as Number, isOn as Boolean) as Void {
        if (!isOn) {
            return;
        }
        dc.setColor(_ledOn, _bgColor);
        dc.fillCircle(x, y, _dotSize / 2);
    }

    // 绘制一个彩色LED点（只绘制亮的点）
    function drawColorDot(dc as Dc, x as Number, y as Number, isOn as Boolean, onColor as Number) as Void {
        if (!isOn) {
            return;
        }
        dc.setColor(onColor, _bgColor);
        dc.fillCircle(x, y, _dotSize / 2);
    }

    // 绘制心形图标（位掩码版本）
    function drawHeart(dc as Dc, x as Number, y as Number, isOn as Boolean) as Void {
        for (var row = 0; row < _heartRows; row++) {
            var rowBits = _heartPattern[row];
            for (var col = 0; col < _heartCols; col++) {
                if (((rowBits >> (_heartCols - 1 - col)) & 1) == 1) {
                    drawColorDot(dc, x + col * _dotHSpacing, y + row * _dotSpacing, isOn, _ledOn);
                }
            }
        }
    }

    // 获取当前心率
    function getHeartRate() as Number {
        var hrIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var sample = hrIterator.next();
        if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            return sample.heartRate;
        }
        return 0;
    }

    // 绘制微型数字（3x5点阵，用于心率，位掩码版本）
    function drawTinyDigit(dc as Dc, x as Number, y as Number, digit as Number) as Void {
        var pattern = _tinyDigitPatterns[digit];
        for (var row = 0; row < _tinyDigitRows; row++) {
            var rowBits = pattern[row];
            for (var col = 0; col < _tinyDigitCols; col++) {
                if (((rowBits >> (_tinyDigitCols - 1 - col)) & 1) == 1) {
                    drawDot(dc, x + col * _dotHSpacing, y + row * _dotSpacing, true);
                }
            }
        }
    }

    // 绘制心率数值（紧凑左对齐）
    function drawHeartRate(dc as Dc, x as Number, y as Number, hr as Number) as Void {
        var tinyWidth = _tinyDigitCols * _dotHSpacing;
        var gap = _dotHSpacing;

        if (hr <= 0) {
            // 无心率数据时显示 "---"
            var dashY = y + _tinyDigitRows * _dotSpacing / 2;
            drawDot(dc, x + 1 * _dotHSpacing, dashY, true);
            drawDot(dc, x + tinyWidth + gap + 1 * _dotHSpacing, dashY, true);
            drawDot(dc, x + 2 * (tinyWidth + gap) + 1 * _dotHSpacing, dashY, true);
            return;
        }

        var pos = x;

        if (hr >= 100) {
            drawTinyDigit(dc, pos, y, hr / 100);
            pos += tinyWidth + gap;
        }
        if (hr >= 10) {
            drawTinyDigit(dc, pos, y, (hr % 100) / 10);
            pos += tinyWidth + gap;
        }
        drawTinyDigit(dc, pos, y, hr % 10);
    }

    // 绘制电池条（10组，每组2个圆点，组间间距为普通间距的2倍）
    function drawBatteryBar(dc as Dc, x as Number, y as Number, level as Number) as Void {
        var totalGroups = 10;
        var litGroups = (level * totalGroups) / 100;
        if (level > 0 && litGroups == 0) {
            litGroups = 1;
        }
        var dotsPerGroup = 2;
        var groupGap = _dotHSpacing ;  // 组间间距为普通间距的2倍
        var groupWidth = dotsPerGroup * _dotHSpacing;  // 组内2个点的宽度
        var groupStep = groupWidth + groupGap;  // 每组占的总宽度
        for (var g = 0; g < totalGroups; g++) {
            var groupX = x + g * groupStep;
            var color = (g < litGroups) ? _ledOn : _ledOff;
            dc.setColor(color, _bgColor);
            for (var d = 0; d < dotsPerGroup; d++) {
                dc.fillCircle(groupX + d * _dotHSpacing, y, _dotSize / 2);
            }
        }
    }

    // 获取身体电量
    function getBodyBattery() as Number {
        if (Toybox has :SensorHistory && SensorHistory has :getBodyBatteryHistory) {
            var iterator = SensorHistory.getBodyBatteryHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            var sample = iterator.next();
            if (sample != null && sample.data != null) {
                return sample.data.toNumber();
            }
        }
        return -1;
    }

    // 绘制表情（根据身体电量选择，位掩码版本）
    function drawFace(dc as Dc, x as Number, y as Number, bodyBattery as Number) as Void {
        var pattern;
        if (bodyBattery >= 60) {
            pattern = _faceHappy;
        } else if (bodyBattery >= 25) {
            pattern = _faceNeutral;
        } else {
            pattern = _faceSad;
        }

        for (var row = 0; row < _faceRows; row++) {
            var rowBits = pattern[row];
            for (var col = 0; col < _faceCols; col++) {
                if (((rowBits >> (_faceCols - 1 - col)) & 1) == 1) {
                    drawDot(dc, x + col * _dotHSpacing, y + row * _dotSpacing, true);
                }
            }
        }
    }

    // 绘制一个数字（位掩码版本）
    function drawDigit(dc as Dc, x as Number, y as Number, digit as Number) as Void {
        var pattern = _digitPatterns[digit];

        for (var row = 0; row < _digitRows; row++) {
            var rowBits = pattern[row];
            for (var col = 0; col < _digitCols; col++) {
                if (((rowBits >> (_digitCols - 1 - col)) & 1) == 1) {
                    drawDot(dc, x + col * _dotHSpacing, y + row * _dotSpacing, true);
                }
            }
        }
    }

    // 绘制一个字母（位掩码版本）
    function drawLetter(dc as Dc, x as Number, y as Number, letter as String) as Void {
        var patternIndex = getLetterPatternIndex(letter);
        var pattern = _letterPatterns[patternIndex];

        for (var row = 0; row < _letterRows; row++) {
            var rowBits = pattern[row];
            for (var col = 0; col < _letterCols; col++) {
                if (((rowBits >> (_letterCols - 1 - col)) & 1) == 1) {
                    drawDot(dc, x + col * _dotHSpacing, y + row * _dotSpacing, true);
                }
            }
        }
    }

    // 获取字母在pattern数组中的索引
    function getLetterPatternIndex(letter as String) as Number {
        switch (letter) {
            case "M": return 0;  // MON
            case "O": return 1;  // MON, SUN
            case "N": return 2;  // MON
            case "T": return 3;  // TUE, THU
            case "U": return 4;  // TUE, SUN
            case "E": return 5;  // WED
            case "W": return 6;  // WED
            case "D": return 7;  // THU, WED, SAT, SUN
            case "H": return 8;  // THU
            case "F": return 9;  // FRI
            case "R": return 10; // FRI
            case "I": return 11; // SAT
            case "S": return 12; // SAT, SUN
            case "A": return 13; // SAT, AM
            case "P": return 14; // PM
            default: return 0;
        }
    }

    // 绘制星期几缩写（使用缓存的星期名称数组）
    function drawWeekday(dc as Dc, x as Number, y as Number, weekday as Number) as Void {
        var weekdayStr = _weekdayNames[weekday];

        var letterWidth = _letterCols * _dotHSpacing;
        var letterGap = _dotHSpacing;

        for (var i = 0; i < weekdayStr.length(); i++) {
            drawLetter(dc, x + i * (letterWidth + letterGap), y, weekdayStr.substring(i, i + 1));
        }
    }

    // 绘制冒号
    function drawColon(dc as Dc, x as Number, y as Number, isOn as Boolean) as Void {
        var digitHeight = _digitRows * _dotSpacing;

        // 上面的点 (2x2)
        var topY = y + digitHeight / 3;
        for (var row = 0; row < 2; row++) {
            for (var col = 0; col < 2; col++) {
                drawDot(dc, x + col * _dotHSpacing, topY + row * _dotSpacing, isOn);
            }
        }

        // 下面的点 (2x2)
        var bottomY = y + 2 * digitHeight / 3;
        for (var row = 0; row < 2; row++) {
            for (var col = 0; col < 2; col++) {
                drawDot(dc, x + col * _dotHSpacing, bottomY + row * _dotSpacing, isOn);
            }
        }
    }

    // 绘制小数字（4x5点阵，位掩码版本）
    function drawSmallDigit(dc as Dc, x as Number, y as Number, digit as Number) as Void {
        var pattern = _smallDigitPatterns[digit];

        for (var row = 0; row < _letterRows; row++) {
            var rowBits = pattern[row];
            for (var col = 0; col < _letterCols; col++) {
                if (((rowBits >> (_letterCols - 1 - col)) & 1) == 1) {
                    drawDot(dc, x + col * _dotHSpacing, y + row * _dotSpacing, true);
                }
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        var screenWidth = _screenWidth;
        var screenHeight = _screenHeight;

        // 清屏（必需：watchface 不调用 View.onUpdate，系统不会自动清除 DC）
        dc.setColor(_bgColor, _bgColor);
        dc.clear();

        // 获取时间和日期
        var clockTime = System.getClockTime();

        // 绘制跑马灯秒针
        drawSecondMarquee(dc, clockTime.sec);
        var hours = clockTime.hour;
        var originalHours = hours;  // 保存原始小时用于判断AM/PM
        var minutes = clockTime.min;
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var weekday = info.day_of_week - 1; // 转换为0-6 (0=星期日)
        var month = info.month; // 月份
        var day = info.day; // 日期

        // 判断AM/PM
        var isPM = (originalHours >= 12);

        // 12小时制
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            } else if (hours == 0) {
                hours = 12;
            }
        }

        // 计算星期几显示的尺寸
        var letterWidth = _letterCols * _dotHSpacing;
        var letterHeight = _letterRows * _dotSpacing;
        var weekdayWidth = 3 * letterWidth + 2 * _dotHSpacing; // 3个字母 + 2个间隙
        var weekdayGap = _dotHSpacing * 3;

        // 计算时间显示的尺寸
        var digitWidth = _digitCols * _dotHSpacing;
        var digitHeight = _digitRows * _dotSpacing;
        var colonWidth = 2 * _dotHSpacing;
        var gap = _dotHSpacing * 2;

        // 冒号居中于屏幕水平中央
        var colonCenterScreenX = screenWidth / 2;
        var startX = colonCenterScreenX - colonWidth / 2 - 2 * (digitWidth + gap);
        var startY = (screenHeight - digitHeight) / 2;

        // 星期几在时间左上方
        var weekdayX = startX - weekdayGap - weekdayWidth + _adjWeekdayX;
        var weekdayY = startY - (letterHeight + weekdayGap);

        // 绘制星期几
        drawWeekday(dc, weekdayX + _dotHSpacing, weekdayY + _dotSpacing, weekday);

        // 在星期右边绘制日期 (月日)
        var dateGap = _dotHSpacing * 2;
        var dateX = weekdayX + weekdayWidth + dateGap;
        var dateY = weekdayY;

        var separatorWidth = _dotHSpacing;

        // 绘制月（使用字母尺寸的数字）
        drawSmallDigit(dc, dateX + _dotHSpacing, dateY + _dotSpacing, month / 10);
        drawSmallDigit(dc, dateX + _dotHSpacing + letterWidth + _dotHSpacing, dateY + _dotSpacing, month % 10);

        // 绘制分隔符（小点）
        var separatorX = dateX + _dotHSpacing + 2 * letterWidth + 2 * _dotHSpacing;
        drawDot(dc, separatorX, dateY + letterHeight / 2, true);

        // 绘制日（使用字母尺寸的数字）
        var dayStartX = separatorX + separatorWidth + _dotHSpacing;
        drawSmallDigit(dc, dayStartX, dateY + _dotSpacing, day / 10);
        drawSmallDigit(dc, dayStartX + letterWidth + _dotHSpacing, dateY + _dotSpacing, day % 10);

        // 身体电量区域（在日期上方）
        var faceWidth = _faceCols * _dotHSpacing;
        var faceHeight = _faceRows * _dotSpacing;
        var topIconGap = _dotHSpacing;

        // 身体电量：表情，水平居中于屏幕
        var bodyBattery = getBodyBattery();
        var bbTotalWidth = faceWidth + topIconGap;
        var bbStartX = screenWidth / 2 - bbTotalWidth / 2;
        var bbY = weekdayY - faceHeight - _dotSpacing - _adjBbYPad;

        // 绘制表情
        drawFace(dc, bbStartX, bbY, bodyBattery);

        var currentX = startX;

        // 小时十位
        var hourTens = hours / 10;
        drawDigit(dc, currentX, startY, hourTens);
        currentX += digitWidth + gap;

        // 小时个位
        drawDigit(dc, currentX, startY, hours % 10);
        currentX += digitWidth + gap;

        // 冒号
        _colonX = currentX;
        _colonY = startY;
        var colonOn = (clockTime.sec % 2 == 0);
        drawColon(dc, currentX, startY, colonOn);
        currentX += colonWidth + gap;

        // 分钟十位
        drawDigit(dc, currentX, startY, minutes / 10);
        currentX += digitWidth + gap;

        // 分钟个位
        drawDigit(dc, currentX, startY, minutes % 10);
        currentX += digitWidth + gap;

        // 绘制AM/PM（仅12小时制，在时间右侧）
        if (!System.getDeviceSettings().is24Hour) {
            var ampmGap = _dotHSpacing;
            var ampmX = currentX + ampmGap + _adjAmpmX;
            var ampmY = startY + (digitHeight - letterHeight) / 2 + _adjAmpmY;
            if (isPM) {
                drawLetter(dc, ampmX, ampmY, "P");
                drawLetter(dc, ampmX, ampmY + letterHeight + _adjAmpmGap, "M");
            } else {
                drawLetter(dc, ampmX, ampmY, "A");
                drawLetter(dc, ampmX, ampmY + letterHeight + _adjAmpmGap, "M");
            }
        }

        // 电池条（水平居中）
        var batteryLevel = System.getSystemStats().battery.toNumber();
        var batteryBarTotalWidth = 10 * (2 * _dotHSpacing + _dotHSpacing) - _dotHSpacing; // 10组，每组2点+间距，减去最后一个间距
        var batteryBarX = colonCenterScreenX - batteryBarTotalWidth / 2;
        var batteryBarY = startY + digitHeight + _dotSpacing * 2;
        drawBatteryBar(dc, batteryBarX, batteryBarY, batteryLevel);

        // 心率区域 - 与冒号水平中央对齐（在电池条下方）
        var heartWidth = _heartCols * _dotHSpacing;
        var heartHeight = _heartRows * _dotSpacing;
        var heartOn = (clockTime.sec % 2 == 0);

        var heartX = colonCenterScreenX - heartWidth / 2;
        var heartY = batteryBarY + _dotSpacing * 3;
        _heartDrawX = heartX;
        _heartDrawY = heartY;
        drawHeart(dc, heartX, heartY, heartOn);

        // 心率数值居中于冒号（在心形下方）
        var hr = getHeartRate();
        var hrDigits = (hr >= 100) ? 3 : ((hr >= 10) ? 2 : 1);
        var hrTinyWidth = _tinyDigitCols * _dotHSpacing;
        var hrTinyGap = _dotHSpacing;
        var hrWidth = hrDigits * (hrTinyWidth + hrTinyGap) - hrTinyGap;
        var hrX = colonCenterScreenX - hrWidth / 2;
        var hrY = heartY + heartHeight + _dotSpacing;
        drawHeartRate(dc, hrX, hrY, hr);

        // 饼状图参数（与心形水平中心对齐，左右等距）
        var pieGap = _dotHSpacing * 2;
        var pieCenterY = heartY + heartHeight / 2 + _adjPieCenterY;

        // 获取活动数据（使用缓存数组，无分配）
        refreshActivityCache();
        var steps = _activityCache[0];
        var stepGoal = _activityCache[1];
        var calories = _activityCache[2];
        var calGoal = _activityCache[3];

        // 步数饼状图（心形左侧）
        var stepPieCenterX = heartX - pieGap - _pieRadius - _adjPieX;
        drawPieChart(dc, stepPieCenterX, pieCenterY, steps, stepGoal, true);

        // 在步数饼状图中心绘制脚印图标
        if (_stepIcon != null) {
            var sw = _stepIcon.getWidth();
            var sh = _stepIcon.getHeight();
            dc.drawBitmap(stepPieCenterX - sw / 2, pieCenterY - sh / 2, _stepIcon);
        }

        // 卡路里饼状图（心形右侧，对称，逆时针）
        var calPieCenterX = heartX + heartWidth + pieGap + _pieRadius + _adjPieX;
        drawPieChart(dc, calPieCenterX, pieCenterY, calories, calGoal, false);

        // 在卡路里饼状图中心绘制火焰图标
        if (_fireIcon != null) {
            var fw = _fireIcon.getWidth();
            var fh = _fireIcon.getHeight();
            dc.drawBitmap(calPieCenterX - fw / 2, pieCenterY - fh / 2, _fireIcon);
        }

        // 一周运动格子（7个，心率下方居中）
        var weekBlockSize = _dotHSpacing;  // 每个格子2x2，宽=dotHSpacing
        var weekBlockGap = _dotHSpacing;  // 格子间距
        var weekTotalWidth = 7 * (weekBlockSize + _dotHSpacing) + 6 * weekBlockGap;
        var weekX = colonCenterScreenX - weekTotalWidth / 2;
        var weekY = hrY + _tinyDigitRows * _dotSpacing + _dotSpacing * 2;
        // 日期变更时刷新一周运动缓存
        if (day != _cachedDay) {
            _cachedDay = day;
            refreshWeeklyActivityCache();
        }
        drawWeeklyDots(dc, weekX, weekY, _weeklyActivityCache);

        // 记录当前秒，供onPartialUpdate首次调用时清除该亮点
        _prevSec = clockTime.sec;
    }

    // 获取一周运动情况（7个布尔值，0=周日 到 6=周六）
    // Garmin day_of_week: 1=Sunday..7=Saturday, 转换后 todayWeekday: 0=Sunday..6=Saturday
    function getWeeklyActivity(todayWeekday as Number) as Array<Boolean> {
        var result = new [7];
        for (var i = 0; i < 7; i++) {
            result[i] = false;
        }

        var history = ActivityMonitor.getHistory();
        if (history != null) {
            for (var i = 0; i < history.size() && i < 7; i++) {
                var entry = history[i];
                if (entry != null) {
                    // history[0] = yesterday, history[1] = 2 days ago, etc.
                    var dayIndex = (todayWeekday - 1 - i + 7) % 7;
                    if (entry.steps != null && entry.steps > 5000) {
                        result[dayIndex] = true;
                    }
                }
            }
        }

        var todayInfo = ActivityMonitor.getInfo();
        if (todayInfo != null && todayInfo.steps != null && todayInfo.steps > 5000) {
            result[todayWeekday] = true;
        }

        return result;
    }

    // 刷新一周运动缓存
    function refreshWeeklyActivityCache() as Void {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var weekday = info.day_of_week - 1;
        _cachedDay = info.day;
        _weeklyActivityCache = getWeeklyActivity(weekday);
    }

    // 刷新活动数据到缓存数组（无分配）
    function refreshActivityCache() as Void {
        var info = ActivityMonitor.getInfo();
        if (info != null) {
            _activityCache[0] = (info.steps != null) ? info.steps : 0;
            _activityCache[1] = (info.stepGoal != null) ? info.stepGoal : 10000;
            _activityCache[2] = (info.calories != null) ? info.calories : 0;
            _activityCache[3] = (info has :calorieGoal && info.calorieGoal != null) ? info.calorieGoal : 2000;
        } else {
            _activityCache[0] = 0;
            _activityCache[1] = 10000;
            _activityCache[2] = 0;
            _activityCache[3] = 2000;
        }
    }

    // 绘制一周运动格子（7个2x2方块，亮=运动，灭=未运动）
    function drawWeeklyDots(dc as Dc, x as Number, y as Number, activity as Array<Boolean>) as Void {
        var blockStep = _dotHSpacing + _dotHSpacing + _dotHSpacing;  // 格子宽 + 间距
        for (var i = 0; i < 7; i++) {
            var blockX = x + i * blockStep;
            if (activity[i]) {
                dc.setColor(_ledOn, _bgColor);
            } else {
                dc.setColor(_ledOff, _bgColor);
            }
            for (var row = 0; row < 2; row++) {
                for (var col = 0; col < 2; col++) {
                    dc.fillCircle(blockX + col * _dotHSpacing, y + row * _dotSpacing, _dotSize / 2);
                }
            }
        }
    }

    // 绘制饼状图（LED点阵风格，使用预计算坐标偏移）
    function drawPieChart(dc as Dc, cx as Number, cy as Number, value as Number, goal as Number, clockwise as Boolean) as Void {
        var totalDots = 24;

        var litDots = 0;
        if (value == 0) {
            litDots = totalDots * 6 / 10;
        } else if (goal > 0) {
            litDots = (value * totalDots) / goal;
            if (litDots > totalDots) {
                litDots = totalDots;
            }
            if (value > 0 && litDots == 0) {
                litDots = 1;
            }
        }

        var dxArr = clockwise ? _pieCWDx : _pieCCWDx;
        var dyArr = clockwise ? _pieCWDy : _pieCCWDy;

        for (var i = 0; i < totalDots; i++) {
            if (i < litDots) {
                dc.setColor(_ledOn, _bgColor);
            } else {
                dc.setColor(_ledOff, _bgColor);
            }
            dc.fillCircle(cx + dxArr[i], cy + dyArr[i], _dotSize / 2);
        }
    }

    // 绘制跑马灯秒针（外圈60个点，使用预计算坐标）
    function drawSecondMarquee(dc as Dc, sec as Number) as Void {
        for (var s = 0; s < 60; s++) {
            if (s == sec) {
                dc.setColor(_ledOn, _bgColor);
            } else {
                dc.setColor(_ledOff, _bgColor);
            }
            dc.fillCircle(_marqueeX[s], _marqueeY[s], _dotSize / 2);
        }
    }

    // 绘制或清除单个秒针点（使用 setClip 限制重绘区域）
    function updateSecondDot(dc as Dc, sec as Number, isDraw as Boolean) as Void {
        var x = _marqueeX[sec] as Number;
        var y = _marqueeY[sec] as Number;
        var r = _dotSize / 2;
        var margin = 2;  // 留余量防残留
        dc.setClip(x - r - margin, y - r - margin, _dotSize + margin * 2, _dotSize + margin * 2);
        dc.setColor(_bgColor, _bgColor);
        dc.clear();
        dc.setColor(isDraw ? _ledOn : _ledOff, _bgColor);
        dc.fillCircle(x, y, r);
        dc.clearClip();
    }

    // 局部重绘冒号（使用 setClip）
    function updateColon(dc as Dc, isOn as Boolean) as Void {
        var digitHeight = _digitRows * _dotSpacing;
        var topY = _colonY + digitHeight / 3;
        var bottomY = _colonY + 2 * digitHeight / 3;
        var r = _dotSize / 2;
        var margin = 2;
        // clip 覆盖冒号的上下两组点
        var clipX = _colonX - r - margin;
        var clipY = topY - r - margin;
        var clipW = 2 * _dotHSpacing + _dotSize + margin * 2;
        var clipH = (bottomY + _dotSpacing) - topY + _dotSize + margin * 2;
        dc.setClip(clipX, clipY, clipW, clipH);
        dc.setColor(_bgColor, _bgColor);
        dc.clear();
        drawColon(dc, _colonX, _colonY, isOn);
        dc.clearClip();
    }

    // 局部重绘心形（使用 setClip）
    function updateHeart(dc as Dc, isOn as Boolean) as Void {
        var r = _dotSize / 2;
        var margin = 2;
        var clipX = _heartDrawX - r - margin;
        var clipY = _heartDrawY - r - margin;
        var clipW = (_heartCols - 1) * _dotHSpacing + _dotSize + margin * 2;
        var clipH = (_heartRows - 1) * _dotSpacing + _dotSize + margin * 2;
        dc.setClip(clipX, clipY, clipW, clipH);
        dc.setColor(_bgColor, _bgColor);
        dc.clear();
        drawHeart(dc, _heartDrawX, _heartDrawY, isOn);
        dc.clearClip();
    }

    // 熄屏模式下每秒调用，仅重绘秒针变化的点、冒号和心形
    function onPartialUpdate(dc as Dc) as Void {
        if (System.getSystemStats().battery <= 20.0) {
            return;
        }

        var sec = System.getClockTime().sec;
        var isOn = (sec % 2 == 0);

        // 清除上一秒的点（变为 LED 灭色）
        if (_prevSec != null && _prevSec != sec) {
            updateSecondDot(dc, _prevSec as Number, false);
        }

        // 绘制当前秒的点（变为 LED 亮色）
        updateSecondDot(dc, sec, true);

        // 闪烁冒号和心形
        updateColon(dc, isOn);
        updateHeart(dc, isOn);

        _prevSec = sec;
    }

}
