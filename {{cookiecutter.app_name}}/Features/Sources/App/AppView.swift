//
//  AppView.swift
//  Features
//
//  Created by {{ cookiecutter.creator }} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Common
import ComposableArchitecture
import Counter
import SwiftUI

@MainActor
public struct AppView: View {
  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewstore in
      Text("\(viewstore.product?.title ?? "Unknown")")
      Text("\(viewstore.product?.description ?? "Unknown")")

      Button("Save") {
        viewstore.send(.view(.save))
      }

      Form {
        Button {
          viewstore.send(.view(.showSheet))
        } label: {
          Text("Sheet")
        }

        Button {
          viewstore.send(.view(.showFullScreenCover))
        } label: {
          Text("Full Screen Cover")
        }
      }
      .onAppear {
        viewstore.send(.view(.onAppear))
      }
      .destinations(with: store)
    }
  }
}

extension StoreOf<AppFeature> {
  fileprivate var destination: PresentationStoreOf<AppFeature.Destination> {
    scope(state: \.$destination, action: \.destination)
  }
}

@MainActor
extension View {
  fileprivate func destinations(with store: StoreOf<AppFeature>) -> some View {
    let destinationStore = store.destination
    return showSheet(with: destinationStore)
      .showFulllScreenCover(with: destinationStore)
  }

  private func showSheet(
    with destinationStore: PresentationStoreOf<AppFeature.Destination>
  ) -> some View {
    sheet(
      store:
        destinationStore.scope(
          state: \.sheet,
          action: \.sheet)
    ) { store in
      CounterView(store: store)
    }
  }

  private func showFulllScreenCover(
    with destinationStore: PresentationStoreOf<AppFeature.Destination>
  ) -> some View {
    fullScreenCover(
      store:
        destinationStore.scope(
          state: \.fullScreenCover,
          action: \.fullScreenCover)
    ) { store in
      CounterView(store: store)
    }
  }
}

#Preview {
  AppView(
    store:
      .init(
        initialState: AppFeature.State(),
        reducer: { AppFeature() }
      )
  )
}
