# Changelog

# 1.5.0

### Important
The lakeFS Helm chart now uses lakeFS Enterprise with integrated authentication, removing the need for the separate Fluffy service. 
All authentication capabilities (LDAP, OIDC, SAML, AWS IAM) are now built directly into lakeFS Enterprise.
For more information, see the [migration guide](https://docs.lakefs.io/latest/enterprise/upgrade/#kubernetes-migrating-with-helm-from-fluffy-to-new-lakefs-enterprise).

:new: What's new:
- Update lakeFS version to [1.63.0](https://github.com/treeverse/lakeFS/releases/tag/v1.63.0)

# 1.4.20

:new: What's new:
- Update lakeFS version to [1.62.0](https://github.com/treeverse/lakeFS/releases/tag/v1.62.0)

# 1.4.19

:new: What's new:
- Update lakeFS version to [1.61.0](https://github.com/treeverse/lakeFS/releases/tag/v1.61.0)
- Update fluffy version to [0.13.2](https://github.com/treeverse/fluffy/releases/tag/v0.13.2), with latest security updates

# 1.4.18

:new: What's new:
- Update lakeFS version to [1.60.0](https://github.com/treeverse/lakeFS/releases/tag/v1.60.0)

# 1.4.17

:new: What's new:
- Update lakeFS version to [1.59.0](https://github.com/treeverse/lakeFS/releases/tag/v1.59.0)

# 1.4.14

:new: What's new:
- Update lakeFS version to [1.58.0](https://github.com/treeverse/lakeFS/releases/tag/v1.58.0)

## 1.4.13

:new: What's new:
- Update lakeFS version to [1.57.0](https://github.com/treeverse/lakeFS/releases/tag/v1.57.0)

## 1.4.12

:new: What's new:
- Update lakeFS version to [1.56.0](https://github.com/treeverse/lakeFS/releases/tag/v1.56.0)

## 1.4.11

:new: What's new:
- Update lakeFS version to [1.55.0](https://github.com/treeverse/lakeFS/releases/tag/v1.55.0)

## 1.4.10

:new: What's new:
- Update fluffy version to [0.11.0](https://github.com/treeverse/fluffy/releases/tag/v0.11.0), support multi resource policies 

## 1.4.9

:new: What's new:
- Update lakeFS version to [1.54.0](https://github.com/treeverse/lakeFS/releases/tag/v1.54.0)

## 1.4.7

:new: What's new:
- Update lakeFS version to [1.53.1](https://github.com/treeverse/lakeFS/releases/tag/v1.53.1)

## 1.4.6

:new: What's new:
- Update lakeFS version to [1.53.0](https://github.com/treeverse/lakeFS/releases/tag/v1.53.0)

## 1.4.5

:new: What's new:
- Update lakeFS version to [1.52.0](https://github.com/treeverse/lakeFS/releases/tag/v1.52.0)

## 1.4.4

:new: What's new:
- Update lakeFS version to [1.51.0](https://github.com/treeverse/lakeFS/releases/tag/v1.51.0)

## 1.4.3

:new: What's new:
- Fix v1.4.1 and v1.4.2 to use Fluffy v0.9.0 - v0.8.4 wasn't published

## 1.4.2

:new: What's new:
- Update lakeFS version to [1.50.0](https://github.com/treeverse/lakeFS/releases/tag/v1.50.0)

## 1.4.1

:new: What's new:
- Update Fluffy version to 0.8.4

## 1.4.0

### Important

This chart introduces the use of lakeFS-Enterprise image when using fluffy.
For enterprise users when upgrading to this chart, either:
1. Remove the `image.repository` configuration from your `values.yaml` file so that the correct image is fetched
2. Modify the value to `treeverse/lakefs-enterprise`

**This chart is backwards compatible and does not require any special migration**

:new: What's new:
- Updated lakeFS version to [1.49.1](https://github.com/treeverse/lakeFS/releases/tag/v1.49.1)

## 1.3.33

:new: What's new:
- Updated lakeFS version to [1.49.1](https://github.com/treeverse/lakeFS/releases/tag/v1.49.1)


## 1.3.32

:new: What's new:
- Updated lakeFS version to [1.49.0](https://github.com/treeverse/lakeFS/releases/tag/v1.49.0)

## 1.3.31

:new: What's new:
- Update Fluffy version to 0.8.3

## 1.3.30

:new: What's new:
- Updated lakeFS version to [1.48.2](https://github.com/treeverse/lakeFS/releases/tag/v1.48.2)

## 1.3.29

:new: What's new:
- Updated lakeFS version to [1.48.1](https://github.com/treeverse/lakeFS/releases/tag/v1.48.1)

## v1.3.28

### Do **NOT** use this version, 1.48.0 breaks backwards compatibility

:new: What's new:
- Updated lakeFS version to [1.48.0](https://github.com/treeverse/lakeFS/releases/tag/v1.48.0)

## v1.3.27

:new: What's new:
- Updated lakeFS version to [1.47.0](https://github.com/treeverse/lakeFS/releases/tag/v1.47.0)

## v1.3.26

:new: What's new:
- Updated lakeFS version to [1.46.0](https://github.com/treeverse/lakeFS/releases/tag/v1.46.0)

## v1.3.24

:new: What's new:
- Updated lakeFS version to [1.45.0](https://github.com/treeverse/lakeFS/releases/tag/v1.45.0)
- Updated fluffy version to [0.8.0](https://github.com/treeverse/fluffy/releases/tag/v0.8.0)

## v1.3.23

:new: What's new:
- Updated lakeFS version to [1.44.0](https://github.com/treeverse/lakeFS/releases/tag/v1.44.0)

## v1.3.19

:new: What's new:
- Updated lakeFS version to [1.43.0](https://github.com/treeverse/lakeFS/releases/tag/v1.43.0)

## v1.3.18

:new: What's new:
- Updated lakeFS version to [1.42.0](https://github.com/treeverse/lakeFS/releases/tag/v1.42.0)
