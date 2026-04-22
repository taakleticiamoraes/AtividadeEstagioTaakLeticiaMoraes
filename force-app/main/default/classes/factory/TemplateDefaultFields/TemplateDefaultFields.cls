public class TemplateDefaultFields {
    
    public interface FieldDefaults {
    Map<String, Object> getFieldDefaults(Decimal count);    }
    
    public class CountryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Country__c country;
            
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            return new Map<String, Object>{
                'Acronym__c' => 'BR'
            };
        }
    }
    
    public class StateDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Country__c country;
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            State__c state;
            List<State__c> states = [
            SELECT Id FROM State__c 
            WHERE Acronym__c = 'SP'
            AND Country__c = :country.Id
            LIMIT 1
        ];
            
            if (!states.isEmpty()) {
                state = states[0];
            } else {
                state = new State__c(
                    Country__c = country.Id,
                Acronym__c = 'SP'
                    );
                insert state;
            }
            
            return new Map<String, Object>{
                'Country__c' => country.Id,
                'Acronym__c' => 'SP'
            };
        }
    }
    
    public class CityDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Country__c country;
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            State__c state;
            List<State__c> states = [
            SELECT Id FROM State__c 
            WHERE Acronym__c = 'SP'
            AND Country__c = :country.Id
            LIMIT 1
        ];
            
            if (!states.isEmpty()) {
                state = states[0];
            } else {
                state = new State__c(
                    Country__c = country.Id,
                Acronym__c = 'SP'
                    );
                insert state;
            }
            
            City__c city;
            List<City__c> cities = [
            SELECT Id FROM City__c 
            WHERE IBGE_Code__c = '3550308'
            AND State__c = :state.Id
            LIMIT 1
        ];
            
            if (!cities.isEmpty()) {
                city = cities[0];
            } else {
                city = new City__c(
                    State__c = state.Id,
                IBGE_Code__c = '3550308'
                    );
                insert city;
            }
            
            return new Map<String, Object>{
                'State__c' => state.Id,
                'IBGE_Code__c' => '3550308'
            };
        }
    }
    
    // =========================
    // ACCOUNT
    // =========================
    public class AccountDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Group_Account__c groupAcc = new Group_Account__c();
            insert groupAcc;
            
            Integer randomNum = Math.abs(Crypto.getRandomInteger());
            String seq = String.valueOf(randomNum).leftPad(14, '0').substring(0,14);
            
            return new Map<String, Object>{
                'Name' => 'Cliente Teste ' + count,
                'CNPJ__c' => seq,
                'Group_Account__c' => groupAcc.Id
            };
        }
    }
    
    // =========================
    // ADDRESS
    // =========================
    public class AddressDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Account acc = (Account) TestFactorySObject.getInstance()
                .createSObject(new Account());
            insert acc;
            
            Country__c country;
            
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            State__c state;
            
            List<State__c> states = [
            SELECT Id FROM State__c 
            WHERE Acronym__c = 'SP'
            AND Country__c = :country.Id
            LIMIT 1
        ];
            
            if (!states.isEmpty()) {
                state = states[0];
            } else {
                state = new State__c(
                    Country__c = country.Id,
                Acronym__c = 'SP'
                    );
                insert state;
            }
            
            City__c city;
            
            List<City__c> cities = [
            SELECT Id FROM City__c 
            WHERE IBGE_Code__c = '3550308'
            AND State__c = :state.Id
            LIMIT 1
        ];
            
            if (!cities.isEmpty()) {
                city = cities[0];
            } else {
                city = new City__c(
                    State__c = state.Id,
                IBGE_Code__c = '3550308'
                    );
                insert city;
            }
            return new Map<String, Object>{
                'Account__c' => acc.Id,
                'City__c' => city.Id,
                'Street__c' => 'Rua Teste ' + count,
                'CEP__c' => '00000000',
                'Neighborhood__c' => 'Centro'
            };
        }
    }
    
    // =========================
    // PRODUCT
    // =========================
    public class Product2Defaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
            insert hierarchy;
            
            return new Map<String, Object>{
                'Name' => 'Prod ' + System.currentTimeMillis(),
                'IsActive' => true,
                'Product_Hierarchy__c' => hierarchy.Id
            };
        }
    }
    
    // =========================
    // ORDER
    // =========================
    public class OrderDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Address__c add = (Address__c) TestFactorySObject.getInstance()
                .createSObject(new Address__c());
            insert add;
            
            Distribution_Center__c dc = new Distribution_Center__c();
            insert dc;
            
            Payment_Terms__c pt = new Payment_Terms__c();
            insert pt;
            
            Account acc = (Account) TestFactorySObject.getInstance()
                .createSObject(new Account());
            insert acc;
            
            return new Map<String, Object>{
                'Name' => 'Pedido ' + count,
                'Address__c' => add.Id,
                'AccountId' => acc.Id,
                'Status' => 'Draft',
                'EffectiveDate' => Date.today(),
                'Delivery_Date__c' => Date.today().addDays(5),
                'Type_of_shipping__c' => 'CIF',
                'Distribution_Center__c' => dc.Id,
                'Payment_Terms__c' => pt.Id,
                'Pricebook2Id' => Test.getStandardPricebookId()
            };
        }
    }
    
    // =========================
    // ORDER ITEM
    // =========================
    public class OrderItemDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
            insert hierarchy;
            
            Product2 prod = new Product2(Name = 'Prod ' + System.currentTimeMillis(), IsActive = true, Product_Hierarchy__c = hierarchy.Id);
            insert prod;
            
            Id pbId = Test.getStandardPricebookId();
            
            PricebookEntry pbe = getOrCreatePricebookEntry(prod, pbId);
            
            Account acc = (Account) TestFactorySObject.getInstance()
                .createSObject(new Account());
            insert acc;
            
            Order ord = (Order) TestFactorySObject.getInstance()
                .createSObject(new Order());
            
            ord.AccountId = acc.Id;
            ord.Pricebook2Id = pbId;
            
            insert ord;
            
            return new Map<String, Object>{
                'OrderId' => ord.Id,
                'PricebookEntryId' => pbe.Id,
                'Quantity' => 1,
                'UnitPrice' => 100,
                'Selling_Price__c' => 100,
                'Production_Cost__c' => 50,
                'Shipping_Cost__c' => 10,
                'Tax_Percentage__c' => 5,
                'Margin_Percentage__c' => 10
            };
        }
        
        @TestVisible
        private PricebookEntry getOrCreatePricebookEntry(Product2 prod, Id pbId) {
            List<PricebookEntry> existingPbe = [
                SELECT Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :pbId
                AND Product2Id = :prod.Id
                LIMIT 1
            ];
            
            if (!existingPbe.isEmpty()) {
                return existingPbe[0];
            }
            
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = pbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
                );
            insert pbe;
            
            return pbe;
        }
    }
    
    // =========================
    // TAX
    // =========================
    public class TaxDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Product2 prod;
            
            List<Product2> prods = [SELECT Id FROM Product2 LIMIT 1];
            
            if (!prods.isEmpty()) {
                prod = prods[0];
            } else {
                prod = (Product2) TestFactorySObject.getInstance()
                    .createSObject(new Product2());
                insert prod;
            }
            
            Distribution_Center__c dc;
            List<Distribution_Center__c> dcs = [SELECT Id FROM Distribution_Center__c LIMIT 1];
            
            if (!dcs.isEmpty()) {
                dc = dcs[0];
            } else {
                dc = new Distribution_Center__c();
                insert dc;
            }
            
            Country__c country;
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            State__c state;
            List<State__c> states = [
            SELECT Id FROM State__c 
            WHERE Acronym__c = 'SP'
            AND Country__c = :country.Id
            LIMIT 1
        ];
            
            if (!states.isEmpty()) {
                state = states[0];
            } else {
                state = new State__c(
                    Acronym__c = 'SP',
                Country__c = country.Id
                    );
                insert state;
            }
            
            return new Map<String, Object>{
                'Product__c' => prod.Id,
                'Distribution_Center__c' => dc.Id,
                'State__c' => state.Id,
                'Status__c' => 'Approved',
                'Tax_on_cost__c' => 15
            };
        }
    }
    
    // =========================
    // FREIGHT
    // =========================
    public class FreightDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Product2 prod;
            
            List<Product2> prods = [SELECT Id FROM Product2 LIMIT 1];
            
            if (!prods.isEmpty()) {
                prod = prods[0];
            } else {
                prod = (Product2) TestFactorySObject.getInstance()
                    .createSObject(new Product2());
                insert prod;
            }
            
            Distribution_Center__c dc;
            List<Distribution_Center__c> dcs = [SELECT Id FROM Distribution_Center__c LIMIT 1];
            
            if (!dcs.isEmpty()) {
                dc = dcs[0];
            } else {
                dc = new Distribution_Center__c();
                insert dc;
            }
            
            Country__c country;
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            State__c state;
            List<State__c> states = [
            SELECT Id FROM State__c 
            WHERE Acronym__c = 'SP'
            AND Country__c = :country.Id
            LIMIT 1
        ];
            
            if (!states.isEmpty()) {
                state = states[0];
            } else {
                state = new State__c(
                    Country__c = country.Id,
                Acronym__c = 'SP'
                    );
                insert state;
            }
            
            City__c city;
            List<City__c> cities = [
            SELECT Id FROM City__c 
            WHERE IBGE_Code__c = '3550308'
            AND State__c = :state.Id
            LIMIT 1
        ];
            
            if (!cities.isEmpty()) {
                city = cities[0];
            } else {
                city = new City__c(
                    State__c = state.Id,
                IBGE_Code__c = '3550308'
                    );
                insert city;
            }
            
            return new Map<String, Object>{
                'Product__c' => prod.Id,
                'Distribution_Center__c' => dc.Id,
                'City__c' => city.Id,
                'Status__c' => 'Approved',
                'Value__c' => 25
            };
        }
    }
    
    // =========================
    // MARGIN
    // =========================
    public class MarginDefaults implements FieldDefaults {
        
        public Map<String, Object> getFieldDefaults(Decimal count) {
            
            Account acc = (Account) TestFactorySObject.getInstance()
                .createSObject(new Account());
            insert acc;
            
            Product2 prod;
            
            List<Product2> prods = [SELECT Id FROM Product2 LIMIT 1];
            
            if (!prods.isEmpty()) {
                prod = prods[0];
            } else {
                prod = (Product2) TestFactorySObject.getInstance()
                    .createSObject(new Product2());
                insert prod;
            }
            
            Distribution_Center__c dc;
            List<Distribution_Center__c> dcs = [SELECT Id FROM Distribution_Center__c LIMIT 1];
            
            if (!dcs.isEmpty()) {
                dc = dcs[0];
            } else {
                dc = new Distribution_Center__c();
                insert dc;
            }
            
            Country__c country;
            List<Country__c> countries = [
            SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1
        ];
            
            if (!countries.isEmpty()) {
                country = countries[0];
            } else {
                country = new Country__c(Acronym__c = 'BR');
                insert country;
            }
            
            State__c state;
            List<State__c> states = [
            SELECT Id FROM State__c 
            WHERE Acronym__c = 'SP'
            AND Country__c = :country.Id
            LIMIT 1
        ];
            
            if (!states.isEmpty()) {
                state = states[0];
            } else {
                state = new State__c(
                    Acronym__c = 'SP',
                Country__c = country.Id
                    );
                insert state;
            }
            
            return new Map<String, Object>{
                'Account__c' => acc.Id,
                'Product__c' => prod.Id,
                'Distribution_Center__c' => dc.Id,
                'State__c' => state.Id,
                'Status__c' => 'Approved',
                'Value__c' => 20
            };
        }
    }
}