import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)

                TextField("Search apps or calculate...", text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20))
                    .onSubmit {
                        viewModel.executeSelected()
                        onDismiss()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if !viewModel.results.isEmpty {
                Divider()

                // Results list
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, result in
                                ResultRowView(
                                    result: result,
                                    isSelected: index == viewModel.selectedIndex,
                                    onHide: {
                                        if case .app(let item) = result {
                                            viewModel.settingsService?.ignore(path: item.path.path)
                                            viewModel.updateResults()
                                        }
                                    }
                                )
                                .id(result.id)
                                .onTapGesture {
                                    viewModel.selectedIndex = index
                                    viewModel.executeSelected()
                                    onDismiss()
                                }
                            }
                        }
                        .padding(6)
                    }
                    .onChange(of: viewModel.selectedIndex) { _, newValue in
                        if newValue < viewModel.results.count {
                            withAnimation(.easeOut(duration: 0.1)) {
                                proxy.scrollTo(viewModel.results[newValue].id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
    }
}
