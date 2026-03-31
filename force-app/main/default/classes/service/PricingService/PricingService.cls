public class PricingService {

    public static void validateRequiredParameters(List<OrderItem> items){

        for(OrderItem item : items){

            if(item.Production_Cost__c == null ||
               item.Shipping_Cost__c == null ||
               item.Tax_Percentage__c == null ||
               item.Margin_Percentage__c == null){

                item.addError(
                    'Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato o time de pricing.'
                );
            }
        }
    }

    public static void calculatePricing(List<OrderItem> items){

        for(OrderItem item : items){

            Decimal cost = item.Production_Cost__c != null ? item.Production_Cost__c : 0;
            Decimal freight = item.Shipping_Cost__c != null ? item.Shipping_Cost__c : 0;
            Decimal tax = item.Tax_Percentage__c != null ? item.Tax_Percentage__c : 0;
            Decimal margin = item.Margin_Percentage__c != null ? item.Margin_Percentage__c : 0;
            Decimal sellingPrice = item.Selling_Price__c != null ? item.Selling_Price__c : 0;

            Decimal priceWithoutMargin = (cost + freight) * (1 + (tax / 100));
            priceWithoutMargin = priceWithoutMargin.setScale(2);

            Decimal finalPrice = priceWithoutMargin * (1 + (margin / 100));
            finalPrice = finalPrice.setScale(2);

            Decimal discount = 0;

            if(finalPrice > 0){
                discount = (finalPrice - sellingPrice) / finalPrice;

                if(discount < 0){
                    discount = 0;
                }

                discount = discount.setScale(2);
            }

            item.Price_without_margin__c = priceWithoutMargin;
            item.Final_Price__c = finalPrice;
            item.Discount__c = discount;
        }
    }
}