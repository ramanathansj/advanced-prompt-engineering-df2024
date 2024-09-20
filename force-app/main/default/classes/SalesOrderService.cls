
/**
 * @description       : Salesorder JSON generation service
 * @author            : Ramanathan
**/

public with sharing class SalesOrderService {
   
    @InvocableMethod(label='Get Sales Order Data JSON' description='returns Sales Order and Master data' category='InvoiceAI')
    public static OrdResponse[] getOrderJSON(List<Order> salesOrds) {
        List<Order> orders = [select Id, TotalAmount, OrderNumber, Account.Name, Account.TaxId__c, Supplier__r.Name, Supplier__r.TaxId__c,(Select Id, OrderItemNumber, quantity, UnitPrice, TotalPrice, Product2.Name, Product2.ProductCode From OrderItems) from Order where Id = :salesOrds[0].Id];
        OrdResponse ordRsp = new OrdResponse('', false);
        if(orders != Null && orders.size() > 0) {
            Order ord = orders[0];
            List<LineWrapper> items = new List<LineWrapper>();
            for (OrderItem item : ord.OrderItems) {
                LineWrapper lineWrap = new LineWrapper(item);
                items.add(lineWrap);
            }
            AccountWrapper client = new AccountWrapper(ord.Account.Name, ord.Account.TaxId__c);
            SupplierWrapper supplier = new SupplierWrapper(ord.Account.Name, ord.Supplier__r.TaxId__c);
            OrderWrapper ordWrap = new OrderWrapper(ord.Id,ord.OrderNumber, ord.TotalAmount, ord.Account.Name, items, client, supplier);
            ordRsp= new OrdResponse(JSON.serialize(ordWrap), true);
        }
        return new OrdResponse[]{ordRsp};
    }

    public class AccountWrapper {
        public String name;
        public String taxId;

        public AccountWrapper(String name, String taxId) {
            this.name = name;
            this.taxId = taxId;
        }
    }

    public class SupplierWrapper {
        public String name;
        public String suptaxId;

        public SupplierWrapper(String name, String taxId) {
            this.name = name;
            this.suptaxId = taxId;
        }
    }

    public class LineWrapper {
        public String lineNumber;
        public String productCode;
        public String productName;
        public Decimal unitPrice;
        public Decimal totalPrice;
        public Decimal quantity;

        public LineWrapper(OrderItem item) {
            this.lineNumber = item.OrderItemNumber;
            this.productCode = item.Product2.ProductCode;
            this.productName = item.Product2.Name;
            this.unitPrice = item.UnitPrice;
            this.quantity = item.quantity;
            this.totalPrice = item.TotalPrice;
        }
    }

    public class OrderWrapper {
        public Id orderId;
        public String orderNumber;
        public Decimal totalAmount;
        public string accountName;
        public List<LineWrapper> orderItems;
        public AccountWrapper client;
        public SupplierWrapper supplier;

        public OrderWrapper(Id oId, String ordNum, Decimal amount, String accName, List<LineWrapper> items, AccountWrapper c, SupplierWrapper s) {
            this.orderId = oId;
            this.orderNumber = ordNum;
            this.totalAmount = amount;
            this.accountName = accName;
            this.orderItems = items;
            this.client = c;
            this.supplier = s;
        }
    }

    public class OrdResponse {
        @InvocableVariable public String orderJS;
        @InvocableVariable public Boolean status;

        public OrdResponse(String ord, Boolean st) {
            this.orderJS = ord;
            this.status = st;
        }
    }

}