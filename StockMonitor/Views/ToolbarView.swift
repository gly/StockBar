import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var sortByChange: Bool

    var body: some View {
        HStack {
            toolbarButton("刷新", icon: "arrow.clockwise") {
                appState.forceRefresh()
            }
            .disabled(appState.isLoading)

            Spacer()

            toolbarButton("排序",
                          icon: sortByChange ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle",
                          tint: sortByChange ? .accentColor : .primary) {
                sortByChange.toggle()
            }

            Spacer()

            toolbarButton("设置", icon: "gearshape") {
                SettingsWindowController.shared.show(appState: appState)
            }

            Spacer()

            toolbarButton("退出", icon: "xmark.circle") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    /// 工具栏按钮：图标+文字整体作为热区（含中间缝隙）
    private func toolbarButton(_ title: String,
                               icon: String,
                               tint: Color = .primary,
                               action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 12))
                .foregroundColor(tint)
                .padding(.vertical, 4)          // 上下扩展热区
                .contentShape(Rectangle())      // 图标与文字中间的空隙也可点击
        }
        .buttonStyle(.plain)
    }
}
