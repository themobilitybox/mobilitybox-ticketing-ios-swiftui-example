import Foundation
import Mobilitybox

class TicketElement: Equatable {
    static func == (lhs: TicketElement, rhs: TicketElement) -> Bool {
        return lhs.type == rhs.type && lhs.couponCode?.couponId == rhs.couponCode?.couponId && lhs.coupon == rhs.coupon && lhs.ticketCode == rhs.ticketCode && lhs.ticket == rhs.ticket
    }
    
    var type: String!
    var id: String!
    var couponCode: MobilityboxCouponCode?
    var coupon: MobilityboxCoupon?
    var ticketCode: MobilityboxTicketCode?
    var ticket: MobilityboxTicket?
    
    init(couponCode: MobilityboxCouponCode){
        self.type = "MobilityboxCouponCode"
        self.couponCode = couponCode
        self.id = getId()
    }
    
    init(coupon: MobilityboxCoupon){
        self.type = "MobilityboxCoupon"
        self.coupon = coupon
        self.id = getId()
    }
    
    init(ticketCode: MobilityboxTicketCode){
        self.type = "MobilityboxTicketCode"
        self.ticketCode = ticketCode
        self.id = getId()
    }
    
    init(ticket: MobilityboxTicket){
        self.type = "MobilityboxTicket"
        self.ticket = ticket
        self.id = getId()
    }
    
    func getId() -> String {
        switch self.type {
        case "MobilityboxCouponCode":
            return couponCode!.couponId
        case "MobilityboxCoupon":
            return coupon!.id
        case "MobilityboxTicketCode":
            return ticketCode!.ticketId
        case "MobilityboxTicket":
            return ticket!.id
        default:
            return ""
        }
    }
}

class ViewModel: ObservableObject {
    @Published var ticketElements = [TicketElement]()
    @Published var mobilityboxAPI = MobilityboxAPI(apiURL: "https://api-alpha.themobilitybox.com/v2", renderEngineURL: "https://ticket-rendering-engine-alpha.themobilitybox.com")
    @Published var renderEngine: MobilityboxTicketRenderingEngine!
    
    init() {
        self.renderEngine = MobilityboxTicketRenderingEngine(mobilityboxAPI: self.mobilityboxAPI)
    }
    
    func addElement(element: TicketElement, atIndex: Int?) {
        if atIndex != nil {
            ticketElements.insert(element, at: atIndex!)
        } else {
            ticketElements.append(element)
        }
    }
    
    func addCouponCode(couponCode: MobilityboxCouponCode, atIndex: Int? = nil){
        self.addElement(element: TicketElement(couponCode: couponCode), atIndex: atIndex)
        saveAllCouponCodes()
    }
    
    func addCoupon(coupon: MobilityboxCoupon, atIndex: Int? = nil){
        self.addElement(element: TicketElement(coupon: coupon), atIndex: atIndex)
        saveAllCoupons()
    }
    
    func addTicketCode(ticketCode: MobilityboxTicketCode, atIndex: Int? = nil){
        self.addElement(element: TicketElement(ticketCode: ticketCode), atIndex: atIndex)
        saveAllTicketCodes()
    }
    
    func addTicket(ticket: MobilityboxTicket, atIndex: Int? = nil){
        self.addElement(element: TicketElement(ticket: ticket), atIndex: atIndex)
        saveAllTickets()
    }
    
    func replaceCouponCodeWithCoupon(couponCode: MobilityboxCouponCode, coupon: MobilityboxCoupon) {
        let removedAtIndex = removeCouponCode(couponCode: couponCode)
        addCoupon(coupon: coupon, atIndex: removedAtIndex)
    }
    
    func replaceCouponWithTicketCode(coupon: MobilityboxCoupon, ticketCode: MobilityboxTicketCode) {
        let removedAtIndex = removeCoupon(coupon: coupon)
        addTicketCode(ticketCode: ticketCode, atIndex: removedAtIndex)
    }
    
    func replaceTicketCodeWithTicket(ticketCode: MobilityboxTicketCode, ticket: MobilityboxTicket) {
        let removedAtIndex = removeTicketCode(ticketCode: ticketCode)
        addTicket(ticket: ticket, atIndex: removedAtIndex)
    }
    
    func saveAllCouponCodes(){
        if let encodedTicketCodes = try? JSONEncoder().encode(ticketElements.filter{ ticketElement in
            return ticketElement.type == "MobilityboxCouponCode"
        }.map({ticketElement in
            ticketElement.couponCode!
        }) as [MobilityboxCouponCode]) {
            UserDefaults.standard.set(encodedTicketCodes, forKey: "savedCouponCodes")
        }
    }
    
    func saveAllCoupons(){
        if let encodedCoupons = try? JSONEncoder().encode(ticketElements.filter{ ticketElement in
            return ticketElement.type == "MobilityboxCoupon"
        }.map({ticketElement in
            ticketElement.coupon!
        }) as [MobilityboxCoupon]) {
            UserDefaults.standard.set(encodedCoupons, forKey: "savedCoupons")
        }
    }
    
    func saveAllTicketCodes(){
        if let encodedTicketCodes = try? JSONEncoder().encode(ticketElements.filter{ ticketElement in
            return ticketElement.type == "MobilityboxTicketCode"
        }.map({ticketElement in
            ticketElement.ticketCode!
        }) as [MobilityboxTicketCode]) {
            UserDefaults.standard.set(encodedTicketCodes, forKey: "savedTicketCodes")
        }
    }
    
    func saveAllTickets(){
        if let encodedTickets = try? JSONEncoder().encode(ticketElements.filter{ ticketElement in
            return ticketElement.type == "MobilityboxTicket"
        }.map({ticketElement in
            ticketElement.ticket!
        }) as [MobilityboxTicket]) {
            UserDefaults.standard.set(encodedTickets, forKey: "savedTickets")
        }
    }
    
    func loadAllData(completion: (() -> Void)?){
        loadCouponCodes(completion: completion)
        loadCoupons(completion: completion)
        loadTicketCodes(completion: completion)
        loadTickets(completion: completion)
    }
    
    func loadCouponCodes(completion: (() -> Void)?){
        if let data = UserDefaults.standard.data(forKey: "savedCouponCodes") {
            if let decodedTickets = try? JSONDecoder().decode([MobilityboxCouponCode].self, from: data) {
                decodedTickets.forEach({ couponCode in
                    self.ticketElements.append(TicketElement(couponCode: couponCode))
                    if completion != nil { completion!() }
                    
                    couponCode.fetchCoupon { coupon in
                        DispatchQueue.main.async {
                            self.replaceCouponCodeWithCoupon(couponCode: couponCode, coupon: coupon)
                            if completion != nil { completion!() }
                        }
                    }
                })
                return
            }
        }
    }
    
    func loadCoupons(completion: (() -> Void)?){
        if let data = UserDefaults.standard.data(forKey: "savedCoupons") {
            if let decodedTickets = try? JSONDecoder().decode([MobilityboxCoupon].self, from: data) {
                decodedTickets.forEach({ coupon in
                    self.ticketElements.append(TicketElement(coupon: coupon))
                    if completion != nil { completion!() }
                })
                return
            }
        }
    }
    
    func loadTicketCodes(completion: (() -> Void)?) {
        if let data = UserDefaults.standard.data(forKey: "savedTicketCodes") {
            if let decodedTickets = try? JSONDecoder().decode([MobilityboxTicketCode].self, from: data) {
                decodedTickets.forEach({ ticketCode in
                    self.ticketElements.append(TicketElement(ticketCode: ticketCode))
                    if completion != nil { completion!() }
                    
                    ticketCode.fetchTicket { ticket in
                        DispatchQueue.main.async {
                            self.replaceTicketCodeWithTicket(ticketCode: ticketCode, ticket: ticket)
                            if completion != nil { completion!() }
                        }
                    }
                })
                return
            }
        }
    }
    
    func loadTickets(completion: (() -> Void)?) {
        if let data = UserDefaults.standard.data(forKey: "savedTickets") {
            if let decodedTickets = try? JSONDecoder().decode([MobilityboxTicket].self, from: data) {
                decodedTickets.forEach({ ticket in
                    self.ticketElements.append(TicketElement(ticket: ticket))
                    if completion != nil { completion!() }
                })
                return
            }
        }
    }
    
    func removeAllData(){
        self.ticketElements = [TicketElement]()
        UserDefaults.standard.removeObject(forKey: "savedCouponCodes")
        UserDefaults.standard.removeObject(forKey: "savedCoupons")
        UserDefaults.standard.removeObject(forKey: "savedTicketCodes")
        UserDefaults.standard.removeObject(forKey: "savedTickets")
    }
    
    func removeCouponCode(couponCode: MobilityboxCouponCode) -> Int? {
        if let index = ticketElements.firstIndex(where: { ticketElement in
            return ticketElement.type == "MobilityboxCouponCode" && ticketElement.couponCode! == couponCode
        }) {
            ticketElements.remove(at: index)
            saveAllCouponCodes()
            return index
        }
        return nil
    }
    
    func removeCoupon(coupon: MobilityboxCoupon) -> Int? {
        if let index = ticketElements.firstIndex(where: { ticketElement in
            return ticketElement.type == "MobilityboxCoupon" && ticketElement.coupon! == coupon
        }) {
            ticketElements.remove(at: index)
            saveAllCoupons()
            return index
        }
        return nil
    }
    
    func removeTicketCode(ticketCode: MobilityboxTicketCode) -> Int? {
        if let index = ticketElements.firstIndex(where: { ticketElement in
            return ticketElement.type == "MobilityboxTicketCode" && ticketElement.ticketCode! == ticketCode
        }) {
            ticketElements.remove(at: index)
            saveAllTicketCodes()
            return index
        }
        return nil
    }
}
