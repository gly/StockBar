import SwiftUI

@MainActor
struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    @ObservedObject private var updater = UpdateChecker.shared

    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var searchText    = ""
    @State private var searchResults = [SearchResult]()
    @State private var isSearching   = false
    @State private var hasSearched   = false
    @State private var searchError: String?
    @State private var editingStock: Stock?
    @State private var editCost      = ""
    @State private var editShares    = ""
    @State private var editTarget    = ""
    @State private var editAlertOn   = false
    @State private var newWatchlistName = ""

    struct SearchResult: Identifiable {
        let id: String; let name: String; let market: Market
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            if editingStock != nil {
                ScrollView { inlineEditView(editingStock!) }
                    .scrollIndicators(.never)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        switch tab {
                        case .general: generalPane
                        case .stocks:  stocksPane
                        case .about:   aboutPane
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.never)
            }
            Divider()
            footerBar
        }
        .frame(width: 420, height: 620)
    }

    // MARK: - Tab 页

    private enum SettingsTab {
        case general, stocks, about

        var label: String {
            switch self {
            case .general: return "通用"
            case .stocks:  return "股票"
            case .about:   return "关于"
            }
        }
        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .stocks:  return "chart.line.uptrend.xyaxis"
            case .about:   return "info.circle"
            }
        }
    }

    @State private var tab: SettingsTab = .general

    @ViewBuilder private var tabBar: some View {
        HStack(spacing: 28) {
            tabButton(.general)
            tabButton(.stocks)
            tabButton(.about)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private func tabButton(_ t: SettingsTab) -> some View {
        let selected = tab == t
        return Button { tab = t } label: {
            VStack(spacing: 3) {
                Image(systemName: t.icon).font(.system(size: 22, weight: .medium))
                Text(t.label).font(.system(size: 11))
            }
            .frame(minWidth: 72, minHeight: 52)
            .foregroundColor(selected ? .accentColor : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(selected ? Color.accentColor.opacity(0.08) : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())   // 整个区域都可点击，扩大热区
        }
        .buttonStyle(.plain)
    }

    /// 底部固定栏：开发者 + 仓库地址
    @ViewBuilder private var footerBar: some View {
        HStack {
            Text("开发者 leo")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Link("github.com/gly/StockBar",
                 destination: URL(string: "https://github.com/gly/StockBar")!)
                .font(.system(size: 11))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - 通用 Tab

    @ViewBuilder private var generalPane: some View {
                // 开机启动
                section("开机启动") {
                    Toggle("登录后自动启动", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { enabled in
                            LaunchAtLogin.setEnabled(enabled)
                            launchAtLogin = LaunchAtLogin.isEnabled
                        }
                }

                // 状态栏显示
                section("状态栏显示") {
                    Picker("", selection: Binding(
                        get: { appState.statusBarStockId },
                        set: { appState.statusBarStockId = $0 }
                    )) {
                        Text("不显示").tag("__none__")
                        Text("日盈亏").tag("__daily_pnl__")
                        Text("总盈亏").tag("__total_pnl__")
                        Text("日盈亏 + 总盈亏").tag("__both_pnl__")
                        Divider()
                        Text("（自动选第一只）").tag("")
                        ForEach(appState.stocks) { s in
                            Text("\(s.name)  \(s.id)").tag(s.id)
                        }
                    }.pickerStyle(.menu)
                }

                // 持仓股分组
                section("持仓股展示") {
                    Toggle("持仓股单独分组置顶", isOn: Binding(
                        get: { appState.config.groupHoldings },
                        set: { appState.config.groupHoldings = $0 }
                    ))
                    .padding(.leading, 8)
                }

                // 观察仓管理
                section("观察仓") {
                    // 当前选择
                    Picker("", selection: Binding(
                        get: { appState.config.activeWatchlistId ?? "__real__" },
                        set: { appState.config.activeWatchlistId = $0 == "__real__" ? nil : $0 }
                    )) {
                        Text("真实持仓").tag("__real__")
                        ForEach(appState.watchlists) { wl in
                            Text(wl.name).tag(wl.id)
                        }
                    }.pickerStyle(.menu)

                    // 新建
                    HStack(spacing: 6) {
                        TextField("新观察仓名称", text: $newWatchlistName)
                            .textFieldStyle(.roundedBorder)
                        Button("新建") {
                            let name = newWatchlistName.trimmingCharacters(in: .whitespaces)
                            guard !name.isEmpty else { return }
                            appState.watchlists.append(Watchlist(name: name))
                            newWatchlistName = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .padding(.leading, 8)

                    // 列表（删除）
                    if !appState.watchlists.isEmpty {
                        ForEach(appState.watchlists) { wl in
                            HStack {
                                Text(wl.name).font(.system(size: 12))
                                Spacer()
                                if appState.config.activeWatchlistId == wl.id {
                                    Text("当前").font(.caption).foregroundColor(.accentColor)
                                }
                                Button {
                                    appState.watchlists.removeAll { $0.id == wl.id }
                                    if appState.config.activeWatchlistId == wl.id {
                                        appState.config.activeWatchlistId = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // 排序规则
                section("排序规则") {
                    Picker("", selection: Binding(
                        get: { appState.config.sortRule },
                        set: { appState.config.sortRule = $0 }
                    )) {
                        ForEach(SortRule.allCases, id: \.rawValue) { rule in
                            Text(rule.displayName).tag(rule)
                        }
                    }.pickerStyle(.segmented)
                }

                // 美股排序价格
                section("美股排序价格") {
                    Picker("", selection: Binding(
                        get: { appState.config.usPriceMode },
                        set: { appState.config.usPriceMode = $0 }
                    )) {
                        ForEach(USPriceMode.allCases, id: \.rawValue) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }.pickerStyle(.segmented)
                }

                // 刷新间隔
                section("刷新间隔") {
                    Picker("", selection: Binding(
                        get: { appState.refreshInterval },
                        set: { appState.refreshInterval = $0; appState.restartScheduler() }
                    )) {
                        ForEach(AppSettings.validRefreshIntervals, id: \.self) { i in
                            Text("\(i) 秒").tag(i)
                        }
                    }.pickerStyle(.segmented)
                }

                // 涨跌颜色
                section("涨跌颜色") {
                    HStack(spacing: 8) {
                        ForEach(ColorTheme.allCases, id: \.rawValue) { scheme in
                            colorCard(scheme)
                        }
                    }
                }

                // 持仓汇总货币
                section("持仓汇总货币") {
                    Picker("", selection: Binding(
                        get: { appState.displayCurrency },
                        set: { appState.displayCurrency = $0 }
                    )) {
                        ForEach(DisplayCurrency.allCases, id: \.rawValue) { c in
                            Text(c.displayName).tag(c)
                        }
                    }.pickerStyle(.segmented)
                }

                // 到价提醒：通知权限 + 测试
                section("到价提醒") {
                    PriceAlertPermissionRow()
                }
    } // end generalPane

    // MARK: - 股票 Tab

    @ViewBuilder private var stocksPane: some View {
                // 添加股票
                section("添加股票") {
                    HStack {
                        TextField("代码 / 名称 / Samsung / 005930.ks", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { search() }
                        if isSearching {
                            ProgressView().scaleEffect(0.6)
                        } else {
                            Button("搜索") { search() }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                        }
                    }
                    if let error = searchError, !isSearching {
                        Text("⚠️ \(error)")
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    } else if hasSearched && !isSearching && searchResults.isEmpty {
                        Text("未找到匹配的股票，试试完整代码，如 sh000001 / hk00700 / 005930.ks")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(searchResults) { r in
                                Button { addStock(r) } label: {
                                    HStack {
                                        Text(r.name).font(.system(size: 12))
                                        Spacer()
                                        Text(r.id).font(.caption).foregroundColor(.secondary)
                                        Text(r.market.rawValue).font(.caption).foregroundColor(.accentColor)
                                    }.padding(.vertical, 4)
                                }.buttonStyle(.plain)
                                Divider()
                            }
                        }
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)
                    }
                }

                // 已有股票：设置了持仓的排在前面，未设置持仓的在后
                if !appState.stocks.isEmpty {
                    section("我的股票") {
                        ForEach(sortedStocksForSettings) { s in stockRow(s) }
                    }
                }
    } // end stocksPane

    // MARK: - 关于 Tab

    @ViewBuilder private var aboutPane: some View {
        section("应用") {
            HStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .cornerRadius(8)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Stockbar")
                        .font(.system(size: 13, weight: .semibold))
                    Text("版本 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if updater.isBusy {
                    HStack(spacing: 4) {
                        ProgressView().scaleEffect(0.6)
                        Text(updater.status)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if !updater.status.isEmpty {
                    Text(updater.status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Button("检查更新") {
                        updater.checkAndUpdate()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }

        section("相关链接") {
            VStack(alignment: .leading, spacing: 6) {
                Link(destination: URL(string: "https://github.com/gly/StockBar")!) {
                    Label("github.com/gly/StockBar", systemImage: "link")
                        .font(.system(size: 12))
                }
                Link(destination: URL(string: "https://gitee.com/leoder/stock-bar")!) {
                    Label("gitee.com/leoder/stock-bar", systemImage: "link")
                        .font(.system(size: 12))
                }
            }
        }
    }
    // MARK: - 排序辅助

    /// 设置页"我的股票"排序：有持仓（成本 + 股数都设置了）的排在前面，
    /// 其它的排在后面；组内保持原顺序。
    private var sortedStocksForSettings: [Stock] {
        let withHolding = appState.stocks.filter {
            appState.effectiveCostPrice(for: $0) != nil
                && appState.effectiveShares(for: $0) != nil
        }
        let withoutHolding = appState.stocks.filter {
            appState.effectiveCostPrice(for: $0) == nil
                || appState.effectiveShares(for: $0) == nil
        }
        return withHolding + withoutHolding
    }

    // MARK: - 子视图

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            content()
        }
    }

    @ViewBuilder
    private func colorCard(_ scheme: ColorTheme) -> some View {
        let selected = appState.colorScheme == scheme
        Button { appState.colorScheme = scheme } label: {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text("涨").foregroundColor(scheme == .chinese ? .red : .green)
                    Text("跌").foregroundColor(scheme == .chinese ? .green : .red)
                }.font(.system(size: 12, weight: .medium))
                Text(scheme.displayName).font(.caption2).foregroundColor(.secondary)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(selected ? Color.accentColor.opacity(0.15)
                                  : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(selected ? Color.accentColor : Color.clear, lineWidth: 1.5))
        }.buttonStyle(.plain)
    }

    @ViewBuilder
    private func stockRow(_ stock: Stock) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.name).font(.system(size: 12))
                if let c = appState.effectiveCostPrice(for: stock),
                   let sh = appState.effectiveShares(for: stock) {
                    Text("成本 \(String(format: "%.3f", c)) × \(String(format: "%.0f", sh)) 股")
                        .font(.caption).foregroundColor(.secondary)
                } else {
                    Text("未设置持仓").font(.caption).foregroundColor(.secondary)
                }
                if let alert = stock.alert, alert.isEnabled {
                    Label(alert.summary, systemImage: "bell.fill")
                        .font(.caption).foregroundColor(.accentColor)
                }
            }
            Spacer()
            Button {
                editingStock = stock
                editCost     = appState.effectiveCostPrice(for: stock).map { String($0) } ?? ""
                editShares   = appState.effectiveShares(for: stock).map { String(Int($0)) } ?? ""
                editTarget   = stock.alert.map { String($0.targetPrice) } ?? ""
                editAlertOn  = stock.alert?.isEnabled ?? false
            } label: { Image(systemName: "pencil").font(.system(size: 11)) }
            .buttonStyle(.plain)

            Button {
                appState.stocks.removeAll { $0.id == stock.id }
                if appState.statusBarStockId == stock.id { appState.statusBarStockId = "" }
            } label: { Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.red) }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func inlineEditView(_ stock: Stock) -> some View {
        VStack(spacing: 12) {
            HStack {
                Button { editingStock = nil } label: {
                    Image(systemName: "chevron.left")
                }.buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 2) {
                    Text("编辑 \(stock.name)").font(.headline)
                    Text(appState.activeWatchlistName)
                        .font(.caption).foregroundColor(.accentColor)
                }
            }
            Divider()
            HStack {
                Text("成本价")
                TextField("如 10.50", text: $editCost).textFieldStyle(.roundedBorder).frame(width: 100)
            }
            HStack {
                Text("持仓股数")
                TextField("如 1000", text: $editShares).textFieldStyle(.roundedBorder).frame(width: 100)
            }
            Divider()
            // 传当前最新的股票（提醒可能在编辑期间被触发关闭）
            PriceAlertEditor(stock: appState.stocks.first(where: { $0.id == stock.id }) ?? stock,
                             targetText: $editTarget, isEnabled: $editAlertOn)
            HStack {
                Button("取消") { editingStock = nil }.buttonStyle(.bordered)
                Button("保存") {
                    let saved = appState.saveEdit(stockId: stock.id,
                                                  cost: Double(editCost), shares: Double(editShares),
                                                  alertTargetText: editTarget, alertEnabled: editAlertOn)
                    // 开着提醒时，第一次在这里申请通知权限
                    if saved?.isEnabled == true {
                        Task { await NotificationService.shared.requestAuthorizationIfNeeded() }
                    }
                    editingStock = nil
                }.buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - 搜索逻辑

    private func search() {
        guard !searchText.isEmpty else { return }
        isSearching = true; hasSearched = true; searchError = nil; searchResults = []
        Task { await runSearch(searchText) }
    }

    /// `op` 超过 `seconds` 秒未完成则抛出超时错误，底层请求会被取消。
    /// 防止单个数据源连接挂起（如 QUIC/UDP 探测包被网络静默丢弃、TLS 握手无响应）拖死整个搜索。
    private nonisolated static func withTimeout<T: Sendable>(_ seconds: Double,
                                                 _ op: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await op() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw URLError(.timedOut)
            }
            let first = try await group.next()!
            group.cancelAll()
            return first
        }
    }

    /// 渐进式搜索：腾讯（A股/港股/美股）结果先到先显示，Yahoo 韩股随后合并。
    /// 每个来源限时 5 秒；全空时走新浪兜底 → 直接代码兜底。
    /// 网络失败与“无结果”分开处理：全部失败且兜底也无结果时，展示报错提示。
    private func runSearch(_ keyword: String) async {
        var seen = Set<String>()
        var merged: [SearchResult] = []
        var failure: String?

        do {
            let tencent = try await Self.withTimeout(5) { try await Self.tencentSearch(keyword) }
            for r in tencent where !seen.contains(r.id) {
                seen.insert(r.id)
                merged.append(r)
            }
        } catch {
            failure = Self.describe(error)
        }
        await MainActor.run {
            if keyword == self.searchText {
                searchResults = merged; isSearching = false; searchError = nil
            }
        }

        if Self.shouldQueryKorean(keyword) {
            do {
                let korean = try await Self.withTimeout(5) { try await Self.yahooKoreanSearch(keyword) }
                for r in korean where !seen.contains(r.id) {
                    seen.insert(r.id)
                    merged.append(r)
                }
            } catch {
                failure = failure ?? Self.describe(error)
            }
            await MainActor.run {
                if keyword == self.searchText { searchResults = merged }
            }
        }

        guard merged.isEmpty else { return }
        // 全空：新浪兜底（覆盖指数、某些美股 ticker 等腾讯搜不到的品种）→ 直接代码兜底
        var results: [SearchResult]
        do {
            let sina = try await Self.withTimeout(5) { try await Self.sinaFetchSuggestions(keyword) }
            results = sina.isEmpty ? Self.directResult(for: keyword) : sina
        } catch {
            failure = failure ?? Self.describe(error)
            results = Self.directResult(for: keyword)
        }
        await MainActor.run {
            if keyword == self.searchText {
                searchResults = results
                // 有兜底结果就不算报错；一个结果都没有且来源失败 → 展示错误提示
                searchError = results.isEmpty ? (failure ?? "") : nil
            }
        }
    }

    /// 把底层错误转成用户能看懂的简短提示
    private nonisolated static func describe(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:                 return "搜索超时（5 秒），请检查网络后重试"
            case .notConnectedToInternet:   return "无网络连接"
            case .cannotFindHost, .dnsLookupFailed: return "无法解析数据源域名，请检查 DNS/网络"
            case .cancelled:                return "搜索已被取消"
            default:                        return "网络错误（代码 \(urlError.code.rawValue)）"
            }
        }
        return "搜索失败：\(error.localizedDescription)"
    }

    /// 腾讯搜索（A股/港股/美股）。网络失败抛错；接口正常但无匹配返回空数组。
    private nonisolated static func tencentSearch(_ keyword: String) async throws -> [SearchResult] {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://proxy.finance.qq.com/ifzqgtimg/appstock/smartbox/search/get?q=\(encoded)") else { return [] }
        var req = URLRequest(url: url)
        req.timeoutInterval = 5
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any],
              let stocks = dataObj["stock"] as? [[String]] else {
            return []
        }
        return stocks.compactMap { item -> SearchResult? in
            guard item.count >= 3 else { return nil }
            let mkt  = item[0].lowercased()
            let code = item[1].lowercased()
            let name = item[2]
            switch mkt {
            case "sh", "sz", "bj": return SearchResult(id: "\(mkt)\(code)", name: name, market: .aStock)
            case "hk":             return SearchResult(id: "hk\(code)",      name: name, market: .hkStock)
            case "us":
                let parts = code.components(separatedBy: ".")
                let ticker = (parts.count > 1 ? parts.dropLast().joined(separator: ".") : code).lowercased()
                return SearchResult(id: "usr_\(ticker)", name: name, market: .usStock)
            default: return nil
            }
        }
    }

    /// 是否同时跑一次 Yahoo 韩股搜索：
    /// - 含 Hangul / 带 .ks/.kq 后缀 / kr_ 前缀 → 一定
    /// - 6 位纯数字（韩股代码长度）→ 一定（即便腾讯能搜到 A 股，同号韩股也想看到）
    /// - 纯字母长度 ≥ 3 → 一定（公司名）
    /// 其它（短数字、特殊字符）跳过 Yahoo，省一次请求
    private nonisolated static func shouldQueryKorean(_ s: String) -> Bool {
        let k = s.trimmingCharacters(in: .whitespaces)
        let lower = k.lowercased()
        if lower.hasSuffix(".ks") || lower.hasSuffix(".kq") { return true }
        if lower.hasPrefix("kr_") { return true }
        if k.unicodeScalars.contains(where: { $0.value >= 0xAC00 && $0.value <= 0xD7AF }) { return true }
        if k.count == 6, k.allSatisfy(\.isNumber) { return true }
        if k.count >= 3, k.allSatisfy({ $0.isLetter }) { return true }
        return false
    }

    /// Yahoo /v1/finance/search — 仅返回韩股（KSC / KOE 两种 exchange）。网络失败抛错。
    private nonisolated static func yahooKoreanSearch(_ keyword: String) async throws -> [SearchResult] {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://query1.finance.yahoo.com/v1/finance/search?q=\(encoded)&quotesCount=10") else {
            return []
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 5
        req.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let quotes = root["quotes"] as? [[String: Any]] else { return [] }
        return quotes.compactMap { q -> SearchResult? in
            guard (q["quoteType"] as? String) == "EQUITY",
                  let symbol = q["symbol"] as? String else { return nil }
            // 韩股 symbol 以 .KS / .KQ 结尾
            let upper = symbol.uppercased()
            guard upper.hasSuffix(".KS") || upper.hasSuffix(".KQ") else { return nil }
            let id = KoreanStockID.fromYahooSymbol(symbol)
            let name = (q["shortname"] as? String) ?? (q["longname"] as? String) ?? symbol
            return SearchResult(id: id, name: name, market: .krStock)
        }
    }

    /// 新浪 suggest 兜底（覆盖指数、美股/期货等腾讯接口搜不到的品种）。网络失败抛错。
    ///
    /// 响应格式：`var suggestvalue="名称,类型,代码,内部ID,名称,...";`
    /// 示例：`sh000001,11,000001,sh000001,上证指数,,上证指数,99,1,,,,`
    /// 类型：11/14=A股，12=港股，13=美股。类型在第 2 个字段（p[1]）。
    private nonisolated static func sinaFetchSuggestions(_ keyword: String) async throws -> [SearchResult] {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://suggest3.sinajs.cn/suggest/type=11,12,13,14&key=\(encoded)") else {
            return directResult(for: keyword)
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 5
        let (data, _) = try await URLSession.shared.data(for: req)
        let body = StringDecoding.decodeGBK(data)
        guard let s = body.range(of: "\""),
              let e = body.lastIndex(of: "\""),
              e > s.upperBound else { return directResult(for: keyword) }
        let results = String(body[body.index(after: s.lowerBound)..<e])
            .components(separatedBy: ";")
            .filter { !$0.isEmpty }
            .compactMap { item -> SearchResult? in
                let p = item.components(separatedBy: ",")
                guard p.count >= 5 else { return nil }
                let market: Market; let id: String
                switch p[1] {
                case "11", "14": market = .aStock;  id = p[3].lowercased()
                case "12":       market = .hkStock; id = "hk" + p[3].lowercased()
                case "13":       market = .usStock; id = p[3].lowercased()
                default: return nil
                }
                return SearchResult(id: id, name: p[4].isEmpty ? p[0] : p[4], market: market)
            }
        return results.isEmpty ? directResult(for: keyword) : results
    }

    /// 将纯数字/字母输入当作直接代码（兜底）：6位数→sh，其余→sz
    private nonisolated static func directResult(for keyword: String) -> [SearchResult] {
        let k = keyword.lowercased().trimmingCharacters(in: .whitespaces)
        guard !k.isEmpty else { return [] }
        // 已有前缀（sh/sz/bj/hk/usr_）直接使用
        if k.hasPrefix("sh") || k.hasPrefix("sz") || k.hasPrefix("bj") {
            let market: Market = k.hasPrefix("hk") ? .hkStock : .aStock
            return [SearchResult(id: k, name: k.uppercased(), market: market)]
        }
        if k.hasPrefix("hk") {
            return [SearchResult(id: k, name: k.uppercased(), market: .hkStock)]
        }
        if k.hasPrefix("usr_") {
            return [SearchResult(id: k, name: k.uppercased(), market: .usStock)]
        }
        // 韩股：kr_005930.ks / 005930.ks / 005930.kq 形式
        if k.hasPrefix("kr_") {
            return [SearchResult(id: k, name: k.uppercased(), market: .krStock)]
        }
        if k.hasSuffix(".ks") || k.hasSuffix(".kq") {
            return [SearchResult(id: "kr_\(k)", name: k.uppercased(), market: .krStock)]
        }
        // 港股：4-5位纯数字，补齐5位前导零
        if k.allSatisfy(\.isNumber), k.count >= 4, k.count <= 5 {
            let padded = String(repeating: "0", count: 5 - k.count) + k
            return [SearchResult(id: "hk\(padded)", name: k, market: .hkStock)]
        }
        // A股：6位纯数字，0/3开头 → sz（深交所），其余 → sh（沪市）
        if k.allSatisfy(\.isNumber), k.count == 6 {
            let prefix = (k.hasPrefix("0") || k.hasPrefix("3")) ? "sz" : "sh"
            return [SearchResult(id: "\(prefix)\(k)", name: k, market: .aStock)]
        }
        return []
    }

    private func addStock(_ r: SearchResult) {
        guard !appState.stocks.contains(where: { $0.id == r.id }) else { return }
        appState.stocks.append(Stock(id: r.id, name: r.name, market: r.market,
                                     costPrice: nil, holdingShares: nil))
        searchText = ""; searchResults = []
        hasSearched = false; searchError = nil
    }
}
