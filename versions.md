# Signature Validation Service versions

**Latest Current version: 1.0.4**

Version | Comment | Date
---|---|---
1.0.0 | Initial release | 2020-10-01
1.0.1  | Support for signature validaion date limit   | 2020-10-02
1.0.2  | Fixed file size issue   | 2020-10-06
1.0.3  | Fxed chain_hash bug in svt lib  | 2020-10-23
1.0.4  | Updated PDF context checking to allow legitimate changes to PDF documents afters signing  | 2021-02-02


## version 1.0.4
This version introduce a new property in application.properties `sigval-service.validator.strict-pdf-context`.
Setting this property to `true` means that the validator will not tolerate that the PDF document is updated through a re-save which may update the Document Security Store (DSS), metadata and document info. A setting to `false` will allow such chages after signing.
