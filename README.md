
---
# CURRENT BUILD VERSION = 1.0.4
---
# eduSign SVT enabled Signature Validation Service

This repo contains build and deploy scripts for the eduSign SVT enabled signature validation service. This includes instructions for the following steps:

1. Building a docker image for the validation service
2. Setting up key files and configuration data.
3. Configuring storage location for cached data.
4. Deploying the docker image as docker container.

The signature validation service is provided as a Spring Boot application which is deployed to the maven repo at: [https://maven.eidastest.se](https://maven.eidastest.se/artifactory/webapp/#/home)

## 1. Building docker file

The docker build script "build.sh" builds a docker image for the Proxy Service by performing the following actions:

- Downloading the signature validation service executable .jar file from maven repository
- Downloading the signature (asc) on the proxy service executable
- Verifying the signature on the downloaded .jar file.
- Building the docker image.

```
Usage: build.sh [options...]

   -u, --user             Username for Maven repository (default is eidasuser)
   -p, --passwd           Password for Maven repository (will be prompted for if not given)
   -v, --version          Version for artifact to download
   -i, --image            Name of image to create (default is sigval-service)
   -t, --tag              Optional docker tag for image
   -c, --clear            Clears the target directory after a successful build (default is to keep it)
   -h, --help             Prints this help
```

## 2. Configuration
### 2.1 General
The resources folder contains sample configuration data. The `eduSign` folder contains files and file structure to be placed in a suitable configuration location on the docker host. The folder may have any name and may be placed in any path, but the name and path must be reflected in the settings of the `application.properties` file. In the example, the path is set using the spring configuration property `spring.config.additional-location`

[Default values with instructions](documentation/default-application.properties)

The following folders and files are present in the `eduSign` sample config folder:

Folder | Description
--- | ---
`keystores` | Location of keystores referenced in `application.properties`
`crl-cache` | Folder used to store crl-cache data
`img` | Image data folder
`softhsm`  | Data folder for keys used to setup soft HSM for test
`trust`  | folder for trusted certificates
`application.properties` | Configuraiton data for this application

More information about property values are provided as comments in the sample properties files.

### 2.2 UI and feature configuration parameters

The following feature parameters should be examined and set to the desired values:

Parameter | Feature
--- | ---
sigval-service.ui.style  |  Sets the UI style. Options are `main`, `edusign` and `sunet`. For eduSign services the value `edusign` is recommended.
sigval-service.ui.logoImage.main  |  Set the file location of the main UI logotype
sigval-service.ui.logoImage.secondary  |  Set the file location of an optional secondary logotype placed in the upper right corner.
sigval-service.ui.issue-svt-if-svt-exist  |  If set to `true`, the service will offer to issue SVT on all validated documents. If set to false, only documents that does not have SVT convering all signatures will be offered to issue an SVT.
sigval-service.ui.enalbe-signed-data-view  |  If set to `false`, no option to see signed version of the document will be displayed
sigval-service.ui.show-loa  |  If set to `false`, the resulting Level of Assurance URI will not be shown in the result
sigval-service.ui.display-downloaded-svt-pdf  |  If `true`, the download PDF SVT option will cause the received document to be displayed in the browser. If set to `false`, the document will not be shown, but downloaded directly to the default download location.
sigval-service.ui.display-downloaded-svt-xml  | Same as above for XML documents.
sigval-service.ui.downloaded-svt-suffix  | Set the suffix to append to SVT enhanced documents. The suffix will be placed just before the document file extension. E.g.  filename{suffix}.xml or  filename{suffix}.pdf. Default setting is ".svt" as suffix.
sigval-service.svt.issuer-enabled  | Set to true to enable the SVT issuer, offering the service to extend validated signed documents with an SVT token.
sigval-service.svt.validator-enabled  | Set to true to enable SVT validation of signed documents that has been enahnced with SVT.

### 2.3 Trust configuration

The signature validation service provide individual trust configuraiton for 3 types of signed objets

Trust type | Configuration parameter prefix
--- | ---
Trust configuration for validation of signing certificates used to sign validated documents | `sigval-service.cert-validator.sig`
Trust configuration for validating signatures on timestamps |`sigval-service.cert-validator.sig`
Trust configuration for validating signatures on SVT (Signature Validation Token)|`sigval-service.cert-validator.sig`

For each trust type, the following parameters are set to decide what the signature validation service will trust in the signature validation process.


Parameter | Feature
--- | ---
`tsltrust-root` | A root certificate having a SubjectInformationAccess extension specifying the location of a PKCS#7 bag of certificates holding all valid certificates issued under this root. This root will be trusted and all referenced certificates will be available to build paths to this root certificate.
`trusted-folder`  |  A file location for trusted certificates. All certificates (PEM formatted certs only) located in the specified folder will be trusted as trust anchor certificates.

The `tsltrust-root` and `trusted-folder` configuration options can be used individually or in combination. The PKIX path validation algorithm used to build a trusted path will pick the most efficient path to a trust anchor.

The certificates `EuQCCert_root.cer` and `EuQCTsa_root.cer` are sample root certificates that can be used for `tsltrust-root` configuraiton where `EuQCCert_root.cer` extends trust to EU QualifiedCertificate issuers and where `EuQCTsa_root.cer` extends trust to EU Qualified Timestamp services and EU QualifiedCertificate issuers. The latter is intended for timestamp validation and the first for certificate validation of EU qualified signatures.

### 2.4 SVT Model
The SVT model defines critical parameters for issuing SVT tokens. The SVT model is defined by the following `application.properties` parameters

Parameter | Feature
--- | ---
sigval-service.svt.model.issuer-id  |  The identity of the SVT issuer as a single string identifier. This should be URI type identifier using a domain name owned by the SVT issuer
sigval-service.svt.model.validity-years  |  Optional amount of time each SVT will be valid. It's recommended to NOT use limited validity time, but instead let the general trust in the applied algorithm determine for how long an SVT can be trusted and used.
sigval-service.svt.model.audience  |  An optional array (comma separated) of identifiers (URI recommended) of audiences for which the SVT is intended. This parameter MAY be used to limit the scope of an SVT that are not intended for public use.
sigval-service.svt.model.cert-ref  |  See KID in section 2.5
sigval-service.svt.model.sig-algo  | The signature algorithm, secified using an URI identifier, used to sign SVT. This also determine the hash algorithm used to hash data in the SVT. This algorihm must be compatible with the SVT signing key.


### 2.5 Using KeyID
Signature Validation Tokens have an option to include a key ID (KID) in the header of the SVT instead of including the actual signing certificate.

The KID is the hash of the signing certificate, using the specified hash algorithm used to sign the SVT.

KID can be used to reduce the size of SVT where a know key is used to sign the SVT. This option is enabled in the SVT issuer by setting the parameter `sigval-service.svt.model.cert-ref` to `true`. If this parameter is set to false, then the complete certificate will be included in the SVT header.

To support validation of SVT with KID, the SVT validator need to know known SVT signing certificates used to match with the provided KID. Known SVT singing certificates are placed in a folder (PEM encoded certificates), and the location of this folder is specified using the parameter `sigval-service.cert-validator.svt.kid-match-folder`




### 2.6 Key configuration
#### 2.6.1. Service keys

By default, the key specified in application.properties is used for all purposes.

- SVT signing key (Signing)

This main key is specified using the following parameters in application.properties

Property | Value
---|---
sigval-service.keySourceType | Defines type = `jks`, `pkcs11`, `pkcs12`, `pem` or `create`. (Case ignore match). **IMPORTANT NOTE:** The `create` option is just for test. This key is never stored and a new key is generated at restart.
sigval-service.keySourceLocation | `file://`, `http`, `https` or `classpath:` location. (Not applicable for PKCS#11 keys)
sigval-service.keySourcePass | Password to private key (or pin for key access in case of PKCS#11), if necessary
sigval-service.keySourceAlias | Optional alias for private key if applicable. PKCS#11 keys MUST provide alias.
sigval-service.keySourceCertLocation | Location of separate cert file if any


#### 2.6.2 PKCS#11 configuration

External PKCS#11 tokens, as well as softhsm PKCS#11 tokens can be configured through the settings above. Using PKCS#11 requires however that generic configuration parameters for PKCS#11 are set.

These are:

Parameter | Value
---|---
`sigval-service.pkcs11.reloadable-keys` | Specifies if private keys shall be tested and reloaded if connection to the key is lost, prior to each usage. Using this option (**true**) have performance penalties but may increase stability.
`sigval-service.pkcs11.external-config-locations` | Specifies an array of file paths to PKCS#11 configuration files used to setup PKCS11 providers. **If this option is set, all other options below are ignored**.
`sigval-service.pkcs11.lib` | location of pkcs#11 library
`sigval-service.pkcs11.name` | A chosen name of the PKCS#11 provider. The actual name of the provider will be "SunPKCS11-{this name}-{index}".
`sigval-service.pkcs11.slotListIndex` | The start slot index to use (default 0).
`sigval-service.pkcs11.slotListIndexMaxRange` | The maximum number of slots after start index that will be used if present. Default null. A null value means that only 1 slot will be used.
`sigval-service.pkcs11.slot` | The actual name of the slot to use. If this parameter is set, then slotListIndex should not be set.


**Soft HSM** properties in addition to generic PKCS#11 properties above are specified as follows. Note that for soft hsm, the parameters slot, slotListIndex and slotListIndexMaxRange are ignored.

Parameter | Value
---|---
`sigval-service.pkcs11.softhsm.keylocation` | The location of keys using the name convention alias.key and alias.crt.
`sigval-service.pkcs11.softhsm.pass` | The pin/password for the soft hsm slot to use. This pin/password should be configured as the password for each configured key.

## 3. Operation
### 3.1. Running the docker container

The documentation folder contains a sample deploy script `deploy.sh`:

```
#!/bin/bash

echo Pulling Docker image ...
docker pull docker.eidastest.se:5000/sigval-service:softhsm

echo Undeploying ...
docker rm svt-es-sigval --force

echo Re-deploying ...

docker run -d --name svt-es-sigval --restart=always \
  -p 9050:8080 -p 9059:8009 -p 9053:8443 -p 9058:8000 \
  -e "SPRING_CONFIG_ADDITIONAL_LOCATION=/opt/sigval/" \
  -e "TZ=Europe/Stockholm" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /opt/docker/sigval-edusign-hsm:/opt/sigval \
  docker.eidastest.se:5000/sigval-service:softhsm

echo Proxy Service started...
```

Use of http or https access to the service is specified in `application.properties`.

The environment variable `SPRING_CONFIG_ADDITIONAL_LOCATION`, specifies the location where the data folder is located. Note that the specified location must end with a "/" character.

All property values in application.properties can ve overridden by docker run environment variable settings. The convention is to specify the property name in uppercase letters and replace "." and "-" characters with underscore " _ ".
