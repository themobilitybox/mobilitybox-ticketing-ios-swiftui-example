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
                                TicketCardView(ticket: Binding(ticketElement.ticket)!, renderEngine: $viewModel.renderEngine)
                            default:
                                EmptyView()
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
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
        let couponCode = MobilityboxCouponCode(couponId: couponId, mobilityboxAPI: self.viewModel.mobilityboxAPI)
        
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
        }
    }
    
    func activateCouponCallback(coupon: MobilityboxCoupon, ticketCode: MobilityboxTicketCode) {
        self.viewModel.replaceCouponWithTicketCode(coupon: coupon, ticketCode: ticketCode)
        
        ticketCode.fetchTicket { ticket in
            DispatchQueue.main.async {
                self.viewModel.replaceTicketCodeWithTicket(ticketCode: ticketCode, ticket: ticket)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
