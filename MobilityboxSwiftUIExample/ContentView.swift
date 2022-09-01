import SwiftUI
import Mobilitybox

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State private var showAddCouponView = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($viewModel.ticketElements, id: \.id) { ticketElement in
                        VStack {
                            switch ticketElement.wrappedValue.type {
                            case "MobilityboxCouponCode":
                                MobilityboxCardView()
                            case "MobilityboxCoupon":
                                CouponCardView(coupon: Binding(ticketElement.coupon)!, activateCouponCallback: activateCouponCallback)
                            case "MobilityboxTicketCode":
                                MobilityboxCardView()
                            case "MobilityboxTicket":
                                TicketCardView(ticket: Binding(ticketElement.ticket)!)
                            default:
                                EmptyView()
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                withAnimation {
                                    self.viewModel.removeTicketElement(ticketElementId: ticketElement.wrappedValue.id)
                                }
                            } label: {
                                Image(systemName: "trash")
                            }.tint(.red)
                        }
                        .compositingGroup()
                        .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .listRowBackground(Color.white.opacity(0.0))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAddCouponView.toggle()
                    } label: {
                        Label("", systemImage: "plus")
                    }
                    .sheet(isPresented: $showAddCouponView) {
                        AddCouponCodeView(addCouponIdCallback: self.addCouponIdCallback)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.viewModel.removeAllData()
                    } label: {
                        Label("", systemImage: "trash")
                    }
                }
            }
        }.onAppear {
            self.viewModel.loadAllData {}
        }
    }
    
    func addCouponIdCallback(couponId: String) {
        let couponCode = MobilityboxCouponCode(couponId: couponId)
        self.viewModel.addCouponCode(couponCode: couponCode)
        
        if let couponCodeIndex = self.viewModel.ticketElements.firstIndex(where: { ticketElement in
            return ticketElement.type == "MobilityboxCouponCode" && ticketElement.couponCode! == couponCode
        }) {
            
            print("scroll to item at: \(couponCodeIndex)")
        }
        
        couponCode.fetchCoupon { coupon in
            DispatchQueue.main.async {
                self.viewModel.replaceCouponCodeWithCoupon(couponCode: couponCode, coupon: coupon)
            }
        } onFailure: { error in
            DispatchQueue.main.async {
                let _ = self.viewModel.removeCouponCode(couponCode: couponCode)
            }
        }
    }
    
    func activateCouponCallback(coupon: MobilityboxCoupon, ticketCode: MobilityboxTicketCode) {
        self.viewModel.replaceCouponWithTicketCode(coupon: coupon, ticketCode: ticketCode)
        
        fetchTicketAndReplace(ticketCode: ticketCode)
    }
    
    func fetchTicketAndReplace(ticketCode: MobilityboxTicketCode) {
        ticketCode.fetchTicket { ticket in
            DispatchQueue.main.async {
                self.viewModel.replaceTicketCodeWithTicket(ticketCode: ticketCode, ticket: ticket)
            }
        } onFailure: { error in
            if error == .retry_later {
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: TimeInterval(2.0), repeats: false){_ in
                        print("Ticket not available ... retry")
                        fetchTicketAndReplace(ticketCode: ticketCode)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
