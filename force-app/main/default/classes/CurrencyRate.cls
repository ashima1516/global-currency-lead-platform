public class CurrencyRateService {

    public static void getRate(String baseCurrency, String targetCurrency) {

        DateTime startTime = System.now();

        HttpRequest request = new HttpRequest();

        request.setEndpoint(
            'callout:Currency_API/v2/rate/'
            + baseCurrency.toLowerCase()
            + '/'
            + targetCurrency.toLowerCase()
        );

        request.setMethod('GET');

        try {

            Http http = new Http();

            HttpResponse response = http.send(request);

            Long responseTime =
    DateTime.now().getTime() - startTime.getTime();

            // SUCCESS
            if (response.getStatusCode() == 200) {

                Map<String, Object> data =
                    (Map<String, Object>) JSON.deserializeUntyped(
                        response.getBody()
                    );

                String baseCurrencyFromApi =
                    (String) data.get('base');

                String targetCurrencyFromApi =
                    (String) data.get('quote');

                Decimal rate =
                    (Decimal) data.get('rate');

                Date rateDate =
                    Date.valueOf((String) data.get('date'));

                // Create Exchange Rate record
                Exchange_Rate__c exchangeRate =
                    new Exchange_Rate__c();

                exchangeRate.Base_Currency__c =
                    baseCurrencyFromApi;

                exchangeRate.Target_Currency__c =
                    targetCurrencyFromApi;

                exchangeRate.Exchange_Rate__c =
                    rate;

                exchangeRate.Rate_Date__c =
                    rateDate;

                exchangeRate.API_Source__c =
                    'Frankfurter API';

                exchangeRate.Status__c =
                    'Success';

                insert exchangeRate;


                // Create SUCCESS Integration Log
                Integration_Log__c log =
                    new Integration_Log__c();

                log.Integration_Name__c =
                    'Currency API';

                log.Endpoint__c =
                    request.getEndpoint();

                log.Request_Type__c =
                    'Get';

                log.HTTP_Status_Code__c =
                    response.getStatusCode();

                log.Response_Time_ms__c =
                    responseTime;

                log.Status__c =
                    'Success';

                insert log;


                System.debug(
                    'Exchange Rate created: '
                    + exchangeRate.Id
                );

            }

            // API returned an error
            else {

                Integration_Log__c log =
                    new Integration_Log__c();

                log.Integration_Name__c =
                    'Currency API';

                log.Endpoint__c =
                    request.getEndpoint();

                log.Request_Type__c =
                    'Get';

                log.HTTP_Status_Code__c =
                    response.getStatusCode();

                log.Response_Time_ms__c =
                    responseTime;

                log.Error_Message__c =
                    response.getBody();

                log.Status__c =
                    'Failed';

                insert log;


                System.debug(
                    'API Error: '
                    + response.getStatusCode()
                    + ' - '
                    + response.getBody()
                );
            }

        }

        // Apex/Callout exception
        catch (Exception e) {

            Long responseTime =
    DateTime.now().getTime() - startTime.getTime();

            Integration_Log__c log =
                new Integration_Log__c();

            log.Integration_Name__c =
                'Currency API';

            log.Endpoint__c =
                request.getEndpoint();

            log.Request_Type__c =
                'Get';

            log.Response_Time_ms__c =
                responseTime;

            log.Error_Message__c =
                e.getMessage();

            log.Status__c =
                'Failed';

            insert log;


            System.debug(
                'Exception: ' + e.getMessage()
            );
        }
    }
}