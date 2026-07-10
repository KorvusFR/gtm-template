___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "displayName": "Korvus",
  "categories": [
    "ANALYTICS",
    "UTILITY"
  ],
  "brand": {
    "id": "github.com_korvusfr",
    "displayName": "Korvus"
  },
  "description": "Korvus turns each technical anomaly on your e-commerce site into a real financial impact. Use the Initialization tag on all pages, then the Transaction tag on your order confirmation trigger to report revenue.",
  "containerContexts": [
    "WEB"
  ],
  "securityGroups": []
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "tagType",
    "displayName": "Tag type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "init",
        "displayValue": "Initialization (all pages)"
      },
      {
        "value": "purchase",
        "displayValue": "Transaction event (order confirmation)"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "init",
    "help": "Initialization loads the Korvus snippet and must fire on all pages. Transaction event reports the order amount and must fire on your order confirmation trigger, after consent."
  },
  {
    "type": "TEXT",
    "name": "apiKey",
    "displayName": "API key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "init",
        "type": "EQUALS"
      }
    ],
    "help": "Found in your Korvus dashboard under Settings. This key is write-only: it can only send data to Korvus, never read it."
  },
  {
    "type": "TEXT",
    "name": "value",
    "displayName": "Transaction value",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "purchase",
        "type": "EQUALS"
      }
    ],
    "help": "Order amount, usually a Data Layer Variable. Both numbers and raw strings are accepted (449, \"449.00\", \"1 234,56\") - Korvus normalizes the format server-side."
  },
  {
    "type": "TEXT",
    "name": "currency",
    "displayName": "Currency",
    "simpleValueType": true,
    "defaultValue": "EUR",
    "enablingConditions": [
      {
        "paramName": "tagType",
        "paramValue": "purchase",
        "type": "EQUALS"
      }
    ],
    "help": "ISO 4217 three-letter code, for example EUR or USD. Any other value is ignored."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const createQueue = require('createQueue');
const injectScript = require('injectScript');
const queryPermission = require('queryPermission');
const setInWindow = require('setInWindow');

const SNIPPET_URL = 'https://cdn.korvus.fr/v1/korvus.min.js';

if (data.tagType === 'purchase') {
  // korvusLayer is order-independent: createQueue creates the array if the
  // snippet has not loaded yet, and the snippet drains it once it boots.
  // No network call happens here - the entry stays in memory until Korvus
  // has confirmed the visitor granted consent.
  const pushToKorvusLayer = createQueue('korvusLayer');
  pushToKorvusLayer({
    event: 'purchase',
    value: data.value,
    currency: data.currency
  });
  data.gtmOnSuccess();
} else {
  setInWindow('__korvus', {apiKey: data.apiKey}, true);
  if (queryPermission('inject_script', SNIPPET_URL)) {
    injectScript(SNIPPET_URL, data.gtmOnSuccess, data.gtmOnFailure, 'korvus');
  } else {
    data.gtmOnFailure();
  }
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "__korvus"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "korvusLayer"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://cdn.korvus.fr/v1/korvus.min.js"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Initialization injects the snippet from the Korvus CDN
  code: |-
    let injectedUrl;
    mock('injectScript', function (url, onSuccess) {
      injectedUrl = url;
      onSuccess();
    });

    runCode({tagType: 'init', apiKey: 'kv_test_key'});

    assertThat(injectedUrl).isEqualTo('https://cdn.korvus.fr/v1/korvus.min.js');
    assertApi('gtmOnSuccess').wasCalled();
- name: Initialization exposes the API key to the snippet
  code: |-
    let writtenKey;
    let writtenValue;
    mock('setInWindow', function (key, value) {
      writtenKey = key;
      writtenValue = value;
    });
    mock('injectScript', function (url, onSuccess) {
      onSuccess();
    });

    runCode({tagType: 'init', apiKey: 'kv_test_key'});

    assertThat(writtenKey).isEqualTo('__korvus');
    assertThat(writtenValue.apiKey).isEqualTo('kv_test_key');
- name: Initialization fails gracefully when the CDN is not permitted
  code: |-
    mock('queryPermission', false);

    runCode({tagType: 'init', apiKey: 'kv_test_key'});

    assertApi('gtmOnFailure').wasCalled();
    assertApi('injectScript').wasNotCalled();
- name: Transaction pushes a purchase entry onto korvusLayer
  code: |-
    const pushed = [];
    let queueName;
    mock('createQueue', function (name) {
      queueName = name;
      return function (entry) {
        pushed.push(entry);
      };
    });

    runCode({tagType: 'purchase', value: '449.00', currency: 'EUR'});

    assertThat(queueName).isEqualTo('korvusLayer');
    assertThat(pushed.length).isEqualTo(1);
    assertThat(pushed[0].event).isEqualTo('purchase');
    assertThat(pushed[0].value).isEqualTo('449.00');
    assertThat(pushed[0].currency).isEqualTo('EUR');
    assertApi('gtmOnSuccess').wasCalled();
- name: Transaction never injects the snippet
  code: |-
    mock('createQueue', function () {
      return function () {};
    });

    runCode({tagType: 'purchase', value: 449, currency: 'EUR'});

    assertApi('injectScript').wasNotCalled();


___NOTES___

The Transaction tag must fire after the Initialization tag has been configured
in the container, but it does not need to wait for the snippet to finish
loading: entries pushed onto window.korvusLayer before korvus.min.js has been
evaluated are drained by the snippet once it boots.

The purchase amount is consent-gated. Korvus drops it client-side, with no
network call, whenever the visitor's consent status is not "granted".


