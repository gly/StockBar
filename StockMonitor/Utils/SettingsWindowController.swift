import AppKit
import SwiftUI

/// 设置窗口管理器：启动/面板首次出现时预热窗口，点击“设置”时直接显示，
/// 避免首次打开要走 SwiftUI Window scene 初始化 + 应用激活流程导致弹窗慢。
@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    /// 预热：提前构建好窗口（不显示）
    func prewarm(appState: AppState) {
        _ = ensureWindow(appState: appState)
    }

    /// 显示设置窗口
    func show(appState: AppState) {
        let w = ensureWindow(appState: appState)
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func ensureWindow(appState: AppState) -> NSWindow {
        if let w = window { return w }
        let content = NSHostingView(rootView: SettingsView().environmentObject(appState))
        let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 420, height: 620),
                         styleMask: [.titled, .closable, .miniaturizable],
                         backing: .buffered, defer: false)
        w.title = "设置"
        w.contentView = content
        w.isReleasedWhenClosed = false   // 常驻复用，关闭只隐藏
        w.center()
        window = w
        return w
    }
}
