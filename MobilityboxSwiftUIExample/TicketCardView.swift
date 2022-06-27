import SwiftUI
import Mobilitybox

struct TicketCardView: View {
    @Binding var ticket: MobilityboxTicket
    @Binding var renderEngine: MobilityboxTicketRenderingEngine
    @State var showTicketInspectionView = false
    
    var body: some View {
        MobilityboxNavigationLink(linkType: .modal) {
            MobilityboxCardView(ticket: $ticket)
        } navigationDestination: {
            MobilityboxTicketInspectionView(ticket: ticket, renderEngine: $renderEngine)
        }
    }
}
