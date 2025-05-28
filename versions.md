# Signature Validation Service versions

**Latest Current version: 1.3.2**

Version | Comment                                                                                                      | Date
---|--------------------------------------------------------------------------------------------------------------|---
1.0.0 | Initial release                                                                                              | 2020-10-01
1.0.1  | Support for signature validaion date limit                                                                   | 2020-10-02
1.0.2  | Fixed file size issue                                                                                        | 2020-10-06
1.0.3  | Fxed chain_hash bug in svt lib                                                                               | 2020-10-23
1.0.4  | Updated PDF context checking to allow legitimate changes to PDF documents afters signing                     | 2021-02-02
1.1.0  | Support for JSON validation, ETSI 110 102-2 validation report and REST API for validation and SVT issuing    | 2022-05-04
1.2.0  | Updated dependencies and upgrade to Sweden Connect Credential Support library for PKCS11 and HSM integration | 2023-01-30
1.2.0  | Updated dependencies and upgrade to Sweden Connect Credential Support library for PKCS11 and HSM integration | 2023-01-30
1.3.2  | Java 21 and Spring Boot 3.4.4                                                                                | 2025-05-28

## 1.2.0
This version removes the SoftHSM options and direct PKCS11 configuratoin options and new require all PKCS11 configuration to
be provided using an external configuration file.

The following configuration properties are deprecated:

> sigval-service.pkcs11.lib<br>
> sigval-service.pkcs11.name<br>
> sigval-service.pkcs11.slotListIndex<br>
> sigval-service.pkcs11.slotListIndexMaxRange<br>
> sigval-service.pkcs11.slot<br>
> sigval-service.pkcs11.softhsm.keylocation<br>
> sigval-service.pkcs11.softhsm.pass<br>
> sigval-service.pkcs11.reloadable-keys<br>

Configuration of PKCS11 is not only supported by providing an external configuration file (only one configuration file is supported)

> proxy-service.pkcs11.external-config-locations

Example:

    sigval-service.pkcs11.external-config-locations=${sigval-service.config.dataDir}hsm-cfg/mypkcs11.cfg




## version 1.1.0

This version introduces new property settings in application.properties:

A report generator now creates signed ETSI 119 102-2 validation reports. This requires the service to assign a signing key.
The following default settings apply:

```
# Sigval Report Key source. This key source is used to sign signature validation reports.
sigval-service.report.keySourceType=create
sigval-service.report.keySourceLocation=#{null}
sigval-service.report.keySourcePass=#{null}
sigval-service.report.keySourceAlias=#{null}
sigval-service.report.keySourceCertLocation=#{null}
```

The report generator has the following default settings that may be modified:

```
# Report Generator
sigval-service.report.default-digest-algorithm=http://www.w3.org/2001/04/xmlenc#sha256
sigval-service.report.default-include-chain=false
sigval-service.report.default-include-tschain=false
sigval-service.report.default-include-siged-doc=false
```

**default-digest-algorithm** sets the default digest algorithm to use to hash referenced data in the report. This value
is overridden by any hash algorithm enforced by data imported from a source using any other digest algorithm.

**default-include-chain** sets the default value whether signature validation reports should include the full signing
certificate validation chain

**default-include-tschain** sets the default value whether time stamp signing certificates should be included in the report

General settings with defaults

```
sigval-service.svt.default-replace=true
sigval-service.ui.show-report-options=true
```

**default-replace** defines whether XML and JOSE documents that has a present SVT should have this SVT replaced if a new SVT is issued
or whether the new SVT should be amended to the existing SVT.

**show-report-options** should be set to `false` to remove the report options pop-up when a report is requested.

The following property settings are removed (no longer have any effect)

```
sigval-service.ui.display-downloaded-svt-pdf
sigval-service.ui.display-downloaded-svt-xml
```

## version 1.0.4
This version introduce a new property in application.properties `sigval-service.validator.strict-pdf-context`.
Setting this property to `true` means that the validator will not tolerate that the PDF document is updated through a re-save which may update the Document Security Store (DSS), metadata and document info. A setting to `false` will allow such chages after signing.
