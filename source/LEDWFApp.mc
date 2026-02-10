import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class LEDWFApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // 手表端长按表盘时显示的设置菜单
    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        var menu = new WatchUi.Menu2({:title => "Settings"});

        // 颜色选项
        var colors = ["White", "Red", "Green", "Blue", "Cyan", "Yellow", "Orange", "Purple"];
        var colorValues = [0xFFFFFF, 0xFF0000, 0x00FF00, 0x0000FF, 0x00FFFF, 0xFFFF00, 0xFF5500, 0xFF00FF];

        // 获取当前选中颜色的索引
        var currentColor = Application.Properties.getValue("ForegroundColor") as Number;
        var currentIndex = 0;
        for (var i = 0; i < colorValues.size(); i++) {
            if (colorValues[i] == currentColor) {
                currentIndex = i;
                break;
            }
        }

        menu.addItem(
            new WatchUi.MenuItem("LED Color", colors[currentIndex], :ledColor, null)
        );

        return [menu, new LEDWFSettingsDelegate()];
    }

    var _view as LEDWFView?;

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new LEDWFView();
        return [ _view ];
    }

    function onSettingsChanged() as Void {
        if (_view != null) {
            _view.loadSettings();
        }
        WatchUi.requestUpdate();
    }

}

function getApp() as LEDWFApp {
    return Application.getApp() as LEDWFApp;
}

// 设置菜单代理
class LEDWFSettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getId() == :ledColor) {
            // 打开颜色子菜单
            var colorMenu = new WatchUi.Menu2({:title => "LED Color"});
            var colors = ["White", "Red", "Green", "Blue", "Cyan", "Yellow", "Orange", "Purple"];
            var colorValues = [0xFFFFFF, 0xFF0000, 0x00FF00, 0x0000FF, 0x00FFFF, 0xFFFF00, 0xFF5500, 0xFF00FF];
            var currentColor = Application.Properties.getValue("ForegroundColor") as Number;

            for (var i = 0; i < colors.size(); i++) {
                var isCurrent = (colorValues[i] == currentColor) ? " *" : "";
                colorMenu.addItem(
                    new WatchUi.MenuItem(colors[i] + isCurrent, null, colorValues[i], null)
                );
            }

            WatchUi.pushView(colorMenu, new LEDWFColorDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// 颜色选择代理
class LEDWFColorDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var colorValue = item.getId() as Number;
        Application.Properties.setValue("ForegroundColor", colorValue);
        // 通知View重新加载颜色
        var app = getApp();
        if (app._view != null) {
            app._view.loadSettings();
        }
        // 返回到表盘（跳过Settings菜单）
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}