import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        setupNavigationBar()
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                SwiftUI.List {
                    invitationsSection
                    todosSection
                }
                VStack {
                    addListButton
                    addListTextField
                }
            }
            .task() {
                viewModel.fetchData()
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("\(Constants.Title.title)")
        .navigationBarItems(
            trailing: navigationBarItems
        )
    }
}

// MARK: - ViewBuilders

private extension HomeView {
    @ViewBuilder
    var navigationBarItems: some View {
        HStack {
            Spacer()
            Button(
                action: {
                    viewModel.signOut()
                    coordinator.loggOut()
                }
            ) {
                AsyncImage(
                    url: URL(string: viewModel.userSelfPhoto),
                    content: {
                        $0.resizable().aspectRatio(contentMode: .fit)
                    }, placeholder: {
                        Image(systemName: Constants.Image.profilePlaceHolder)
                    })
                .frame(width: 30, height: 30)
                .cornerRadius(15.0)
            }
        }
    }
    
    @ViewBuilder
    var invitationsSection: some View {
        if !viewModel.invitations.isEmpty {
            Section(
                header:
                    Text(Constants.Title.invitations)
                    .foregroundColor(.buttonPrimary)
            ) {
                ForEach(viewModel.invitations) { invitation in
                    HStack {
                        VStack(alignment: .leading, content: {
                            Text("\(invitation.ownerName) (\(invitation.ownerEmail)) \n \(Constants.Title.wantsToShare) \(invitation.listName)")
                        })
                        Spacer()
                        TDButton(title: "\(Constants.Title.accept)") {
                            viewModel.importList(listId: invitation.listId,
                                                 invitationId: invitation.documentId)
                        }
                    }
                    .background()
                }
            }
        }
    }
    
    @ViewBuilder
    var todosSection: some View {
        Section(
            header:
                Text(Constants.Title.todoos)
                .foregroundColor(.buttonPrimary)
        ) {
            ListRowsView(viewModel: viewModel,
                         mainAction: itemViewMainAction,
                         swipeActions: itemViewOptionsAction)
        }
    }
    
    @ViewBuilder
    var addListButton: some View {
        if viewModel.isShowingAddButton {
            Spacer()
            Button(action: {
                viewModel.isShowingAddButton = false
                withAnimation(.easeOut(duration: 0.75)) {
                    viewModel.isShowingAddTextField = true
                }
            }, label: {
                Image(systemName: Constants.Image.addButton)
                    .resizable()
                    .frame(width: 48.0, height: 48.0)
            })
            .foregroundColor(.buttonPrimary)
        }
    }
    
    @ViewBuilder
    var addListTextField: some View {
        if viewModel.isShowingAddTextField {
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.75)) {
                        viewModel.isShowingAddTextField = false
                    } completion: {
                        viewModel.isShowingAddButton = true
                    }
                }, label: {
                    Image("")
                        .resizable()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity)
                        .ignoresSafeArea()
                })
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.75)) {
                                viewModel.isShowingAddTextField = false
                            } completion: {
                                viewModel.isShowingAddButton = true
                            }
                        },
                               label: {
                            Image(systemName: Constants.Image.closeAddListButton)
                                .resizable()
                                .frame(width: 16.0, height: 16.0)
                        })
                        .foregroundColor(.buttonPrimary)
                        .padding([.top, .trailing], 24.0)
                    }
                    TextField(Constants.Title.addList,
                              text: $viewModel.listName)
                    .textFieldStyle(BottomLineStyle() {
                        viewModel.createList()
                    })
                    .background(.white)
                }
                .background(
                    Color.white
                        .shadow(color: .buttonPrimary, radius: 6, x: 0, y: 10)
                        .mask(Rectangle().padding(.top, -25))
                )
            }
            .transition(.move(edge: .bottom))
        }
    }
}

// MARK: - Private

private extension HomeView {
    struct Constants {
        struct Title {
            static let title = "Todoo"
            static let invitations = "Invitations"
            static let todoos = "Todoos"
            static let wantsToShare = "wants to share"
            static let accept = "Accept"
            static let addList = "List name..."
        }
        struct Image {
            static let profilePlaceHolder = "person.crop.circle"
            static let addButton = "plus.circle.fill"
            static let closeAddListButton = "xmark"
        }
    }
    
    func setupNavigationBar() {
        UINavigationBar.appearance()
            .largeTitleTextAttributes = [
                .foregroundColor: UIColor(.buttonPrimary)
            ]
    }
    
    var itemViewMainAction: (any ListRow) -> Void {
        {
            guard let list = $0 as? List else { return }
            coordinator.push(.products(list))
        }
    }
    
    var itemViewOptionsAction: (Int, ListRowAction) -> Void {
        { index, option in
            if case .share = option {
                guard let list = viewModel.rows[index] as? List else {
                    return
                }
                coordinator.present(sheet: .shareList(list))
            } else {
                viewModel.onDidTapOption(index, option)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
