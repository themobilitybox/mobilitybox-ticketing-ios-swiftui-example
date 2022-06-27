import SwiftUI
import Mobilitybox

struct CouponCardView: View {
    @Binding var coupon: MobilityboxCoupon
    @State var showIdentificationView = false
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    
    @State var showDestinationView = false
    
    var body: some View {
        MobilityboxNavigationLink(linkType: .modal) {
            MobilityboxCardView(coupon: $coupon)
        } navigationDestination: {
            MobilityboxIdentificationView(coupon: $coupon, activateCouponCallback: activateCouponCallback)
        }
    }
}
